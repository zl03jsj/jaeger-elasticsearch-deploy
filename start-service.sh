#!/bin/bash

set -eo pipefail

if [ $# != 1 ]; then
    echo input a servername'('elasticsearch, jaeger-elk')' to startup..
    exit 0
fi
start_container() {
    if [ $# != 1 ]; then
        echo 'start_container failed, need a(and only) server-name paramater.'
        exit 0
    fi
    name=$1

    if [ ! "$(docker ps -q -f name=$name)" ]; then
        echo container $name not running!

        if [ "$(docker ps -aq -f status=exited -f status=created -f name=$name)" ]; then
            echo start $name
            docker start $name
        else
            echo create container $name
            ./run-$name.sh
        fi
    fi
}

servername=$1

start_container $servername
