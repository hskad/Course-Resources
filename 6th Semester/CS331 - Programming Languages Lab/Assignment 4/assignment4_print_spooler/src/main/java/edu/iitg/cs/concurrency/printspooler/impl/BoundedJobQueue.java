package edu.iitg.cs.concurrency.printspooler.impl;

import java.util.ArrayDeque;
import java.util.Deque;

/**
 * TODO(STUDENT): Implement a correct bounded blocking queue using:
 * - synchronized
 * - while(condition) wait()
 * - notifyAll() after enqueue/dequeue/remove
 */
final class BoundedJobQueue {
    private final int capacity;
    private final Deque<Long> q = new ArrayDeque<>();
    private int maxDepth = 0;

    BoundedJobQueue(int capacity) {
        if (capacity <= 0) throw new IllegalArgumentException("capacity must be > 0");
        this.capacity = capacity;
    }

    int maxDepthObserved() {
        synchronized (this) { return maxDepth; }
    }

    void putBlocking(long jobId) throws InterruptedException {
        synchronized (this) {
            while (q.size() >= capacity) {
                wait();
            }
            q.addLast(jobId);
            maxDepth = Math.max(maxDepth, q.size());
            notifyAll();
        }
    }

    boolean putWithTimeout(long jobId, long timeoutMs) throws InterruptedException {
        synchronized (this) {
            long deadline = System.nanoTime() + timeoutMs * 1_000_000;
            while (q.size() >= capacity) {
                long remaining = deadline - System.nanoTime();
                if (remaining <= 0) {
                    return false;
                }
                wait(remaining / 1_000_000);
            }
            q.addLast(jobId);
            maxDepth = Math.max(maxDepth, q.size());
            notifyAll();
            return true;
        }
    }

    long takeBlocking() throws InterruptedException {
        synchronized (this) {
            while (q.isEmpty()) {
                wait();
            }
            long id = q.removeFirst();
            notifyAll();
            return id;
        }
    }

    boolean removeIfPresent(long jobId) {
        synchronized (this) {
            boolean removed = q.remove(jobId);
            if (removed) notifyAll();
            return removed;
        }
    }
}
