#!/bin/bash

# Get a list of all files in the current directory, excluding .sh files, sorted alphabetically
files=($(ls | grep -v '\.sh$' | sort))

# Initialize the counter
counter=1

# Loop through each file in the sorted list
for file in "${files[@]}"; do
    # Extract the file extension
    extension="${file##*.}"
    
    # Skip renaming for .sh files
    if [ "$extension" = "sh" ]; then
        continue
    fi

    # Construct the new filename with the counter and original extension
    newname="${counter}.${extension}"

    # Rename the file
    mv -- "$file" "$newname"

    # Increment the counter
    ((counter++))
done

echo "Renaming complete."

