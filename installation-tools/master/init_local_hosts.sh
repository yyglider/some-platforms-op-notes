#!/bin/sh

wget http://$remote_ip/hosts -O /etc/hosts.new
mv /etc/hosts.new /etc/hosts
