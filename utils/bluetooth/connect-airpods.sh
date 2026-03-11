#!/bin/bash

set -e

DEVICE="34:0E:22:06:D1:5B"

bluetoothctl connect $DEVICE

if bluetoothctl info $DEVICE | grep -q "Connected: yes"; then
    echo "✓ Connected to headphones"
    notify-send "Bluetooth" "Headphones connected" -u normal
else
    echo "✗ Connection failed"
    notify-send "Bluetooth" "Connection failed" -u critical
fi
