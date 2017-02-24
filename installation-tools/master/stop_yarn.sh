#!/bin/sh

service hadoop-yarn-resourcemanager stop
for host in `cat h.slaves`; do
  ssh $host service hadoop-yarn-nodemanager stop
done
service hadoop-mapreduce-historyserver stop
