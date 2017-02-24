#!/bin/sh

service hadoop-hdfs-namenode start
for host in `cat h.secondarynamenode`; do
  ssh $host service hadoop-hdfs-secondarynamenode start
done

for host in `cat h.slaves`; do
  ssh $host service hadoop-hdfs-datanode start
done
