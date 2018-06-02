#!/bin/bash
MODE=$1

# DATE=`date '+%Y%m%d%H%M%S'`
DATE=`date '+%Y%m%d'`
BACKUPDIR=/var/opt/mssql/backup
QUERY_TIMEOUT=0
DB_CMD="/opt/mssql-tools/bin/sqlcmd -S . -U $SQL_USER -P $SQL_PASS -W -h -1 -Q \"SET NOCOUNT ON;SELECT name + '|' + CAST(recovery_model AS nvarchar(1)) FROM sys.databases\""

IFS=
function SQLBackup (){
    case $MODE in
        "FULL") 
            TARGET="DATABASE"
            EXT=".bak"
            ;;
        "LOG")
            TARGET="LOG"
            EXT=".trn"
            ;;
        *)
            exit -1
    esac

    for db in `eval $DB_CMD | awk '{print}'`;do
        echo $db | while IFS="|" read name model;do
            if [ "$name" != "tempdb" ]; then
                if [ "$model" = "3" ] && [ "$TARGET" = "LOG" ]; then
                    continue
                fi
                echo "[`date '+%Y/%m/%d %H:%M:%S'`] [INFO] [$name] Backup $TARGET Start"
                MSG=`/opt/mssql-tools/bin/sqlcmd \
                    -U $SQL_USER \
                    -P $SQL_PASS \
                    -t $QUERY_TIMEOUT \
                    -b \
                    -h -1 \
                    -Q "BACKUP $TARGET [$name] TO DISK=N'$BACKUPDIR/$name-$DATE$EXT' WITH INIT,FORMAT,COMPRESSION"` 2>&1
                if [ $? != 0 ]; then
                    logger -p daemon.error -t "$0" "[ERROR] Backup $TARGET [$name] Error"
                    echo "[`date '+%Y/%m/%d %H:%M:%S'`] [ERROR] Backup $TARGET [$name] Error"
                fi
                if [ `echo $MSG | grep "Timeout expired" | wc -l` != 0 ]; then
                    logger -p daemon.error -t "$0" "[ERROR] BACKUP $TARGET [$name] Query Timeout"
                    echo "[`date '+%Y/%m/%d %H:%M:%S'`] [ERROR] BACKUP $TARGET [$name] Query Timeout"
                fi
                echo "[`date '+%Y/%m/%d %H:%M:%S'`] [INFO] [$name] Backup $TARGET End"
            fi
        done
    done
}

SQLBackup $MODE