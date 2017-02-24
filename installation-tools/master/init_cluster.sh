#!/bin/sh

mkdir /mnt/dfs_name
chown hdfs /mnt/dfs_name

for host in `cat h.slaves`; do
  ssh $host mkdir /mnt/dfs_data
  ssh $host chown hdfs /mnt/dfs_data
  ssh $host mkdir /mnt/mapred_local
  ssh $host chown mapred /mnt/mapred_local
  ssh $host mkdir /mnt/nm_local
  ssh $host chown yarn /mnt/nm_local
done

for host in `cat h.secondarynamenode`; do
  ssh $host mkdir /mnt/dfs_secondname
  ssh $host chown hdfs /mnt/dfs_secondname
done

sudo -u hdfs hadoop namenode -format

service zookeeper-server init --myid=0
