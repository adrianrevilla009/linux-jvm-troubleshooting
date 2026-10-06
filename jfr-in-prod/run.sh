#!/usr/bin/env bash
# Records a JFR profile of a busy JVM and finds the hot method from the recording.
set -euo pipefail
cd "$(dirname "$0")"
out=$(mktemp -d); trap 'rm -rf "$out"' EXIT
mkdir "$out/cls"; javac -d "$out/cls" Busy.java

# production-style: bounded recording that stops itself, low overhead 'profile' settings
java -XX:StartFlightRecording=filename="$out/busy.jfr",settings=profile,maxage=1m,maxsize=50m \
  -cp "$out/cls" Busy > /dev/null 2>&1

jfr summary "$out/busy.jfr" | grep -E 'jdk.ExecutionSample|jdk.GarbageCollection ' || true
jfr print --events jdk.ExecutionSample --stack-depth 1 "$out/busy.jfr" \
  | grep -o 'Busy\.[a-zA-Z]*' | sort | uniq -c | sort -rn | head -3 | tee "$out/top.txt"
head -1 "$out/top.txt" | grep -q 'Busy.priceOrder'
echo "OK: JFR top frame is Busy.priceOrder"
