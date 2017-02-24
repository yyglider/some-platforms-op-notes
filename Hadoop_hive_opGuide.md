
##Hadoop
注意：所有操作均在Hadoop部署目录下进行。
#### 启动Hadoop集群
- Step1 :在各个JournalNode节点上(htzqhadoop-2,htzqhaodop-3,htzqhadoop-4)，输入以下命令启动journalnode服务:

    > sbin/hadoop-daemon.sh start journalnode

	journalnode用于存储namenode的操作日志，所有的更新操作都会写到JN节点的共享目录中，这格式有dfs.namenode.shared.edits.dir配置。activenn和standbynn从jn的edits的共享目录中同步edits到自己的edits目录中。activenn在文件系统被修改时，会向JournalNode写入修改记录，而standbynn可以方便的读取到这样的修改记录。

	hadoop/etc/hadoop/hdfs-site.xml中可以看到journalNode数据存放的目录地址。主备nn同步元信息的共享存储目录

> 	<property>
> 		<name>dfs.namenode.shared.edits.dir</name>
> 		<value>qjournal://htzqhadoop-2:8485;htzqhadoop-3:8485;htzqhadoop-4:8485/hadoop-htzq</value>
> 	</property>
> 
> 	journalnode数据本地存放位置
> 	<property>
> 		<name>dfs.journalnode.edits.dir</name>
> 		<value>/home/hadoop/dfs_journal/</value>
> 	</property>



- Step2:（首次使用）在[nn1]上，对其进行格式化并启动：
> 	首次操作时bin/hdfs namenode -format
> 	namenode fsiamge存放目录
> 	<property>
> 	   <name>dfs.namenode.name.dir</name>
> 	   <value>file:///home/hadoop/dfs_name</value>
> 	</property>
>   **启动namenode**
>   
> sbin/hadoop-daemon.sh start namenode

- Step3:在[nn2]上，同步nn1的元数据信息：
>  bin/hdfs namenode -bootstrapStandby

- Step4:启动[nn2]：
>  sbin/hadoop-daemon.sh start namenode
> 
经过以上四步操作，nn1和nn2均处理standby状态

- Step5: 将[nn1]切换为Active
> bin/hdfs haadmin -transitionToActive htzqhadoop-1

- Step6: 在[nn1]上，启动所有datanode
> sbin/hadoop-daemons.sh start datanode

####关闭Hadoop集群：
在[nn1]上，输入以下命令
> sbin/stop-dfs.sh

####启动YARN:
> sbin/start-yarn.sh
####停止YARN:
> sbin/stop-yarn.sh

####启动jobhistroy server
JobHistory Server，这是一个独立的服务，可通过web UI展示历史作业日志，之所以将其独立出来，是为了减轻ResourceManager负担。通常可以启动在一台独立的机器上，你需在*mapred-site.xml*中对其进行配置。Server将会分析作业运行日志，并展示作业的启动时间、结束时间、各个任务的运行时间，各种Counter数据等，并产生一个指向作业和任务日志的链接。

	mapred-site.xml
	<property>
	  <name>mapreduce.jobhistory.webapp.address</name>
	  <value>htzqhadoop-2:19888</value>
	  <description>MapReduce JobHistory Server Web UI host:port</description>
	</property>

	即，通过http://168.7.9.134:19888/jobhistory访问

在N2上启动 jobserver：
> sbin/mr-jobhistroy-daemon.sh start historyserver





##HDF操作

> sudo -u hadoop ./hdfs dfs -mkdir /user/'root'
> 
> hdfs dfs -chown -R 'root':hadoop /user/'root';


##MR 作业提交

###创建一个maven项目
> mvn -B archetype:generate \
>  -DarchetypeGroupId=org.apache.maven.archetypes \
>  -DgroupId=com.htzq.wordcount \
>  -DartifactId=wordcount
###构建
> mvn package
###提交job到hadoop集群
> hadoop jar target/my-app-1.0-SNAPSHOT.jar com.mycompany.app.App INPUT_PATH OUTPUT_PATH
###清除
> mvn clean
###运行本地任务
> java -cp target/my-app-1.0-SNAPSHOT.jar com.htzq.app.App


##Hive
###mysql 安装

安装

	sudo yum install mysql-server
	sudo service mysqld start
    sudo /sbin/chkconfig mysqld on （设置自启劢）

	设置root密码("hadoop123")
    sudo /usr/bin/mysql_secure_installation

	创建数据库
	mysql -u root -p
	CREATE DATABASE hive;
	
	创建hive用户,并授权
	grant all on hive.* to hive@'%'  identified by 'password';  
	flush privileges;  

配置mysql驱动包（用mysql做metastore时）

	wget http://115.28.73.167/software/mysql-connector-java-5.1.34-bin.jar

	cp mysql-connector-java-5.1.34-bin.jar /usr/lib/hive/lib/

mysql中查看hive的表
	
	use hive;
	show tables;
	select * from TBLS;

###hive安装
1. 在/etc/profile 中配置环境变量

2. 重命名hive-default.xml.templat -> hive-site.xml

3. 更改hive-site.xml相关配置

		<property>
			<name>javax.jdo.option.ConnectionURL</name>
			<value>jdbc:mysql://DX2-1:3306/hive?characterEncoding=UTF-8</value>
		</property>
		<property>
			<name>javax.jdo.option.ConnectionDriverName</name>
			<value>com.mysql.jdbc.Driver</value>
		</property>
		<property>
			<name>javax.jdo.option.ConnectionUserName</name>
			<value>hive</value>
		</property>
		<property>
			<name>javax.jdo.option.ConnectionPassword</name>
			<value>password</value>
		</property>
		<property>
			<name>hive.metastore.warehouse.dir</name>
			<!-- base hdfs path -->
			<value>/user/hive/warehouse</value>
			<description>location of default database for the warehouse</description>
		</property>
###hive操作
注：如果hdfs集群是在hadoop用户下创建的，那么登陆hive时也需要使用hadoop用户。

使用本地模式（local mode）运行
> Hive

Beeline 方式：

开启meatedata 服务
> sudo service hive-metastore start

开启HiveServer2 服务
> sudo service hive-server2 start

并用BeeLine CLI 访问
/usr/lib/hive/bin/beeline
!connect jdbc:hive2://DX2-1:10000 username password



**创建表**

加载数据
> 
> load data local inpath '/home/hadoop/userinfo.txt' overwrite into table userinfo;


内部表

> create table ptest(userid int) partitioned by (name string)
> row format delimited fields terminated by '\t';
> load data local inpath '/home/hadoop/yaoyuan.txt' overwrite into table ptest partition (name='yaoyuan')

外部表

> create external table sogouqueryfish(time varchar(8), userid
> varchar(30), query string, pagerank int, clickrank int, site
> string) ROW FORMAT DELIMITED FIELDS TERMINATED BY
> '\t' location 'hdfs://DX2-1:8020 /data/SogouQtmp'

**查看分区**
> show partitions ptest;

**删除分区**
> alter table ptest drop partition (name='yaoyuan')


**修改表**

重命名表名：alter table testtable1 rename to testtable2;

增加数据列：alter table testtable1 add columns(newCol string);

显示表结构：describe testtable1;