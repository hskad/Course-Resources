package edu.iitg.cs.concurrency.printspooler.impl;

import edu.iitg.cs.concurrency.printspooler.api.PrintJob;

final class PrintWorker implements Runnable {
    private final long jobId;
    private final JobRegistry registry;

    PrintWorker(long jobId, JobRegistry registry) {
        this.jobId = jobId;
        this.registry = registry;
    }

    @Override
    public void run() {
        JobRecord r = registry.get(jobId);
        if (r == null) return;

        if (!registry.markPrinting(jobId)) return;

        PrintJob job = r.job;
        for (int p = 1; p <= job.pages(); p++) {
            if (r.cancelRequested) {
                registry.markCancelled(jobId);
                return;
            }
            try {
                Thread.sleep(job.pageMillis());
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                registry.markCancelled(jobId);
                return;
            }
        }
        registry.markDone(jobId);
    }
}
