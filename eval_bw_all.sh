#!/bin/bash

#SBATCH --job-name=evaluate_bw_datasets                       # Job name
#SBATCH --output=./slurm-runs/result-%j.out            # Standard output and error log
#SBATCH --error=./slurm-runs/error-%j.err              # Error file
#SBATCH --partition=OOD_gpu_32gb          # Specify the GPU partition
#SBATCH --gres=gpu:1                      # Request 1 GPU
#SBATCH --mem=256G                         # Memory total in GB
#SBATCH --ntasks=1                        # Run on a single CPU
#SBATCH --cpus-per-task=16                 # Number of CPU cores per task

hostname

module add cuda/11.1
module add python3/anaconda/2020.02
source activate deepsolo

conda list
module list
which python
python --version

# Evaluate with pretrained model
conda run python tools/train_net.py --config-file configs/R_50/film/train_bw.yaml --eval-only MODEL.WEIGHTS ./weights/res50_pretrain_synth-tt-mlt-13-15-textocr.pth

# Evaluate with finetuned model
conda run python tools/train_net.py --config-file configs/R_50/film/train_bw.yaml --eval-only MODEL.WEIGHTS ./output/bw_train_all/model_final.pth