# linux-jvm-troubleshooting

Six small Java programs that each reproduce a classic production failure (syscall storms, deadlocks, heap leaks, container OOM-kills, socket leaks, hot methods) and a script that diagnoses it with the standard Linux and JDK tools.

## What is inside

| Folder | What it shows | Run |
| --- | --- | --- |
| [`strace-perf`](./strace-perf) | Counting `read(2)` syscalls of an unbuffered vs buffered read loop with `strace` | `bash strace-perf/run.sh` |
| [`thread-dump-analysis`](./thread-dump-analysis) | Finding a two-lock deadlock in a `jcmd Thread.print` dump | `bash thread-dump-analysis/run.sh` |
| [`heap-dump-oom`](./heap-dump-oom) | An `OutOfMemoryError` with an automatic heap dump, plus a live class histogram | `bash heap-dump-oom/run.sh` |
| [`cgroup-limits`](./cgroup-limits) | A JVM whose `-Xmx` exceeds the container memory limit and gets OOM-killed by the kernel | `bash cgroup-limits/run.sh` |
| [`ss-lsof-network`](./ss-lsof-network) | Leaked loopback sockets seen with `ss` and `lsof` | `bash ss-lsof-network/run.sh` |
| [`jfr-in-prod`](./jfr-in-prod) | A bounded Java Flight Recorder capture that points at the hot method | `bash jfr-in-prod/run.sh` |

## Prerequisites

- Linux (or WSL2) with Bash.
- JDK 21 with `java`, `javac`, `jcmd` and `jfr` on the PATH.
- `strace` for `strace-perf`; `perf` is optional there.
- `ss` and `lsof` for `ss-lsof-network`.
- Docker for `cgroup-limits` (it builds an image from `eclipse-temurin:21.0.5_11-jdk`).

## How to read it

Start with `thread-dump-analysis`, the shortest loop from symptom to diagnosis, then pick the failure you care about. Each folder is standalone; the Orders domain only shows up in class and thread names.
