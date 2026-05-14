package edu.iitg.cs.concurrency.ticketing.api;
import java.util.List;
public record Hold(long holdId, String userId, List<Integer> seatIds, long createdAtMs) {}
