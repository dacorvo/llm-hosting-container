# Fetch and extract the optimum-neuron sources
FROM alpine AS optimum-neuron
RUN mkdir -p /optimum-neuron
ADD https://github.com/huggingface/optimum-neuron/archive/refs/tags/v0.3.0.tar.gz /optimum-neuron/sources.tar.gz
RUN tar -C /optimum-neuron -xf /optimum-neuron/sources.tar.gz --strip-components=1

FROM ubuntu:22.04 AS base

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
    python3-pip \
    python3-setuptools \
    python-is-python3 \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean
RUN pip3 --no-cache-dir install --upgrade pip

# Sagemaker base image (used for deployment)
FROM base AS sagemaker

# Install system prerequisites
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
    gnupg2 \
    wget \
    libexpat1 \
    libpython3-dev \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

RUN echo "deb https://apt.repos.neuron.amazonaws.com jammy main" > /etc/apt/sources.list.d/neuron.list
RUN wget -qO - https://apt.repos.neuron.amazonaws.com/GPG-PUB-KEY-AMAZON-AWS-NEURON.PUB | apt-key add -

# Install neuronx packages
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
    aws-neuronx-dkms=2.22.2.0 \
    aws-neuronx-collectives=2.26.43.0-47cc904ea \
    aws-neuronx-runtime-lib=2.26.42.0-2ff3b5c7d \
    aws-neuronx-tools=2.24.54.0 \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

ENV PATH="/opt/bin/:/opt/aws/neuron/bin:${PATH}"

# Install HuggingFace packages
RUN pip3 install \
    hf_transfer huggingface_hub

# Install optimum-neuron
COPY --from=optimum-neuron /optimum-neuron optimum-neuron
RUN cd ./optimum-neuron && pip3 install .[neuronx,vllm] \
    --extra-index-url=https://pip.repos.neuron.amazonaws.com

# HF base env
ENV HUGGINGFACE_HUB_CACHE=/tmp \
    HF_HUB_ENABLE_HF_TRANSFER=1 \
    HF_HUB_USER_AGENT_ORIGIN=aws:sagemaker:neuron:inference:vllm-optimum-neuron

COPY /huggingface/pytorch/vllm-optimum-neuron/sagemaker-entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]

RUN apt-get update && apt-get install -y --no-install-recommends curl unzip \
    && rm -rf /var/lib/apt/lists/*
RUN HOME_DIR=/root && \
    pip install requests && \
    curl -o ${HOME_DIR}/oss_compliance.zip https://aws-dlinfra-utilities.s3.amazonaws.com/oss_compliance.zip && \
    unzip ${HOME_DIR}/oss_compliance.zip -d ${HOME_DIR}/ && \
    cp ${HOME_DIR}/oss_compliance/test/testOSSCompliance /usr/local/bin/testOSSCompliance && \
    chmod +x /usr/local/bin/testOSSCompliance && \
    chmod +x ${HOME_DIR}/oss_compliance/generate_oss_compliance.sh && \
    ${HOME_DIR}/oss_compliance/generate_oss_compliance.sh ${HOME_DIR} python && \
    rm -rf ${HOME_DIR}/oss_compliance*

RUN echo "N.B.: Although this image is released under the Apache-2.0 License, the Dockerfile used to build the image \
    has an indirect documentation dependency on third party <docutils/tools/editors/emacs/rst.el> project. The \
    <docutils/tools/editors/emacs/rst.el> project's licensing includes the <GPL v3> license." > /root/THIRD_PARTY_LICENSES

LABEL dlc_major_version="1"
LABEL com.amazonaws.ml.engines.sagemaker.dlc.framework.huggingface.vllm="true"
LABEL com.amazonaws.sagemaker.capabilities.accept-bind-to-port="true"
