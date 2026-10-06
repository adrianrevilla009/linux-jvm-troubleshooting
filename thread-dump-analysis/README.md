# thread-dump-analysis

`Deadlock.java` deadlocks two threads on purpose, and `run.sh` takes a thread dump with `jcmd` and checks the deadlock report.

## Goal

Show how to read a thread dump to find a lock-ordering deadlock: which threads, which locks, who holds what.

## Run it

```bash
bash thread-dump-analysis/run.sh
```

Expected: the script prints about 12 lines starting at `Found one Java-level deadlock`, naming `order-writer` and `payment-writer`, then `OK: deadlock between order-writer and payment-writer found`.

Not run end to end for this README: the script was read and not executed in this pass, so the dump text is not quoted.

## What it proves

- In `Deadlock.java`, `order-writer` locks `ORDERS` then `PAYMENTS`, while `payment-writer` locks them in the opposite order; a 200 ms sleep between the two locks makes the deadlock deterministic.
- `jcmd <pid> Thread.print` reports the cycle under `Found one Java-level deadlock`, with each thread waiting on a monitor held by the other.
- The script relies on the single-file launch (`java Deadlock.java`) running in the same JVM, so the shell's `$!` is the pid `jcmd` needs.

## Trade-offs

- A thread dump is a snapshot; a deadlock shows up reliably, but a slow lock convoy needs several dumps taken seconds apart.
- `jcmd` reports only monitor and `java.util.concurrent` ownership deadlocks, not a thread stuck waiting for a database or a socket.
- The `sleep` calls make the demo timing-dependent in principle; the margins used are generous but not guaranteed on a very slow machine.

## When not to use it

- For a process that is slow but not blocked: take a profile with `jfr-in-prod`.
- When `jcmd` cannot attach (different user, or a minimal container image without JDK tools); use `kill -3` and read the process stdout.
