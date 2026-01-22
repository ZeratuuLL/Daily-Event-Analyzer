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

### Handling Events Across Midnight

**IMPORTANT PRINCIPLE:** Events that cross midnight must be split into two separate log entries.

Rules:
- Each event must start no earlier than `"0000"` and end no later than `"2359"`
- For an event spanning midnight, create two entries:
  1. First entry: From start time to `"2359"` (logged on the first day)
  2. Second entry: From `"0000"` to end time (logged on the next day)
- Both entries should have the same category, notes, and attributes (efficiency, focused, energy, mood)

**Example:**
User says: "I slept from 10:30pm to 8:30am"

Log as two events:
```bash
# Day 1 (e.g., 2026-01-20): Sleep from 22:30 to 23:59
.claude/tools/log_event.sh 2026 01 20 '{"start": "2230", "end": "2359", "category": "sleeping", "notes": "sleep", "efficiency": "medium", "focused": 3, "energy": 3, "mood": "neutral"}'

# Day 2 (e.g., 2026-01-21): Sleep from 00:00 to 08:30
.claude/tools/log_event.sh 2026 01 21 '{"start": "0000", "end": "0830", "category": "sleeping", "notes": "sleep", "efficiency": "medium", "focused": 3, "energy": 3, "mood": "neutral"}'
```

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

## Editing and Deleting Events

When users want to correct or remove previously logged events, use the edit/delete tools.

### Available Tools

- `list_events.sh` - Show events for a date with line numbers
- `edit_event.sh` - Replace an event at a specific line number
- `delete_event.sh` - Remove an event at a specific line number

### Edit/Delete Workflow

1. **Identify the date** from user's description:
   - "today" = current date
   - "yesterday" = previous day
   - "the coding session this morning" = today
   - If unclear, ask the user or search

2. **List events** for that date to find the right one:
   ```bash
   .claude/tools/list_events.sh <year> <month> <day>
   ```
   Output shows numbered events:
   ```
   Events for 2026-01-18:
     #1: 09:00-11:00 [working] "API integration"
         (efficiency: high, focused: 4, energy: 4, mood: motivated)
     #2: 21:00-22:08 [working] "working on event logging tool"
         (efficiency: medium, focused: 3, energy: 3, mood: neutral)

   2 event(s) found.
   ```

3. **Match the user's description** to an event number:
   - Use time, category, and notes to identify the correct event
   - If ambiguous, ask the user to confirm which event

4. **For edits**: Build complete updated JSON with ALL fields:
   ```bash
   .claude/tools/edit_event.sh <year> <month> <day> <line_number> '<complete_json_event>'
   ```
   **Important**: The edit replaces the entire event. Include all fields, not just changed ones.

5. **For deletes**: Confirm with user before deleting:
   ```bash
   .claude/tools/delete_event.sh <year> <month> <day> <line_number>
   ```

### Finding Events When Date is Unknown

If user says something like "sometime last week" or "that meeting with John":

1. Use Grep to search across data files:
   ```bash
   grep "keyword" data/2026/01/*/events.jsonl
   ```

2. The file path in output reveals the date (e.g., `data/2026/01/15/events.jsonl`)

3. Then use `list_events.sh` on that specific date

### Example Edit

User says: "Actually that coding session this morning ended at 11:30, not 11:00"

1. List today's events:
   ```bash
   .claude/tools/list_events.sh 2026 01 18
   ```
   Output shows event #1 is the 09:00-11:00 coding session

2. Build updated JSON (changing only `end`):
   ```bash
   .claude/tools/edit_event.sh 2026 01 18 1 '{"start": "0900", "end": "1130", "category": "working", "notes": "API integration", "efficiency": "high", "focused": 4, "energy": 4, "mood": "motivated"}'
   ```

### Example Delete

User says: "Delete that duplicate entry from yesterday"

1. List yesterday's events:
   ```bash
   .claude/tools/list_events.sh 2026 01 17
   ```

2. Identify the duplicate, confirm with user

3. Delete:
   ```bash
   .claude/tools/delete_event.sh 2026 01 17 2
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

## Code Management

When checking in code changes: Always ensure local main is up to date before creating a new branch and PR.
