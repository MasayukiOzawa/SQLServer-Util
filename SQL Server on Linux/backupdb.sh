#!/bin/bash
MODE=$1

# DATE=`date '+%Y%m%d%H%M%S'`
DATE=`date '+%Y%m%d'`
BACKUPDIR=/var/opt/mssql/backup
QUERY_TIMEOUT=5

DB_CMD="/opt/mssql-tools/bin/sqlcmd -U $SQL_USER -P $SQL_PASS -W -h -1 -Q \"SET NOCOUNT ON;SELECT name + '|' + CAST(recovery_model AS nvarchar(1)) FROM sys.databases\""
IFS=

if [ "$MODE" == "FULL" ]; then
    for db in `eval $DB_CMD | awk '{print}'`;do
        echo $db | while IFS="|" read name model;do
            if [ "$name" != "tempdb" ]; then
                echo "[`date '+%Y/%m/%d %H:%M:%S'`] [INFO] [$name] Full Backup Start"
               MSG=`/opt/mssql-tools/bin/sqlcmd \
                    -U $SQL_USER \
                    -P $SQL_PASS \
                    -t $QUERY_TIMEOUT \
                    -b \
                    -h -1 \
                    -Q "BACKUP DATABASE [$name] TO DISK=N'$BACKUPDIR/$name-$DATE.bak' WITH INIT,FORMAT,COMPRESSION"` 2>&1
                if [ $? != 0 ]; then
                    echo "[`date '+%Y/%m/%d %H:%M:%S'`] [ERROR] [$name] Full Backup"
                fi
                if [ `echo $MSG | grep "Timeout expired" | wc -l` != 0 ]; then
                    logger -p daemon.error -t "$0" "[ERROR] Backup Database [$name] Query Timeout"
                fi
                echo "[`date '+%Y/%m/%d %H:%M:%S'`] [INFO] [$name] Full Backup End"
            fi
        done
    done

elif [ "$MODE" == "LOG" ]; then
    for db in `eval $DB_CMD | awk '{print}'`;do
        echo $db | while IFS="|" read name model;do
            if [ "$model" != "3" ]; then
                echo "[`date '+%Y/%m/%d %H:%M:%S'`] [INFO] [$name] Log Backup Start"
                MSG=`/opt/mssql-tools/bin/sqlcmd \
                    -U $SQL_USER \
                    -P $SQL_PASS \
                    -t $QUERY_TIMEOUT \
                    -b \
                    -h -1 \
                    -Q "BACKUP LOG [$name] TO DISK=N'$BACKUPDIR/$name-$DATE.trn' WITH COMPRESSION"` 2>&1
                if [ $? != 0 ]; then
                    echo "[`date '+%Y/%m/%d %H:%M:%S'`] [ERROR] [$name] Log Backup"
                fi
                if [ `echo $MSG  | grep "Timeout expired" | wc -l` != 0 ]; then
                     logger -p daemon.error -t "$0" "[ERROR] Backup Log [$name] Query Timeout"
                 fi
                echo "[`date '+%Y/%m/%d %H:%M:%S'`] [INFO] [$name] Log Backup End"
            fi
        done
    done
fi
