# cgroup-limits

`Hog.java` and a `Dockerfile` for a JVM started with `-Xmx512m`, plus `run.sh`, which runs it under a 128 MB container limit.

## Goal

Show the difference between a Java `OutOfMemoryError` and a kernel OOM-kill: when `-Xmx` is larger than the container limit, the process dies with exit code 137 and no heap dump.

## Run it

```bash
bash cgroup-limits/run.sh
```

Expected: first a line from `Hog` with `cpus=` and `maxHeapMB=` under default ergonomics (`--memory=128m --cpus=1`), then `exit=137 OOMKilled=true` and `OK: kernel OOM-kill (137, SIGKILL), no Java OutOfMemoryError and no heap dump`.

Not run end to end for this README: the script needs Docker and a pull of `eclipse-temurin:21.0.5_11-jdk`, and it was read, not executed, in this pass.

## What it proves

- With the container-aware defaults the JVM sizes its heap from the cgroup limit (the script's comment says a quarter of it), so `Hog` prints a small `maxHeapMB`.
- The image's `ENTRYPOINT` pins `-Xmx512m`; `Hog` touches 200 MB of arrays, so under `--memory=128m --memory-swap=128m` the kernel kills it.
- `docker inspect` then shows `ExitCode=137` and `OOMKilled=true`, which the script asserts.

## Trade-offs

- `--memory-swap` equal to `--memory` disables swap, so the kill is immediate rather than slow.
- Docker Desktop and WSL2 may run with cgroup v1 or v2 and report the limit differently; the check uses `docker inspect`, not cgroup files.
- The lab uses one JDK image tag and does not cover Kubernetes limits or `-XX:MaxRAMPercentage`.

## When not to use it

- To tune a heap in production: set `-XX:MaxRAMPercentage` and leave room for metaspace, threads and direct buffers instead of a fixed `-Xmx` close to the limit.
- Where Docker is not available; the other folders need only a JDK.
