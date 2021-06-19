#!/bin/bash

source ./rollover_configurations

display_rollover_configurations

docker run --privileged -it --rm --net=host \
    -e CONDITIONS='{"max_age": "'$max_age'"}' \
    jaegertracing/jaeger-es-rollover:latest \
    rollover \
    $elasticsearch_url
