#!/bin/bash
model_id=${1:-unsloth/Llama-3.2-1B-Instruct}
batch_size=${2:-1}
tensor_parallel_size=${3:-2}
sequence_length=${4:-4096}

docker run -it -p 8080:8080 \
    --privileged \
    -e HF_TOKEN=$(cat ~/.cache/huggingface/token) \
    -e SM_VLLM_MODEL=${model_id} \
    -e SM_VLLM_MAX_NUM_SEQS=${batch_size} \
    -e SM_VLLM_TENSOR_PARALLEL_SIZE=${tensor_parallel_size} \
    -e SM_VLLM_MAX_MODEL_LEN=${sequence_length} \
    vllm-optimum-neuron:0.3.0
