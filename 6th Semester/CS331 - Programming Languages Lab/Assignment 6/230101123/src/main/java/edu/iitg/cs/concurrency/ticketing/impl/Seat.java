package edu.iitg.cs.concurrency.ticketing.impl;

import edu.iitg.cs.concurrency.ticketing.api.SeatState;
import java.util.concurrent.locks.ReentrantLock;

final class Seat {
    final int seatId;
    final ReentrantLock lock = new ReentrantLock();
    SeatState state = SeatState.FREE;
    long holdId = -1;

    Seat(int seatId) { this.seatId = seatId; }
}
