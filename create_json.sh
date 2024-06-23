#!/bin/bash

# Define directory containing images
dir="frame_test/video_1"

# Define JSON output file
output_file="vts_test_wo_anno.json"

# Start the JSON file
echo '{ "images": [' > "$output_file"

# Get a list of all JPB files in the directory, sorted numerically
files=($(ls "$dir"/*.jpg | sort -V))

# Initialize ID and frame_id counters
id=1
frame_id=1

# Process each file
for file in "${files[@]}"; do
    file_name=$(basename "$file")
    
    # Construct the JSON entry for each file
    if [ "$id" -eq 1 ]; then
        prev_image_id=-1
    else
        prev_image_id=$((id - 1))
    fi

    next_image_id=$((id + 1))

    # Check if this is the last file
    if [ "$id" -eq "${#files[@]}" ]; then
        next_image_id=-1
    fi

    # Format the JSON string
    json_string='    {
      "file_name": "'"video_1/$file_name"'",
      "id": '"$id"',
      "height": 2048,
      "width": 1556,
      "frame_id": '"$frame_id"',
      "prev_image_id": '"$prev_image_id"',
      "next_image_id": '"$next_image_id"',
      "video_id": 1
    }'

    # Append comma if not the last file
    if [ "$id" -lt "${#files[@]}" ]; then
        json_string="$json_string,"
    fi

    # Write to output file
    echo "$json_string" >> "$output_file"

    # Increment the ID and frame_id
    ((id++))
    ((frame_id++))
done

# Close the JSON array and object
echo '  ]' >> "$output_file"
echo '}' >> "$output_file"

echo "JSON file created: $output_file"

