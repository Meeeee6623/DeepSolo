#!/bin/bash

#SBATCH --job-name=pretrain_film                       # Job name
#SBATCH --output=./training/result-%j.out            # Standard output and error log
#SBATCH --error=./training/error-%j.err              # Error file
#SBATCH --partition=OOD_gpu_32gb         # Specify the GPU partition
#SBATCH --gres=gpu:2                      # Request 2 GPUs
#SBATCH --mem=64G                         # Memory total in GB
#SBATCH --ntasks=1                        # Run on a single CPU
#SBATCH --cpus-per-task=48                 # Number of CPU cores per task

# Load any modules or sorce your Python environment here if necessary
# e.g., module load python/3.8
# or source activate your_python_env
hostname

module add cuda/11.1
module add python3/anaconda/2020.02
source activate deepsolo

conda list
module list
which python
python --version

# Execute the Python script with conda run to ensure correct python version is used
conda run python tools/train_net.py --config-file configs/R_50/film/train_bw.yaml --num-gpus 2 --resume
