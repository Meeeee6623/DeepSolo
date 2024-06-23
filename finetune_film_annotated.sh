#!/bin/bash

#SBATCH --job-name=finetune_film_annotated           # Job name
#SBATCH --output=./slurm-runs/result-%j.out            # Standard output and error log
#SBATCH --error=./slurm-runs/error-%j.err              # Error file
#SBATCH --partition=OOD_gpu_32gb          # Specify the GPU partition
#SBATCH --gres=gpu:2                      # Request 1 GPU
#SBATCH --mem=64G                         # Memory total in GB
#SBATCH --ntasks=1                        # Run on a single CPU
#SBATCH --cpus-per-task=48                 # Number of CPU cores per task

# Load any modules or sorce your Python environment here if necessary
# e.g., module load python/3.8
# or source activate your_python_env
module purge
module load cuda/11.1
module load python3/anaconda/2020.02
source activate deepsolo

conda list
which python
python --version

# Execute the Python script with conda run to ensure correct python version is used
conda run python tools/train_net.py --config-file configs/R_50/film_annotated/finetune_film_annotated.yaml --num-gpus 2
