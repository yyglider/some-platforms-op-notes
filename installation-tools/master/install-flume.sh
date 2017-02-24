#!/bin/sh

for host in `cat h.flume`; do
 ssh $host yum install flume-ng  -y
done
