#!/bin/bash
# Delete an event at a specific line number
# Usage: ./delete_event.sh <year> <month> <day> <line_number>
# Example: ./delete_event.sh 2026 01 18 1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

YEAR="$1"
MONTH="$2"
DAY="$3"
LINE_NUM="$4"

if [ -z "$YEAR" ] || [ -z "$MONTH" ] || [ -z "$DAY" ] || [ -z "$LINE_NUM" ]; then
    echo "Usage: ./delete_event.sh <year> <month> <day> <line_number>"
    echo "Example: ./delete_event.sh 2026 01 18 1"
    exit 1
fi

DATA_FILE="$PROJECT_ROOT/data/$YEAR/$MONTH/$DAY/events.jsonl"

if [ ! -f "$DATA_FILE" ]; then
    echo "Error: No events file found for $YEAR-$MONTH-$DAY"
    exit 1
fi

# Count non-empty lines (events)
TOTAL_EVENTS=$(grep -c -v '^[[:space:]]*$' "$DATA_FILE" 2>/dev/null || echo "0")

if [ "$LINE_NUM" -lt 1 ] || [ "$LINE_NUM" -gt "$TOTAL_EVENTS" ]; then
    echo "Error: Line number must be between 1 and $TOTAL_EVENTS"
    exit 1
fi

# Get the event being deleted for display
DELETED_EVENT=$(sed -n "${LINE_NUM}p" "$DATA_FILE")

# Create temp file
TEMP_FILE=$(mktemp)

# Build new file content, skipping the deleted line
CURRENT_LINE=0
while IFS= read -r line || [ -n "$line" ]; do
    # Skip empty lines
    if [ -z "$line" ]; then
        continue
    fi

    CURRENT_LINE=$((CURRENT_LINE + 1))

    if [ "$CURRENT_LINE" -ne "$LINE_NUM" ]; then
        echo "$line" >> "$TEMP_FILE"
    fi
done < "$DATA_FILE"

# Handle case where all events are deleted
if [ ! -s "$TEMP_FILE" ]; then
    # Keep empty file or remove it
    rm "$DATA_FILE"
    rm "$TEMP_FILE"
    echo "Event #$LINE_NUM deleted. No events remaining for this date."
else
    # Atomically replace the original file
    mv "$TEMP_FILE" "$DATA_FILE"

    REMAINING=$((TOTAL_EVENTS - 1))
    echo "Event #$LINE_NUM deleted successfully."
    echo ""
    echo "Deleted:"
    echo "  $DELETED_EVENT"
    echo ""
    echo "$REMAINING event(s) remaining."
fi
