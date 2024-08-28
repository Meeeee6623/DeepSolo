#!/bin/bash

#SBATCH --job-name=distributed_pretrain_film    # Job name
#SBATCH --nodes=2                               # Number of nodes
#SBATCH --output=./training/result-%j-%N.out    # Standard output log (per node)
#SBATCH --error=./training/error-%j-%N.err      # Error log (per node)
#SBATCH --partition=OOD_gpu_32gb                # Specify the GPU partition
#SBATCH --gres=gpu:2                            # Request 2 GPUs per node
#SBATCH --mem=191844                            # Max memory available for node
#SBATCH --cpus-per-task=48                      # Number of CPU cores per task
#SBATCH --ntasks-per-node=1                     # Number of tasks (1 per node)

hostname

module add cuda/11.1
module add python3/anaconda/2020.02
source activate deepsolo

conda list
module list
which python
python --version

# Set the master node and its port
export MASTER_ADDR=$(scontrol show hostname "$SLURM_NODELIST" | head -n 1)
export MASTER_PORT=14567

echo "Master url: " "$MASTER_ADDR":$MASTER_PORT

# Set OMP_NUM_THREADS
export OMP_NUM_THREADS=16 # 16 CPU cores per task


# Number of nodes and GPUs per node
NUM_NODES=$SLURM_NNODES
NUM_GPUS_PER_NODE=2

# set 1 image per GPU due to memory constraints...
export TOTAL_GPUS=$((NUM_NODES * NUM_GPUS_PER_NODE * 2))

# Set the necessary environment variables for torch.distributed
export NCCL_DEBUG=INFO
export NCCL_SOCKET_IFNAME=^docker0,lo

# Run the distributed training script on each node independently
for NODE_RANK in $(seq 0 $((NUM_NODES - 1)))
do
    srun --nodes=1 --ntasks=1 --exclusive -w "$(scontrol show hostname "$SLURM_NODELIST" | sed -n "$((NODE_RANK + 1))p")" \
        --output=./training/job_"${SLURM_JOB_ID}"_node_"${NODE_RANK}".out \
        --error=./training/job_"${SLURM_JOB_ID}"_node_"${NODE_RANK}".err \
        conda run python tools/train_net.py \
        --config-file configs/R_50/film/train_bw.yaml \
        --num-gpus="$NUM_GPUS_PER_NODE" \
        --machine-rank="$NODE_RANK" \
        --num-machines="$SLURM_NTASKS" \
        --dist-url "tcp://$MASTER_ADDR:$MASTER_PORT" \
        --resume \
        SOLVER.IMS_PER_BATCH $TOTAL_GPUS &
done

# Wait for all the background jobs to finish
wait
