package cn.chinahadoop.kafka.hadoop_consumer;
import kafka.consumer.ConsumerConfig;
import kafka.consumer.KafkaStream;
import kafka.javaapi.consumer.ConsumerConnector;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.hdfs.HdfsConfiguration;

public class TestHadoopConsumer {
    private final ConsumerConnector consumer;
    private final String topic;
    private  ExecutorService executor;
    private FileSystem hdfs;
    public TestHadoopConsumer(String a_zookeeper, String a_groupId, String a_topic) {
        consumer = kafka.consumer.Consumer.createJavaConsumerConnector(
                createConsumerConfig(a_zookeeper, a_groupId));
        this.topic = a_topic;
        try {
			hdfs = FileSystem.get(new HdfsConfiguration());
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
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
            executor.submit(new SubTaskConsumer(stream, threadNumber,hdfs));
            threadNumber++;
        }
    }

    private static ConsumerConfig createConsumerConfig(String a_zookeeper, String a_groupId) {
        Properties props = new Properties();
        props.put("zookeeper.connect", a_zookeeper);
        props.put("group.id", a_groupId);
        props.put("zookeeper.session.timeout.ms", "60000");
        props.put("zookeeper.sync.time.ms", "2000");
        props.put("auto.commit.interval.ms", "1000");
        props.put("auto.offset.reset","smallest");
        return new ConsumerConfig(props);
    }

    public static void main(String[] args) throws Exception {
    	if(args.length<2){
    		throw new Exception("At least two parameters:1 topic_name,2:group_name");
    	}
    	//zookeeper 地址，多个可用“,”相隔，如 192.168.0.20,192.168.1.21
        String zooKeeper = "50.23.114.61:2181";
    	 //String zooKeeper = "192.168.1.101:2181";
        String topic = "testTopic";
        String groupId = "testGroup";
        int threads = Integer.parseInt("1");
        TestHadoopConsumer example = new TestHadoopConsumer(zooKeeper, groupId, topic);
        example.run(threads);
    }
}