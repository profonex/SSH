#!/bin/sh

read -p 'IP Address: ' ip_address
read -p 'Subnet Mask: ' mask
read -p 'Gateway: ' gateway

sed "s@iface eth0 inet dhcp@iface eth0 inet static@g" -i /etc/network/interfaces

cat >> /etc/network/interfaces << EOF
address $ip_address
netmask $mask
gateway $gateway
EOF

sed "s@127.0.1.1@127.0.0.1@g" -i /etc/hosts
rm /etc/resolv.conf
touch /etc/resolv.conf
cat >> /etc/resolv.conf << EOF
nameserver 4.2.2.2
nameserver 8.8.8.8
EOF


service networking restart

echo hostname -I
