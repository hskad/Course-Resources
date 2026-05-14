package edu.iitg.cs.concurrency.ticketing.api;
import java.util.List;
public record Receipt(long receiptId, String userId, List<Integer> seatIds, long bookedAtMs) {}
