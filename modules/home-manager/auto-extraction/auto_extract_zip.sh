#!/bin/bash

WATCH_DIR="$HOME/Downloads"
MAX_UNZIP_SIZE=100M  # Max size of files to extract
UNZIP_CMD=$(command -v unzip)

inotifywait -m -e create --format '%f' "$WATCH_DIR" | while read NEW_FILE
do
    if [[ "$NEW_FILE" == *.zip ]]; then
        ZIP_NAME="${NEW_FILE%.zip}"  # Remove .zip extension
        TIMESTAMP=$(date +%Y%m%d%H%M%S)  # Unique timestamp to avoid name collision
        SUBFOLDER="$WATCH_DIR/${ZIP_NAME}_$TIMESTAMP"
        ZIP_FILE="$WATCH_DIR/$NEW_FILE"

        # Create the subfolder
        mkdir -p "$SUBFOLDER"

        # Check file size before extraction to prevent zip bombs
        ZIP_SIZE=$(du -sh "$ZIP_FILE" | cut -f1)
        echo "File size: $ZIP_SIZE"
        if [[ $(du -b "$ZIP_FILE" | cut -f1) -gt $(echo "$MAX_UNZIP_SIZE" | numfmt --from=iec) ]]; then
            echo "Error: ZIP file too large, skipping extraction"
            continue
        fi

        # Extract the zip file with size limit and avoid overwriting
        unzip -d "$SUBFOLDER" "$ZIP_FILE"

        # Change permissions of the extracted files to prevent execution
        find "$SUBFOLDER" -type f -exec chmod 0644 {} \;
        find "$SUBFOLDER" -type d -exec chmod 0755 {} \;

        echo "Extracted $NEW_FILE into $SUBFOLDER with non-executable permissions"
    fi
done

