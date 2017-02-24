#!/bin/sh

bin=`dirname "$0"`

cd $bin
sh install-hadoop-hbase.sh
sh config-system.sh
sh init_cluster.sh
sh start_hdfs.sh
