#!/bin/sh

for host in `cat h.slaves`; do
  ssh $host groupadd supergroup
  ssh $host usermod -g supergroup mapred
  ssh $host usermod -g supergroup hbase
  ssh $host usermod -g supergroup yarn
done
sudo -u hdfs hadoop fs -chmod 775 /
sudo -u hdfs hadoop fs -mkdir /user
sudo -u hdfs hadoop fs -mkdir /user/mapred
sudo -u hdfs hadoop fs -chown mapred /user/mapred
sudo -u hdfs hadoop fs -mkdir /tmp
sudo -u hdfs hadoop fs -chmod 777 /tmp
sudo -u hdfs hadoop fs -mkdir /hbase
sudo -u hdfs hadoop fs -chown hbase /hbase
