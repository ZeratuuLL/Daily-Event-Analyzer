# Daily Event Analyzer

A personal daily event logging and analysis system.

## First Time Setup

Before first use, run the initialize tool to set up local config:
```bash
.claude/tools/initialize.sh
```

This creates local config files from defaults:
- `config/categories.json` - Activity categories
- `config/moods.json` - Mood options
- `config/settings.json` - Python environment settings
- `config/.initialized` - Marker file indicating system is ready

**Checking if initialized:**
```bash
[ -f config/.initialized ] && echo "Initialized" || echo "Not initialized"
```
The system is initialized if `config/.initialized` exists.

## Logging Events

When the user describes an activity, log it using the `log_event.sh` tool.

### Event Schema
```json
{"start": "0900", "end": "1100", "category": "working", "notes": "User's description", "efficiency": "medium", "focused": 3, "energy": 3, "mood": "neutral"}
```

### Fields
**Required (infer from user input):**
- `start`, `end` - HHMM format (e.g., "0900", "1430")
- `category` - Must match a value from `config/categories.json`
- `notes` - The user's description of the activity

**Optional (use defaults if not provided):**
- `efficiency` - "high" / "medium" / "low" (default: "medium")
- `focused` - 0-5 scale (default: 3)
- `energy` - 0-5 scale (default: 3)
- `mood` - Must match a value from `config/moods.json` (default: "neutral")

### Logging Workflow

**Getting current time:**
If the user says "now" or "current time" for start/end, use:
```bash
.claude/tools/get_time.sh
```
This returns the current time in HHMM format.

1. Parse the user's natural language input to extract:
   - Time range (convert to HHMM format)
   - Activity description (becomes `notes`)
   - Any mentioned feelings, focus, energy levels

2. Read `config/categories.json` and infer the best matching category

3. If no category matches well:
   - Suggest a new category to the user
   - If they agree, run `update_config.sh category "new_category"` first
   - Then log the event

4. Read `config/moods.json` if user mentions a feeling, match to existing mood

5. If no mood matches well:
   - Suggest a new mood to the user
   - If they agree, run `update_config.sh mood "new_mood"` first

6. Build the JSON event and log it:
   ```bash
   .claude/tools/log_event.sh <year> <month> <day> '<json_event>'
   ```

### Example Logging

User says: "I worked on coding from 9am to 11am, felt really focused"

1. Parse: start=0900, end=1100, notes="worked on coding", focused=high (maybe 5)
2. Category: "working" (matches)
3. Mood: not explicitly stated, use default "neutral"
4. Log:
   ```bash
   .claude/tools/log_event.sh 2026 01 18 '{"start": "0900", "end": "1100", "category": "working", "notes": "worked on coding", "efficiency": "medium", "focused": 5, "energy": 3, "mood": "neutral"}'
   ```

## Analyzing Data

For analysis requests, use the utilities in `scripts/analysis_utils.py`.

### Available Functions
- `load_events(start_date, end_date)` - Load events from date range (YYYY-MM-DD format)
- `time_by_category(events)` - Get minutes per category
- `time_by_category_percentage(events)` - Get percentage per category
- `mood_distribution(events)` - Count moods
- `efficiency_stats(events)` - Efficiency breakdown
- `focus_stats(events)` - Average/min/max focus
- `energy_stats(events)` - Average/min/max energy
- `daily_summary(events)` - Comprehensive summary
- `format_minutes(minutes)` - Format as "Xh Ym"

### Analysis Workflow

1. Read `config/settings.json` to get Python environment settings:
   - `python_activate` - Command to activate venv/conda (empty if not needed)
   - `python_cmd` - Python command to use (e.g., "python3", "python")

2. Determine the date range from user request:
   - "today" = current date
   - "this week" = last 7 days
   - "this month" = current month
   - Or specific dates mentioned

3. Write and execute Python code using heredoc pattern:
   ```bash
   # If python_activate is set:
   source ~/venv/bin/activate && python << 'EOF'
   import sys
   sys.path.insert(0, 'scripts')
   from analysis_utils import load_events, daily_summary
   # ... custom analysis code
   EOF

   # If python_activate is empty, just use python_cmd directly:
   python3 << 'EOF'
   import sys
   sys.path.insert(0, 'scripts')
   from analysis_utils import load_events, daily_summary
   # ... custom analysis code
   EOF
   ```

4. For complex analysis not covered by existing utilities, write custom analysis code

### Example Analysis

User asks: "How did I spend my time today?"

```python
import sys
sys.path.insert(0, 'scripts')
from analysis_utils import load_events, time_by_category_percentage, format_minutes

events = load_events("2026-01-18", "2026-01-18")
total_mins = sum(e.get("_duration_minutes", 0) for e in events)
breakdown = time_by_category_percentage(events)

print(f"Total tracked time: {format_minutes(total_mins)}")
for cat, pct in sorted(breakdown.items(), key=lambda x: -x[1]):
    print(f"  {cat}: {pct:.1f}%")
```

## Data Structure

```
data/
  {year}/
    {month}/
      {day}/
        events.jsonl    # One event per line
```

## Config Files

Located in `config/` (gitignored for privacy):
- `categories.json` - List of activity categories
- `moods.json` - List of mood options
- `settings.json` - Python environment settings

**Python environment examples for settings.json:**
```json
// System Python (default)
{"python_activate": "", "python_cmd": "python3"}

// Venv
{"python_activate": "source ~/myproject/venv/bin/activate", "python_cmd": "python"}

// Conda
{"python_activate": "conda activate myenv", "python_cmd": "python"}
```

Default values are in `config_defaults/` (tracked in git).
