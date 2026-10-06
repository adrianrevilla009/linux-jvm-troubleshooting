#!/usr/bin/env bash
# Starts a deadlocking JVM, takes a thread dump with jcmd and checks the deadlock report.
set -euo pipefail
cd "$(dirname "$0")"
out=$(mktemp -d)
java Deadlock.java > "$out/app.log" &
pid=$!
trap 'kill $pid 2>/dev/null || true; rm -rf "$out"' EXIT

for _ in $(seq 50); do grep -q started "$out/app.log" && break; sleep 0.2; done
sleep 1.5
# single-file launch runs in the same JVM, so $pid is the JVM pid
jcmd "$pid" Thread.print > "$out/dump.txt"

grep -A12 'Found one Java-level deadlock' "$out/dump.txt" | head -16
grep -q 'Found one Java-level deadlock' "$out/dump.txt"
grep -q 'order-writer' "$out/dump.txt" && grep -q 'payment-writer' "$out/dump.txt"
echo "OK: deadlock between order-writer and payment-writer found"
