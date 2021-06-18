#!/bin/bash

docker run -it --rm --net=host \
	jaegertracing/jaeger-es-rollover:1.23 init \
	http://localhost:9200

docker run -d --name jaeger-elk \
  -e SPAN_STORAGE_TYPE=elasticsearch \
  -e ES_SERVER_URLS=http://localhost:9200 \
  -p 5775:5775/udp \
  -p 6831:6831/udp \
  -p 6832:6832/udp \
  -p 5778:5778 \
  -p 16686:16686 \
  -p 14268:14268 \
  -p 14250:14250 \
  -p 9411:9411 \
  jaegertracing/all-in-one:1.23

./wait-for-port.sh 6831
