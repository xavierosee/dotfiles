#!/bin/sh
# display-setup.sh — disable internal display when an external one is connected,
# and move all workspaces to the external output.
# Also sets the wallpaper on the external display based on its aspect ratio.
#
# Subscribes to sway output events and reacts to hotplug changes.
# Launched via exec_always in sway config.

INTERNAL="eDP-1"
WALLPAPER_DIR="$HOME/.config/wallpapers"
WALLPAPER_ULTRAWIDE="$WALLPAPER_DIR/uw.jpg"
WALLPAPER_STANDARD="$WALLPAPER_DIR/coe33.jpg"

STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/display-setup-state"

get_external_output() {
    swaymsg -t get_outputs -r | jq -r \
        '.[] | select(.name != "'"$INTERNAL"'" and .active) | .name' | head -n1
}

get_aspect_type() {
    output="$1"
    ratio=$(swaymsg -t get_outputs -r | jq -r \
        '.[] | select(.name == "'"$output"'")
         | .current_mode | .width / .height')
    is_ultrawide=$(echo "$ratio" | awk '{ print ($1 >= 2.0) }')
    if [ "$is_ultrawide" = "1" ]; then
        echo "ultrawide"
    else
        echo "standard"
    fi
}

set_wallpaper() {
    output="$1"
    case "$(get_aspect_type "$output")" in
        ultrawide) wp="$WALLPAPER_ULTRAWIDE" ;;
        *)         wp="$WALLPAPER_STANDARD" ;;
    esac
    if [ -f "$wp" ]; then
        swaymsg output "$output" bg "$wp" fill
    fi
}

move_workspaces_to() {
    target="$1"
    swaymsg -t get_workspaces -r | jq -r '.[].name' | while read -r ws; do
        swaymsg "[workspace=$ws]" move workspace to output "$target" 2>/dev/null
    done
}

apply() {
    ext=$(get_external_output)
    state="ext=${ext:-none}"

    # Skip if nothing changed (prevents feedback loops from wallpaper commands)
    [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "$state" ] && return
    printf '%s' "$state" > "$STATE_FILE"

    if [ -n "$ext" ]; then
        move_workspaces_to "$ext"
        set_wallpaper "$ext"
        swaymsg output "$INTERNAL" disable
    else
        swaymsg output "$INTERNAL" enable
    fi
}

# Clear stale state so apply() always runs fresh after sway reload
rm -f "$STATE_FILE"

# Apply once at startup
sleep 1
apply

# React to output hotplug events; restart subscribe if connection drops
while true; do
    swaymsg -t subscribe -m '["output"]' | while read -r _event; do
        sleep 1
        apply
    done
    # subscribe exited (sway reload or output reconfiguration) — retry
    sleep 2
done
