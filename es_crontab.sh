#!/bin/sh

basePath=`dirname $0`

cd $basePath

./es_rollover_newidx.sh

./es_rollover_rm_oldidx.sh

