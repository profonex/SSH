#!/bin/bash


systemctl stop btsync

sh -c 'echo "deb http://linux-packages.resilio.com/resilio-sync/deb resilio-sync non-free" > /etc/apt/sources.list.d/resilio-sync.list'
wget -qO - https://linux-packages.resilio.com/resilio-sync/key.asc | apt-key add -
apt-get update
apt-get install -y resilio-sync

cp /usr/src/scripts/rslsync/rslsync.conf /etc/resilio-sync/rslsync.conf

sed -i '8,9s/rslsync/www-data/' /lib/systemd/system/resilio-sync.service
sed -i '15s/rslsync:rslsync/www-data:www-data/' /lib/systemd/system/resilio-sync.service
#sed -i '16s/config.json/rslsync.conf/' /lib/systemd/system/resilio-sync.service

chown -R www-data:www-data /var/lib/resilio-sync
systemctl daemon-reload
#systemctl stop resilio-sync
#rslsync --config rslsync/rslsync.conf
systemctl restart resilio-sync
systemctl enable resilio-sync


apt-get purge -y btsync
