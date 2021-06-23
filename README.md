## Deploy jaeger with elaticsearch rollover

jaeger使用elasticsearch作为存储介质,采用rollover的index管理方式来部署比默认的麻烦很多, 用官方的话来说就是:

> Rollover index management strategy is more complex than using the default daily indices and it requires an initialisation job to prepare the storage and two cron jobs to manage indices.

### deploy elasticsearch

following command starts a **single-node** elasticsearch with docker.
~~`docker run --privileged -d --name elasticsearch -p 9200:9200 \
	-p 9300:9300
	-e "discovery.type=single-node"
	-v "/root/venus-tracer-collector/elastic_search_data:/es_data"
	elasticsearch:7.12.0`~~

`python3 ./es_rollover.py init $(elasticsearch_url)`

这里的es_rollover.py请参考后面的:[rollover to new index 方法二](#rollover_nex_idx_2)

**es_rollover.py init依赖jaeger项目中的命令:`esmapping-generator`, 所以没办法直接使用.**

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

- 方法一(deprecated, 由于默认会删除jaeger-service-indcas,导致查询不可用, 推荐使用方法二)
  **jaeger-service-indcas** <font color=red>是被监控的程序启动时像jaeger注册自己后产生的indcas, 
  由于服务并不会一直重启,所以这个索引的数据量并不大,
  并且一旦删除之后, 如果服务没有重新注册, 就会导致数据库中关于这个服务的索引不可用,
  所以我们的应用场景中,并不应该rollover这个索引, 也不应该定期删除这个索引.
  </font>

  ```shell
  docker run -it --rm --net=host \ 
    -e CONDITIONS='{"max_age": "5h"}' \
    jaegertracing/jaeger-es-rollover:latest rollover \
    http://192.168.1.125:9200 
```
  删除老的index别名(可选, 在执行后面的es_clean时,会也会被删除掉)
    ```shell
		docker run -it --rm --net=host \
		-e UNIT=hours \
		-e UNIT_COUNT=5 \
			jaegertracing/jaeger-es-rollover:latest lookback \
		http://192.168.1.125:9200
```
- <span id='rollover_nex_idx_2'>方法二</span>

  根据上面的分析, 我们不太需要重建jaeger-service的索引, 但官方打包的docker image中并没有合适的选项对其进行控制,所以直接修改[esRollOver.py](https://raw.githubusercontent.com/jaegertracing/jaeger/master/plugin/storage/es/esRollover.py)的源代码为[es_rollover.py](https://raw.githubusercontent.com/zl03jsj/jaeger-elasticsearch-deploy/master/es_rollover.py),去掉了rollover jaeger-service indicas的部分.

  在需要rollover的时候直接调用:
  ```shell
  export CONDITIONS='{"max_age": "'${max_age}'"}'
  python3 ./es_rollover.py rollover ${elasticsearch_url}
  ```

### remove old index data

下面删除elasticsearch的方法个人不推荐了, 这个jaeger-es-index-cleaner并不支持删除时,分,秒等单位的index, 只支持按day来创建的索引.
如果我们的index只需要保持几个小时, 这个方法就没办法删除.
  ```shell
docker run -it --rm --net=host \
	-e ROLLOVER=true \
	jaegertracing/jaeger-es-index-cleaner:latest 10 \
	http://192.168.1.125:9200
  ```

<font color=green weight=20 size=5>推荐这个方法:</font>
个人从[jaeger-es-index-cleaner](https://github.com/jaegertracing/jaeger/blob/master/plugin/storage/es/esCleaner.py)的仓库fork了一个 [es_cleaner.py](https://raw.githubusercontent.com/zl03jsj/jaeger-elasticsearch-deploy/master/es_cleaner.py), 使用时, 需要安装python3和相关的依赖包:

```shell
yum install python3 
```

安装依赖包:`elasticsearch` and `elasticsearch-curator`
```shell
pip3 install elasticsearch elasticsearch-curator
```

执行脚本删除第count个index之前的所有索引:
```shell
python3 ./es_cleaner.py 3 localhost:9200
```
假设索引是按每2个小时一次rollover的, 指定数字3, 表示删除除最近3个索引之前的所有索引(**每个索引表示2个小时, 则是保存最近4-6小时的索引**)

#### 便捷部署和管理

在[jaeger-elasticsearch-deploy](https://github.com/zl03jsj/jaeger-elasticsearch-deploy.git)中编写了部署和管理jaeger 使用elasticsearch作为存储方案的相关脚本.具体使用方法:

1. 下载脚本库
```git clone https://github.com/zl03jsj/jaeger-elasticsearch-deploy.git```
2. 启动elasticsearch, 默认端口为:9200
```./start-service.sh elasticsearch```
3. 初始化elasticsearch为rollover模式.
```./es_rollover_init.sh```
4. 修改配置文件`rollover_configurations`
`...
unit=hours
unit_count=2
del_lastcount=3
...
`
- unit: elasticsearch创建索引的单位为(seconds, minutes, hours, days)

- unit_count:每unit_count个unit创建一个索引文件,文件中默认为3小时创建一个索引文件

- del_lastcount:在删除时, 保存2个最近的索引文件, 比最近两个更旧的索引都会被删除.

5. 根据前面的配置rollover一个新的索引:
```./es_rollover_new_idx.sh```
5. 添加定时任务管理elasticsearch的索引
这里, unit=hours, unit_count=2所以编译:
```crontab -e```
添加内容:
```* */2 * * * sh /root/jaeger-elasticsearch-deploy/es_crontab.sh```
 es_crontab.sh就会每2小时自动执行一次, 
并完成下面的工作:
- rollover一个新的index文件, 如果最近的index文件没有操作3小时, 则忽略.
- 删除最近2(del_lastcount=3)个index文件之前的所有index(每个index保存2个小时的数据, 之前又创建了一个新的, 所以会删除3-6个小时之前的所有index)
6. 启动jaeger服务
```./start-service.sh jaeger-elk```
7. 启动需要监控的服务.

### reference

[jaegertracing-using-elasticsearch-rollover-to-manage-indices](https://medium.com/jaegertracing/using-elasticsearch-rollover-to-manage-indices-8b3d0c77915d)
[jaeger deployment official document](https://www.jaegertracing.io/docs/1.23/deployment/)
[jaeger github repo](https://github.com/jaegertracing/jaeger)
[jaeger elasticsearch索引管理策略化](https://www.jaegertracing.io/docs/1.23/deployment/#elasticsearch-ilm-support)

[python curator document](https://curator.readthedocs.io/en/latest/index.html)
[Where did all my spans go](https://medium.com/jaegertracing/where-did-all-my-spans-go-a-guide-to-diagnosing-dropped-spans-in-jaeger-10d9697f8182)
