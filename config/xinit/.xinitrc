if [ "$(cat /etc/hostname)" = "moebius" ]; then
    xrandr --output DisplayPort-2 --mode 3440x1440 --rate 120
fi
exec awesome
