package edu.iitg.cs.concurrency.ticketing.runtime;

import edu.iitg.cs.concurrency.ticketing.impl.TicketServiceImpl;
import edu.iitg.cs.concurrency.ticketing.api.Hold;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class TicketBench {
    public static void main(String[] args) throws Exception {
        int seats = args.length > 0 ? Integer.parseInt(args[0]) : 80;
        int threads = args.length > 1 ? Integer.parseInt(args[1]) : 16;
        int opsPerThread = args.length > 2 ? Integer.parseInt(args[2]) : 500;

        try (var svc = new TicketServiceImpl(seats)) {
            List<Thread> ts = new ArrayList<>();
            long start = System.currentTimeMillis();
            for (int i = 0; i < threads; i++) {
                final int tid = i;
                Thread t = new Thread(() -> {
                    Random r = new Random(7000 + tid);
                    for (int op = 0; op < opsPerThread; op++) {
                        try {
                            int count = 1 + r.nextInt(4);
                            Hold h = svc.holdSeats("u"+tid, count);
                            if (h == null) continue;
                            if (r.nextDouble() < 0.7) svc.confirm(h.holdId());
                            else svc.cancel(h.holdId());
                        } catch (InterruptedException e) {
                            Thread.currentThread().interrupt();
                            return;
                        }
                    }
                }, "client-"+tid);
                ts.add(t);
                t.start();
            }
            for (Thread t: ts) t.join();
            Thread.sleep(2000);
            long end = System.currentTimeMillis();

            var m = svc.metrics();
            double secs = (end-start)/1000.0;
            long totalOps = (long)threads * opsPerThread;
            System.out.println("ops=" + totalOps + " booked=" + m.successfulBookings()
                    + " expired=" + m.expiredHolds() + " rejected=" + m.rejectedRequests());
            System.out.printf("throughput=%.2f ops/s%n", totalOps/secs);
        }
    }
}
