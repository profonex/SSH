#!/bin/bash

read -p "number: " node


COUNTER=0
  while [  $COUNTER -lt $node ]; do
    echo The counter is $COUNTER
    let COUNTER=COUNTER+1 
  done
