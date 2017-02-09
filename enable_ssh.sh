#!/bin/sh

sed "s@PermitRootLogin wilthout-password@PermitRootLogin yes@g" -i /etc/ssh/sshd_config
