#!/bin/sh

for host in `cat h.kafka`; do
  ssh $host rm -rf /tmp/kafka_2.10-0.8.2.0.tgz
  ssh $host rm -rf /usr/lib/kafka
  ssh $host wget http://ftp.tsukuba.wide.ad.jp/software/apache/kafka/0.8.2.0/kafka_2.10-0.8.2.0.tgz -O /tmp/kafka_2.10-0.8.2.0.tgz
  ssh $host tar -zxvf /tmp/kafka_2.10-0.8.2.0.tgz -C /usr/lib/
done
