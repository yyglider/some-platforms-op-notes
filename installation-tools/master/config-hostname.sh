#!/bin/bash

bin=`dirname "$0"`
bin=`cd "$bin"; pwd`
i=0;
sh $bin/init_local_hosts.sh
for host in `cat $bin/h.hosts`; do
  i=`expr $i + 1`;
  name=$prefix-$i
  echo $host $name >> /etc/hosts
  if [ $i = 1 ]; then
	echo $name > h.master
	echo $name > h.zookeeper
  fi

  if [ $i = 2 ]; then
        echo $name > h.secondarynamenode
  fi
  echo $name >> h.slaves.new
  ssh $host hostname $name
  ssh $host 'sed -i -r "s/(HOSTNAME *= *).*/\1'$name'/" /etc/sysconfig/network'
done
mv $bin/h.slaves.new $bin/h.slaves


for host in `cat $bin/h.hosts`; do
  rsync /etc/hosts $host:/etc/
done
