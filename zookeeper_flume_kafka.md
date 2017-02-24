
##zookeper操作

1. 启动ZK服务:       sh bin/zkServer.sh start
2. 查看ZK服务状态:    sh bin/zkServer.sh status
3. 停止ZK服务:       sh bin/zkServer.sh stop
4. 重启ZK服务:       sh bin/zkServer.sh restart

使用 zkCli.sh -server 127.0.0.1:2181 连接到 ZooKeeper 服务，连接成功后，系统会输出 ZooKeeper 的相关环境以及配置信息。

命令行工具的一些简单操作如下：

- 显示根目录下、文件： ls / 使用 ls 命令来查看当前 ZooKeeper 中所包含的内容
- 显示根目录下、文件： ls2 / 查看当前节点数据并能看到更新次数等数据
- 创建文件，并设置初始内容： create /zk "test" 创建一个新的 znode节点“ zk ”以及与它关联的字符串
- 获取文件内容： get /zk 确认 znode 是否包含我们所创建的字符串
- 修改文件内容： set /zk "zkbak" 对 zk 所关联的字符串进行设置
- 删除文件： delete /zk 将刚才创建的 znode 删除

##flume

**基本组成**

- Event：消息的基本单位，由headers和body组成
- Agent：JVM进程，负责将外部来源产生的消息转发到外部的目
的地
- Source：从外部来源读入event，并写入channel
- Channel：event暂存组件，在agent中与用亍临时存储数据的，可以存放在memory、jdbc、file 、自定义。source写入后，event将会一直
保存，直到被sink成功消费。
- Sink：从channel读入event，并写入目的地
- Interceptor：events在写入channel前，会先经过interceptor chain
进行处理，可以修改或丢弃event (参考ChannelProcessor.java)，内置Interceptor：timestamp、host、static、uuid、regex_filter、
regex_extractor
-自定义Interceptor：实现Interceptor接口，参考TimestampInterceptor.java
- 注：一个source可以有多个channel，
但一个sink只能有一个channel

**运行agent命令：**
 
> bin/flume-ng agent --conf conf --conf-file conf/es_and_hdfs.conf --name a1 -Dflume.root.logger=INFO,console  -Dflume.monitoring.type=http -Dflume.monitoring.port=34545 


**配置从kafka读取数据，写入hdfs**

    # example.conf: A single-node Flume configuration
    
    # Name the components on this agent
    a1.sources = r1
    a1.sinks = k1
    a1.channels = c1
    
    # Describe/configure the source
    a1.sources.r1.type = org.apache.flume.source.kafka.KafkaSource
    a1.sources.r1.zookeeperConnect = htzqhadoop-2:2181,htzqhadoop-3:2181,htzqhadoop-4:2181
    a1.sources.r1.topic = flumelog
    
    #interceptor
    a1.sources.r1.interceptors = i1 i2 i3
    a1.sources.r1.interceptors.i1.type = timestamp
    a1.sources.r1.interceptors.i2.type = host
    a1.sources.r1.interceptors.i3.type = static
    a1.sources.r1.interceptors.i3.key = category
    a1.sources.r1.interceptors.i3.value = gpqq
    
    # Describe the sink
    a1.sinks.k1.type = hdfs
    a1.sinks.k1.hdfs.fileType = DataStream
    a1.sinks.k1.hdfs.writeFormat = Text
    a1.sinks.k1.hdfs.miniBlockReplicas = 1
    a1.sinks.k1.hdfs.useLocalTimeStamp = true
    ## HDFS每64M生成log文件 
    a1.sinks.k1.hdfs.rollSize = 64000000
	## 按照event数量滚动生成文件，为0时不采用此策略
    a1.sinks.k1.hdfs.rollCount = 0
	## 按照时间间隔滚动生成文件，为0时不采用此策略
    a1.sinks.k1.hdfs.rollInterval = 0
	##hdfs若性能不佳，调大callTimeout（默认10s），
    ##调大batchSize（每个批次刷新到HDFS上的events数量默认100）
	a1.sinks.k1.hdfs.callTimeout = 120000
	a1.sinks.k1.hdfs.batchSize = 1000	
    ## 必须配置namenode地址？
    a1.sinks.k1.hdfs.path = hdfs://htzqhadoop-1:8020/log/%{category}/%y-%m-%d/
    a1.sinks.k1.hdfs.filePrefix = gpqq.%y-%m-%d
    a1.sinks.k1.hdfs.fileSuffix = .log
    
    # Use a channel which buffers events in memory
    #a1.channels.c1.type = memory
    #a1.channels.c1.capacity = 1000
    #a1.channels.c1.transactionCapacity = 100
    a1.channels.c1.type = file
    a1.channels.c1.checkpointDir = /home/flume/checkpoint
    a1.channels.c1.dataDir = /home/flume/data
    
    # Bind the source and sink to the channel
    a1.sources.r1.channels = c1
    a1.sinks.k1.channel = c1


###flume整合elasticsearch
it seems that Apache Flume 1.6.0 and Elasticsearch 2.0 cant communicate right. 

从github上下载一个第三方的[es-sink](https://github.com/lucidfrontier45/ElasticsearchSink2 "es-sink") ,使用gradle生成lib之后，拷贝到flume安装目录下的lib目录中。同时，删除flume lib中的 guava-*.jar 和 jackson-core-*.jar （They are outdated and newer version are included in Elasticsearch.），并且拷贝elasticsearch lib下的jar包到flume lib下。


配置如下	

    # Describe the elasticsearch sink
    a1.sinks.k2.type=com.frontier45.flume.sink.elasticsearch2.ElasticSearchSink
    a1.sinks.k2.batchSize=1000
    a1.sinks.k2.hostNames = 168.7.9.134:9300,168.7.9.129:9300,168.7.9.135:9300,168.7.9.136:9300
    a1.sinks.k2.indexType = logs
    a1.sinks.k2.indexName = gpqq
    a1.sinks.k2.clusterName = elasticsearch
    a1.sinks.k2.serializer = org.apache.flume.sink.elasticsearch.ElasticSearchIndexRequestBuilderFactory
    a1.sinks.k2.ttl=1d

###flume通过replicating方式整合hdfs sink和es sink
a1.sources = r1
    a1.sinks = k1 k2
    a1.channels = c1 c2
   
    # Describe/configure the source
    a1.sources.r1.type = org.apache.flume.source.kafka.KafkaSource
    a1.sources.r1.zookeeperConnect = htzqhadoop-2:2181,htzqhadoop-3:2181,htzqhadoop-4:2181
    a1.sources.r1.topic = flume_log
    a1.sources.r1.selector.type = replicating
   
    #interceptor
    a1.sources.r1.interceptors = i1 i2 i3
    a1.sources.r1.interceptors.i1.type = timestamp
    a1.sources.r1.interceptors.i2.type = host
    a1.sources.r1.interceptors.i3.type = static
    a1.sources.r1.interceptors.i3.key = category
    a1.sources.r1.interceptors.i3.value = gpqq
   
    # Describe the hdfs sink
    a1.sinks.k1.type = hdfs
    a1.sinks.k1.hdfs.fileType = DataStream
    a1.sinks.k1.hdfs.writeFormat = Text
    a1.sinks.k1.hdfs.miniBlockReplicas = 1
    a1.sinks.k1.hdfs.useLocalTimeStamp = true
    ## HDFS每64M生成log文件
    a1.sinks.k1.hdfs.rollSize = 64000000
    ## 按照event数量滚动生成文件，为0时不采用此策略
    a1.sinks.k1.hdfs.rollCount = 0
    ## 按照时间间隔滚动生成文件，为0时不采用此策略
    a1.sinks.k1.hdfs.rollInterval = 0
    ##hdfs若性能不佳，调大callTimeout（默认10s），
    ##调大batchSize（每个批次刷新到HDFS上的events数量默认100）
    a1.sinks.k1.hdfs.callTimeout = 120000
    a1.sinks.k1.hdfs.batchSize = 1000
    ## 必须配置namenode地址？
    a1.sinks.k1.hdfs.path = hdfs://htzqhadoop-1:8020/log/%{category}/%y-%m-%d/
    a1.sinks.k1.hdfs.filePrefix = gpqq.%y-%m-%d
    a1.sinks.k1.hdfs.fileSuffix = .log
   
    # Describe the elasticsearch sink
    a1.sinks.k2.type=org.apache.flume.sink.elasticsearch.ElasticSearchSink
    a1.sinks.k2.batchSize=1000
    a1.sinks.k2.hostNames = htzqhadoop-1:9300
    a1.sinks.k2.indexType = logs
    a1.sinks.k2.indexName = gpqq
    a1.sinks.k2.clusterName = elasticsearch
    a1.sinks.k2.ttl=2d


    # Use a channel which buffers events in memory
    a1.channels.c2.type = memory
    a1.channels.c2.capacity = 1000
    a1.channels.c2.transactionCapacity = 1000
    a1.channels.c2.keep-alive = 5 
    
    a1.channels.c1.type = file
    a1.channels.c1.checkpointDir = /home/flume/hdfs_checkpoint
    a1.channels.c1.dataDir = /home/flume/hdfs_data
    a1.channels.c1.keep-alive = 5
    
    # Bind the source and sink to the channel
    a1.sources.r1.channels = c1 c2
    a1.sinks.k1.channel = c1
    a1.sinks.k2.channel = c2

##kafka

**基本组成**

- Producer ：消息生产者，就是向Kafka broker发消息的客户端。
- Consumer ：消息消费者，向Kafka broker取消息的客户端。
- Broker ：Kafkacluster 是由多个broker组成，一台Kafka服务器就是一个broker。一个broker可以容纳多个topic。
- Topic ：可以理解为一个队列。
- **Partition**：为了实现扩展性，**一个非常大的topic可以分布到多个broker（服务器）上**，一个topic由多个partition组成，每个partition是一个有序的队列。partition中的每条消息都会被分配一个有序的id（offset）。
- Producer通过Partitioner决定消息发送到哪个Partition
- Consumer消费消息时，**只保证按一个partition中的顺序进行消费，不保证一个topic的整体（多个partition间）的顺序**。
- Consumer Group（CG）: 这是Kafka用来实现一个topic消息的广播（发给所有的consumer）和单播（发给任意一个consumer）的手段。一个topic可以有多个CG。topic的消息会分发给所有的CG，但每个CG只会把消息发给该CG中的一个consumer。如果需要实现广播，只要每个consumer有一个独立的CG就可以了。要实现单播只要所有的consumer在同一个CG。

###运行命令


- 开启zookeeper


> bin/zookeeper-server-start.sh



- 运行broker，在每台机器运行  


> bin/kafka-server-start.sh config/server.properties &



- 创建topic


> bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 3 --partitions 3 --topic my-topic1

- 查看已创建的topic


> bin/kafka-topics.sh --describe --zookeeper clocalhost:2181 --topic my-topic1

- 删除topic


> bin/kafka-topics.sh --zookeeper localhost:2181 --delete --topic my-topic1

- 可以通过list命令查看所有的topic:


> bin/kafka-topics.sh --list --zookeeper localhost:2181

- consumer查看topic内容：


> bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic mytopic1 --from-beginning



- 模拟生产者和消费者

> bin/kafka-console-producer.sh --broker-list localhost:9092 --topic mytopic
> 
> bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic mytopic --from-beginning

###consumer端的java代码实现
> java -cp target/test_kafka-0.0.1-SNAPSHOT.jar com.htsc.kafka.hadoop_consumer.TestHadoopConsumer


> 

    
    import kafka.consumer.ConsumerConfig;
    import kafka.consumer.KafkaStream;
    import kafka.javaapi.consumer.ConsumerConnector;
    
    import java.util.HashMap;
    import java.util.List;
    import java.util.Map;
    import java.util.Properties;
    import java.util.concurrent.ExecutorService;
    import java.util.concurrent.Executors;
    
    public class TestConsumer {
	    private final ConsumerConnector consumer;
	    private final String topic;
	    private  ExecutorService executor;

	    public TestConsumer(String a_zookeeper, String a_groupId, String a_topic) {
		    consumer = kafka.consumer.Consumer.createJavaConsumerConnector(
			createConsumerConfig(a_zookeeper, a_groupId));
		    this.topic = a_topic;	
  		  }
    
	    public void shutdown() {
		    if (consumer != null) consumer.shutdown();
		    if (executor != null) executor.shutdown();
	    }
    
	    public void run(int a_numThreads) {
		    Map<String, Integer> topicCountMap = new HashMap<String, Integer>();
		    topicCountMap.put(topic, new Integer(a_numThreads));
		    Map<String, List<KafkaStream<byte[], byte[]>>> consumerMap = consumer.createMessageStreams(topicCountMap);
		    List<KafkaStream<byte[], byte[]>> streams = consumerMap.get(topic);
		    // 启动所有线程
		    executor = Executors.newFixedThreadPool(a_numThreads);
		    // 开始消费消息
		    int threadNumber = 0;
		    for (final KafkaStream stream : streams) {
			    executor.submit(new SubTaskConsumer(stream, threadNumber));
			    threadNumber++;
		    }
	    }
    
	   	 private static ConsumerConfig createConsumerConfig(String a_zookeeper, String a_groupId) {
		    Properties props = new Properties();
		    props.put("zookeeper.connect", a_zookeeper);
		    props.put("group.id", a_groupId);
		    props.put("zookeeper.session.timeout.ms", "60000");
		    props.put("auto.commit.interval.ms", "1000");
		    props.put("auto.offset.reset","smallest");
		    return new ConsumerConfig(props);
   		 }
    
	     public static void main(String[] args) throws Exception {
		    String zooKeeper = "cmmaster:2181";
		    String topic = "testTopic";
		    String groupId = "testGroup";
		    int threads = Integer.parseInt("1");
		    TestConsumer example = new TestConsumer(zooKeeper, groupId, topic);
		    example.run(threads);
		  }
	}
    