"""
Analysis utilities for Daily Event Analyzer.
Provides functions to load and analyze event data.
"""

import json
import os
from datetime import datetime, timedelta
from pathlib import Path
from collections import defaultdict
from typing import List, Dict, Optional, Tuple


def get_project_root() -> Path:
    """Get the project root directory."""
    return Path(__file__).parent.parent


def get_data_dir() -> Path:
    """Get the data directory path."""
    return get_project_root() / "data"


def parse_hhmm(time_str: str) -> Tuple[int, int]:
    """Parse HHMM format to (hour, minute) tuple."""
    hour = int(time_str[:2])
    minute = int(time_str[2:])
    return hour, minute


def duration_minutes(start: str, end: str) -> int:
    """Calculate duration in minutes between two HHMM times."""
    start_h, start_m = parse_hhmm(start)
    end_h, end_m = parse_hhmm(end)
    start_total = start_h * 60 + start_m
    end_total = end_h * 60 + end_m
    # Handle overnight events (end < start means it crosses midnight)
    if end_total < start_total:
        end_total += 24 * 60
    return end_total - start_total


def load_events_for_date(year: int, month: int, day: int) -> List[Dict]:
    """Load events for a specific date."""
    data_dir = get_data_dir()
    file_path = data_dir / f"{year:04d}" / f"{month:02d}" / f"{day:02d}" / "events.jsonl"

    events = []
    if file_path.exists():
        with open(file_path, "r") as f:
            for line in f:
                line = line.strip()
                if line:
                    event = json.loads(line)
                    # Add date context to event
                    event["_date"] = f"{year:04d}-{month:02d}-{day:02d}"
                    event["_duration_minutes"] = duration_minutes(event["start"], event["end"])
                    events.append(event)
    return events


def load_events(start_date: str, end_date: str) -> List[Dict]:
    """
    Load events from a date range.

    Args:
        start_date: Start date in YYYY-MM-DD format
        end_date: End date in YYYY-MM-DD format (inclusive)

    Returns:
        List of event dictionaries with added _date and _duration_minutes fields
    """
    start = datetime.strptime(start_date, "%Y-%m-%d")
    end = datetime.strptime(end_date, "%Y-%m-%d")

    events = []
    current = start
    while current <= end:
        day_events = load_events_for_date(current.year, current.month, current.day)
        events.extend(day_events)
        current += timedelta(days=1)

    return events


def time_by_category(events: List[Dict]) -> Dict[str, int]:
    """
    Calculate total time (in minutes) spent on each category.

    Returns:
        Dict mapping category to total minutes
    """
    totals = defaultdict(int)
    for event in events:
        category = event.get("category", "unknown")
        duration = event.get("_duration_minutes", 0)
        totals[category] += duration
    return dict(totals)


def time_by_category_percentage(events: List[Dict]) -> Dict[str, float]:
    """
    Calculate percentage of time spent on each category.

    Returns:
        Dict mapping category to percentage (0-100)
    """
    totals = time_by_category(events)
    total_time = sum(totals.values())
    if total_time == 0:
        return {}
    return {cat: (mins / total_time) * 100 for cat, mins in totals.items()}


def mood_distribution(events: List[Dict]) -> Dict[str, int]:
    """
    Count occurrences of each mood.

    Returns:
        Dict mapping mood to count
    """
    counts = defaultdict(int)
    for event in events:
        mood = event.get("mood", "neutral")
        counts[mood] += 1
    return dict(counts)


def efficiency_stats(events: List[Dict]) -> Dict[str, any]:
    """
    Calculate efficiency statistics.

    Returns:
        Dict with efficiency breakdown and stats
    """
    counts = defaultdict(int)
    for event in events:
        efficiency = event.get("efficiency", "medium")
        counts[efficiency] += 1

    total = sum(counts.values())
    return {
        "counts": dict(counts),
        "percentages": {k: (v / total) * 100 for k, v in counts.items()} if total > 0 else {}
    }


def focus_stats(events: List[Dict]) -> Dict[str, any]:
    """
    Calculate focus level statistics.

    Returns:
        Dict with average, min, max focus levels
    """
    focus_values = [event.get("focused", 3) for event in events]
    if not focus_values:
        return {"average": 0, "min": 0, "max": 0, "count": 0}

    return {
        "average": sum(focus_values) / len(focus_values),
        "min": min(focus_values),
        "max": max(focus_values),
        "count": len(focus_values)
    }


def energy_stats(events: List[Dict]) -> Dict[str, any]:
    """
    Calculate energy level statistics.

    Returns:
        Dict with average, min, max energy levels
    """
    energy_values = [event.get("energy", 3) for event in events]
    if not energy_values:
        return {"average": 0, "min": 0, "max": 0, "count": 0}

    return {
        "average": sum(energy_values) / len(energy_values),
        "min": min(energy_values),
        "max": max(energy_values),
        "count": len(energy_values)
    }


def daily_summary(events: List[Dict]) -> Dict[str, any]:
    """
    Generate a comprehensive daily summary.

    Returns:
        Dict with time breakdown, mood, efficiency, focus, and energy stats
    """
    return {
        "total_events": len(events),
        "total_minutes": sum(e.get("_duration_minutes", 0) for e in events),
        "time_by_category": time_by_category(events),
        "time_percentage": time_by_category_percentage(events),
        "mood_distribution": mood_distribution(events),
        "efficiency": efficiency_stats(events),
        "focus": focus_stats(events),
        "energy": energy_stats(events)
    }


def format_minutes(minutes: int) -> str:
    """Format minutes as Xh Ym string."""
    hours = minutes // 60
    mins = minutes % 60
    if hours > 0 and mins > 0:
        return f"{hours}h {mins}m"
    elif hours > 0:
        return f"{hours}h"
    else:
        return f"{mins}m"
