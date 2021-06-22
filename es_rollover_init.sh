#!/bin/bash

source ./rollover_configurations

#docker run --privileged --name esrollover -it --rm --net=host \
#    jaegertracing/jaeger-es-rollover:1.23 \
#    init $elasticsearch_url

esmapgenFile=$GOBIN/esmapping-generator

if [ ! -f "$esmapgenFile" ]; then
  go get github.com/jaegertracing/jaeger/cmd/esmapping-generator@v1.23.0
fi

# 需要编译esmapping-generator,所以没办法直接使用
python3 ./es_rollover.py init ${elasticsearch_url}

