#!/bin/bash
# List events for a specific date with line numbers
# Usage: ./list_events.sh <year> <month> <day>
# Example: ./list_events.sh 2026 01 18

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

YEAR="$1"
MONTH="$2"
DAY="$3"

if [ -z "$YEAR" ] || [ -z "$MONTH" ] || [ -z "$DAY" ]; then
    echo "Usage: ./list_events.sh <year> <month> <day>"
    echo "Example: ./list_events.sh 2026 01 18"
    exit 1
fi

DATA_FILE="$PROJECT_ROOT/data/$YEAR/$MONTH/$DAY/events.jsonl"

if [ ! -f "$DATA_FILE" ]; then
    echo "No events found for $YEAR-$MONTH-$DAY"
    exit 0
fi

echo "Events for $YEAR-$MONTH-$DAY:"
echo ""

LINE_NUM=0
while IFS= read -r line || [ -n "$line" ]; do
    if [ -z "$line" ]; then
        continue
    fi

    LINE_NUM=$((LINE_NUM + 1))

    # Parse JSON fields using grep and sed (portable)
    start=$(echo "$line" | grep -o '"start"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)"$/\1/')
    end=$(echo "$line" | grep -o '"end"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)"$/\1/')
    category=$(echo "$line" | grep -o '"category"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)"$/\1/')
    notes=$(echo "$line" | grep -o '"notes"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)"$/\1/')
    efficiency=$(echo "$line" | grep -o '"efficiency"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)"$/\1/')
    focused=$(echo "$line" | grep -o '"focused"[[:space:]]*:[[:space:]]*[0-9]*' | sed 's/.*:[[:space:]]*//')
    energy=$(echo "$line" | grep -o '"energy"[[:space:]]*:[[:space:]]*[0-9]*' | sed 's/.*:[[:space:]]*//')
    mood=$(echo "$line" | grep -o '"mood"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)"$/\1/')

    # Format time as HH:MM
    start_fmt="${start:0:2}:${start:2:2}"
    end_fmt="${end:0:2}:${end:2:2}"

    echo "  #$LINE_NUM: $start_fmt-$end_fmt [$category] \"$notes\""
    echo "      (efficiency: $efficiency, focused: $focused, energy: $energy, mood: $mood)"
    echo ""
done < "$DATA_FILE"

echo "$LINE_NUM event(s) found."
