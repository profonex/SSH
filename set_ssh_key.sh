#!/bin/bash

read -p "Enter SSH Key: " sshkey

mkdir ~/.ssh
touch ~/.ssh/authorized_keys
echo "$sshkey" >> ~/.ssh/authorized_keys

echo "SSH Key Set"
