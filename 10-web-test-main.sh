#!/usr/bin/env bash
set -e

export ION_HOST=$(test -z "$ION_HOST" && echo 'localhost:9090' || echo "$ION_HOST")
export ION_ROOM=$(test -z "$ION_ROOM" && echo 'test-pink-video' || echo "$ION_ROOM")
export HTTP_SCHEME=$(test -z "$ION_HTTP_SCHEME" && echo 'https' || echo "$ION_HTTP_SCHEME")
export WS_SCHEME=$(test -z "$ION_WS_SCHEME" && echo 'wss' || echo "$ION_WS_SCHEME")
export ENDPOINT=$(test -z "$ENDPOINT" && echo "$WS_SCHEME://$ION_HOST/ws" || echo "$ENDPOINT")
export URL=$(test -z "$URL" && echo "$HTTP_SCHEME://$ION_HOST" || echo "$URL")

echo "Running e2e tests"
echo "Job: $JOB_ID"
echo "URL: $URL"
echo "Biz Endpoint: $ENDPOINT"
echo "Room: $ION_ROOM"
echo
echo "======================="
echo
echo "1. Joining $ION_ROOM with pink.video via go client"

go run join.go -d 600 &

echo
echo "======================="
echo
echo "2. Launching browser and searching for hot pink..."
echo "This takes <= 20 seconds, plus browserstack queue time for MAC or IOS"

/usr/bin/python3 browsertest.py

echo
echo "======================="
echo
echo "All done!"
sleep 3
PIDS=$(ps -ef | grep join | grep go-build | awk '{print $2}')
echo "cleaning up... $PIDS"

kill -9 $PIDS