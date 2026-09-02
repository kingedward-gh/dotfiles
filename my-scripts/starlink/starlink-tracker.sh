#!/bin/bash

# ==============================================================================
# Starlink tracker: log public IP / geo / ISP changes
# Source: https://ipinfo.io/json (no API key for light personal use)
#
# Cron (every 5 minutes), after stow:
#   */5 * * * * "$HOME/.local/bin/starlink-tracker"
# ==============================================================================

LOG_FILE="$HOME/.starlink_tracker.log"
LAST_IP_FILE="$HOME/.starlink_tracker.last_ip"

if ! command -v curl &>/dev/null || ! command -v jq &>/dev/null; then
    echo "❌ starlink-tracker requires curl and jq."
    exit 1
fi

DATA=$(curl -sS --connect-timeout 5 --max-time 15 https://ipinfo.io/json 2>/dev/null) || true

# No internet (or empty response): exit quietly so cron stays silent
if [ -z "$DATA" ]; then
    exit 0
fi

if ! echo "$DATA" | jq -e . >/dev/null 2>&1; then
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

# Incomplete payload: do not treat as a real IP change
if [ -z "$IP" ]; then
    exit 0
fi

LAST_IP=""
if [ -f "$LAST_IP_FILE" ]; then
    LAST_IP=$(cat "$LAST_IP_FILE")
fi

if [ "$IP" = "$LAST_IP" ]; then
    exit 0
fi

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
LOG_ENTRY="[$TIMESTAMP] NEW IP: $IP | Geo: $CITY, $REGION ($COUNTRY) | GPS: $LOC | TZ: $TIMEZONE | Host: $HOSTNAME | Provider: $ORG"

echo "$LOG_ENTRY" >> "$LOG_FILE"
echo "$IP" > "$LAST_IP_FILE"

echo "Starlink IP change detected and logged."
echo "$LOG_ENTRY"
