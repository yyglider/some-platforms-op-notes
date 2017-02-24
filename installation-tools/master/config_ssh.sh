#!/bin/sh

yum install expect -y

auto_ssh_copy_id() {
  local HOST=$1
  local PASSWD="Abcdefg123"
  expect -c "set timeout -1;
    spawn ssh-copy-id -i /root/.ssh/id_rsa.pub root@$HOST
    expect {
      *(yes/no)* {send yes\r; exp_continue;}
      *password* {send \"$PASSWD\r\"; exp_continue;}
      eof {exit 0;}
    }";
}

#spawn /usr/bin/rsync -rl ~/.ssh $HOST:/root/

while read line; do
  echo "$line"
  auto_ssh_copy_id "$line"
done < h.hosts
