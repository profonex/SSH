#!/bin/bash

nodename=node1
dbasepass=ux24QBkpVXfCWFlKbw5I7ciP0Mq
totalnode=2
thisip=172.20.20.150

ip[1]=$thisip
ip[2]=172.20.20.151


domainname=pbx1.profonex.com
username=admin
userpass=M0rph3us
email=erikwyand@priserv.com

#database details
database_host=127.0.0.1
database_port=5432
database_username=fusionpbx

systemctl daemon-reload
systemctl restart postgresql

sudo -u postgres psql -c "DROP DATABASE fusionpbx";
sudo -u postgres psql -c "DROP DATABASE freeswitch";
sudo -u postgres psql -c "CREATE DATABASE fusionpbx";
sudo -u postgres psql -c "CREATE DATABASE freeswitch";
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE fusionpbx to fusionpbx;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE freeswitch to fusionpbx;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE freeswitch to freeswitch;"
sudo -u postgres psql -c "ALTER USER fusionpbx WITH PASSWORD '$dbasepass';"
sudo -u postgres psql -c "ALTER USER freeswitch WITH PASSWORD '$dbasepass';"
sudo -u postgres psql -d fusionpbx -c "CREATE EXTENSION btree_gist;"
sudo -u postgres psql -d fusionpbx -c "CREATE EXTENSION bdr;"
sudo -u postgres psql -d freeswitch -c "CREATE EXTENSION btree_gist;"
sudo -u postgres psql -d freeswitch -c "CREATE EXTENSION bdr;"
sudo -u postgres psql -d fusionpbx -c "SELECT bdr.bdr_group_create(local_node_name := '$nodename', node_external_dsn := 'host=$thisip port=5432 dbname=fusionpbx connect_timeout=10 keepalives_idle=5 keepalives_interval=1 sslmode=require');"
sudo -u postgres psql -d fusionpbx -c "SELECT bdr.bdr_node_join_wait_for_ready();"
sleep 15
sudo -u postgres psql -d fusionpbx -c "CREATE EXTENSION pgcrypto;"
sudo -u postgres psql -d freeswitch -c "SELECT bdr.bdr_group_create(local_node_name := '$nodename', node_external_dsn := 'host=$thisip port=5432 dbname=fusionpbx connect_timeout=10 keepalives_idle=5 keepalives_interval=1 sslmode=require');"
sudo -u postgres psql -d freeswitch -c "SELECT bdr.bdr_node_join_wait_for_ready();"
sleep 15
sudo -u postgres psql -d freeswitch -c "CREATE EXTENSION pgcrypto;"
