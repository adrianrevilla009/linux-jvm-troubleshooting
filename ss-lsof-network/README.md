# ss-lsof-network

`SocketLeak.java` opens loopback connections and never closes them, and `run.sh` finds them with `ss` and `lsof`.

## Goal

Show how to confirm a socket or file-descriptor leak from outside the JVM, and how to compare the open descriptors with the process limit.

## Run it

```bash
bash ss-lsof-network/run.sh
```

Expected: the script starts `SocketLeak 200`, prints the established count from `ss` and the TCP descriptor count from `lsof`, then `fd limit: ... open fds: ...`, and finally `OK: leaked sockets visible in ss and lsof`.

Not run end to end for this README: the script was read and not executed in this pass, so no measured counts are quoted.

## What it proves

- `SocketLeak.java` opens 200 client sockets to its own server; the server side keeps each accepted socket too, so both ends are held by one process.
- `ss -Htn state established` filtered on the server port counts both ends, so at least 400 are expected, and the script asserts that.
- `lsof -a -p <pid> -iTCP` lists the same descriptors from the process side, and `/proc/<pid>/fd` gives the total against `ulimit -n`.

## Trade-offs

- Everything is on loopback in one process, so there is no `TIME_WAIT` or `CLOSE_WAIT` buildup as you would see against a real remote service.
- The count of 200 is far below a typical limit; the lab shows how to see a leak, not how it fails when the limit is hit.
- It needs `ss` and `lsof` installed, which minimal containers often lack.

## When not to use it

- For connection pools that are bounded by design: look at pool metrics before the OS.
- When the socket state itself is the question (`CLOSE_WAIT`, retransmits); this lab only counts established sockets.
