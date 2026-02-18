#!/bin/sh
# Power-aware idle management for sway
# On AC:      no screen lock, no display off, touchbar stays bright
# On battery: normal swayidle (lock after 5min, display off after 10min)

TOUCHBAR="/sys/class/backlight/appletb_backlight/brightness"
TOUCHBAR_MAX="/sys/class/backlight/appletb_backlight/max_brightness"

start_idle() {
    # Only start if not already running
    pgrep -x swayidle >/dev/null && return
    swayidle -w \
        timeout 300 'swaylock -f -c 000000' \
        timeout 600 'swaymsg "output * power off"' resume 'swaymsg "output * power on"' \
        before-sleep 'swaylock -f -c 000000' &
}

stop_idle() {
    pkill -x swayidle 2>/dev/null
    # Restore displays in case they were powered off
    swaymsg "output * power on" 2>/dev/null
}

set_touchbar() {
    if [ -w "$TOUCHBAR" ] && [ -r "$TOUCHBAR_MAX" ]; then
        if [ "$1" = "ac" ]; then
            cat "$TOUCHBAR_MAX" > "$TOUCHBAR"
        fi
        # On battery, let the kernel handle dimming normally
    fi
}

apply_power_state() {
    # Find the AC adapter sysfs path
    for ps in /sys/class/power_supply/A*/online; do
        [ -r "$ps" ] || continue
        if [ "$(cat "$ps")" = "1" ]; then
            stop_idle
            set_touchbar ac
            return
        fi
    done
    # No AC adapter online → battery
    start_idle
    set_touchbar battery
}

# Apply initial state
apply_power_state

# Monitor for power changes
upower --monitor | while read -r _line; do
    apply_power_state
done
