#!/bin/bash
# Clamshell mode: disable the internal display when the lid closes while on
# AC power with an external monitor connected; re-enable it when the lid opens.
# Invoked from hyprland.lua switch:on/off binds for both "Lid Switch" and
# "macsmc-chamshell" switch devices (whichever actually fires on this hardware).

ACTION="$1"  # "close" or "open"

INTERNAL="eDP-1"
EXTERNAL="DP-4"
AC_ONLINE_FILE="/sys/class/power_supply/macsmc-ac/online"

is_ac_online() {
    [ -r "$AC_ONLINE_FILE" ] && [ "$(cat "$AC_ONLINE_FILE")" = "1" ]
}

is_external_connected() {
    hyprctl monitors -j 2>/dev/null | grep -q "\"name\": *\"$EXTERNAL\""
}

case "$ACTION" in
    close)
        if is_ac_online && is_external_connected; then
            hyprctl eval "hl.monitor({ output = '$INTERNAL', disabled = true })"
        fi
        ;;
    open)
        hyprctl eval "hl.monitor({ output = '$INTERNAL', disabled = false, mode = '2880x1800@60', position = '1440x0', scale = 2 })"
        ;;
esac
