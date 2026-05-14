package edu.iitg.cs.concurrency.printspooler.impl;

import edu.iitg.cs.concurrency.printspooler.api.JobStatus;
import edu.iitg.cs.concurrency.printspooler.api.PrintJob;

import java.util.HashMap;
import java.util.Map;

/**
 * STUDENT TODO:
 * Make this class thread-safe and "linearizable" (operations appear atomic).
 *
 * Allowed: synchronized methods/blocks OR ReentrantLock (if covered).
 *
 * Required state machine:
 *   QUEUED   -> PRINTING  -> DONE
 *   QUEUED   -> CANCELLED
 *   PRINTING -> CANCELLED
 *
 * IMPORTANT:
 * - Cancellation must be visible quickly (cancelRequested is volatile in JobRecord).
 * - markPrinting must NOT start printing if a job was cancelled.
 */
final class JobRegistry {
    private final Map<Long, JobRecord> jobs = new HashMap<>();

    // TODO: make thread-safe
    JobRecord create(long jobId, PrintJob job) {
        synchronized (this) {
            JobRecord r = new JobRecord(jobId, job);
            jobs.put(jobId, r);
            return r;
        }
    }

    // TODO: make thread-safe
    JobRecord get(long jobId) {
        synchronized (this) {
            return jobs.get(jobId);
        }
    }

    // TODO: make thread-safe + enforce cancel rule
    boolean markPrinting(long jobId) {
        synchronized (this) {
            JobRecord r = jobs.get(jobId);
            if (r == null) return false;
            if (r.status != JobStatus.QUEUED) return false;
            if (r.cancelRequested) return false;
            r.status = JobStatus.PRINTING;
            return true;
        }
    }

    // TODO: make thread-safe
    void markDone(long jobId) {
        synchronized (this) {
            JobRecord r = jobs.get(jobId);
            if (r != null && r.status == JobStatus.PRINTING) r.status = JobStatus.DONE;
        }
    }

    // TODO: make thread-safe
    boolean markCancelled(long jobId) {
        synchronized (this) {
            JobRecord r = jobs.get(jobId);
            if (r == null) return false;
            if (r.status == JobStatus.DONE) return false;
            r.status = JobStatus.CANCELLED;
            r.cancelRequested = true;
            return true;
        }
    }

    // TODO: make thread-safe
    JobStatus status(long jobId) {
        synchronized (this) {
            JobRecord r = jobs.get(jobId);
            return r == null ? null : r.status;
        }
    }
}
