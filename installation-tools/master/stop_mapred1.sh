#!/bin/sh

service hadoop-0.20-mapreduce-jobtracker stop
for host in `cat h.slaves`; do
  ssh $host service hadoop-0.20-mapreduce-tasktracker stop
done
