package edu.iitg.cs.concurrency.printspooler;

import edu.iitg.cs.concurrency.printspooler.api.PrintJob;
import edu.iitg.cs.concurrency.printspooler.api.JobStatus;
import edu.iitg.cs.concurrency.printspooler.impl.SpoolerImpl;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class PublicSpoolerTest {

    @Test
    void jobsEventuallyComplete() throws Exception {
        try (var spooler = new SpoolerImpl(10, 2)) {
            long a = spooler.submitBlocking(new PrintJob("A", 2, 5));
            long b = spooler.submitBlocking(new PrintJob("B", 2, 5));
            long c = spooler.submitBlocking(new PrintJob("C", 2, 5));

            long deadline = System.currentTimeMillis() + 2000;
            while (System.currentTimeMillis() < deadline) {
                if (spooler.status(a) == JobStatus.DONE &&
                    spooler.status(b) == JobStatus.DONE &&
                    spooler.status(c) == JobStatus.DONE) return;
                Thread.sleep(20);
            }
            fail("Jobs did not complete in time (possible deadlock / queue bug)");
        }
    }

    @Test
    void cancelQueuedJob() throws Exception {
        try (var spooler = new SpoolerImpl(1, 1)) {
            long slow = spooler.submitBlocking(new PrintJob("S", 50, 10));
            long queued = spooler.trySubmit(new PrintJob("Q", 1, 1), 50);
            assertTrue(queued != -1);

            boolean ok = spooler.cancel(queued);
            assertTrue(ok);

            Thread.sleep(50);
            assertEquals(JobStatus.CANCELLED, spooler.status(queued));
        }
    }
}
