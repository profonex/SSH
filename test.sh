#!/bin/sh

read -p "Node Name: " nodename

for i in {nodename}
do
  echo "test $i times"
done
