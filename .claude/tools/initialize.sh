#!/bin/bash
# Initialize local config from defaults if missing
# Usage: ./initialize.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

CONFIG_DIR="$PROJECT_ROOT/config"
DEFAULTS_DIR="$PROJECT_ROOT/config_defaults"

# Create config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Copy categories.json if missing
if [ ! -f "$CONFIG_DIR/categories.json" ]; then
    cp "$DEFAULTS_DIR/categories.json" "$CONFIG_DIR/categories.json"
    echo "Created config/categories.json from defaults"
else
    echo "config/categories.json already exists"
fi

# Copy moods.json if missing
if [ ! -f "$CONFIG_DIR/moods.json" ]; then
    cp "$DEFAULTS_DIR/moods.json" "$CONFIG_DIR/moods.json"
    echo "Created config/moods.json from defaults"
else
    echo "config/moods.json already exists"
fi

# Copy settings.json if missing
if [ ! -f "$CONFIG_DIR/settings.json" ]; then
    cp "$DEFAULTS_DIR/settings.json" "$CONFIG_DIR/settings.json"
    echo "Created config/settings.json from defaults"
else
    echo "config/settings.json already exists"
fi

# Create initialization marker file
touch "$CONFIG_DIR/.initialized"

echo ""
echo "Initialization complete!"
echo ""
echo "To configure Python environment, edit config/settings.json:"
echo "  Default (system python):  {\"python_activate\": \"\", \"python_cmd\": \"python3\"}"
echo "  Venv example:             {\"python_activate\": \"source ~/venv/bin/activate\", \"python_cmd\": \"python\"}"
echo "  Conda example:            {\"python_activate\": \"conda activate myenv\", \"python_cmd\": \"python\"}"
