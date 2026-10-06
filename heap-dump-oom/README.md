# heap-dump-oom

`Leak.java` caches 10 KB orders in a static map forever, and `run.sh` triggers an `OutOfMemoryError` with an automatic heap dump.

## Goal

Show how to capture evidence of a memory leak (a heap dump written on OOM) and how to peek at a live process with a class histogram when no dump exists.

## Run it

```bash
bash heap-dump-oom/run.sh
```

Expected: the first `OutOfMemoryError` line from the app log, then `OK: heap dump <size> written; open it in Eclipse MAT or VisualVM`, then the first lines of a `GC.class_histogram` from a second, live `Leak` process (limited to 64 MB heap).

Not run end to end for this README: the script was read and not executed in this pass, so the sizes and histogram rows are not quoted.

## What it proves

- With `-Xmx32m -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=...`, the leak in `Leak.java` ends in an `OutOfMemoryError` and a non-empty `leak.hprof`.
- The script checks the file starts with the `JAVA PROFILE` header, so it really is an HPROF dump.
- `jcmd <pid> GC.class_histogram` on the running process shows `byte[]` and the `Leak$Order` record dominating, without writing a file.

## Trade-offs

- A dump is as large as the heap, and writing it pauses the JVM; on a multi-gigabyte heap that is slow and needs disk space at the dump path.
- The class histogram has no reference paths, so it says what is big but not who holds it; you need the dump and a tool such as Eclipse MAT for that.
- The 32 MB heap keeps the demo fast; real leaks take hours and the dump contains customer data, so treat it as sensitive.

## When not to use it

- For native or off-heap leaks (direct buffers, JNI): the heap dump will not show them; see `cgroup-limits` for the RSS side.
- When the heap is slowly growing but not yet failing: sample with JFR rather than waiting for an OOM.
