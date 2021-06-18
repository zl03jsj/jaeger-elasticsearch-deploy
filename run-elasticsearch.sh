#!/bin/bash

set -x

path=`pwd`/es_data

if [ ! -d "$path" ]; then
    mkdir -p $path
fi

docker run -d --name elasticsearch -p 9200:9200 \
    -p 9300:9300 \
    -e "discovery.type=single-node" \
    -v "$path:/es_data" \
    elasticsearch:7.12.0

./wait-for-port.sh 9200
