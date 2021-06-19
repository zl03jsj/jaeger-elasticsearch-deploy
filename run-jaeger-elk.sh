#!/bin/bash

source ./rollover_configurations

echo es_server_urls=$elasticsearch_url

docker run --privileged -d --name jaeger-elk \
    -e SPAN_STORAGE_TYPE=elasticsearch \
    -e ES_SERVER_URLS=$elasticsearch_url \
    -p 5775:5775/udp \
    -p 6831:6831/udp \
    -p 6832:6832/udp \
    -p 5778:5778 \
    -p 16686:16686 \
    -p 14268:14268 \
    -p 14250:14250 \
    -p 9411:9411 \
    jaegertracing/all-in-one:1.23 \
    --es.use-aliases=true

./wait-for-port.sh 6831
