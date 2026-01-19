#!/bin/bash
# Edit an event at a specific line number
# Usage: ./edit_event.sh <year> <month> <day> <line_number> '<json_event>'
# Example: ./edit_event.sh 2026 01 18 1 '{"start": "0900", "end": "1130", "category": "working", "notes": "coding"}'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

YEAR="$1"
MONTH="$2"
DAY="$3"
LINE_NUM="$4"
EVENT_JSON="$5"

if [ -z "$YEAR" ] || [ -z "$MONTH" ] || [ -z "$DAY" ] || [ -z "$LINE_NUM" ] || [ -z "$EVENT_JSON" ]; then
    echo "Usage: ./edit_event.sh <year> <month> <day> <line_number> '<json_event>'"
    echo "Example: ./edit_event.sh 2026 01 18 1 '{\"start\": \"0900\", \"end\": \"1130\", \"category\": \"working\", \"notes\": \"coding\"}'"
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

# Validate JSON (basic check - ensure it starts with { and ends with })
if ! echo "$EVENT_JSON" | grep -q '^{.*}$'; then
    echo "Error: Invalid JSON format. Must be a JSON object."
    exit 1
fi

# Get the old event for display
OLD_EVENT=$(sed -n "${LINE_NUM}p" "$DATA_FILE")

# Create temp file
TEMP_FILE=$(mktemp)

# Build new file content
CURRENT_LINE=0
while IFS= read -r line || [ -n "$line" ]; do
    # Skip empty lines
    if [ -z "$line" ]; then
        continue
    fi

    CURRENT_LINE=$((CURRENT_LINE + 1))

    if [ "$CURRENT_LINE" -eq "$LINE_NUM" ]; then
        echo "$EVENT_JSON" >> "$TEMP_FILE"
    else
        echo "$line" >> "$TEMP_FILE"
    fi
done < "$DATA_FILE"

# Atomically replace the original file
mv "$TEMP_FILE" "$DATA_FILE"

echo "Event #$LINE_NUM updated successfully."
echo ""
echo "Before:"
echo "  $OLD_EVENT"
echo ""
echo "After:"
echo "  $EVENT_JSON"
