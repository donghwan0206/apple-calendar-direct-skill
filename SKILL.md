---
name: apple-calendar-direct
description: Read and write macOS Apple Calendar events reliably via osascript (Calendar.app) instead of direct DB access. Use when the user asks to check schedules (today/tomorrow/this week/specific day), create calendar events, or when previous calendar requests failed with DB-path/permission confusion.
---

# Apple Calendar Direct (osascript)

Use Calendar.app AppleScript APIs as the default path.
Do not query Calendar SQLite files directly unless explicitly asked for forensic/debug work.

## Runbook

1. Verify Calendar access quickly by listing tomorrow first.
2. For read requests, run `scripts/calendar-list.sh` with the matching mode.
3. For add requests, run `scripts/calendar-add.sh` with explicit date/time inputs.
4. Return concise, human-readable output (calendar name, title, start/end, all-day).
5. If Calendar permission is denied, tell the user to allow terminal/OpenClaw under:
   - System Settings → Privacy & Security → Calendars

## Commands

### List events

```bash
# tomorrow
bash skills/apple-calendar-direct/scripts/calendar-list.sh tomorrow

# today
bash skills/apple-calendar-direct/scripts/calendar-list.sh today

# this week (today 00:00 ~ +7 days)
bash skills/apple-calendar-direct/scripts/calendar-list.sh week

# specific day
bash skills/apple-calendar-direct/scripts/calendar-list.sh day 2026-04-18
```

### Add event

```bash
# timed event
bash skills/apple-calendar-direct/scripts/calendar-add.sh \
  "개인" "미팅" "2026-04-18" "15:30" "17:00" "강남" "준비물: 노트북"

# all-day event (start/end time ignored)
bash skills/apple-calendar-direct/scripts/calendar-add.sh \
  "개인" "중요 일정" "2026-04-20" "00:00" "00:00" "" "" true
```

Arguments:
1. calendar name (required)
2. title (required)
3. date `YYYY-MM-DD` (required)
4. start `HH:MM` (required for timed)
5. end `HH:MM` (required for timed)
6. location (optional)
7. note/description (optional)
8. all-day flag `true|false` (optional, default false)

## Response format guideline

Prefer this shape in user replies:
- [캘린더명] 제목
  - 시간: 시작 ~ 종료
  - 종일 여부

If no events exist, say the date range clearly and report none.
