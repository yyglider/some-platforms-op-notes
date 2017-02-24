package cn.chinahadoop.kafka.consumer;

import kafka.consumer.ConsumerIterator;
import kafka.consumer.KafkaStream;

public class SubTaskConsumer implements Runnable {
    private KafkaStream m_stream;
    private int m_threadNumber;
    public SubTaskConsumer(KafkaStream a_stream, int a_threadNumber) {
        m_threadNumber = a_threadNumber;
        m_stream = a_stream;
    }

    public void run() {
    	ConsumerIterator<byte[], byte[]> it = m_stream.iterator();
        while (it.hasNext()){
        	byte[] by = it.next().message();
            System.out.println("Thread " + m_threadNumber + ": " + new String(by) +"-id:"+Thread.currentThread().getId());
        }
        System.out.println("Shutting down Thread: " + m_threadNumber);  
    }
}