#!/bin/sh

repeat=${1:-1}
max_new_tokens=${2:-128}

for i in $(seq ${repeat}); do
curl 127.0.0.1:8080/v1/completions \
    -H 'Content-Type: application/json' \
    -X POST \
    -d '{"prompt":"One of my fondest memory is", "temperature": 0.8, "max_tokens":'${max_new_tokens}'}'
    echo "\nRequest ${i} completed."
done
