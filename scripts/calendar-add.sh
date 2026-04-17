#!/usr/bin/env bash
set -euo pipefail

calendar_name="${1:-}"
title="${2:-}"
ymd="${3:-}"
start_hm="${4:-}"
end_hm="${5:-}"
location="${6:-}"
note="${7:-}"
all_day="${8:-false}"

if [[ -z "$calendar_name" || -z "$title" || -z "$ymd" ]]; then
  echo "Usage: $0 <calendar> <title> <YYYY-MM-DD> <HH:MM> <HH:MM> [location] [note] [all_day=true|false]" >&2
  exit 1
fi

if [[ "$all_day" != "true" && "$all_day" != "false" ]]; then
  echo "all_day must be true or false" >&2
  exit 1
fi

osascript - "$calendar_name" "$title" "$ymd" "$start_hm" "$end_hm" "$location" "$note" "$all_day" <<'APPLESCRIPT'
on ymdToDate(ymd)
	set oldTID to AppleScript's text item delimiters
	set AppleScript's text item delimiters to "-"
	set parts to text items of ymd
	set AppleScript's text item delimiters to oldTID
	if (count of parts) is not 3 then error "Invalid date format. Use YYYY-MM-DD"
	set y to (item 1 of parts) as integer
	set m to (item 2 of parts) as integer
	set d to (item 3 of parts) as integer
	set dt to current date
	set year of dt to y
	set month of dt to m
	set day of dt to d
	set time of dt to 0
	return dt
end ymdToDate

on applyHM(dt, hm)
	set oldTID to AppleScript's text item delimiters
	set AppleScript's text item delimiters to ":"
	set parts to text items of hm
	set AppleScript's text item delimiters to oldTID
	if (count of parts) is not 2 then error "Invalid time format. Use HH:MM"
	set h to (item 1 of parts) as integer
	set m to (item 2 of parts) as integer
	set time of dt to (h * hours) + (m * minutes)
	return dt
end applyHM

on run argv
	set calName to item 1 of argv
	set evTitle to item 2 of argv
	set ymd to item 3 of argv
	set startHM to item 4 of argv
	set endHM to item 5 of argv
	set evLocation to item 6 of argv
	set evNote to item 7 of argv
	set allDayFlag to item 8 of argv

	set startDate to ymdToDate(ymd)
	set endDate to ymdToDate(ymd)

	if allDayFlag is "true" then
		set endDate to endDate + (1 * days)
	else
		set startDate to applyHM(startDate, startHM)
		set endDate to applyHM(endDate, endHM)
		if endDate ≤ startDate then error "End time must be after start time"
	end if

	tell application "Calendar"
		if not (exists calendar calName) then error "Calendar not found: " & calName
		set targetCal to calendar calName
		set newEvent to make new event at end of events of targetCal with properties {summary:evTitle, start date:startDate, end date:endDate, allday event:(allDayFlag is "true")}
		if evLocation is not "" then set location of newEvent to evLocation
		if evNote is not "" then set description of newEvent to evNote
	end tell

	return "CREATED\t" & calName & tab & evTitle & tab & (startDate as string) & tab & (endDate as string) & tab & allDayFlag
end run
APPLESCRIPT
