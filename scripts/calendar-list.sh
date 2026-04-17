#!/usr/bin/env bash
set -euo pipefail

mode="${1:-tomorrow}"
date_arg="${2:-}"

osascript - "$mode" "$date_arg" <<'APPLESCRIPT'
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

on fmtLine(calName, evSummary, evStart, evEnd, isAllDay)
	return calName & tab & evSummary & tab & (evStart as string) & tab & (evEnd as string) & tab & (isAllDay as string)
end fmtLine

on run argv
	set mode to item 1 of argv
	set dateArg to item 2 of argv
	set nowDate to current date
	set startDate to nowDate
	set endDate to nowDate

	if mode is "today" then
		set time of startDate to 0
		set endDate to startDate + (1 * days)
	else if mode is "tomorrow" then
		set startDate to nowDate + (1 * days)
		set time of startDate to 0
		set endDate to startDate + (1 * days)
	else if mode is "week" then
		set time of startDate to 0
		set endDate to startDate + (7 * days)
	else if mode is "day" then
		if dateArg is "" then error "day mode requires YYYY-MM-DD"
		set startDate to ymdToDate(dateArg)
		set endDate to startDate + (1 * days)
	else
		error "Unknown mode. Use today|tomorrow|week|day"
	end if

	set outLines to {}
	tell application "Calendar"
		repeat with cal in calendars
			set calName to name of cal
			set evs to (every event of cal whose start date ≥ startDate and start date < endDate)
			repeat with ev in evs
				set end of outLines to my fmtLine(calName, summary of ev, start date of ev, end date of ev, allday event of ev)
			end repeat
		end repeat
	end tell

	if (count of outLines) is 0 then
		return "__NO_EVENTS__"
	else
		set oldTID to AppleScript's text item delimiters
		set AppleScript's text item delimiters to linefeed
		set joined to outLines as text
		set AppleScript's text item delimiters to oldTID
		return joined
	end if
end run
APPLESCRIPT
