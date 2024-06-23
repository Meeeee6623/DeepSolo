#bin/bash

rm -rf slurm-runs/*

sbatch ./finetune_film.sh --exclusive

squeue -u chauhanb

