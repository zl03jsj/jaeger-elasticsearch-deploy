#!/bin/bash

source ./rollover_configurations

display_rollover_configurations

# remove old indices from read aliases.
# It means that old data will not be available for search.
# This imitates the behavior of --es.max-span-age flag used in the default index-per-day deployment.
# This step could be optional and 
# old indices could be simply removed by index cleaner in the next step.

#echo ------------------------------------
#echo '|'remove old indices from read aliases

#docker run --privileged -it --rm --net=host -e UNIT=$unit -e \
    #UNIT_COUNT=$unit_count \
    #jaegertracing/jaeger-es-rollover:latest lookback \
    #$elasticsearch_url

#echo ------------------------------------
#echo '|'remove old indices from read aliases success!

# Remove indices older than 2*60 seconds

# The historical data can be removed with the jaeger-es-index-cleaner 
# that is also used for daily indices.

echo
echo -----------------------------------
echo '|'remove old history data, last $del_lastcount indexs

docker run --privileged -it --rm --net=host \
    -e ROLLOVER=true \
    jaegertracing/jaeger-es-index-cleaner:latest 1 \
    $elasticsearch_url
