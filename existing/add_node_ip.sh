#!/bin/bash

thisip=$(hostname -I | cut -d ' ' -f1)


read -p "Total Number of Nodes Adding: " totalnode


#ip[1]=$thisip

nodenumber=$(($totalnode))
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

iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6



for i in $(seq $totalnode)
do
  echo "hostssl     all     all     ${ip[$i]}/32     trust" >> /etc/postgresql/9.4/main/pg_hba.conf
done

for i in $(seq $totalnode)
do
  echo "hostssl     replication     postgres     ${ip[$i]}/32     trust" >> /etc/postgresql/9.4/main/pg_hba.conf
done


systemctl daemon-reload
systemctl restart postgresql
