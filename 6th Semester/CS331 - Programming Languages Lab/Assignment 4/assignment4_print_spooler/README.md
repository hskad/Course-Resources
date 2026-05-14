# Assignment 4 — Campus Print Spooler (Java Concurrency)

## Overview (What you are building)

A **print spooler** is the software that accepts print jobs from many users and prints them using a limited number of printer workers (like a shared lab printer).

In this assignment you will build a **thread-safe, bounded, cancellable** print spooler using only the Java concurrency topics covered in the tutorial sessions.

You are given a **half-made project**. Your task is to complete the missing concurrency modules (TODOs) so that the system:

- accepts jobs concurrently from multiple producers
- enforces a **bounded queue** (so memory cannot grow unbounded)
- prints jobs using a fixed number of worker threads (`ExecutorService`)
- supports job cancellation (queued and in-progress)
- shuts down cleanly (no deadlocks, no stuck threads)

---

## Allowed Topics / Scope (Institute Policy)

You must stay within the tutorial scope:

- `Thread`, `Runnable`
- `synchronized`
- `volatile`
- `wait()` / `notifyAll()`
- `ExecutorService` / `Executors.newFixedThreadPool(...)`
- `AtomicLong` (and similar atomics)
- (Optional) `ReentrantLock` / `tryLock` **only if covered**
- (Optional) bounded `BlockingQueue` **only if covered**

Do **not** use frameworks or external libraries for concurrency (Akka, Reactor, RxJava, etc.).  
Only JDK + JUnit tests are used.

---

## Java + Maven Requirements

### Java version
**Use Java 17 (JDK 17)**

Check:
```bash
java -version
javac -version
```

### Maven requirement

**Apache Maven** is used to compile and run tests.

Check:

```bash
mvn -version
```

---

## Installing Java 17 + Maven

### Linux (Ubuntu/Debian)

Install Java 17:

```bash
sudo apt update
sudo apt install -y openjdk-17-jdk
```

Install Maven:

```bash
sudo apt install -y maven
```

Verify:

```bash
java -version
mvn -version
```

### Windows

You have two common options:

#### Option A: Use WSL (recommended if you want to run bash scripts)

1. Install WSL (Ubuntu)
2. Inside WSL, follow the Linux steps above.

#### Option B: Native Windows install (PowerShell/CMD)

1. Install **JDK 17** (Oracle JDK 17 or OpenJDK 17)
2. Install **Maven**:

   * Download Apache Maven binary zip
   * Extract to a folder, e.g. `C:\apache-maven-3.x.x`
   * Add `C:\apache-maven-3.x.x\bin` to your `PATH`
3. Verify in PowerShell:

```powershell
java -version
mvn -version
```

> If you do not have Git Bash or WSL, you can still run everything using Maven commands directly (see below).

---

## Project Structure (Important Files)

```
src/main/java/edu/iitg/cs/concurrency/printspooler/
  api/
    Spooler.java
    PrintJob.java
    JobStatus.java
    SpoolerMetrics.java
  impl/
    SpoolerImpl.java          <-- TODO
    BoundedJobQueue.java      <-- TODO
    JobRegistry.java          <-- TODO
    PrintWorker.java          (given; should work once TODOs are done)
    JobRecord.java            (given; cancellation flag is volatile)
  runtime/
    SpoolerBench.java         (benchmark runner)

src/test/java/.../
  PublicSpoolerTest.java      (public tests; must pass)
```

---

## What you must implement (TODOs)

### TODO 1 — `BoundedJobQueue.java`

Implement a **bounded blocking queue** for job IDs using:

* `synchronized`
* `while(condition) wait()`
* `notifyAll()` after enqueue/dequeue/remove

Requirements:

* `putBlocking(jobId)` blocks when queue is full
* `takeBlocking()` blocks when queue is empty
* `putWithTimeout(jobId, timeoutMs)` waits up to timeout for space (returns false on timeout)
* `removeIfPresent(jobId)` removes from queue if still queued

### TODO 2 — `JobRegistry.java`

Make job tracking thread-safe and correct:

* store and retrieve `JobRecord`
* ensure state transitions are consistent:

  * `QUEUED → PRINTING → DONE`
  * `QUEUED → CANCELLED`
  * `PRINTING → CANCELLED`

**Important rule:** if a job is cancelled, status should become `CANCELLED` reliably under concurrency.

### TODO 3 — `SpoolerImpl.java`

Make spooler behaviour correct:

* use a dispatcher thread that repeatedly:

  * takes job IDs from `BoundedJobQueue`
  * submits `PrintWorker` to `ExecutorService`
* implement cancellation rules:

  * cancel a queued job (remove from queue + mark CANCELLED)
  * cancel an in-progress job (set `cancelRequested` and ensure status becomes CANCELLED)
* implement `close()`:

  * stop accepting
  * stop dispatcher thread
  * shutdown executor properly (shutdown → awaitTermination → shutdownNow if needed)

---

## How to run (Linux / WSL / Git Bash)

### Run tests

```bash
bash scripts/run_tests.sh
```

### Run benchmark

```bash
bash scripts/run_bench.sh
```

You can also pass arguments to benchmark:

```bash
bash scripts/run_bench.sh 2 10 2 10
```

#### What do these arguments mean?

`bash scripts/run_bench.sh <workers> <capacity> <producers> <jobsPerProducer>`

So:

* `2` = workers (number of printer worker threads in the fixed thread pool)
* `10` = capacity (maximum jobs allowed in the bounded queue)
* `2` = producers (number of job-submitting threads)
* `10` = jobsPerProducer (how many jobs each producer submits)

Total submitted jobs = `producers * jobsPerProducer`
In the example: `2 * 10 = 20 jobs`

---

## How to run (Windows PowerShell/CMD, without bash)

Run tests:

```powershell
mvn -q clean test
```

Run benchmark:

```powershell
mvn -q -DskipTests package
java -cp "target/classes" edu.iitg.cs.concurrency.printspooler.runtime.SpoolerBench
```

Benchmark with arguments:

```powershell
java -cp "target/classes" edu.iitg.cs.concurrency.printspooler.runtime.SpoolerBench 2 10 2 10
```

---

## Submission Instructions

Submit:

1. The folder:
   * complete code zipped
2. Your `DESIGN.md` describing how you avoided race conditions and deadlocks.

Do **not** modify:

* public tests
* runtime bench files
* API interfaces

---

## Tips (common mistakes)

* Always use `while(...) wait()` instead of `if(...) wait()`
* Always `notifyAll()` after you enqueue/dequeue, otherwise producer/consumer can deadlock.
* Cancellation must be visible across threads (`volatile` cancellation flag is already provided).
* Do not let dispatcher thread crash (handle empty queue correctly by blocking in `takeBlocking()`).

---

## Expected outcome

When complete:

* `bash scripts/run_tests.sh` should pass all public tests
* benchmark should finish and print something like:

  * `submitted=... completed=... cancelled=... maxQueue=...`
  * `throughput=... jobs/s`

## Grading (Total: 70 points)

### A) Timing sanity (20 pts)
- Single-worker scenario checks that printing takes “reasonable time”.
- Prevents trivial cheating like instantly marking jobs DONE.
- Timing uses `System.nanoTime()` (measures elapsed time; not wall-clock).  
- Reminder: `Thread.sleep()` is not guaranteed to be precise.  


### B) Concurrency + cancellation + performance (40 pts)
B1) Terminal correctness (20 pts)
- All submitted jobs must reach a terminal state: `DONE` or `CANCELLED`.
- If your code deadlocks/hangs, this section loses marks.

B2) Cancellation correctness (5 pts)
- Some jobs are cancelled while queued or printing.
- Cancellation must be visible across threads (use `volatile` flags correctly).

B3) Performance (0–15 pts), **machine-fair**
- Performance is NOT scored with a fixed absolute threshold.
- Instead, your throughput is compared to a **reference spooler run on the same machine**.
  Score is based on the ratio (student/reference).

### C) Shutdown correctness (10 pts)
- `close()` must terminate dispatcher + thread pool promptly.
- Executor shutdown semantics follow `ExecutorService` contract:
  `shutdown()` allows tasks to finish; `shutdownNow()` attempts to stop tasks. 