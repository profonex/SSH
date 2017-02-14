#!/bin/sh

sed "s@PermitRootLogin without-password@PermitRootLogin yes@g" -i /etc/ssh/sshd_config

service ssh stop
service ssh start
