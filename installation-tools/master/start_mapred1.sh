#!/bin/sh

service hadoop-0.20-mapreduce-jobtracker start
for host in `cat h.slaves`; do
  ssh $host service hadoop-0.20-mapreduce-tasktracker start
done
