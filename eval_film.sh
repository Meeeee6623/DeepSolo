#!/bin/bash

#SBATCH --job-name=eval_film           # Job name
#SBATCH --output=./slurm-runs/result-%j.out            # Standard output and error log
#SBATCH --error=./slurm-runs/error-%j.err              # Error file
#SBATCH --partition=OOD_gpu_32gb          # Specify the GPU partition
#SBATCH --gres=gpu:1                      # Request 1 GPU
#SBATCH --mem=32G                         # Memory total in GB
#SBATCH --ntasks=1                        # Run on a single CPU
#SBATCH --cpus-per-task=16                 # Number of CPU cores per task

# Load any modules or sorce your Python environment here if necessary
# e.g., module load python/3.8
# or source activate your_python_env
hostname
module purge
module load cuda/11.1
module load python3/anaconda/2020.02
source activate deepsolo

conda list
which python
python --version

# Execute the Python script with conda run to ensure correct python version is used
conda run python demo/demo.py --config-file configs/R_50/film/eval_film.yaml --input datasets/film_sample/test_images --output output/film_sample_default --opts MODEL.WEIGHTS ./weights/res50_pretrain_synth-tt-mlt-13-15-textocr.pth 

