#!/bin/bash
set -x

xrandr --output DP1 --primary --mode 1920x1080 --rotate normal \
	--output VGA1 --mode 1440x900 --rotate left