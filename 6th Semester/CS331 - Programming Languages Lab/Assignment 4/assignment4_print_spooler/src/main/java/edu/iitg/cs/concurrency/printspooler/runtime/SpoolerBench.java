package edu.iitg.cs.concurrency.printspooler.runtime;

import edu.iitg.cs.concurrency.printspooler.api.PrintJob;
import edu.iitg.cs.concurrency.printspooler.impl.SpoolerImpl;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class SpoolerBench {
    public static void main(String[] args) throws Exception {
        int workers = args.length > 0 ? Integer.parseInt(args[0]) : 4;
        int capacity = args.length > 1 ? Integer.parseInt(args[1]) : 20;
        int producers = args.length > 2 ? Integer.parseInt(args[2]) : 8;
        int jobsPerProducer = args.length > 3 ? Integer.parseInt(args[3]) : 50;

        try (var spooler = new SpoolerImpl(capacity, workers)) {
            List<Thread> ps = new ArrayList<>();
            long start = System.currentTimeMillis();
            for (int p = 0; p < producers; p++) {
                final int pid = p;
                Thread t = new Thread(() -> {
                    Random r = new Random(1000 + pid);
                    for (int j = 0; j < jobsPerProducer; j++) {
                        try {
                            int pages = 1 + r.nextInt(5);
                            long pageMs = 5 + r.nextInt(10);
                            spooler.submitBlocking(new PrintJob("student-" + pid, pages, pageMs));
                        } catch (InterruptedException e) {
                            Thread.currentThread().interrupt();
                            return;
                        }
                    }
                }, "producer-" + pid);
                ps.add(t);
                t.start();
            }
            for (Thread t : ps) t.join();
            Thread.sleep(2000);
            long end = System.currentTimeMillis();
            var m = spooler.metrics();
            long total = m.totalSubmitted();
            double secs = (end - start) / 1000.0;
            System.out.println("submitted=" + total + " completed=" + m.totalCompleted() +
                    " cancelled=" + m.totalCancelled() + " maxQueue=" + m.maxQueueDepth());
            System.out.printf("throughput=%.2f jobs/s%n", total / secs);
        }
    }
}
