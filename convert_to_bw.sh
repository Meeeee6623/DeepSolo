#!/bin/bash

base_dir="."

# Find directories with 'images' in their name, excluding 'raw' directories
find "$base_dir" -type d -name '*images*' -not -path '*/raw/*' | while read dir; do
    # Create a temporary Slurm script
    cat > temp_slurm_script.sh <<EOF
#!/bin/bash
#SBATCH --job-name=convert_bw
#SBATCH --output=convert_bw_%j.out
#SBATCH --ntasks=1
#SBATCH --mem=1000

# Load the ffmpeg module, if available
module load ffmpeg 

# Navigate to the specific directory
cd "$dir"

# Convert all images to black and white using ffmpeg
for file in \$(find . -type f -name '*.jpg' -o -name '*.png'); do
    ffmpeg -y -i "\$file" -vf format=gray "\$file"
done
EOF

    # Submit the job to Slurm
    sbatch temp_slurm_script.sh

    # Clean up the temporary Slurm script
    rm temp_slurm_script.sh
done

squeue -u chauhanb
