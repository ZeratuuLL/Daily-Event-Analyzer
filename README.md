# Daily Event Analyzer

A personal daily event logging and analysis system built on Claude Code. Track what you do, how you feel, and analyze your time usage patterns.

## Features

- **Natural language logging** - Just describe what you did: "Worked on coding from 9am to 11am, felt focused"
- **Automatic categorization** - Claude infers categories from your descriptions
- **Flexible analysis** - Daily, weekly, monthly, or custom date range analysis
- **Private by design** - Your data and personal categories stay local (gitignored)

## Setup

1. Clone this repository
2. Run the initialization tool:
   ```bash
   .claude/tools/initialize.sh
   ```
   This creates your local `config/` folder with default categories, moods, and settings.

3. (Optional) Configure your Python environment in `config/settings.json`:
   ```json
   // System Python (default)
   {"python_activate": "", "python_cmd": "python3"}

   // Venv
   {"python_activate": "source ~/myproject/venv/bin/activate", "python_cmd": "python"}

   // Conda
   {"python_activate": "conda activate myenv", "python_cmd": "python"}
   ```

4. Start Claude Code in this directory and begin logging!

## Usage

### Logging Events

Just tell Claude what you did:

- "I worked on the API from 9am to 11am"
- "Had lunch with the team from 12 to 1pm, felt happy"
- "Commuted home 5:30-6pm, was tired"
- "Exercised for an hour starting at 7am, high energy, very focused"

Claude will:
- Parse the time range
- Infer the category (working, dining, commute, exercise, etc.)
- Pick up on any mood, energy, or focus indicators
- Log it to `data/{year}/{month}/{day}/events.jsonl`

### Analyzing Data

Ask Claude to analyze your time:

- "How did I spend my time today?"
- "Show me this week's breakdown by category"
- "What's my average focus level this month?"
- "Compare my efficiency between mornings and afternoons"

### Customizing Categories

Your categories and moods are stored in `config/` (private, not tracked in git).

When you mention an activity that doesn't fit existing categories, Claude will suggest adding a new one. If you agree, it persists for future sessions.

Default categories: `working`, `commute`, `exercise`, `dining`, `errands`

Default moods: `happy`, `calm`, `motivated`, `neutral`, `tired`, `stressed`, `frustrated`, `anxious`

## Data Structure

```
data/
  {year}/
    {month}/
      {day}/
        events.jsonl
```

Each event is a single JSON line:
```json
{"start": "0900", "end": "1100", "category": "working", "notes": "API integration", "efficiency": "medium", "focused": 3, "energy": 3, "mood": "neutral"}
```

## Project Structure

```
├── CLAUDE.md              # Instructions for Claude
├── README.md              # This file
├── .gitignore             # Ignores config/ and data/
├── config_defaults/       # Default configs (tracked)
│   ├── categories.json
│   ├── moods.json
│   └── settings.json
├── config/                # Your local config (not tracked)
├── data/                  # Your event logs (not tracked)
├── scripts/
│   └── analysis_utils.py  # Analysis utilities
└── .claude/tools/
    ├── initialize.sh      # Set up local config
    ├── log_event.sh       # Log an event
    └── update_config.sh   # Add new category/mood
```

## Privacy

Your personal data stays local:
- `config/` - Your customized categories, moods, and Python environment settings
- `data/` - All your event logs

Both folders are in `.gitignore` and will never be committed.
