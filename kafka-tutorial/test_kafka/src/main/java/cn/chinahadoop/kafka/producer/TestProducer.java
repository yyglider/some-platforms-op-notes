package cn.chinahadoop.kafka.producer;

import java.util.*;

import kafka.javaapi.producer.Producer;
import kafka.producer.KeyedMessage;
import kafka.producer.ProducerConfig;

public class TestProducer {
    public TestProducer() {
    }

    public static void main(String[] args) {

        long events = Long.parseLong("10");
        Random rnd = new Random();
        Properties props = new Properties();
        props.put("metadata.broker.list", "50.23.114.61:9092");
        props.put("serializer.class", "kafka.serializer.StringEncoder");

        ProducerConfig config = new ProducerConfig(props);

        Producer<String, String> producer = new Producer<String, String>(config);
        System.out.println("welcome producer");
        for (long nEvents = 0; nEvents < events; nEvents++) {
            long runtime = new Date().getTime();
            String key = "192.168.2." + rnd.nextInt(255);
            String msg = runtime + ",abc," + key;
            KeyedMessage<String, String> data = new KeyedMessage<String, String>("testTopic", key, msg);
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            producer.send(data);
        }
        producer.close();
    }
}