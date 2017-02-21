#!/bin/sh
now=$(date +%Y-%m-%d)
database_host=127.0.0.1
database_port=5432
#export PGPASSWORD="zzz"

echo "Server Maintenance"
mkdir -p /var/backups/fusionpbx/postgresql
#delete backups older 3 days
find /var/backups/fusionpbx/postgresql/fusionpbx_pgsql* -mtime +2 -exec rm {} \;
find /var/backups/fusionpbx/*.tgz -mtime +2 -exec rm {} \;
#delete postgres logs older than 7 days
find /var/log/postgresql/postgresql-9.4-main* -mtime +7 -exec rm {} \;
#delete freeswitch logs older 3 days
find /var/log/freeswitch/freeswitch.log.* -mtime +2 -exec rm {} \;
#find /usr/local/freeswitch/log/freeswitch.log.* -mtime +2 -exec rm {} \;
#delete fax older than 90 days
#source
#find /usr/local/freeswitch/storage/fax/*  -name '*.tif' -mtime +90 -exec rm {} \;
#find /usr/local/freeswitch/storage/fax/*  -name '*.pdf' -mtime +90 -exec rm {} \;
#package
#find /var/lib/freeswitch/storage/fax/*  -name '*.tif' -mtime +90 -exec rm {} \;
#find /var/lib/freeswitch/storage/fax/*  -name '*.pdf' -mtime +90 -exec rm {} \;
#package
#find /var/lib/freeswitch/recordings/*/archive/*  -name '*.wav' -mtime +7 -exec rm {} \;
#find /var/lib/freeswitch/recordings/*/archive/*  -name '*.mp3' -mtime +7 -exec rm {} \;


#source
#find /usr/local/freeswitch/recordings/*/archive/*  -name '*.wav' -mtime +7 -exec rm {} \;
#find /usr/local/freeswitch/recordings/*/archive/*  -name '*.mp3' -mtime +7 -exec rm {} \;
#psql --host=$database_host --port=$database_port --username=fusionpbx -c "delete from v_fax_files WHERE fax_date < NOW() - INTERVAL '90 days'"
#delete voicemail older than 90 days
#find /usr/local/freeswitch/storage/voicemail/*  -name 'msg_*.wav' -mtime +90 -exec rm {} \;
#psql --host=$database_host --port=$database_port --username=fusionpbx -c "delete from v_voicemail_messages WHERE to_timestamp(created_epoch) < NOW() - INTERVAL '90 days'"
#delete call detail records older 90 days
#psql --host=$database_host --port=$database_port --username=fusionpbx -c "delete from v_xml_cdr WHERE start_stamp < NOW() - INTERVAL '90 days'"
echo "Starting Backup"
#backup the database all tables
pg_dump --verbose -Fc --host=$database_host --port=$database_port -U fusionpbx fusionpbx --schema=public -f /var/backups/fusionpbx/postgresql/fusionpbx_pgsql_$now.sql
#backup the database exclude xml_cdr
#pg_dump --verbose -Fc --exclude-table=v_xml_cdr --host=$database_host --port=$database_port -U fusionpbx fusionpbx --schema=public -f /var/backups/fusionpbx/postgresql/fusionpbx_pgsql_$now.sql
#backup the database exclude xml_cdr

#backup only the xml cdr table
#pg_dump --verbose -Fc --table=v_xml_cdr --host=$database_host --port=$database_port -U fusionpbx fusionpbx --schema=public -f /var/backups/fusionpbx/postgresql/fusionpbx_xml_cdr_$now.sql

#mysqldump -u root fusionpbx > /var/backup/fusionpbx/mysql/fusionpbx_mysql_$now.sql

#package - backup the files and directories
tar -zvcf /var/backups/fusionpbx/backup_$now.tgz /var/backups/fusionpbx/postgresql/fusionpbx_pgsql_$now.sql /var/www/fusionpbx /usr/share/freeswitch/scripts /var/lib/freeswitch/storage /var/lib/freeswitch/recordings /etc/fusionpbx /etc/freeswitch

#source - backup the files and directories
#tar -zvcf /var/backups/fusionpbx/backup_$now.tgz /var/backups/fusionpbx/postgresql/fusionpbx_pgsql_$now.sql /var/www/fusionpbx /usr/local/freeswitch/scripts /usr/local/freeswitch/storage /usr/local/freeswitch/recordings /etc/fusionpbx /usr/local/freeswitch/conf

echo "Backup Complete";
#package
