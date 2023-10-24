#!/usr/bin/env sh

run() {
    if ! pgrep -f "$1"; then
        "$@" &
    fi
}

run "picom" -b
run "pasystray"
run "nm-applet"
run "gammastep" -l 54:10
run "feh" --randomize --bg-fill ~/MEGA/Wallpaper/
sleep 5 && run "megasync"
