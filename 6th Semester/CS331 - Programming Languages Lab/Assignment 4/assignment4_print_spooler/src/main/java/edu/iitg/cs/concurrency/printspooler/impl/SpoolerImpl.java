package edu.iitg.cs.concurrency.printspooler.impl;

import edu.iitg.cs.concurrency.printspooler.api.*;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicLong;

/**
 * TODO(STUDENT):
 * - Ensure dispatcher does not die if queue empty.
 * - Ensure cancel() makes status CANCELLED immediately.
 * - Ensure close() shuts down threads correctly.
 */
public final class SpoolerImpl implements Spooler {
    private final AtomicLong idGen = new AtomicLong(1);
    private final AtomicLong submitted = new AtomicLong(0);
    private final AtomicLong completed = new AtomicLong(0);
    private final AtomicLong cancelled = new AtomicLong(0);

    private final JobRegistry registry = new JobRegistry();
    private final BoundedJobQueue queue;

    private final ExecutorService pool;
    private final Thread dispatcher;

    private volatile boolean closed = false;

    public SpoolerImpl(int capacity, int workers) {
        this.queue = new BoundedJobQueue(capacity);
        this.pool = Executors.newFixedThreadPool(workers);

        this.dispatcher = new Thread(() -> {
            while (!closed) {
                try {
                    long jobId = queue.takeBlocking();
                    pool.submit(() -> {
                        new PrintWorker(jobId, registry).run();
                        JobStatus st = registry.status(jobId);
                        if (st == JobStatus.DONE) completed.incrementAndGet();
                        else if (st == JobStatus.CANCELLED) cancelled.incrementAndGet();
                    });
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    break;
                } catch (RuntimeException e) {
                    // avoid dispatcher death - log and continue
                    e.printStackTrace();
                }
            }
        }, "spooler-dispatcher");
        this.dispatcher.start();
    }

    @Override
    public long submitBlocking(PrintJob job) throws InterruptedException {
        if (closed) throw new IllegalStateException("spooler closed");
        long id = idGen.getAndIncrement();
        registry.create(id, job);
        queue.putBlocking(id);
        submitted.incrementAndGet();
        return id;
    }

    @Override
    public long trySubmit(PrintJob job, long timeoutMs) throws InterruptedException {
        if (closed) throw new IllegalStateException("spooler closed");
        long id = idGen.getAndIncrement();
        registry.create(id, job);
        boolean ok = queue.putWithTimeout(id, timeoutMs);
        if (!ok) {
            registry.markCancelled(id);
            return -1;
        }
        submitted.incrementAndGet();
        return id;
    }

    @Override
    public boolean cancel(long jobId) {
        // Try to remove from queue and mark as cancelled
        queue.removeIfPresent(jobId);
        return registry.markCancelled(jobId);
    }

    @Override
    public JobStatus status(long jobId) {
        JobStatus s = registry.status(jobId);
        return s == null ? JobStatus.CANCELLED : s;
    }

    @Override
    public SpoolerMetrics metrics() {
        return new SpoolerMetrics(
                submitted.get(),
                completed.get(),
                cancelled.get(),
                queue.maxDepthObserved()
        );
    }

    @Override
    public void close() throws Exception {
        closed = true;
        dispatcher.interrupt();
        dispatcher.join();
        
        pool.shutdown();
        if (!pool.awaitTermination(10, java.util.concurrent.TimeUnit.SECONDS)) {
            pool.shutdownNow();
        }
    }
}
