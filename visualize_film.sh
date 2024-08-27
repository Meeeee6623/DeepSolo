#!/bin/bash

#SBATCH --job-name=visualize_film           # Job name
#SBATCH --output=./slurm-runs/vis-film-result-%j.out            # Standard output and error log
#SBATCH --error=./slurm-runs/vis-film-error-%j.err              # Error file
#SBATCH --partition=OOD_gpu_32gb          # Specify the GPU partition
#SBATCH --gres=gpu:1                      # Request 1 GPU
#SBATCH --mem=32G                         # Memory total in GB
#SBATCH --ntasks=1                        # Run on a single CPU
#SBATCH --cpus-per-task=16                 # Number of CPU cores per task

hostname
module purge
module load cuda/11.1
module load python3/anaconda/2020.02
source activate deepsolo

conda list
which python
python --version

# Visualize with pretrained model
conda run python demo/demo.py --config-file configs/R_50/film/eval_film.yaml --input datasets/film_sample --output output/film_sample_default --opts MODEL.WEIGHTS ./weights/res50_pretrain_synth-tt-mlt-13-15-textocr.pth

# Visualize with finetuned model
conda run python demo/demo.py --config-file configs/R_50/film/eval_film.yaml --input datasets/film_sample --output output/film_sample_finetuned --opts MODEL.WEIGHTS ./weights/bw_model_final.pth
