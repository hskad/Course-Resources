package edu.iitg.cs.concurrency.printspooler.impl;

import edu.iitg.cs.concurrency.printspooler.api.PrintJob;
import edu.iitg.cs.concurrency.printspooler.api.JobStatus;

final class JobRecord {
    final long jobId;
    final PrintJob job;

    // must be visible across threads
    volatile boolean cancelRequested = false;

    // protected by JobRegistry synchronisation
    JobStatus status = JobStatus.QUEUED;

    JobRecord(long jobId, PrintJob job) {
        this.jobId = jobId;
        this.job = job;
    }
}
