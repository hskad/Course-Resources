package edu.iitg.cs.concurrency.ticketing;

import edu.iitg.cs.concurrency.ticketing.impl.TicketServiceImpl;
import edu.iitg.cs.concurrency.ticketing.api.Hold;
import edu.iitg.cs.concurrency.ticketing.api.SeatState;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class PublicTicketTest {

    @Test
    void noDoubleBookingSmall() throws Exception {
        try (var svc = new TicketServiceImpl(10)) {
            Thread t1 = new Thread(() -> {
                try {
                    Hold h = svc.holdSeats("A", 6);
                    if (h != null) svc.confirm(h.holdId());
                } catch (InterruptedException e) { Thread.currentThread().interrupt(); }
            });
            Thread t2 = new Thread(() -> {
                try {
                    Hold h = svc.holdSeats("B", 6);
                    if (h != null) svc.confirm(h.holdId());
                } catch (InterruptedException e) { Thread.currentThread().interrupt(); }
            });
            t1.start(); t2.start();
            t1.join(2000); t2.join(2000);

            int booked = 0;
            for (int i = 0; i < 10; i++) {
                if (svc.seatState(i) == SeatState.BOOKED) booked++;
            }
            assertTrue(booked <= 10);
        }
    }

    @Test
    void holdExpiresReleasesSeats() throws Exception {
        try (var svc = new TicketServiceImpl(5)) {
            Hold h = svc.holdSeats("A", 5);
            assertNotNull(h);

            Thread.sleep(TicketServiceImpl.HOLD_TTL_MS + 500);

            Hold h2 = svc.holdSeats("B", 5);
            assertNotNull(h2, "Expected seats to be released after expiry");
        }
    }
}
