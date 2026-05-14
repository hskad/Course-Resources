package edu.iitg.cs.concurrency.ticketing.impl;

import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;

final class HoldExpiryService {
    private final ScheduledExecutorService scheduler =
            Executors.newScheduledThreadPool(1);

    // Maps holdId -> its pending ScheduledFuture so confirm/cancel can cancel it.
    private final ConcurrentHashMap<Long, ScheduledFuture<?>> futures =
            new ConcurrentHashMap<>();

    void scheduleExpiry(long holdId, long ttlMs, Runnable expireAction) {
        ScheduledFuture<?> future = scheduler.schedule(
                () -> {
                    futures.remove(holdId);   // clean up map entry
                    expireAction.run();
                },
                ttlMs,
                TimeUnit.MILLISECONDS
        );
        futures.put(holdId, future);
    }

    void cancelExpiry(long holdId) {
        ScheduledFuture<?> future = futures.remove(holdId);
        if (future != null) {
            // mayInterruptIfRunning = false: if expiry has already started, let it
            // finish; TicketServiceImpl will detect the seat is no longer HELD.
            future.cancel(false);
        }
    }

    void shutdown() {
        scheduler.shutdown();
        try {
            if (!scheduler.awaitTermination(2, TimeUnit.SECONDS)) {
                scheduler.shutdownNow();
            }
        } catch (InterruptedException e) {
            scheduler.shutdownNow();
            Thread.currentThread().interrupt();
        }
    }
}
