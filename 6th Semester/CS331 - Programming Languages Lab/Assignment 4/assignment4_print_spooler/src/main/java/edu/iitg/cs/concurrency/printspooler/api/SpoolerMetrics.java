package edu.iitg.cs.concurrency.printspooler.api;

public record SpoolerMetrics(
        long totalSubmitted,
        long totalCompleted,
        long totalCancelled,
        int maxQueueDepth
) {}
