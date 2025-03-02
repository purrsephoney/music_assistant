#!/bin/bash

NEW_FILE="/home/user/music_library_new.txt"
OLD_FILE="/home/user/music_library_old.txt"
LOG_FILE="/home/user/music_changes.log"
DATE=$(date +"%Y-%m-%d %H:%M:%S")

# Create Log File if it does not exist 
if [ ! -f "LOG_FILE" ] 
	touch "LOG_FILE"
	echo "Music library updates as of [$DATE]" >> "$LOG_FILE" 

# Ensure both files exist
if [ ! -f "$NEW_FILE" ] || [ ! -f "$OLD_FILE" ]; then
    echo "Missing files. Ensure both new and old music library files exist." >> "$LOG_FILE"
    exit 1
fi

# Sort and store unique songs in temp files
sort "$NEW_FILE" | uniq > /tmp/sorted_new.txt
sort "$OLD_FILE" | uniq > /tmp/sorted_old.txt

# Find new and removed songs
NEW_SONGS=$(comm -13 /tmp/sorted_old.txt /tmp/sorted_new.txt)
REMOVED_SONGS=$(comm -23 /tmp/sorted_old.txt /tmp/sorted_new.txt)

# Log results with timestamp
echo "Music library updates as of [$DATE]" >> "$LOG_FILE"

if [ -n "$NEW_SONGS" ]; then
    echo "  ➕ New Songs Added:" >> "$LOG_FILE"
    echo "$NEW_SONGS" >> "$LOG_FILE"
fi

if [ -n "$REMOVED_SONGS" ]; then
    echo "  ❌ Songs Removed:" >> "$LOG_FILE"
    echo "$REMOVED_SONGS" >> "$LOG_FILE"
fi

echo "---------------------" >> "$LOG_FILE"

# Update reference file
cp "$NEW_FILE" "$OLD_FILE"

# Optional: Send a notification (Mac only)
if [ -n "$NEW_SONGS" ]; then
    osascript -e "display notification \"New songs detected!\" with title \"Apple Music Tracker\""
fi

