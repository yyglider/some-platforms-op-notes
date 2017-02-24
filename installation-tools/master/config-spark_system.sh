#!/bin/sh
mv /etc/spark/conf/spark-env.sh /etc/spark/conf/spark-env.sh.bak
wget http://DX2/DX3-conf/spark-standalone/spark-env.sh -O /etc/spark/conf/spark-env.sh
mv /etc/spark/conf/spark-defaults.conf /etc/spark/conf/spark-defaults.conf.bak
wget http://DX2/DX3-conf/spark-standalone/spark-defaults.conf -O /etc/spark/conf/spark-defaults.conf

for host in `cat h.slaves`; do
  rsync /etc/spark/conf/spark-defaults.conf $host:/etc/spark/conf/spark-defaults.conf
  rsync /etc/spark/conf/spark-env.sh $host:/etc/spark/conf/spark-env.sh
done
