#!/bin/sh

for host in `cat h.slaves`; do
 #ssh $host yum install hadoop hadoop-yarn-nodemanager hadoop-hdfs-datanode hadoop-mapreduce  hbase-regionserver oracle-j2sdk1.7-1.7.0+update45-1.x86_64 hadoop-lzo -y
 ssh $host yum install hadoop hadoop-yarn-nodemanager hadoop-hdfs-datanode hadoop-mapreduce  hbase-regionserver java-1.7.0-openjdk-devel.x86_64 hadoop-lzo -y
done

for host in `cat h.master`; do
 ssh $host yum install hadoop-yarn-resourcemanager hadoop-mapreduce-historyserver hadoop-hdfs-namenode hbase-master -y
done

for host in `cat h.secondarynamenode`; do
 ssh $host yum install hadoop-hdfs-secondarynamenode -y
done

for host in `cat h.zookeeper`; do
 ssh $host yum install zookeeper -y
 ssh $host yum install zookeeper-server -y
done

