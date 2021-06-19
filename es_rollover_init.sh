#!/bin/bash

docker run --privileged --name esrollover -it --rm --net=host \
    jaegertracing/jaeger-es-rollover:1.23 \
    init http://localhost:9200
