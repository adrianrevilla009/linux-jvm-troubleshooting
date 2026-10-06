#!/usr/bin/env bash
# Leaks 200 loopback connections, then finds them with ss and lsof.
set -euo pipefail
cd "$(dirname "$0")"
out=$(mktemp -d)
java SocketLeak.java 200 > "$out/app.log" &
pid=$!
trap 'kill $pid 2>/dev/null || true; rm -rf "$out"' EXIT

for _ in $(seq 100); do grep -q port= "$out/app.log" && break; sleep 0.2; done
port=$(sed -n 's/^port=//p' "$out/app.log")
sleep 1

echo "ss summary of established sockets on port $port:"
est=$(ss -Htn state established "( sport = :$port or dport = :$port )" | wc -l)
echo "  $est established (client + server side)"
echo "lsof TCP descriptors held by pid $pid:"
fds=$(lsof -nP -a -p "$pid" -iTCP | grep -c ESTABLISHED || true)
echo "  $fds"
echo "fd limit: $(ulimit -n); open fds: $(ls /proc/"$pid"/fd | wc -l)"

[ "$est" -ge 400 ] && [ "$fds" -ge 400 ]
echo "OK: leaked sockets visible in ss and lsof"
