#!/bin/bash

docker run -it --rm --net=host -e ROLLOVER=true jaegertracing/jaeger-es-index-cleaner:latest 0 http://localhost:9200
