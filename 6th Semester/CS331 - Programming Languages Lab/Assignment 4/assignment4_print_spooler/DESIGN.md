# Campus Print Spooler — Concurrency Design

## Overview

This document describes how the print spooler achieves thread safety, prevents deadlocks and race conditions, and ensures correct cancellation semantics using only core Java concurrency primitives: `synchronized`, `volatile`, `wait()`, `notifyAll()`, and `ExecutorService`.

\---

## 1\. BoundedJobQueue — Producer-Consumer Synchronization

### Purpose

A thread-safe, bounded queue that enforces capacity limits while allowing producers and consumers to block when necessary.

### Data Structure

* **Private `Deque<Long> q`**: Holds job IDs; capacity bounded by field `capacity`
* **Private `int maxDepth`**: Tracks maximum observed queue depth for metrics
* **Private `int capacity`**: Immutable capacity limit

### Thread Safety Mechanism: Synchronized Monitor

All methods use `synchronized(this)` to create a **monitor lock**:

```java
synchronized (this) {
    // mutual exclusion: only one thread at a time
}
```

This ensures:

* **Atomicity**: queue modifications (add/remove), size checks, and waitset manipulation happen as a unit
* **Mutual exclusion**: No data race on `q` or `maxDepth`
* **Visibility**: `notifyAll()` flushes memory barriers; waiting threads see all changes

### Method: `putBlocking(long jobId)`

**Blocking condition**: Queue at capacity (`q.size() >= capacity`)

```java
while (q.size() >= capacity) {
    wait();  // release lock, sleep
}
q.addLast(jobId);
maxDepth = Math.max(maxDepth, q.size());
notifyAll();  // wake all waiters (consumers + other producers)
```

**Correctness**:

* **`while` not `if`**: Spurious wakeups won't bypass the capacity check
* After wakeup, we re-check the condition because another producer may have grabbed the space first
* **`notifyAll()`**: Both consumers (who were waiting for jobs) and other producers (waiting for space) are awakened
* **Atomicity**: Space check + insertion is atomic w.r.t. concurrent removals

### Method: `takeBlocking()`

**Blocking condition**: Queue empty

```java
while (q.isEmpty()) {
    wait();  // release lock, sleep
}
long id = q.removeFirst();
notifyAll();  // wake producers waiting for space
return id;
```

**Correctness**:

* **`while` loop**: Handles spurious wakeups; re-checks emptiness
* **Notification**: Wakes producers blocked on `putBlocking()` because removal creates space

### Method: `putWithTimeout(long jobId, long timeoutMs)`

**Deadline-based timeout** using nanosecond precision:

```java
long deadline = System.nanoTime() + timeoutMs \* 1\_000\_000;
while (q.size() >= capacity) {
    long remaining = deadline - System.nanoTime();
    if (remaining <= 0) return false;  // timeout expired
    wait(remaining / 1\_000\_000);  // wait up to remaining ms
}
// queue has space, add job
q.addLast(jobId);
notifyAll();
return true;
```

**Correctness**:

* Converts total timeout → nanosecond deadline to handle multiple wait loops in case of spurious wakeups
* Recalculates remaining time before each `wait()` call
* Returns `false` only when timeout genuinely expires (not on spurious wakeup)

### Method: `removeIfPresent(long jobId)`

Used for **queued job cancellation**:

```java
boolean removed = q.remove(jobId);
if (removed) notifyAll();  // wake producers if space was freed
return removed;
```

**Why `notifyAll()`?** Removing a job frees space; producers blocked on `putBlocking()` can now proceed.

\---

## 2\. JobRegistry — Job State Machine

### Purpose

Maintain thread-safe job status tracking and enforce valid state transitions for cancellation.

### Data Structure

* **Private `Map<Long, JobRecord> jobs`**: Maps job ID → `JobRecord`

  * Each `JobRecord` holds: job ID, `PrintJob`, `JobStatus status`, `volatile boolean cancelRequested`

### Thread Safety: Synchronized Dispatch

All methods synchronize on `this`:

```java
synchronized (this) {
    // read/modify/write registry atomically
}
```

This prevents:

* **Race between `markPrinting()` and `markCancelled()`**: Only one can execute; status transitions are atomic
* **Lost updates**: If job is cancelled while `markPrinting()` checks it, the `cancelRequested` flag is visible

### State Machine

```
Diagram:
  create → QUEUED ─── markPrinting ──→ PRINTING ─── markDone ──→ DONE
            ↑                             ↓
            └─────── markCancelled ←─────┘
```

Valid transitions:

* `QUEUED → PRINTING`: Only if `!cancelRequested` (see below)
* `PRINTING → DONE`: Job completes normally
* `QUEUED → CANCELLED`: Via `markCancelled()`
* `PRINTING → CANCELLED`: Via `markCancelled()`
* ✗ `DONE → CANCELLED`: Invalid; prevents marking completed jobs as cancelled

### Method: `markPrinting(long jobId)`

**Critical cancellation check**:

```java
synchronized (this) {
    JobRecord r = jobs.get(jobId);
    if (r == null) return false;
    if (r.status != JobStatus.QUEUED) return false;
    if (r.cancelRequested) return false;  // ← CANCEL PREVENTION
    r.status = JobStatus.PRINTING;
    return true;
}
```

**Why this matters**:

* Even though `cancelRequested` is `volatile`, we check it under the lock to atomically verify:

  * Job is still in QUEUED state
  * AND no cancellation has been requested
  * AND we transition to PRINTING

If cancellation happened before `markPrinting()` acquired the lock, `cancelRequested` will be true, and printing is prevented.

### Method: `markCancelled(long jobId)`

```java
synchronized (this) {
    JobRecord r = jobs.get(jobId);
    if (r == null) return false;
    if (r.status == JobStatus.DONE) return false;  // prevent double-cancel of finished jobs
    r.status = JobStatus.CANCELLED;
    r.cancelRequested = true;  // volatile write
    return true;
}
```

**Effect**:

* Sets both status and `volatile` flag so `PrintWorker` (running in separate thread) sees cancellation immediately
* Status change is durable even if worker is already printing
* Return value allows `SpoolerImpl.cancel()` to report success/failure

\---

## 3\. SpoolerImpl — Dispatcher Coordination \& Shutdown

### Purpose

Coordinate job submission, dispatching to workers, and clean shutdown without deadlocks or stuck threads.

### Architecture

```
Main threads:
  - Producer threads: Call submitBlocking() / trySubmit()
  - Dispatcher thread: Takes from queue, submits to executor
  - Worker threads: Part of ExecutorService, run PrintWorker

Synchronization:
  - Producers ↔ BoundedJobQueue: synchronized queue
  - Dispatcher ↔ Queue: blocking take
  - Workers ↔ Registry: synchronized reads/writes
  - Shutdown: volatile flag + interrupt
```

### Field: `volatile boolean closed`

Signals dispatcher to stop accepting new queue items:

```java
private volatile boolean closed = false;
```

**Visibility**: All threads see the latest value without lock (due to JMM guarantee for volatile reads).

### Dispatcher Thread

```java
this.dispatcher = new Thread(() -> {
    while (!closed) {
        try {
            long jobId = queue.takeBlocking();  // blocks if empty
            pool.submit(() -> {
                new PrintWorker(jobId, registry).run();
                JobStatus st = registry.status(jobId);
                if (st == JobStatus.DONE) completed.incrementAndGet();
                else if (st == JobStatus.CANCELLED) cancelled.incrementAndGet();
            });
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            break;  // exit dispatcher loop
        } catch (RuntimeException e) {
            e.printStackTrace();  // avoid dispatcher death
        }
    }
}, "spooler-dispatcher");
this.dispatcher.start();
```

**Key design decisions**:

1. **Blocking take**: `queue.takeBlocking()` blocks when queue is empty. This is correct—dispatcher should sleep, not busy-wait.
2. **Worker submission**: Each job is wrapped in a lambda that:

   * Runs `PrintWorker` (performs the print operation)
   * Atomically increments `completed` or `cancelled` counter
   * This happens in a worker thread, not the dispatcher
3. **Exception handling**: Catches and logs runtime exceptions but continues (prevents dispatcher thread from crashing)
4. **Interruption handling**: Catches `InterruptedException`, re-interrupts the thread, and breaks

### Method: `close()`

**Challenge**: Dispatcher is blocked on `queue.takeBlocking()` when `close()` is called. How do we wake it?

**Solution**: Interrupt the dispatcher thread

```java
@Override
public void close() throws Exception {
    closed = true;                    // signal the loop to exit
    dispatcher.interrupt();           // wake from takeBlocking()
    dispatcher.join();                // wait for thread to finish
    
    pool.shutdown();                  // no new submissions
    if (!pool.awaitTermination(10, TimeUnit.SECONDS)) {
        pool.shutdownNow();           // force kill remaining tasks
    }
}
```

**Correctness**:

1. **Set `closed = true`**: Tells dispatcher's while loop to exit (though it won't check immediately if blocked)
2. **`dispatcher.interrupt()`**: Wakes the dispatcher from `queue.takeBlocking()` by throwing `InterruptedException`

   * Dispatcher catches it, re-interrupts itself, and breaks
   * Without this, dispatcher blocks forever waiting for jobs
3. **`dispatcher.join()`**: Wait for dispatcher to actually terminate (guarantees it's not mid-submission)
4. **`pool.shutdown()`**: Stops accepting new submissions; running tasks finish
5. **`pool.awaitTermination(10s)`**: Wait for workers to complete, then force-kill stragglers

### Method: `submitBlocking()` \& `trySubmit()`

**Thread safety** via `BoundedJobQueue`:

```java
public long submitBlocking(PrintJob job) throws InterruptedException {
    if (closed) throw new IllegalStateException("spooler closed");
    long id = idGen.getAndIncrement();  // atomic, no race
    registry.create(id, job);           // creates QUEUED entry
    queue.putBlocking(id);              // blocks if full
    submitted.incrementAndGet();        // atomic increment
    return id;
}
```

**Race-free because**:

* `AtomicLong.getAndIncrement()` is atomic (no ID collisions)
* `registry.create()` is synchronized (no concurrent creation of same ID)
* `queue.putBlocking()` is synchronized (no concurrent adds)

### Method: `cancel()`

```java
public boolean cancel(long jobId) {
    queue.removeIfPresent(jobId);      // if queued, remove it
    return registry.markCancelled(jobId); // mark as CANCELLED
}
```

**Handles both cases**:

* **Queued job**: `removeIfPresent()` removes from queue, `markCancelled()` marks status
* **Printing job**: `removeIfPresent()` returns false, but `markCancelled()` still sets the flag

  * `PrintWorker` sees `cancelRequested == true` and sets status to CANCELLED

\---

## 4\. Deadlock Prevention

### Potential Deadlock #1: Producer-Consumer Starvation

**Scenario**: If producers never call `notifyAll()`, consumers starve; if consumers never notify, producers starve.

**Prevention**: Every method in `BoundedJobQueue` calls `notifyAll()` after modification:

* `putBlocking()` → notifyAll (wakes consumers waiting for jobs)
* `takeBlocking()` → notifyAll (wakes producers waiting for space)
* `removeIfPresent()` → notifyAll (wakes producers waiting for space)

### Potential Deadlock #2: Dispatcher Blocks Forever on Queue

**Scenario**: `close()` sets `closed=true`, but dispatcher is blocked in `queue.takeBlocking()`. It never checks the condition.

**Prevention**: `dispatcher.interrupt()` throws `InterruptedException` in the blocked thread, allowing it to exit.

### Potential Deadlock #3: Cycle in Synchronization

**Scenario**: If we locked registry from within queue (or vice versa), and another thread acquired in opposite order, we'd have a cycle.

**Prevention**: No nested locks. Each class synchronizes on its own monitor (`this`), never acquiring another object's lock while holding its own.

\---

## 5\. Race Condition Prevention

### Race #1: Job Status Transition

**Scenario**: Producer and canceller both try to change job status concurrently.

**Prevention**: JobRegistry's `create()`, `markPrinting()`, `markDone()`, `markCancelled()` are all synchronized. Only one can execute.

### Race #2: Job Visibility After Cancellation

**Scenario**: Canceller sets `cancelRequested = true`, but PrintWorker (in another thread) doesn't see it.

**Prevention**: `cancelRequested` is `volatile`, so the write is immediately visible to all threads.

### Race #3: Metrics Corruption

**Scenario**: Multiple workers increment `completed` / `cancelled` concurrently.

**Prevention**: `AtomicLong.incrementAndGet()` is atomic; no race.

\---

## 6\. Cancellation Correctness

### Queued Job Cancellation

**Flow**:

1. User calls `cancel(jobId)`
2. `queue.removeIfPresent(jobId)` removes it from queue
3. `registry.markCancelled(jobId)` sets status to CANCELLED
4. Dispatcher never sees this job (it's gone from queue)
5. Status correctly shows CANCELLED

### Printing Job Cancellation

**Flow**:

1. User calls `cancel(jobId)`
2. `queue.removeIfPresent(jobId)` returns false (not in queue)
3. `registry.markCancelled(jobId)` sets `status=CANCELLED` and `cancelRequested=true`
4. `PrintWorker` reads `record.cancelRequested` (volatile visibility)
5. Worker stops printing and exits, registry shows CANCELLED

### Visibility Guarantee

Even though `cancelRequested` is checked before `markPrinting()`, we still need the synchronized block because:

* We need to atomically verify the job is QUEUED and not cancelled
* Then transition to PRINTING
* Without the lock, another thread could cancel after our check but before our transition

\---

## Summary of Concurrency Tools Used

|Component|Tool|Purpose|
|-|-|-|
|BoundedJobQueue|`synchronized` + `wait()` / `notifyAll()`|Bounded blocking queue|
|JobRegistry|`synchronized`|State machine enforcement|
|SpoolerImpl|`volatile` flag + `ExecutorService`|Dispatcher control|
|Job cancellation|`volatile boolean`|Immediate visibility to workers|
|Metrics|`AtomicLong`|Atomic counters|

All designs follow the **tutorial scope** and avoid higher-level abstractions like `BlockingQueue` or `ReentrantLock`.

