
# Battery Notification Script

This script monitors your battery level and sends notifications when the battery is low (20% or less) or fully charged (80% or more). It prevents repeated notifications by creating temporary files that act as flags.

## Requirements

- `upower` utility installed
- `notify-send` for notifications

## Installation

1. Clone this repository or download the script.
2. Make the script executable:

    ```bash
    chmod +x battery_notification.sh
    ```

## Usage

Run the script in the background to start monitoring your battery:

```bash
./battery_notification.sh &
```

## File Locations

- Notification flags are stored in the `/tmp` directory:
  - `/tmp/battery_low_notified.txt`
  - `/tmp/battery_high_notified.txt`

These files are used to track if a notification has already been sent and to avoid repeated alerts.

## Script

```bash
#!/bin/bash

# Files to track notification status
BATTERY_LOW_FILE="/tmp/battery_low_notified.txt"
BATTERY_HIGH_FILE="/tmp/battery_high_notified.txt"

# Time interval in seconds (5 minutes)
INTERVAL=300

while true; do
  # Get current battery level and state
  BATTERY_INFO=$(upower -i $(upower -e | grep BAT))
  BATTERY_LEVEL=$(echo "$BATTERY_INFO" | grep percentage | awk '{print $2}' | sed 's/%//')
  BATTERY_STATE=$(echo "$BATTERY_INFO" | grep state | awk '{print $2}')

  # Notify if battery is low and hasn't been notified before
  if [ "$BATTERY_LEVEL" -le 20 ] && [ "$BATTERY_STATE" == "discharging" ] && [ ! -f "$BATTERY_LOW_FILE" ]; then
    notify-send -i battery-low "Battery Low" "Battery level is ${BATTERY_LEVEL}%." -t 10000
    touch "$BATTERY_LOW_FILE"
    [ -f "$BATTERY_HIGH_FILE" ] && rm "$BATTERY_HIGH_FILE"
  elif [ "$BATTERY_LEVEL" -gt 20 ] && [ -f "$BATTERY_LOW_FILE" ]; then
    rm "$BATTERY_LOW_FILE"
  fi

  # Notify if battery is fully charged and hasn't been notified before
  if [ "$BATTERY_LEVEL" -ge 80 ] && [ "$BATTERY_STATE" == "charging" ] && [ ! -f "$BATTERY_HIGH_FILE" ]; then
    notify-send -i battery-full "Battery Full" "Battery level is ${BATTERY_LEVEL}%." -t 10000
    touch "$BATTERY_HIGH_FILE"
    [ -f "$BATTERY_LOW_FILE" ] && rm "$BATTERY_LOW_FILE"
  elif [ "$BATTERY_LEVEL" -lt 80 ] && [ -f "$BATTERY_HIGH_FILE" ]; then
    rm "$BATTERY_HIGH_FILE"
  fi

  sleep $INTERVAL
done
```

## Explanation

The script performs the following steps in an infinite loop:

1. **Get Battery Information**:
   - Uses `upower` to get the current battery level and state.

2. **Check Battery Level**:
   - If the battery is low (20% or less) and discharging, it sends a notification if it hasn't been sent already.
   - If the battery level exceeds 20%, it removes the low battery notification flag.
   
3. **Check Charging State**:
   - If the battery is fully charged (80% or more) and charging, it sends a notification if it hasn't been sent already.
   - If the battery level drops below 80%, it removes the full battery notification flag.

4. **Wait Interval**:
   - The script waits for the defined interval (5 minutes) before checking the battery status again.

## Optimization Notes

- Combined `if` statements to avoid redundancies and ensure the correct logical flow.
- Used temporary files to track notification status and avoid repeated notifications.

Feel free to customize the script as needed. Contributions and improvements are welcome!