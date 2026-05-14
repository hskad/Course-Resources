package edu.iitg.cs.concurrency.printspooler.api;

public final class PrintJob {
    private final String owner;
    private final int pages;
    private final long pageMillis;

    public PrintJob(String owner, int pages, long pageMillis) {
        if (pages <= 0) throw new IllegalArgumentException("pages must be > 0");
        if (pageMillis < 0) throw new IllegalArgumentException("pageMillis must be >= 0");
        this.owner = owner;
        this.pages = pages;
        this.pageMillis = pageMillis;
    }

    public String owner() { return owner; }
    public int pages() { return pages; }
    public long pageMillis() { return pageMillis; }
}
