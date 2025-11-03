#!/bin/bash

# Entrypoint script for Spotify container
# Starts an isolated D-Bus session and keeps container alive

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

CON_UID=$(id -u spotify)
CON_GID=$(id -g spotify)

if [ "$HOST_UID" -ne "$CON_UID" ] || [ "$HOST_GID" -ne "$CON_GID" ]; then
    echo -e "${YELLOW}Host UID/GID ($HOST_UID/$HOST_GID) does not match container ($CON_UID/$CON_GID)...${NC}"
    echo -e "${YELLOW}Updating container user...${NC}"

    sudo groupmod -o -g "$HOST_GID" spotify # Change the group ID first
    sudo usermod -o -u "$HOST_UID" -g "$HOST_GID" spotify # Change the user ID
    sudo chown -R "$HOST_UID":"$HOST_GID" /home/spotify # Fix permissions on home directory

    echo -e "${GREEN}Container user updated to UID/GID ($HOST_UID/$HOST_GID), restarting entrypoint.sh with new IDs.${NC}"
    exec sudo -E -u spotify "$0" "$@"
else
    echo "${GREEN}Host UID/GID ($HOST_UID/$HOST_GID) matches container. No changes needed.${NC}"
fi

echo -e "${GREEN}Starting Spotify container...${NC}"

mkdir -p /tmp/runtime-spotify

# D-Bus setup
echo -e "${GREEN}Starting isolated D-Bus session...${NC}"
dbus-daemon --session --address="unix:path=/tmp/runtime-spotify/dbus-session" --nofork --nopidfile --syslog-only &
DBUS_PID=$!
sleep 0.5
export DBUS_SESSION_BUS_ADDRESS="unix:path=/tmp/runtime-spotify/dbus-session"
# Verify D-Bus is running
if dbus-send --session --dest=org.freedesktop.DBus --type=method_call --print-reply /org/freedesktop/DBus org.freedesktop.DBus.ListNames >/dev/null 2>&1; then
    echo -e "${GREEN}D-Bus session initialized${NC}"
else
    echo -e "${YELLOW}Warning: D-Bus session may not be fully initialized${NC}"
    sleep 2
fi

echo -e "${GREEN}Container ready.${NC}"

# Cleanup
cleanup() {
    echo -e "${GREEN}Shutting down container...${NC}"
    if [ -n "$DBUS_PID" ]; then
        kill "$DBUS_PID" 2>/dev/null || true
    fi
    exit 0
}

# Set up signal handlers
trap cleanup SIGTERM SIGINT SIGQUIT

# Keep container alive - wait indefinitely
while true; do
    sleep infinity & wait $!
done
