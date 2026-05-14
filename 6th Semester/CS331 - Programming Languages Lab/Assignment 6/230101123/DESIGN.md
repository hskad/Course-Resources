# DESIGN.md — Assignment 6: Ticket Booking with Seat Holds

## 1. What I synchronised and why

### Per-seat `ReentrantLock` (in `Seat.java`)
Each `Seat` carries its own `ReentrantLock`. State changes (`state`, `holdId`) on any
seat only happen while that seat's lock is held. This gives fine-grained concurrency:
threads operating on disjoint sets of seats never block each other.

### `ConcurrentHashMap` for the `holds` map
The original code used a plain `HashMap` with a TODO to protect it.
I replaced it with `ConcurrentHashMap`, which is safe for concurrent
`get / put / remove` at the reference level. The seat-level invariants (state
transitions) are still protected by per-seat locks, so no additional lock around
the map is required. Crucially, operations that need map + seat-state atomicity
(e.g. confirming a hold) perform the map operation (`holds.remove`) *inside*
the per-seat lock region to prevent races.

### `volatile boolean closed`
A single volatile flag is sufficient here: only `close()` writes it, and it
is only checked at the top of public methods, so no compound read-modify-write
is needed.

### Audit log — `CopyOnWriteArrayList`
Already provided. Writes are infrequent compared to reads; the copy-on-write
cost is acceptable and gives lock-free reads.

### Counters — `AtomicLong`
`successful`, `expired`, `rejected`, `holdIdGen`, `receiptIdGen` are all
`AtomicLong` — no locks needed for increment/get.

---

## 2. How I avoided deadlocks

**Lock-ordering in `SeatLockManager.lockAll`**

A classic deadlock arises when two threads each hold a lock the other needs:

```
Thread A: holds lock(seat 1), waiting for lock(seat 3)
Thread B: holds lock(seat 3), waiting for lock(seat 1)
```

The fix is a globally consistent locking order. Before acquiring any locks,
`lockAll` sorts the supplied seat list by ascending `seatId`. Because every
thread will always attempt to acquire seat locks in the same order, the
circular-wait condition (one of the four Coffman conditions) is broken —
deadlock becomes impossible.

```java
sorted.sort(Comparator.comparingInt(s -> s.seatId));
for (Seat s : sorted) s.lock.lockInterruptibly();
```

`lockInterruptibly()` is used instead of plain `lock()` so that threads
waiting on locks can be interrupted during shutdown or test teardown.

---

## 3. How expiry cancellation is handled

`HoldExpiryService` stores the `ScheduledFuture<?>` returned by
`ScheduledExecutorService.schedule()` in a `ConcurrentHashMap<Long, ScheduledFuture<?>>`,
keyed by `holdId`.

**Scheduling:**
```java
ScheduledFuture<?> future = scheduler.schedule(expiryTask, ttlMs, MILLISECONDS);
futures.put(holdId, future);
```

**Cancellation (on `confirm` or `cancel`):**
```java
ScheduledFuture<?> future = futures.remove(holdId);
if (future != null) future.cancel(false);
```

`cancel(false)` is intentional: if the expiry task has already started running,
we let it finish rather than interrupting it mid-way. The expiry code in
`TicketServiceImpl.expireHold` guards against this with a double-check:

```java
Hold h = holds.remove(holdId);  // returns null if confirm already removed it
if (h == null) return;          // already confirmed/cancelled — nothing to do
```

And within the lock:
```java
if (s.state == SeatState.HELD && s.holdId == holdId) { ... free ... }
```

This ensures expiry never frees a seat that was already BOOKED by a confirm that
raced with the expiry timer.

**Shutdown:**
`HoldExpiryService.shutdown()` calls `scheduler.shutdown()` followed by
`awaitTermination(2s)` and `shutdownNow()` if needed, so `close()` always
returns promptly.

---

## 4. Linearizability argument (brief)

Each public operation (`holdSeats`, `confirm`, `cancel`, `expireHold`) has a
single "commit point" where the visible state changes atomically:

| Operation    | Commit point                              |
|-------------|-------------------------------------------|
| `holdSeats` | `s.state = HELD` inside per-seat lock     |
| `confirm`   | `s.state = BOOKED` inside per-seat lock   |
| `cancel`    | `s.state = FREE` + `holds.remove` inside per-seat lock |
| `expireHold`| `s.state = FREE` inside per-seat lock, only if still HELD by this holdId |

Because all state mutations happen under the per-seat lock, and the `holds` map
operations that need to be atomic with state changes are also done inside the
lock, the system is linearizable: every operation appears to take effect
instantaneously at its commit point.
