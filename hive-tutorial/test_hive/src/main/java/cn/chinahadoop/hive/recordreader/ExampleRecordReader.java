package cn.chinahadoop.hive.recordreader;

import java.io.IOException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapred.FileSplit;
import org.apache.hadoop.mapred.JobConf;
import org.apache.hadoop.mapred.LineRecordReader;
import org.apache.hadoop.mapred.RecordReader;

public class ExampleRecordReader implements RecordReader<LongWritable, Text> {

	private static final Log logger=LogFactory.getLog(ExampleRecordReader.class);
	// Reader
	private LineRecordReader reader;
	// The current line_num and lin
	private LongWritable lineKey = null;
	private Text lineValue = null;
	// Doc related
	private StringBuilder sb = new StringBuilder();
	private boolean inDoc = false;
	private final String DOC_START = "<DOC>";
	private final String DOC_END = "</DOC>";
	
	public ExampleRecordReader(JobConf job, FileSplit split) throws IOException {
		reader = new LineRecordReader(job, split);
		lineKey = reader.createKey();
		lineValue = reader.createValue();
	}
	@Override
	public void close() throws IOException {
		reader.close();
	}
	@Override
	public boolean next(LongWritable key, Text value) throws IOException {
		logger.info("1welcome recordReader ............");
		System.out.println("1welcome recordReader ............");
		while (true) {
			// get current line
			if (!reader.next(lineKey, lineValue)) {
				break;
			}
			if (!inDoc) {
				// not in doc, check if <doc>
				if (lineValue.toString().startsWith(DOC_START)) {
					// reset doc status
					inDoc = true;
					// clean buff
					sb.delete(0, sb.length());
				}
			} else {
				// indoc, check if </doc>
				if (lineValue.toString().startsWith(DOC_END)) {
					// reset doc status
					inDoc = false;
					// set kv and return
					key.set(key.get() + 1);
					value.set(sb.toString());
					return true;
				} else {
					if (sb.length() != 0) {
						sb.append("\n");
					}
					sb.append(lineValue.toString());
				}
			}
		}
		return false;
	}
	@Override
	public float getProgress() throws IOException {
		return reader.getProgress();
	}
	@Override
	public LongWritable createKey() {
		return new LongWritable(0);
	}
	@Override
	public Text createValue() {
		return new Text("");
	}
	@Override
	public long getPos() throws IOException {
		return reader.getPos();
	}

}