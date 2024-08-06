#!/bin/bash

BATTERY_LOW_FILE="/tmp/battery_low_notified.txt"
BATTERY_HIGH_FILE="/tmp/battery_high_notified.txt"


INTERVAL=300


while true; do
  BATTERY_LEVEL=$(upower -i $(upower -e | grep BAT) | grep percentage | awk '{print $2}' | sed s/%//)
  BATTERY_STATE=$(upower -i $(upower -e | grep BAT) | grep state | awk '{print $2}')

  if [ "$BATTERY_LEVEL" -le 20 ] && [ "$BATTERY_STATE" == "discharging" ] && [ -f "$BATTERY_LOW_FILE" ]; then
    sleep $INTERVAL
    continue
  fi

  if [ "$BATTERY_LEVEL" -ge 80 ] && [ "$BATTERY_STATE" == "charging" ] && [ -f "$BATTERY_HIGH_FILE" ]; then
    sleep $INTERVAL
    continue
  fi

  if [ "$BATTERY_LEVEL" -le 20 ] && [ "$BATTERY_STATE" == "discharging" ] && [ ! -f "$BATTERY_LOW_FILE" ]; then
    notify-send -i battery-low "Battery Low" "Battery level is ${BATTERY_LEVEL}%." -t 10000
    touch "$BATTERY_LOW_FILE"
  elif [ "$BATTERY_LEVEL" -gt 20 ] && [ "$BATTERY_STATE" == "charging" ]; then
    if [ -f "$BATTERY_LOW_FILE" ]; then
      rm "$BATTERY_LOW_FILE"
    fi
  fi

  if [ "$BATTERY_LEVEL" -ge 80 ] && [ "$BATTERY_STATE" == "charging" ] && [ ! -f "$BATTERY_HIGH_FILE" ]; then
    notify-send -i battery-full "Battery Full" "Battery level is ${BATTERY_LEVEL}%." -t 10000
    touch "$BATTERY_HIGH_FILE"
  elif [ "$BATTERY_LEVEL" -lt 80 ] && [ "$BATTERY_STATE" == "discharging" ]; then
    if [ -f "$BATTERY_HIGH_FILE" ]; then
      rm "$BATTERY_HIGH_FILE"
    fi
  fi

  sleep $INTERVAL
done
