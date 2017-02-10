#!/bin/sh

read -p "Total Number of Nodes: " tnode

for i in 'seq $tnode'
do
  read -p "Node $i IP Address: " ip
done
echo "$i $ip"
