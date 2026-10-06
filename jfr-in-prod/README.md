# jfr-in-prod

`Busy.java` burns CPU for six seconds in one hot method, and `run.sh` records it with Java Flight Recorder and reads the hot method back from the file.

## Goal

Show a production-style JFR capture, a bounded recording that stops itself, and how to find the hot method from the recording with the `jfr` command.

## Run it

```bash
bash jfr-in-prod/run.sh
```

Expected: `jfr summary` lines for `jdk.ExecutionSample` and `jdk.GarbageCollection`, then up to three `Busy.<method>` counts with `Busy.priceOrder` first, then `OK: JFR top frame is Busy.priceOrder`.

Not run end to end for this README: the script was read and not executed in this pass, so the sample counts are not quoted.

## What it proves

- `-XX:StartFlightRecording=filename=...,settings=profile,maxage=1m,maxsize=50m` writes a `.jfr` file when the JVM exits, with age and size bounded.
- `jfr print --events jdk.ExecutionSample --stack-depth 1` gives the top frame of each CPU sample; counting them shows `Busy.priceOrder` dominating, and the script fails otherwise.
- No agent, code change or restart is needed beyond a JVM flag; `jcmd <pid> JFR.start` can do the same on a running process.

## Trade-offs

- The `profile` settings sample more often than `default`; the overhead is low but not zero, so check it on your own workload.
- Only the top frame is counted, so a hot library method called from your code shows up as the library frame.
- The demo uses a fixed six-second run; real recordings need a dump trigger (`JFR.dump`) or `maxage` and a sensible disk location.

## When not to use it

- To find a deadlock or a blocked thread; use `thread-dump-analysis`.
- For memory retention paths; a heap dump (`heap-dump-oom`) answers that better.
