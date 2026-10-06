# strace-perf

`ReadBytes.java` reads a file one byte at a time, and `run.sh` counts its `read(2)` syscalls with `strace`.

## Goal

Show that an unbuffered `FileInputStream.read()` loop makes one syscall per byte, and that wrapping it in a `BufferedInputStream` removes almost all of them.

## Run it

```bash
bash strace-perf/run.sh
```

Expected: the script creates a 20000-byte file, runs `ReadBytes` twice under `strace -f -e trace=read`, and prints `unbuffered read() calls: N, buffered: M`, then `OK: unbuffered issues >20x more syscalls`. If `perf` is installed it also prints the `task-clock` line from `perf stat`; otherwise it prints `perf not installed: skipping perf stat`.

Not run end to end for this README: the script was read and not executed in this pass, so no measured counts are quoted here.

## What it proves

- `ReadBytes.java` with no second argument reads through `FileInputStream` directly, so each byte is a separate `read` call in the trace.
- With the argument `buffered` the stream is wrapped in a 64 KiB `BufferedInputStream`, so the 20000 bytes arrive in a handful of calls.
- `run.sh` fails unless the unbuffered count is more than 20 times the buffered count, so the claim is checked, not just printed.

## Trade-offs

- The count includes reads made by the JVM itself while starting up (`java ReadBytes.java` also compiles the source); the script only counts reads whose payload is zero bytes, which matches the data file, to keep that noise out.
- `strace -f` slows the JVM a lot, so timings under it are not meaningful; only the counts are.
- `perf stat` is an optional extra and needs kernel permissions that WSL2 and many containers do not grant.

## When not to use it

- On a production process under load: `strace` stops the traced threads on every syscall. Prefer `perf trace` or eBPF tools there.
- When the question is Java-level CPU cost; use `jfr-in-prod` instead.
