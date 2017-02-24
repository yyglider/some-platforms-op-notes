#!/bin/sh

service hadoop-yarn-resourcemanager start
for host in `cat h.slaves`; do
  ssh $host service hadoop-yarn-nodemanager start
done
service hadoop-mapreduce-historyserver start
