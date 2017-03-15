spark操作

启动spark
在Master上执行
> /home/software/spark/spark-1.4.0/sbin/start-all.sh

关闭spark
> /home/software/spark/spark-1.4.0/sbin/stop-all.sh

运行自带样例 
可以用 run-example 执行spark自带样例程序，如下：
> ./bin/run-example org.apache.spark.examples.SparkPi

交互运行
> ./bin/spark-shell

Spark Shell中已经默认将SparkContext类初始化为对象sc。用户代码如果需要用到，则直接应用sc即可，否则用户自己再初始化，就会出现端口占用问题，相当于启动两个上下文。

在使用spark-shell时，可以通过 –driver-class-path 选项来指定所依赖的jar文件，多个jar文件之间使用分号”:”分割。


提交到集群
可以用 spark-submit 提交任务到集群执行，如下(这里我们指定了集群URL为spark standalone集群)：


> spark-submit \
> --class 应用程序的类名 \
> --master spark://master:7077 \
> --jars 依赖的库文件,多个包之间用逗号","分割 \
> --executor-memory 2G \
> --total-executor-cores 20 \

spark应用程序的jar包 你的应用程序需要的参数(即main方法的参数)
--master参数指定集群URL，可以是独立集群、YARN集群、Mesos集群，甚至是本地模式。 
见下：master可选值	

| master可选值        | 描述     |
| ------------- |:-------------:|
| spark://host:port     | spark standalone集群，默认端口为7077 |
| yarn     				| YARN集群，当在YARN上运行时，需设置环境变量HADOOP_CONF_DIR指向hadoop配置目录，以获取集群信息|
|mesos://host:port		| Mesos集群，默认端口为5050|
|local					| 本地模式，使用1个核心|
|local[n]				| 本地模式，使用n个核心|
|local[*]				| 本地模式，使用尽可能多的核心|


如果jar包所需的依赖较少，通过--jars手动指定还可以，如果很多，最好使用构建工具打包。需要注意的是，你的spark程序需要打包成jar包，spark-submit会将程序包分发到各个worker节点，同时这些上传到worker节点的文件，需要定时清理，否则会占用许多磁盘空间，如果运行于standalone模式，你可以设置 spark.worker.cleanup.appDataTtl 选项来让spark自动清理这些文件。

其实安装spark不需要安装scala，因为 spark-assembly-1.2.0-hadoop2.4.0.jar 中已经自带了scala库。spark/bin/compute-classpath.sh 会自动将spark自带的库文件(spark-assembly-1.2.0-hadoop2.4.0.jar等)添加到classpath中，因此即使classpath和你的spark应用程序中都没有指定spark库文件路径，你的spark应用程序照样可以执行。

###应用相关(Scala)
#####数据加载与保存
- 从程序中的集合生成
- 从文本文件加载数据

	sc.textFile()默认从hdfs中读取文件，在路径前面加上hdfs://可显式表示从hdfs中读取文件，在路径前面加上file://表示从本地文件系统读。
	如:sc.textFile("hdfs://http://168.7.9.129:50070/test/yaoyuan/input/pom.xml");

	同其他transform算子一样，文本读取操作也是惰性的并由action算子触发，如果发生重新计算，那么读取数据的操作也可能会被再次执行。另外，在spark中超出内存大小的文件同样是可以被处理的，因为spark并不是将数据一次性全部装入内存，而是边装入边计算
- 从数据库加载数据

	spark中可以使用JdbcRDD从数据库中加载数据。spark会将数据从数据库中拷贝到集群各个节点，因此使用JdbcRDD会有初始的拷贝数据的开销。也可以考虑使用sqoop将数据从数据库中迁移到hdfs中，然后从hdfs中读取数据。

将结果写入文本文件
   rdd.saveAsTextFile()用于将RDD写入文本文件。spark会将传入该函数的路径参数作为目录对待，默认情况下会在对应目录输出多个文件，这取决于并行度。如果要将结果写入hdfs的一个文件中，可以这样：rdd.coalesce(1).saveAsTextFile("filename")
