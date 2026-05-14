# Assignment 2 — Ticket Booking with Seat Holds (Concurrency)

This assignment is to revise Java concurrency topics:
- `Thread` / `Runnable`
- `synchronized`, `volatile`
- `wait()` / `notify()` / `notifyAll()` (coordination)
- `ReentrantLock` / `tryLock` (deadlock avoidance)
- atomic variables (`AtomicLong`, etc.)
- executors (`ExecutorService`, `ScheduledExecutorService`)
- concurrent collections used in the starter (e.g., `CopyOnWriteArrayList`)

## Problem
A cinema has **N seats**. Many users operate concurrently. The system supports:
1. **Hold**: temporarily reserve `count` free seats for a user (like a shopping cart hold).
2. **Confirm**: confirm a hold → seats become **BOOKED**.
3. **Cancel**: cancel a hold → seats become **FREE** again.
4. **Expiry**: if a hold is not confirmed within `HOLD_TTL_MS`, it must expire automatically and release seats.

You are given a partially implemented codebase. Your job is to make it **thread-safe**, **deadlock-free**, and correct.

## What you must implement (TODOs)
Implement missing/incorrect parts in:

`src/main/java/edu/iitg/cs/concurrency/ticketing/impl/`

Main TODO files:
- `TicketServiceImpl.java`
  - make `holdSeats`, `confirm`, `cancel`, and `expireHold` **linearizable** (no double-booking, no lost updates)
  - protect shared state (`holds` map, seat states) correctly
- `SeatLockManager.java`
  - implement deadlock-free locking when multiple seats must be locked together
  - use **lock ordering by seatId** or **tryLock + rollback**
- `HoldExpiryService.java`
  - schedule expiry with `ScheduledExecutorService`
  - store the `ScheduledFuture` so that `confirm()` / `cancel()` can cancel expiry

## Correctness requirements
- A seat must never be simultaneously held by two holds.
- A seat must never be booked twice.
- Confirming an expired/cancelled/invalid hold must fail safely.
- Hold expiry must not accidentally free seats that have already been confirmed.

## How to run
### Prerequisites
- Java **17** (JDK 17)
- Maven 3.x

### Linux / macOS
```bash
java -version
mvn -version
bash scripts/run_tests.sh
bash scripts/run_bench.sh
```

### Windows (PowerShell)
- Install JDK 17 and Maven, then from the project folder:
```powershell
mvn test
mvn -DskipTests package
java -cp "target/*" edu.iitg.cs.concurrency.ticketing.runtime.TicketBench
```

## Benchmark (optional)
`bash scripts/run_bench.sh [seats] [threads] [opsPerThread]`

Example:
```bash
bash scripts/run_bench.sh 200 32 2000
```

## Submission
Submit the full project folder (**<ROLL_NUM>.zip**). Include a short `DESIGN.md` explaining:
- what you synchronised (and why)
- how you avoided deadlocks
- how expiry cancellation is handled
