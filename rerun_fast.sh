#bin/bash

rm -rf fast-slurm-runs/
mkdir fast-slurm-runs/

rm -rf output/fast_bw_train_all/*

sbatch train_bw_fast.sh --exclusive

squeue -u chauhanb

