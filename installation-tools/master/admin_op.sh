#!/bin/sh

if [ $# = 0 ]; then
    echo " please input user id ..."
    exit
fi

bin=`dirname "$0"`
userid="$1"
echo $userid > userid.private
/bin/hostname $userid-1
export bin=`cd "$bin"; pwd`
export prefix=$userid
export remote_ip=10.161.49.84
sh $bin/config_ssh.sh
sh $bin/config-hostname.sh
for host in `cat $bin/h.slaves`; do
  ssh $host wget http://$remote_ip/cloudera-cdh5-myself.repo -O /etc/yum.repos.d/cloudera-cdh5-myself.repo
  ssh $host wget http://$remote_ip/cloudera-gplextras5-myself.repo -O /etc/yum.repos.d/cloudera-gplextras5-myself.repo

  /usr/sbin/ntpdate 133.100.11.8
  ssh $host wget http://$remote_ip/ntpsync -O /etc/cron.hourly/ntpsync
  chmod +x /etc/cron.hourly/ntpsync
  #ssh $host 'echo "export PATH=\$PATH:/usr/java/jdk1.7.0_45-cloudera/bin" >> /etc/profile'
  ssh $host 'echo "export PATH=\$PATH:/usr/lib/jvm/java-1.7.0-openjdk.x86_64/bin" >> /etc/profile'
done

