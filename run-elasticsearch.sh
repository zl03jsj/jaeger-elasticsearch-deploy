#!/bin/bash

path=`pwd`/es_data

echo store elasticsearch index at : $path

docker run --privileged -d --name elasticsearch -p 9200:9200 \
    -p 9300:9300 \
    -e "discovery.type=single-node" \
    -v "$path:/usr/share/elasticsearch/data/" \
    elasticsearch:7.12.0

./wait-for-port.sh 9200
