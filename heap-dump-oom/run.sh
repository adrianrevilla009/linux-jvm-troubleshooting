#!/usr/bin/env bash
# Forces an OutOfMemoryError with a 32 MB heap and checks the automatic heap dump.
set -euo pipefail
cd "$(dirname "$0")"
out=$(mktemp -d); trap 'rm -rf "$out"' EXIT

java -Xmx32m -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath="$out/leak.hprof" \
  Leak.java > "$out/app.log" 2>&1 || true

grep -m1 'OutOfMemoryError' "$out/app.log"
test -s "$out/leak.hprof"
head -c 18 "$out/leak.hprof" | grep -q 'JAVA PROFILE'
echo "OK: heap dump $(du -h "$out/leak.hprof" | cut -f1) written; open it in Eclipse MAT or VisualVM"

# live-process alternative: class histogram, no dump file needed
java -Xmx64m Leak.java > /dev/null 2>&1 &
pid=$!
sleep 2
jcmd "$pid" GC.class_histogram | sed -n 1,6p
kill "$pid" 2>/dev/null || true
