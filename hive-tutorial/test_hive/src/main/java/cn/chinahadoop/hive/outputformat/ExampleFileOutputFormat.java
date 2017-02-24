package cn.chinahadoop.hive.outputformat;

import java.io.IOException;
import java.util.Properties;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.hadoop.fs.FSDataOutputStream;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.hive.ql.exec.FileSinkOperator.RecordWriter;
import org.apache.hadoop.hive.ql.io.HiveOutputFormat;
import org.apache.hadoop.io.Writable;
import org.apache.hadoop.io.WritableComparable;
import org.apache.hadoop.mapred.JobConf;
import org.apache.hadoop.mapred.Reporter;
import org.apache.hadoop.mapred.TextOutputFormat;
import org.apache.hadoop.util.Progressable;

import cn.chinahadoop.hive.recordreader.ExampleRecordReader;
import cn.chinahadoop.hive.recordwriter.ExampleRecordWriter;

@SuppressWarnings({ "rawtypes" })
public class ExampleFileOutputFormat<K extends WritableComparable, V extends Writable>
		extends TextOutputFormat<K, V> implements HiveOutputFormat<K, V> {
	
	private static final Log logger=LogFactory.getLog(ExampleFileOutputFormat.class);
	public ExampleFileOutputFormat(){
		logger.info("ExampleFileOutputFormat1:~~~~~~~~~~~~~~~~~~~~~~");
		System.out.println("ExampleFileOutputFormat1:~~~~~~~~~~~~~~~~~~~~~~");
	}
	
	@Override
	public RecordWriter getHiveRecordWriter(JobConf job, Path outPath,
			Class<? extends Writable> valueClass, boolean isCompressed,
			Properties tableProperties, Progressable progress)
			throws IOException {
		FileSystem fs = outPath.getFileSystem(job);
		FSDataOutputStream out = fs.create(outPath);

		return new ExampleRecordWriter(out);
	}
	
// protected static class IgnoreKeyWriter<K extends WritableComparable, V extends Writable>
//      implements org.apache.hadoop.mapred.RecordWriter<K, V> {
//
//    private final org.apache.hadoop.mapred.RecordWriter<K, V> mWriter;
//
//    public IgnoreKeyWriter(org.apache.hadoop.mapred.RecordWriter<K, V> writer) {
//      this.mWriter = writer;
//    }
//
//    public synchronized void write(K key, V value) throws IOException {
//      this.mWriter.write(null, value);
//    }
//    
//	@Override
//	public void close(Reporter reporter) throws IOException {
//		 this.mWriter.close(reporter);		
//	}
//  }
//
//  @Override
//  public org.apache.hadoop.mapred.RecordWriter<K, V> getRecordWriter(
//      FileSystem ignored, JobConf job, String name, Progressable progress)
//      throws IOException {
//	  logger.info("ExampleFileOutputFormat:getRecordWriter~~~~~~~~~~~~~~~~~~~~~~");
//		System.out.println("ExampleFileOutputFormat:getRecordWriter~~~~~~~~~~~~~~~~~~~~~~");
//    return new IgnoreKeyWriter<K, V>(super.getRecordWriter(ignored, job, name,
//        progress));
//  }
}