package edu.iitg.cs.concurrency.ticketing.impl;

import edu.iitg.cs.concurrency.ticketing.api.*;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.atomic.AtomicLong;

public final class TicketServiceImpl implements TicketService {
    public static final long HOLD_TTL_MS = 1500;

    private final Seat[] seats;
    private final SeatLockManager lockMgr = new SeatLockManager();
    private final HoldExpiryService expiry = new HoldExpiryService();

    // ConcurrentHashMap: safe for concurrent get/put/remove without extra locking.
    // Individual seat-state changes are protected by per-seat ReentrantLocks, so
    // the map itself only needs to be concurrency-safe at the reference level.
    private final Map<Long, Hold> holds = new ConcurrentHashMap<>();

    private final AtomicLong holdIdGen    = new AtomicLong(1);
    private final AtomicLong receiptIdGen = new AtomicLong(1);

    private final CopyOnWriteArrayList<String> auditLog = new CopyOnWriteArrayList<>();

    private final AtomicLong successful = new AtomicLong();
    private final AtomicLong expired    = new AtomicLong();
    private final AtomicLong rejected   = new AtomicLong();

    private volatile boolean closed = false;

    public TicketServiceImpl(int seatCount) {
        if (seatCount <= 0) throw new IllegalArgumentException("seatCount must be > 0");
        this.seats = new Seat[seatCount];
        for (int i = 0; i < seatCount; i++) seats[i] = new Seat(i);
    }

    // -------------------------------------------------------------------------
    // holdSeats
    // -------------------------------------------------------------------------
    @Override
    public Hold holdSeats(String userId, int count) throws InterruptedException {
        if (closed) throw new IllegalStateException("closed");
        if (count <= 0) throw new IllegalArgumentException("count must be > 0");

        // ---------- PHASE 1: optimistic seat selection (no locks held) ----------
        // We do a quick, unlocked scan to find candidate seats that *look* FREE.
        // This is a performance optimisation: we avoid locking every seat to scan.
        // We will re-validate state under the lock in Phase 2.
        List<Seat> candidates = new ArrayList<>(count);
        for (Seat s : seats) {
            // Volatile read of state; may be stale, but that's fine — we re-check.
            if (s.state == SeatState.FREE) {
                candidates.add(s);
                if (candidates.size() == count) break;
            }
        }
        if (candidates.size() < count) {
            rejected.incrementAndGet();
            return null;
        }

        // ---------- PHASE 2: lock candidates and re-validate ----------
        // lockAll sorts by seatId, preventing deadlock.
        lockMgr.lockAll(candidates);
        try {
            // After acquiring the locks, verify that each seat is still FREE.
            // Another thread may have grabbed some of them between Phase 1 and now.
            for (Seat s : candidates) {
                if (s.state != SeatState.FREE) {
                    // At least one seat was taken — bail out and let the caller retry.
                    rejected.incrementAndGet();
                    return null;
                }
            }

            // All seats confirmed FREE under lock — commit the hold atomically.
            long hid = holdIdGen.getAndIncrement();
            long now  = System.currentTimeMillis();
            for (Seat s : candidates) {
                s.state  = SeatState.HELD;
                s.holdId = hid;
            }
            Hold h = new Hold(hid, userId,
                    candidates.stream().map(s -> s.seatId).toList(), now);
            holds.put(hid, h);
            auditLog.add("HOLD " + hid + " user=" + userId);

            // Schedule expiry AFTER recording the hold but still inside the lock
            // so the scheduled task can never run before the hold is visible.
            expiry.scheduleExpiry(hid, HOLD_TTL_MS, () -> expireHold(hid));
            return h;
        } finally {
            lockMgr.unlockAll(candidates);
        }
    }

    // -------------------------------------------------------------------------
    // expireHold  (called by the scheduler thread after TTL)
    // -------------------------------------------------------------------------
    private void expireHold(long holdId) {
        Hold h = holds.remove(holdId);
        if (h == null) {
            // Already confirmed or cancelled — nothing to do.
            return;
        }

        List<Seat> ss = new ArrayList<>();
        for (int sid : h.seatIds()) ss.add(seats[sid]);

        try {
            lockMgr.lockAll(ss);
        } catch (InterruptedException e) {
            // Restore the hold entry so it is not silently lost, then bail.
            holds.put(holdId, h);
            Thread.currentThread().interrupt();
            return;
        }

        try {
            for (Seat s : ss) {
                // Only free the seat if it is still HELD by *this* hold.
                // If it was already BOOKED (confirmed) we must not touch it.
                if (s.state == SeatState.HELD && s.holdId == holdId) {
                    s.state  = SeatState.FREE;
                    s.holdId = -1;
                }
            }
        } finally {
            lockMgr.unlockAll(ss);
        }

        expired.incrementAndGet();
        auditLog.add("EXPIRE " + holdId);
    }

    // -------------------------------------------------------------------------
    // confirm
    // -------------------------------------------------------------------------
    @Override
    public Receipt confirm(long holdId) throws InterruptedException {
        if (closed) throw new IllegalStateException("closed");

        Hold h = holds.get(holdId);
        if (h == null) {
            rejected.incrementAndGet();
            return null;
        }

        List<Seat> ss = new ArrayList<>();
        for (int sid : h.seatIds()) ss.add(seats[sid]);

        lockMgr.lockAll(ss);
        try {
            // Re-check: the hold may have expired between holds.get() and locking.
            if (!holds.containsKey(holdId)) {
                rejected.incrementAndGet();
                return null;
            }

            // Validate that every seat is still HELD by this hold.
            for (Seat s : ss) {
                if (s.state != SeatState.HELD || s.holdId != holdId) {
                    rejected.incrementAndGet();
                    return null;
                }
            }

            // Commit: mark all seats BOOKED.
            for (Seat s : ss) {
                s.state  = SeatState.BOOKED;
                s.holdId = -1;
            }

            // Remove hold and cancel the pending expiry timer.
            holds.remove(holdId);
            expiry.cancelExpiry(holdId);

            successful.incrementAndGet();
            auditLog.add("CONFIRM " + holdId);
            return new Receipt(receiptIdGen.getAndIncrement(),
                    h.userId(), h.seatIds(), System.currentTimeMillis());
        } finally {
            lockMgr.unlockAll(ss);
        }
    }

    // -------------------------------------------------------------------------
    // cancel
    // -------------------------------------------------------------------------
    @Override
    public boolean cancel(long holdId) {
        // Atomically remove the hold; if it's not there, it was already
        // confirmed/expired — return false.
        Hold h = holds.remove(holdId);
        if (h == null) return false;

        List<Seat> ss = new ArrayList<>();
        for (int sid : h.seatIds()) ss.add(seats[sid]);

        try {
            lockMgr.lockAll(ss);
        } catch (InterruptedException e) {
            // Restore the entry so we don't silently lose a hold.
            holds.put(holdId, h);
            Thread.currentThread().interrupt();
            return false;
        }

        try {
            for (Seat s : ss) {
                if (s.state == SeatState.HELD && s.holdId == holdId) {
                    s.state  = SeatState.FREE;
                    s.holdId = -1;
                }
            }
        } finally {
            lockMgr.unlockAll(ss);
        }

        // Cancel the scheduled expiry — seats are already freed above.
        expiry.cancelExpiry(holdId);
        auditLog.add("CANCEL " + holdId);
        return true;
    }

    // -------------------------------------------------------------------------
    // Read-only helpers
    // -------------------------------------------------------------------------
    @Override
    public SeatState seatState(int seatId) {
        // Volatile read — good enough for observability queries.
        return seats[seatId].state;
    }

    @Override
    public TicketMetrics metrics() {
        return new TicketMetrics(successful.get(), expired.get(), rejected.get());
    }

    @Override
    public void close() throws Exception {
        closed = true;
        expiry.shutdown();
    }
}
