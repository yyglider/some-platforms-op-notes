#!/bin/sh

cd /root/master

for host in `cat /root/master/h.slaves`; do
  ssh $host hostname
done
