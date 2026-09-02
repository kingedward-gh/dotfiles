#!/bin/bash

# ==============================================================================
# Starlink tracker: log public IP / geo / ISP changes
# Source: https://ipinfo.io/json (no API key for light personal use)
#
# Cron (every 5 minutes), after stow:
#   */5 * * * * "$HOME/.local/bin/starlink-tracker"
# Interactive runs always print a status and offer to open/view the log.
# Non-TTY (cron) stays silent except on a hard error.
# ==============================================================================

LOG_FILE="$HOME/.starlink_tracker.log"
LAST_IP_FILE="$HOME/.starlink_tracker.last_ip"

is_interactive() {
    [ -t 0 ] && [ -t 1 ]
}

say() {
    if is_interactive; then
        echo "$@"
    fi
}

current_line() {
    local prefix="$1"
    echo "[$(date "+%Y-%m-%d %H:%M:%S")] $prefix: $IP | Geo: $CITY, $REGION ($COUNTRY) | GPS: $LOC | TZ: $TIMEZONE | Host: $HOSTNAME | Provider: $ORG"
}

offer_log() {
    if ! is_interactive; then
        return 0
    fi

    echo ""
    if [ ! -f "$LOG_FILE" ]; then
        echo "No log file yet ($LOG_FILE)."
        return 0
    fi

    echo "Log: $LOG_FILE"
    echo "  [n] open in nano"
    echo "  [t] view last 20 lines (tail)"
    echo "  [q] quit"
    read -r -p "Choice [n/t/q]: " choice

    case "$choice" in
        n|N)
            nano "$LOG_FILE"
            ;;
        t|T)
            echo ""
            tail -n 20 "$LOG_FILE"
            ;;
        *)
            ;;
    esac
}

if ! command -v curl &>/dev/null || ! command -v jq &>/dev/null; then
    echo "❌ starlink-tracker requires curl and jq."
    exit 1
fi

DATA=$(curl -sS --connect-timeout 5 --max-time 15 https://ipinfo.io/json 2>/dev/null) || true

if [ -z "$DATA" ]; then
    say "No internet (or empty response from ipinfo.io). Nothing logged."
    offer_log
    exit 0
fi

if ! echo "$DATA" | jq -e . >/dev/null 2>&1; then
    say "Invalid response from ipinfo.io. Nothing logged."
    offer_log
    exit 0
fi

IP=$(echo "$DATA" | jq -r '.ip // empty')
CITY=$(echo "$DATA" | jq -r '.city // "N/A"')
REGION=$(echo "$DATA" | jq -r '.region // "N/A"')
COUNTRY=$(echo "$DATA" | jq -r '.country // "N/A"')
LOC=$(echo "$DATA" | jq -r '.loc // "N/A"')
ORG=$(echo "$DATA" | jq -r '.org // "N/A"')
TIMEZONE=$(echo "$DATA" | jq -r '.timezone // "N/A"')
HOSTNAME=$(echo "$DATA" | jq -r '.hostname // "N/A"')

if [ -z "$IP" ]; then
    say "Incomplete payload (no IP). Nothing logged."
    offer_log
    exit 0
fi

LAST_IP=""
if [ -f "$LAST_IP_FILE" ]; then
    LAST_IP=$(cat "$LAST_IP_FILE")
fi

if [ "$IP" = "$LAST_IP" ]; then
    say "No IP change. Still $IP"
    say "$(current_line "CURRENT")"
    offer_log
    exit 0
fi

LOG_ENTRY=$(current_line "NEW IP")
echo "$LOG_ENTRY" >> "$LOG_FILE"
echo "$IP" > "$LAST_IP_FILE"

say "Starlink IP change detected and logged."
say "$LOG_ENTRY"
if ! is_interactive; then
    exit 0
fi

offer_log
