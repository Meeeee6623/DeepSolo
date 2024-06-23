#!/bin/bash

# List of known filenames
declare -a filenames=(
    "clear.py" "fast_rerun_task.sh" "requirements.txt" "tools"
    "configs" "LICENSE" "rerun_task.sh" "train_bw_fast.sh"
    "AdelaiDet.egg-info" "datasets" "output" "train_bw.sh"
    "adet" "demo" "pretrained_backbone" "slurm-runs"
    "build" "eval_film.sh" "README.md" "weights"
    "demo" "finetune_film.sh" "setup.py" "figs"
    "first-training-half" "tmp"
)

# Set the directory for recovered files
RECOVERY_DIR="recovered_files"
mkdir -p "$RECOVERY_DIR"

# Find all dangling blobs and output their hashes
blobs=$(git fsck --no-reflog | grep 'dangling blob' | awk '{print $3}')

# Recover each blob
for blob in $blobs; do
    matched=false
    # Check if blob's hash matches any filename from the list
    for filename in "${filenames[@]}"; do
        if [[ "$blob" == *"$filename"* ]]; then
            # If it matches, save the blob's content into a file in the recovery directory
            git show $blob > "${RECOVERY_DIR}/${filename}"
            echo "Recovered blob $blob as ${filename} in $RECOVERY_DIR"
            matched=true
            break
        fi
    done
    # If no match is found, save the blob with its hash as the filename
    if [ "$matched" == false ]; then
        git show $blob > "${RECOVERY_DIR}/${blob}.txt"
        echo "Recovered unidentified blob $blob to ${RECOVERY_DIR}/${blob}.txt"
    fi
done

echo "Recovery complete. All files are saved in $RECOVERY_DIR/"

