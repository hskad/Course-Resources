package edu.iitg.cs.concurrency.ticketing.impl;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

final class SeatLockManager {

    /**
     * Acquires locks on all seats in a globally consistent order (ascending seatId).
     *
     * Why this prevents deadlock:
     *   Thread A holding lock(seat 1) waiting for lock(seat 3)
     *   Thread B holding lock(seat 3) waiting for lock(seat 1)
     * — is impossible when both threads sort before locking, because both will
     * always try seat 1 before seat 3, so one of them will always succeed first.
     */
    void lockAll(List<Seat> seats) throws InterruptedException {
        // Build a sorted copy so we never mutate the caller's list.
        List<Seat> sorted = new ArrayList<>(seats);
        sorted.sort(Comparator.comparingInt(s -> s.seatId));

        for (Seat s : sorted) {
            s.lock.lockInterruptibly();
        }
    }

    void unlockAll(List<Seat> seats) {
        // Unlock in reverse order (good practice, though order doesn't matter for
        // correctness here since we hold all locks before doing any work).
        for (int i = seats.size() - 1; i >= 0; i--) {
            Seat s = seats.get(i);
            if (s.lock.isHeldByCurrentThread()) {
                s.lock.unlock();
            }
        }
    }
}
