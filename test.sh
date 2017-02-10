#!/bin/sh

read -p "Total Number of Nodes: " tnode

max=$tnode

for i in `seq $max`
do
    read -p "Node $i IP Address: " ipadd
    nodenum=$i
    ip=$ipadd
    nodeip=
    echo "$i$ipnode" "$ip" "$i"
done
