#!/usr/bin/env bash
# Counts read(2) syscalls of an unbuffered vs buffered JVM read loop with strace.
set -euo pipefail
cd "$(dirname "$0")"
out=$(mktemp -d); trap 'rm -rf "$out"' EXIT
head -c 20000 /dev/zero > "$out/data.bin"

count() { # $1 = mode; number of read() calls on the 20000-byte payload
  strace -f -e trace=read -o "$out/$1.trace" java ReadBytes.java "$out/data.bin" "$1" > /dev/null
  grep -c 'read(.*\\0' "$out/$1.trace" || true
}
slow=$(count unbuffered); fast=$(count buffered)
echo "unbuffered read() calls: $slow, buffered: $fast"
[ "$slow" -gt $((fast * 20)) ] && echo "OK: unbuffered issues >20x more syscalls"

if command -v perf >/dev/null; then   # optional: CPU cost of the same loop
  perf stat -e task-clock java ReadBytes.java "$out/data.bin" 2>&1 | grep task-clock || true
else
  echo "perf not installed: skipping perf stat (see README)"
fi
