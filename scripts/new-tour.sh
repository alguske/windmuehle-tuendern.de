#!/usr/bin/env bash
# Append a guided tour entry to data/fuehrungen.toml.
# Pure bash. No AI involvement required.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DATA_FILE="${FUEHRUNGEN_DATA:-$ROOT/data/fuehrungen.toml}"

usage() {
  cat <<EOF
Usage: $(basename "$0") --date YYYY-MM-DD --time HH:MM --kind public|private [options]

Required:
  -d, --date <YYYY-MM-DD>     Tour date, Europe/Berlin time zone
  -t, --time <HH:MM>          Start time (24h)
  -k, --kind <public|private> Open to anyone, or closed group

Optional:
  -s, --status <free|booked|cancelled>  Defaults to "free" (public) or "booked" (private)
  -m, --duration <minutes>    Default: 60
  -g, --guide <name>          Guide first name(s), e.g. "Dirk" or "Falk & Philipp"
  -h, --help                  Show this help

Example:
  $(basename "$0") --date 2026-08-09 --time 15:00 --kind public --guide Dirk
EOF
}

die() { echo "ERROR: $*" >&2; exit 1; }

DATE=""
TIME=""
KIND=""
STATUS=""
DURATION="60"
GUIDE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--date) DATE="${2:-}"; shift 2 ;;
    -t|--time) TIME="${2:-}"; shift 2 ;;
    -k|--kind) KIND="${2:-}"; shift 2 ;;
    -s|--status) STATUS="${2:-}"; shift 2 ;;
    -m|--duration) DURATION="${2:-}"; shift 2 ;;
    -g|--guide) GUIDE="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; die "Unknown argument: $1" ;;
  esac
done

[[ -n "$DATE" ]] || { usage >&2; die "--date required"; }
[[ -n "$TIME" ]] || { usage >&2; die "--time required"; }
[[ -n "$KIND" ]] || { usage >&2; die "--kind required"; }

[[ "$DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || die "Invalid date '$DATE' (expected YYYY-MM-DD)"
[[ "$TIME" =~ ^[0-9]{2}:[0-9]{2}$ ]] || die "Invalid time '$TIME' (expected HH:MM)"
[[ "$KIND" == "public" || "$KIND" == "private" ]] || die "Invalid kind '$KIND' (public|private)"

if [[ -z "$STATUS" ]]; then
  if [[ "$KIND" == "private" ]]; then STATUS="booked"; else STATUS="free"; fi
fi

[[ "$STATUS" == "free" || "$STATUS" == "booked" || "$STATUS" == "cancelled" ]] \
  || die "Invalid status '$STATUS' (free|booked|cancelled)"

if [[ "$KIND" == "private" && "$STATUS" == "free" ]]; then
  die "Private slot cannot have status 'free' (use 'booked' or 'cancelled')"
fi

[[ "$DURATION" =~ ^[0-9]+$ ]] || die "Invalid duration '$DURATION' (positive integer)"
[[ "$DURATION" -gt 0 ]] || die "Duration must be positive"

[[ -f "$DATA_FILE" ]] || die "$DATA_FILE not found"

# Ensure file ends with a newline before appending
if [[ -s "$DATA_FILE" ]] && [[ "$(tail -c 1 "$DATA_FILE" | wc -l)" -eq 0 ]]; then
  printf '\n' >> "$DATA_FILE"
fi

{
  printf '\n[[slots]]\n'
  printf 'date = "%s"\n' "$DATE"
  printf 'time = "%s"\n' "$TIME"
  if [[ "$DURATION" != "60" ]]; then
    printf 'duration_min = %s\n' "$DURATION"
  fi
  printf 'kind = "%s"\n' "$KIND"
  printf 'status = "%s"\n' "$STATUS"
  if [[ -n "$GUIDE" ]]; then
    escaped="${GUIDE//\\/\\\\}"
    escaped="${escaped//\"/\\\"}"
    printf 'guide = "%s"\n' "$escaped"
  fi
} >> "$DATA_FILE"

cat <<EOF
Appended to $DATA_FILE:
  date=$DATE  time=$TIME  kind=$KIND  status=$STATUS  duration=${DURATION}min  guide=${GUIDE:-(none)}

Next steps:
  ./scripts/validate-fuehrungen.py
  zola build
EOF
