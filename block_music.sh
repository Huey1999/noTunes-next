#!/bin/bash

log stream --style compact --info \
  --predicate 'process == "mediaremoted" AND eventMessage CONTAINS[c] "Destination app com.apple.Music not available" AND eventMessage CONTAINS[c] "command requested a launch" AND eventMessage CONTAINS[c] "com.apple.bluetoothd"' |
while IFS= read -r line; do
    case "$line" in
        *"Destination app com.apple.Music not available for command"*)
            echo "=== XM4/Music launch detected ==="
            echo "$line"

            sleep 0.05

            pid=$(pgrep -x Music)

            if [ -n "$pid" ]; then
                echo "Music PID: $pid"
                kill "$pid" 2>/dev/null
                echo "Music terminated"
            else
                echo "Music PID: not found"
            fi

            echo "================================="
            ;;
    esac
done