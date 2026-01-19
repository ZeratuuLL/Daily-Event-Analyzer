#!/bin/bash
# Add a new category or mood to local config
# Usage: ./update_config.sh <type> <value>
# type: "category" or "mood"
# Example: ./update_config.sh category "reading"
# Example: ./update_config.sh mood "excited"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

CONFIG_DIR="$PROJECT_ROOT/config"

TYPE="$1"
VALUE="$2"

if [ -z "$TYPE" ] || [ -z "$VALUE" ]; then
    echo "Usage: ./update_config.sh <type> <value>"
    echo "  type: 'category' or 'mood'"
    echo "  Example: ./update_config.sh category reading"
    exit 1
fi

if [ "$TYPE" = "category" ]; then
    CONFIG_FILE="$CONFIG_DIR/categories.json"
    KEY="categories"
elif [ "$TYPE" = "mood" ]; then
    CONFIG_FILE="$CONFIG_DIR/moods.json"
    KEY="moods"
else
    echo "Error: type must be 'category' or 'mood'"
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file not found. Run initialize.sh first."
    exit 1
fi

# Use Python to update the JSON (more reliable than sed/jq for this)
python3 << EOF
import json

with open("$CONFIG_FILE", "r") as f:
    config = json.load(f)

if "$VALUE" not in config["$KEY"]:
    config["$KEY"].append("$VALUE")
    with open("$CONFIG_FILE", "w") as f:
        json.dump(config, f)
    print(f"Added '$VALUE' to $KEY")
else:
    print(f"'$VALUE' already exists in $KEY")
EOF
