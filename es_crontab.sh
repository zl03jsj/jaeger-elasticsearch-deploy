#!/bin/sh
basePath=`dirname $0`
time=$(date "+%Y-%m-%d %H:%M:%S")

cd $basePath

echo
echo ----------------TASK TIME:$time----------------
./es_rollover_newidx.sh
./es_rollover_rm_oldidx.sh

source ./rollover_configurations

curl -XGET ${elasticsearch_url}'/_cat/indices?v&pretty' | awk 'NR>1{print $3}'

