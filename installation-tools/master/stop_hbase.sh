#!/bin/sh

service hbase-master stop

for host in `cat h.slaves`; do
  ssh $host service hbase-regionserver stop
done

for host in `cat h.zookeeper`; do
  ssh $host service zookeeper-server stop
done
