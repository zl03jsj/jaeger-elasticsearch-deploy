#!/bin/sh
ES_URL_AND_PORT=192.168.1.189:9200

main() {
    curl -H'Content-Type:application/json' -d'{
    "query": { "range": { "startTimeMillis": {"lt":"now-2h", "format":"epoch_millis"} } }
    }' -XPOST "$ES_URL_AND_PORT/*-*/_delete_by_query?pretty" 
}

main "$@"
