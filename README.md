# apple-calendar-direct-skill

Reliable Apple Calendar access for OpenClaw using **macOS AppleScript (`osascript`)**.
No fragile SQLite path parsing. Uses Calendar.app directly.

OpenClaw에서 **macOS AppleScript(`osascript`)**로 Apple Calendar를 안정적으로 조회/등록하는 스킬입니다.
SQLite DB 경로를 직접 파지 않고 Calendar.app을 직접 사용합니다.

---

## Why / 왜 이 스킬인가

**EN**
- Calendar DB paths can vary by macOS version and environment.
- Direct app scripting is usually more stable for read/write automation.
- Works great for "today / tomorrow / this week / specific day" checks.

**KO**
- macOS 버전/환경마다 Calendar DB 경로가 달라 실패가 자주 납니다.
- 앱 직접 제어(AppleScript)가 조회/등록 자동화에 더 안정적입니다.
- 오늘/내일/이번 주/특정 날짜 조회에 특히 적합합니다.

---

## Included Files / 구성 파일

- `SKILL.md` — Skill definition and runbook
- `scripts/calendar-list.sh` — Event listing script
- `scripts/calendar-add.sh` — Event creation script

---

## Requirements / 요구사항

- macOS
- `osascript` (built-in)
- Calendar access permission for terminal/OpenClaw

### Permission / 권한

If access is denied:
- **System Settings → Privacy & Security → Calendars**
- Allow your terminal/OpenClaw process.

권한 오류가 나면:
- **시스템 설정 → 개인정보 보호 및 보안 → 캘린더**
- 터미널/OpenClaw 프로세스를 허용하세요.

---

## Usage / 사용법

### 1) List events / 일정 조회

```bash
# tomorrow / 내일
bash scripts/calendar-list.sh tomorrow

# today / 오늘
bash scripts/calendar-list.sh today

# week / 이번 7일
bash scripts/calendar-list.sh week

# specific day / 특정 날짜
bash scripts/calendar-list.sh day 2026-04-18
```

Output format:
`<calendar>\t<title>\t<start>\t<end>\t<allDay>`

### 2) Add event / 일정 등록

```bash
# timed event / 시간 지정 일정
bash scripts/calendar-add.sh \
  "개인" "미팅" "2026-04-18" "15:30" "17:00" "강남" "준비물: 노트북"

# all-day event / 종일 일정
bash scripts/calendar-add.sh \
  "개인" "중요 일정" "2026-04-20" "00:00" "00:00" "" "" true
```

Arguments:
1. calendar name / 캘린더명 (required)
2. title / 제목 (required)
3. date `YYYY-MM-DD` (required)
4. start `HH:MM` (required for timed)
5. end `HH:MM` (required for timed)
6. location / 장소 (optional)
7. note/description / 메모 (optional)
8. all-day flag `true|false` (optional, default: false)

---

## Troubleshooting / 문제 해결

- `Calendar not found: <name>`
  - Check exact calendar name in Calendar.app.
  - Calendar.app에서 캘린더 이름(띄어쓰기 포함) 정확히 확인하세요.

- Permission error / 권한 오류
  - Re-check Calendar permission in Privacy settings.

- No events returned / 일정이 안 보임
  - Verify date range and timezone.
  - 날짜 범위/시간대를 확인하세요.

---

## Security Note / 보안 안내

This skill runs local AppleScript commands only.
Still, review scripts before use in sensitive environments.

이 스킬은 로컬 AppleScript 명령만 실행하지만,
민감 환경에서는 스크립트를 먼저 검토한 뒤 사용하세요.

---

## License

MIT (or your preferred license)
