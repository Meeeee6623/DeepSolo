#!/bin/bash
#SBATCH --job-name=distributed_pretrain_film  # Job name
#SBATCH --nodes=5                             # Number of nodes
#SBATCH --output=./training/result-%j.out     # Standard output and error log
#SBATCH --error=./training/error-%j.err       # Error file
#SBATCH --partition=OOD_gpu_32gb              # Specify the GPU partition
#SBATCH --gres=gpu:2                          # Request 2 GPUs per node
#SBATCH --mem=191844                          # Max memory available for node
#SBATCH --cpus-per-task=16                    # Number of CPU cores per task
#SBATCH --ntasks-per-node=2                   # Number of tasks per node
#SBATCH --nodelist=node402,node403,node404,node405,node406  # Specific nodes

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
NUM_NODES=5
NUM_GPUS_PER_NODE=2

# Total number of GPUs (world size)
WORLD_SIZE=$(($NUM_NODES * $NUM_GPUS_PER_NODE))

# Set the necessary environment variables for torch.distributed
export NCCL_DEBUG=INFO
export NCCL_SOCKET_IFNAME=^docker0,lo

# Determine node rank based on hostname
if [ "$(hostname)" == "node402" ]; then
    NODE_RANK=0
elif [ "$(hostname)" == "node403" ]; then
    NODE_RANK=1
elif [ "$(hostname)" == "node404" ]; then
    NODE_RANK=2
elif [ "$(hostname)" == "node405" ]; then
    NODE_RANK=3
elif [ "$(hostname)" == "node406" ]; then
    NODE_RANK=4
else
    echo "Unknown host: $(hostname)"
    exit 1
fi

echo "SLURM_NODEID: $SLURM_NODEID"
echo "NODE_RANK: $NODE_RANK"

# Run the distributed training script
srun conda run python -m torch.distributed.run \
    --nproc_per_node=$NUM_GPUS_PER_NODE \
    --nnodes=$NUM_NODES \
    --node_rank=$NODE_RANK \
    --rdzv_backend=c10d \
    --rdzv_endpoint="$MASTER_ADDR:$MASTER_PORT" \
    tools/train_net.py \
    --config-file configs/R_50/film/train_bw.yaml \
    --num-gpus $WORLD_SIZE \
    --num-machines $NUM_NODES \
    --machine-rank $NODE_RANK \
    SOLVER.IMS_PER_BATCH 16
