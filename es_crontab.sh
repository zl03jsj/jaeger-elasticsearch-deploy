#!/bin/sh

time=$(date "+%Y-%m-%d %H:%M:%S")
echo rollover_newidx at time=$time >> cron.log
./es_rollover_newidx.sh

echo rollover rm old index at time=$time >> cron.log
./es_rollover_rm_oldidx.sh

echo >> cron.log

