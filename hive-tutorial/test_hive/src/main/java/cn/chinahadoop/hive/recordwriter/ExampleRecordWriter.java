package cn.chinahadoop.hive.recordwriter;

import java.io.IOException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.hadoop.fs.FSDataOutputStream;
import org.apache.hadoop.hive.ql.exec.FileSinkOperator.RecordWriter;
import org.apache.hadoop.io.Writable;

import cn.chinahadoop.hive.recordreader.ExampleRecordReader;

public class ExampleRecordWriter implements RecordWriter {
	private static final Log logger=LogFactory.getLog(ExampleRecordWriter.class);
	private FSDataOutputStream out;
	private final String DOC_START = "<DOC>";
	private final String DOC_END = "</DOC>";

	public ExampleRecordWriter(FSDataOutputStream o) {
		this.out = o;
	}

	@Override
	public void close(boolean abort) throws IOException {
		out.flush();
		out.close();
	} 
	
	@Override
	public void write(Writable wr) throws IOException {
		logger.info("welcome recordWriter ............");
		System.out.println("welcome recordWriter ............");
		write(DOC_START);
		write("\n");
		write(wr.toString());
		write("\n");
		write(DOC_END);
		write("\n");
	}

	private void write(String str) throws IOException {
		out.write(str.getBytes(), 0, str.length());
	}
	

}