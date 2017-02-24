#!/bin/sh
mv /etc/hadoop/conf/core-site.xml /etc/hadoop/conf/core-site.xml.bak
wget http://DX2/DX3-conf/core-site.xml -O /etc/hadoop/conf/core-site.xml
mv /etc/hadoop/conf/hdfs-site.xml /etc/hadoop/conf/hdfs-site.xml.bak
wget http://DX2/DX3-conf/hdfs-site.xml -O /etc/hadoop/conf/hdfs-site.xml
mv /etc/hadoop/conf/yarn-site.xml /etc/hadoop/conf/yarn-site.xml.bak
wget http://DX2/DX3-conf/yarn-site.xml -O /etc/hadoop/conf/yarn-site.xml
mv /etc/hadoop/conf/mapred-site.xml /etc/hadoop/conf/mapred-site.xml.bak
wget http://DX2/DX3-conf/mapred-site.xml -O /etc/hadoop/conf/mapred-site.xml
mv /etc/hadoop/conf/fair-scheduler.xml /etc/hadoop/conf/fair-scheduler.xml.bak
wget http://DX2/DX3-conf/fair-scheduler.xml -O /etc/hadoop/conf/fair-scheduler.xml
mv /etc/hadoop/conf/hadoop-env.sh /etc/hadoop/conf/hadoop-env.sh.bak
wget http://DX2/DX3-conf/hadoop-env.sh -O /etc/hadoop/conf/hadoop-env.sh
mv /etc/hbase/conf/hbase-site.xml /etc/hbase/conf/hbase-site.xml.bak
wget http://DX2/DX3-conf/hbase-site.xml -O /etc/hbase/conf/hbase-site.xml
mv /etc/zookeeper/conf/zoo.cfg /etc/zookeeper/conf/zoo.cfg.bak
wget http://DX2/DX3-conf/zoo.cfg -O /etc/zookeeper/conf/zoo.cfg

prefix=`cat ./userid.private`
sed -i "s/DX3/$prefix/g" /etc/hadoop/conf/*
sed -i "s/DX3/$prefix/g" /etc/hbase/conf/*
sed -i "s/DX3/$prefix/g" /etc/zookeeper/conf/*

for host in `cat h.slaves`; do
  rsync /etc/hadoop/conf/core-site.xml $host:/etc/hadoop/conf/core-site.xml
  rsync /etc/hadoop/conf/hdfs-site.xml $host:/etc/hadoop/conf/hdfs-site.xml
  rsync /etc/hadoop/conf/yarn-site.xml $host:/etc/hadoop/conf/yarn-site.xml
  rsync /etc/hadoop/conf/mapred-site.xml $host:/etc/hadoop/conf/mapred-site.xml
  rsync /etc/hbase/conf/hbase-site.xml $host:/etc/hbase/conf/hbase-site.xml
  rsync /etc/zookeeper/conf/zoo.cfg $host:/etc/zookeeper/conf/zoo.cfg
  ssh $host service iptables stop
done
