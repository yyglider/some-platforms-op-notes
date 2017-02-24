#!/bin/sh

for host in `cat h.zookeeper`; do
  ssh $host service zookeeper-server start
done

service hbase-master start

for host in `cat h.slaves`; do
  ssh $host service hbase-regionserver start
done
