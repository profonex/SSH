#!/bin/bash

thisip=$(hostname -I | cut -d ' ' -f1)

read -p "Total Number of Nodes: " totalnode
echo "IP Address of this node is $thisip "


ip[1]=$thisip

nodenumber=$(($totalnode-1))
c=2
for i in $(seq $nodenumber);
do
    read -p "Node $(($i+1)) IP Address: " ipadd;
    eval ip[$(($i+1))]=$ipadd;
    c=$((c+1));
done


for i in $(seq $totalnode)
do
  iptables -A INPUT -j ACCEPT -p tcp --dport 5432 -s ${ip[$i]}/32
  iptables -A INPUT -j ACCEPT -p tcp --dport 8080 -s ${ip[$i]}/32
  iptables -A INPUT -j ACCEPT -p tcp --dport 4444 -s ${ip[$i]}/32
done

#answer the questions for iptables persistent
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
apt-get install -y --force-yes  iptables-persistent
