#!/bin/bash

source ./rollover_configurations

#docker run --privileged --name esrollover -it --rm --net=host \
#    jaegertracing/jaeger-es-rollover:1.23 \
#    init $elasticsearch_url

python3 ./es_rollover.py init $(elasticsearch_url)


