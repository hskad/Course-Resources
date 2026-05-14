package edu.iitg.cs.concurrency.ticketing.api;

public interface TicketService extends AutoCloseable {
    Hold holdSeats(String userId, int count) throws InterruptedException;
    Receipt confirm(long holdId) throws InterruptedException;
    boolean cancel(long holdId);

    SeatState seatState(int seatId);
    TicketMetrics metrics();

    @Override void close() throws Exception;
}
