#!/bin/bash

#SBATCH --job-name=distributed_pretrain_film                       # Job name
#SBATCH --nodes=4
#SBATCH --output=./training/result-%j.out            # Standard output and error log
#SBATCH --error=./training/error-%j.err              # Error file
#SBATCH --partition=OOD_gpu_32gb         # Specify the GPU partition
#SBATCH --gres=gpu:2                      # Request 2 GPUs
#SBATCH --mem=191844                         # Max memory available for node
#SBATCH --cpus-per-task=16                 # Number of CPU cores per task
#SBATCH --ntasks-per-node=2

hostname

module add cuda/11.1
module add python3/anaconda/2020.02
source activate deepsolo

conda list
module list
which python
python --version

# Set the master node and its port
export MASTER_ADDR=$(scontrol show hostname $SLURM_NODELIST | head -n 1)
export MASTER_PORT=14567

# Set OMP_NUM_THREADS
export OMP_NUM_THREADS=16 # 16 CPU cores per task

# Number of nodes and GPUs per node
NUM_NODES=$SLURM_NNODES
NUM_GPUS_PER_NODE=2

# Total number of GPUs (world size)
WORLD_SIZE=$(($NUM_NODES * $NUM_GPUS_PER_NODE))

# Set the necessary environment variables for torch.distributed
export NCCL_DEBUG=INFO
export NCCL_SOCKET_IFNAME=^docker0,lo

# Run the distributed training script
srun python -m torch.distributed.launch \
    --nproc_per_node=$NUM_GPUS_PER_NODE \
    --nnodes=$NUM_NODES \
    --node_rank=$SLURM_NODEID \
    --rdzv_backend=c10d \
    --rdzv_endpoint=$MASTER_ADDR:$MASTER_PORT \
    tools/train_net.py \
    --config-file configs/R_50/film/train_bw.yaml \
    --num-gpus $WORLD_SIZE \
    --num-machines $NUM_NODES \
    --machine-rank $SLURM_NODEID \
    SOLVER.IMS_PER_BATCH 32