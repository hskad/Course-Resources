package edu.iitg.cs.concurrency.ticketing.api;
public record TicketMetrics(long successfulBookings, long expiredHolds, long rejectedRequests) {}
