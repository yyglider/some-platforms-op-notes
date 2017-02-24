#!/bin/sh

service spark-master stop
service spark-history-server stop
for host in `cat h.slaves`; do
  ssh $host service spark-worker stop
done
