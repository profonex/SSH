#!/bin/sh

sed "s@PermitRootLogin yes@PermitRootLogin without-password@g" -i /etc/ssh/sshd_config
sed "s@#PasswordAuthentication yes@PasswordAuthentication no@g" -i /etc/ssh/sshd_config

service ssh stop
service ssh start
