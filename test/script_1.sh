

#!/bin/bash

# Script one

# Details of the source file and target directory.
SOURCE_FILE="test.sh"
TARGET_DIR="Dir1"
LOG_FILE="error.log"

# Check for the source file.
if [ -f "$SOURCE_FILE" ]; then
    # Attempt to copy the file to the target directory
    cp "$SOURCE_FILE" "$TARGET_DIR"
else
    # Log an error message if the file does not exist
    echo "Mentioned file not found. Check the spelling." >> "$LOG_FILE"
fi