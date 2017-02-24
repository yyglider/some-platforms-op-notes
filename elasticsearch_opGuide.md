###启动和关闭

切换权限
> su - es

启动es
> /home/software/elasticsearch/bin/elasticsearch -d

###集群管理

**关闭所有节点**

> curl -XPOST 'http://168.7.9.134:9200/_shutdown'

**关闭指定节点**

> curl -XPOST 'http://168.7.9.134:9200/_cluster/nodes/nodeId1,nodeId2/_shutdown'

**延迟关闭**

> curl -XPOST 'http://168.7.9.134:9200/_cluster/nodes/_local/_shutdown?delay=10s'

**集群健康查看**
> curl 'http://168.7.9.134:9200/_cat/health?v'

**查看所有的索引**

在ES中索引有两个意思：

- 动词的索引，表示把数据存储到ES中，提供搜索的过程；这期间可能正在执行一个创建搜索的过程。
- 名字的索引，它是ES中的一个存储类型，与数据库类似，内部包含type字段，type中包含各种文档。
> curl '168.7.9.134:9200/_cat/indices?v'

**列出索引名称**

> curl 'http://168.7.9.134:9200/_aliases?pretty=1'

**查看所有索引状态**

> curl 'http://168.7.9.134:9200/_stats?pretty=1'

**列出集群索引**

> curl  'http://168.7.9.134:9200/_cat/indices?pretty=1'

**查看索引大小**

> curl 'http://168.7.9.134:9200/_cat/indices?bytes=kb'

**get all mapping**

> curl -XGET 'http://168.7.9.134:9200/_mapping?pretty=1'

**查看集群线程池**

> curl 'http://168.7.9.134:9200/_cat/thread_pool?v'

**查看磁盘使用情况**

> curl 'http://168.7.9.134:9200/_cat/allocation?v'

**集群健康**

在Elasticsearch集群中可以监控统计很多信息，集群健康(cluster health)。ES中用三种颜色状态表示:green,yellow,red.
Green：所有主分片和副本分片都可用
Yellow：所有主分片可用，但不是所有副本分片都可用
Red：不是所有的主分片都可用


> curl -XGET 'http://168.7.9.134:9200/_cluster/health?pretty=true'


###Rest API中的常用用法
1.数据格式化，当在Rest请求后面添加?pretty时，结果会以Json格式化的方式显示。另外，如果添加?format=yaml结果会以树的形式显示，默认都是Flase.

2.数据易读性，结尾添加?human=true，返回的数据会有很好的可读性

3.常用的DateMath：

	+1h ，表示加上一个一个小时
	-1d，表示减去一天
	/d，表示向一天取整

	y，代表一年
	M，代表一个月
	w，代表一周
	d，代表一天
	h，代表一个小时
	m，代表一分钟
	s，代表一秒钟
	ms，代表毫秒
	

	now+1h，表示当前时间加上一个小时，即一个小时后
	now+1h+1m，表示当前时间加上一个小时零一分钟，即一个小时一分钟后
	now+1h/d，表示当前时间加上一个小时，并向一天取整。
	2015-01-01||+1M/d，2015-01-01加上一个月，并向一天取整

4.返回的***字段*** 过滤

对查询返回的结果进行过滤。所有的API都接受一个参数——filter_path，这个参数支持逗号分隔，可以同时填写多个值。

> curl -XGET '168.7.9.129:9200/_nodes/stats?filter_path=nodes.*.ho*'

###Document API——Elasticsearch的增删改查
Document的API大致可以分为两类：单文档操作和多文档操作。

- 单文档操作：index,get,delete,update，正好就是传统的CRUD

- 多文档操作：multi_get 和 bulk，它们适合批量操作。

**index索引**

- 创建索引
> curl -XPUT '168.7.9.129:9200/ggqq?pretty'

- 插入数据

> curl -XPUT '168.7.9.129:9200/indexname/typename/idname?pretty' -d 
> '{
>   "name": "John Doe"
> }'


- 自动创建索引

如果上面执行操作前，ES中没有这个索引，那么默认会直接创建这个索引；type也会自动创建。也就是说，ES并不需要像传统的数据库事先定义表的结构。ES会把我们指定的文档id做为ID。如果不指定ID，那么就会随机分配一个：

通过在配置文件中设置action.auto_create_index为false，可以关闭自动创建index这个功能。

设置action.auto_create_index为 +aaa*,-bbb*，'+'号意味着允许创建aaa开头的索引，'-'号意味着不允许创建bbb开头的索引。


- 操作类型op_type

ES通过参数op_type提供“缺少即加入”的功能，即如果ES中没有该文档，就进行索引；如果有了，则报错返回。


- ttl文档过期

ES中也可以设置文档自动过期，过期是设置一个正的时间间隔，然后以_timestamp为基准，如果超时，就会自动删除。

- 查询和搜索

> 	curl -XGET 'http://168.7.9.129:9200/twitter/tweet/1'
> 
> 	返回数据为：
> 
> 	{
> 	    "_index" : "twitter",
> 	    "_type" : "tweet",
> 	    "_id" : "1",
> 	    "_version" : 1,
> 	    "found": true,
> 	    "_source" : {
> 	        "user" : "kimchy",
> 	        "postDate" : "2009-11-15T14:12:12",
> 	        "message" : "trying out Elasticsearch"
> 	    }
> 	}

上面返回的数据包括文档的基本内容，_index是索引名称，_type是类型，_id是ID，_version是版本号。_source字段包括了文档的基本内容；found字段代表是否找到。

> 查询范例
> Elasticsearch支持对多索引以及多类型进行查询。
> 
> 比如，下面对某个特定索引的所有类型执行查询，查询user为kimchy的所有类型的文档：
> 
> $ curl -XGET 'http://localhost:9200/twitter/_search?q=user:kimchy'
> 
> 也可以指定某个特定的类型：
> 
> $ curl -XGET 'http://localhost:9200/twitter/tweet,user/_search?q=user:kimchy'
> 
> 当然，对于index来说，也是支持多个Index共同查询的：
> 
> $ curl -XGET 'http://localhost:9200/kimchy,elasticsearch/tweet/_search?q=tag:wow'
> 
> 使用_all也可以表示对所有的索引执行查询：
> 
> $ curl -XGET 'http://localhost:9200/_all/tweet/_search?q=tag:wow'
> 
> 如果忽略索引和类型字段，则表示对所有的索引和类型执行查询：
> 
> $ curl -XGET 'http://localhost:9200/_search?q=tag:wow'


- source过滤

仅返回_source，使用*/{index}/{type}/{id}/_source*可以仅仅返回_source字段，而不必返回过多不必要的信息，浪费网络带宽。

curl -XGET 'http://168.7.9.129:9200/twitter/tweet/1/_source'

如果想要返回特定的字段，可以使用_source_include或者_source_exclude进行过滤。
可以使用逗号分隔来设置多种匹配模式，比如：

> curl -XGET 'http://168.7.9.129:9200/twitter/tweet/1?_source_include=*.id&_source_exclude=entities'

如果希望返回特定的字段，也可以直接写上字段的名称:

> curl -XGET 'http://168.7.9.129:9200/twitter/tweet/1?_source=*.id,retweeted'

- 搜索  

ES提供了两种搜索的方式：请求参数方式 和 请求体方式。

请求参数方式,其中bank是查询的索引名称，q后面跟着搜索的条件：q=*表示查询所有的内容。

> curl '168.7.9.129:9200/gpqq-2016-07-19/_search?q=*&pretty'

请求体方式

> curl -XPOST '168.7.9.129:9200/gpqq-2016-07-19/_search?pretty' -d '
{
  "query": { "match_all": {} }
}'


















