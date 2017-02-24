#!/bin/sh

service spark-master start
service spark-history-server start
for host in `cat h.slaves`; do
  ssh $host service spark-worker start
done
