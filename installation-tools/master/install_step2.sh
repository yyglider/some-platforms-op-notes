#!/bin/sh
bin=`dirname "$0"`

cd $bin
sh init_hdfs.sh
sh start_yarn.sh
#sh start_hbase.sh
