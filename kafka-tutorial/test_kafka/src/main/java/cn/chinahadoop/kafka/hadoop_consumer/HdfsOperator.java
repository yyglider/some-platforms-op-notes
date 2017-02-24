package cn.chinahadoop.kafka.hadoop_consumer;

import java.io.IOException;


import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FSDataOutputStream;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.hdfs.HdfsConfiguration;


public class HdfsOperator {
	static public String fixedPrefix = "/user";
	FileSystem fs;
	Configuration conf;

	public HdfsOperator() {
		conf = new HdfsConfiguration();
		System.out.println(conf.get("fs.hdfs.impl"));
		// Strange, does not take the effect
		// System.setProperty("HADOOP_USER_NAME", "hdfs");
		try {
			fs = FileSystem.get(conf);
			System.out.println(fs.getClass().getName());
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public void createDir() throws IOException {
		FileSystem hdfs = FileSystem.get(new Configuration());
		Path path = new Path("/user/shen/tt/test.txt");

		// writing
		FSDataOutputStream dos = hdfs.create(path);
		byte[] readBuf = "Hello World1111".getBytes("UTF-8");
		dos.write(readBuf, 0, readBuf.length);
		dos.flush();
		dos.close();
		hdfs.close();
	}
	public static void main(String args[]) throws Exception{
		HdfsOperator ho = new HdfsOperator();
		ho.createDir();
	}

}
