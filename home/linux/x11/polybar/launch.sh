#!/usr/bin/env bash

killall -q polybar
polybar main 2>&1 | tee -a /tmp/polybar.main.log &
disown
