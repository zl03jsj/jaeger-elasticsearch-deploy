#!/bin/sh


main() {
    curl -H'Content-Type:application/json' -d'{
    "query": { "range": { "startTimeMillis": {"lt":"now-2h", "format":"epoch_millis"} } }
    }' -XPOST "$ES_URL_AND_PORT/*-*/_delete_by_query?pretty" 
}

main "$@"
