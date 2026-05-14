package edu.iitg.cs.concurrency.printspooler.api;

public interface Spooler extends AutoCloseable {
    long submitBlocking(PrintJob job) throws InterruptedException;
    long trySubmit(PrintJob job, long timeoutMs) throws InterruptedException;
    boolean cancel(long jobId);
    JobStatus status(long jobId);
    SpoolerMetrics metrics();
    @Override void close() throws Exception;
}
