#!/bin/bash

docker run --privileged -it --rm --net=host \
    -e CONDITIONS='{"max_age": "60s"}' \
    jaegertracing/jaeger-es-rollover:latest \
    rollover \
    http://localhost:9200
