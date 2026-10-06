#!/usr/bin/env bash
# Runs a JVM whose -Xmx exceeds the container memory limit and confirms the kernel OOM-kills it.
set -euo pipefail
cd "$(dirname "$0")"
img=lab-cgroup-hog
name=lab-cgroup-hog-run
trap 'docker rm -f $name >/dev/null 2>&1 || true' EXIT

docker build -q -t $img . > /dev/null

echo "--- default ergonomics under --memory=128m (heap = 1/4 of the limit)"
docker run --rm --memory=128m --cpus=1 --entrypoint java $img -cp /app Hog 2>&1 | head -1 || true

echo "--- -Xmx512m under --memory=128m"
docker run --name $name --memory=128m --memory-swap=128m $img > /dev/null 2>&1 || true
code=$(docker inspect -f '{{.State.ExitCode}}' $name)
oom=$(docker inspect -f '{{.State.OOMKilled}}' $name)
echo "exit=$code OOMKilled=$oom"
[ "$oom" = "true" ] && [ "$code" = "137" ]
echo "OK: kernel OOM-kill (137, SIGKILL), no Java OutOfMemoryError and no heap dump"
