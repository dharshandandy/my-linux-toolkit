#!/bin/bash

# This script will remove permentently the files|folders which are moved to trash 30 days ago. 

TRASH_DIR="$HOME/.local/share/Trash"
INFO_DIR="$TRASH_DIR/info"
FILES_DIR="$TRASH_DIR/files"
LOG_FILE="$TRASH_DIR/autotrash_cleaned.log"

# Ensure log file exists
touch "$LOG_FILE"

# Current time in seconds
NOW=$(date +%s)

# 30 days in seconds
DAYS_30=$((30 * 24 * 60 * 60))

for info_file in "$INFO_DIR"/*.trashinfo; do
    [ -e "$info_file" ] || continue

    # Extract filename (without extension)
    base_name=$(basename "$info_file" .trashinfo)

    # Read Path and DeletionDate
    original_path=$(grep '^Path=' "$info_file" | cut -d= -f2-)
    deletion_date=$(grep '^DeletionDate=' "$info_file" | cut -d= -f2)

    # Skip if no date found
    [ -z "$deletion_date" ] && continue

    # Convert deletion date to seconds
    deletion_seconds=$(date -d "$deletion_date" +%s 2>/dev/null)
    [ -z "$deletion_seconds" ] && continue

    # Check if older than 30 days
    age=$((NOW - deletion_seconds))
    if [ "$age" -ge "$DAYS_30" ]; then

        file_path="$FILES_DIR/$base_name"

        # Log entry
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Deleted: $original_path | TrashName: $base_name | DeletedAt: $deletion_date" >> "$LOG_FILE"

        # Remove file or directory
        if [ -e "$file_path" ]; then
            /usr/bin/rm -rf "$file_path"
        fi

        # Remove .trashinfo file
        /usr/bin/rm -f "$info_file"
    fi

done
