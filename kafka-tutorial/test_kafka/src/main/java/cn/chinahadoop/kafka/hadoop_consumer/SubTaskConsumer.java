package cn.chinahadoop.kafka.hadoop_consumer;

import java.io.IOException;

import org.apache.hadoop.fs.FSDataOutputStream;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;

import kafka.consumer.ConsumerIterator;
import kafka.consumer.KafkaStream;

public class SubTaskConsumer implements Runnable {
    private KafkaStream m_stream;
    private int m_threadNumber;
    FileSystem hdfs;
    public SubTaskConsumer(KafkaStream a_stream, int a_threadNumber,FileSystem fs) {
        m_threadNumber = a_threadNumber;
        m_stream = a_stream;
        hdfs = fs;
        System.out.println("come in 11111111");
    }

    public void run() {
    	Path path = new Path("/user/shen/tt/test.txt");
		// writing
		try {
			FSDataOutputStream dos = hdfs.create(path);
			ConsumerIterator<byte[], byte[]> it = m_stream.iterator();
	        while (it.hasNext()){
	        	byte[] by = it.next().message();
	        	dos.write(by);
	            System.out.println("Thread " + m_threadNumber + ": " + new String(by) +"-id:"+Thread.currentThread().getId());
	        }
	        System.out.println("Shutting down Thread: " + m_threadNumber);
			dos.flush();
			dos.close();
			hdfs.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
       
    }
}