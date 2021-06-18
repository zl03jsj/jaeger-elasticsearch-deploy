#!/bin/bash

set -eo pipefail

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

start_container elasticsearch
start_container jaeger-elk
