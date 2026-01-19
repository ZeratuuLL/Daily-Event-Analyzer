#!/bin/bash
# Log an event to the daily JSONL file
# Usage: ./log_event.sh <year> <month> <day> '<json_event>'
# Example: ./log_event.sh 2026 01 18 '{"start": "0900", "end": "1100", "category": "working", "notes": "coding"}'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

YEAR="$1"
MONTH="$2"
DAY="$3"
EVENT_JSON="$4"

if [ -z "$YEAR" ] || [ -z "$MONTH" ] || [ -z "$DAY" ] || [ -z "$EVENT_JSON" ]; then
    echo "Usage: ./log_event.sh <year> <month> <day> '<json_event>'"
    echo "Example: ./log_event.sh 2026 01 18 '{\"start\": \"0900\", \"end\": \"1100\", \"category\": \"working\", \"notes\": \"coding\"}'"
    exit 1
fi

# Create the date folder structure
DATA_DIR="$PROJECT_ROOT/data/$YEAR/$MONTH/$DAY"
mkdir -p "$DATA_DIR"

# Append the event to events.jsonl
echo "$EVENT_JSON" >> "$DATA_DIR/events.jsonl"

echo "Event logged to $DATA_DIR/events.jsonl"
