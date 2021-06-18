#!/bin/bash

while [ `lsof -i:$1 | wc -l` == '0' ];do
    echo waiting for port $1 listen 3 seconds
    sleep 3
done
