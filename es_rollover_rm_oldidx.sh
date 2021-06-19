#!/bin/bash

# remove old indices from read aliases.
# It means that old data will not be available for search.
# This imitates the behavior of --es.max-span-age flag used in the default index-per-day deployment.
# This step could be optional and 
# old indices could be simply removed by index cleaner in the next step.
docker run -it --rm --net=host -e UNIT=seconds -e \
    UNIT_COUNT=2 \
    jaegertracing/jaeger-es-rollover:latest lookback \
    http://localhost:9200

# Remove indices older than 2*60 seconds

# The historical data can be removed with the jaeger-es-index-cleaner 
# that is also used for daily indices.

docker run -it --rm --net=host \
    -e ROLLOVER=true \
    jaegertracing/jaeger-es-index-cleaner:latest 2 \
    http://localhost:9200
