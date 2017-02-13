#!/bin/bash

read -p "Total Number of Nodes: " totalnode
read -p "This Nodes IP Address: " thisip

ip[1]=$thisip

nodenumber=$(($totalnode-1))
c=2
for i in $(seq $nodenumber);
do
    read -p "Node $(($i+1)) IP Address: " ipadd;
    eval ip[$(($i+1))]=$ipadd;
    c=$((c+1));
done


for j in $(seq $totalnode)
do
  #echo "Node $j ipaddress ${ip[$j]}"
  echo "iptables -A INPUT -j ACCEPT -p tcp --dport 5432 -s ${ip[$j]}/32"
  echo "iptables -A INPUT -j ACCEPT -p tcp --dport 8080 -s ${ip[$j]}/32"
  echo "iptables -A INPUT -j ACCEPT -p tcp --dport 4444 -s ${ip[$j]}/32"
done
