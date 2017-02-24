package cn.chinahadoop.flume;

import java.util.Map;
import java.util.Properties;

import kafka.javaapi.producer.Producer;
import kafka.producer.KeyedMessage;
import kafka.producer.ProducerConfig;

import org.apache.flume.Channel;
import org.apache.flume.Context;
import org.apache.flume.Event;
import org.apache.flume.EventDeliveryException;
import org.apache.flume.Transaction;
import org.apache.flume.conf.Configurable;
import org.apache.flume.conf.ConfigurationException;
import org.apache.flume.sink.AbstractSink;

public class KafkaSink extends AbstractSink implements Configurable {
	  private String topic;
	  private Producer<String, byte[]>  producer;

	  public void configure(Context context) {
		  topic = context.getString("topic");
			if (topic == null) {
				throw new ConfigurationException("Kafka topic must be specified.");
			}
			Properties props = new Properties();
			//props 外部配置 
			Map<String, String> contextMap = context.getParameters();
			for (String key : contextMap.keySet()) {
				if (!key.equals("type") && !key.equals("channel")) {
					props.setProperty(key, context.getString(key));
					//LOG.info("key={},value={}", key, context.getString(key));
				}
			}
			producer = new Producer<String, byte[]> (new ProducerConfig(props));
	  }

	  @Override
	  public void start() {
	    // Initialize the connection to the external repository (e.g. HDFS) that
	    // this Sink will forward Events to ..
	  }

	  @Override
	  public void stop () {
	    // Disconnect from the external respository and do any
	    // additional cleanup (e.g. releasing resources or nulling-out
	    // field values) ..
	  }

	  public Status process() throws EventDeliveryException {
		  Channel channel = getChannel();
			Transaction tx = channel.getTransaction();
			try {
				tx.begin();
				Event e = channel.take();
				if (e == null) {
					tx.rollback();
					return Status.BACKOFF;
				}
				KeyedMessage<String, byte[]> data = 
						new KeyedMessage<String, byte[]>(topic,e.getBody());
				producer.send(data);
				tx.commit();
				return Status.READY;
			} catch (Exception e) {
				tx.rollback();
				return Status.BACKOFF;
			} finally {
				tx.close();
			}
	  }
	}