#!/bin/sh


#install spark
for host in `cat h.slaves`; do
 ssh $host  yum install spark-core spark-master spark-worker spark-history-server spark-python
done
