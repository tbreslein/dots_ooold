#!/usr/bin/env sh

run() {
    if ! pgrep -f "$1"; then
        "$@" &
    fi
}

run "picom" -bfc --backend glx --experimental-backends --blur-background --blur-method dual_kawase --blur-strength 3 --vsync --corner-radius 7
run "pasystray"
run "nm-applet"
run "gammastep" -l 54:10
run "feh" --bg-fill ~/MEGA/Wallpaper/lofi-cafe_gray.jpg
sleep 5 && run "megasync"
