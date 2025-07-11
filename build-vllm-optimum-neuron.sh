#!/bin/sh

version=${1:-0.3.0}
docker build --rm \
    -f huggingface/pytorch/vllm-optimum-neuron/${version}/Dockerfile \
    -t vllm-optimum-neuron:${version} .
