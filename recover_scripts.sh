#!/bin/bash

# Define the directory containing the files and the target directory
SOURCE_DIR="recovered_files"
TARGET_DIR="${SOURCE_DIR}/scripts"

# Create the target directory if it does not exist
mkdir -p "$TARGET_DIR"

# Process each .txt file in the source directory
for file in "$SOURCE_DIR"/*.txt; do
    if [ -f "$file" ]; then  # Check if it is a file and not an empty pattern
        # Check for the presence of 'import' or 'bin' in the file
        if grep -E "import|bin" "$file" > /dev/null; then
            # Move the file to the target directory if a match is found
            mv "$file" "$TARGET_DIR"
            echo "Moved $file to $TARGET_DIR"
        fi
    fi
done

echo "Processing complete. Check $TARGET_DIR for scripts."

