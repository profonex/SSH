#!/bin/sh

read -p "Total Number of Nodes: " tnode

for i in 'seq $tnode
do
  read -p "Node $i IP Address: " $i_ip
done
echo $i_ip
