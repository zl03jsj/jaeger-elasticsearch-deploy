## Deploy jaeger with elaticsearch rollover

jaeger使用elasticsearch作为存储介质,采用rollover的index管理方式来部署比默认的麻烦很多, 用官方的话来说就是:

> Rollover index management strategy is more complex than using the default daily indices and it requires an initialisation job to prepare the storage and two cron jobs to manage indices.

### deploy elasticsearch
following command starts a **single-node** elasticsearch with docker.
```shell
docker run --privileged -d --name elasticsearch -p 9200:9200 \
	-p 9300:9300 \
	-e "discovery.type=single-node" \
	-v "/root/venus-tracer-collector/elastic_search_data:/es_data" \
	elasticsearch:7.12.0
```

### elasticsearch initialize

```shell
docker run -it --rm --net=host \ 
	jaegertracing/jaeger-es-rollover:1.23 init \
	http://localhost:9200
```

### deploy jaeger-all-in-one

```shell
docker run -it --rm --net=host \
	-e SPAN_STORAGE_TYPE=elasticsearch \
  -e ES_SERVER_URLS=http://192.168.1.125:9200 \
  -v /home/venus-message-tracer/esdata:/esdata \
  -p 5775:5775/udp \
  -p 6831:6831/udp \
  -p 6832:6832/udp \
  -p 5778:5778 \
  -p 16686:16686 \
  -p 14268:14268 \
  -p 14250:14250 \
  -p 9411:9411 \
	jaegertracing/all-in-one:1.23 \
	--es.use-aliases=true
```

### rollover to new index
```shell
docker run -it --rm --net=host \ 
	-e CONDITIONS='{"max_age": "5h"}' \
	jaegertracing/jaeger-es-rollover:latest rollover \
	http://192.168.1.125:9200 
```
删除老的index别名(可选, 在clean数据的时候也会被清除掉)
```shell
docker run -it --rm --net=host \
	-e UNIT=hours \
	-e UNIT_COUNT=5 \
	jaegertracing/jaeger-es-rollover:latest lookback \
	http://192.168.1.125:9200
```
### remove old index data
```shell
docker run -it --rm --net=host \
	-e ROLLOVER=true \
	jaegertracing/jaeger-es-index-cleaner:latest 10 \
	http://192.168.1.125:9200
```

### One-click  scripts

#### installation



#### start up



#### shut down



### reference

[jaegertracing-using-elasticsearch-rollover-to-manage-indices](https://medium.com/jaegertracing/using-elasticsearch-rollover-to-manage-indices-8b3d0c77915d)
[jaeger deployment official document](https://www.jaegertracing.io/docs/1.23/deployment/)
[jaeger github repo](https://github.com/jaegertracing/jaeger)
[jaeger elasticsearch索引管理策略化](https://www.jaegertracing.io/docs/1.23/deployment/#elasticsearch-ilm-support)

