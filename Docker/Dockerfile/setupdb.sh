#!/bin/bash
while [ `cat /var/opt/mssql/log/errorlog | grep "The default collation was successfully changed" | wc -l` -eq 0 ]
do
    echo "Wait"
    sleep 5s
done

while :
do
    /opt/mssql-tools/bin/sqlcmd -S . -U sa -P $SA_PASSWORD -Q "SELECT @@SERVERNAME" -t 5 > /dev/null
    if [ $? -eq 0 ]; then
        echo "Connected"
        break
    fi
done

# << COMMENT

if [ ! -f /var/opt/mssql/data/WideWorldImporters-Full.bak ]; then
    wget https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak -O /var/opt/mssql/data/WideWorldImporters-Full.bak
fi

SQL="
RESTORE DATABASE WideWorldImporters 
FROM DISK='/var/opt/mssql/data/WideWorldImporters-Full.bak' 
WITH MOVE 'WWI_Primary' TO '/var/opt/mssql/data/WideWorldImporters.mdf', 
MOVE 'WWI_UserData' TO '/var/opt/mssql/data/WideWorldImporters_userdata.ndf', 
MOVE 'WWI_Log' TO '/var/opt/mssql/data/WideWorldImporters.ldf', 
MOVE 'WWI_InMemory_Data_1' TO '/var/opt/mssql/data/WideWorldImporters_InMemory_Data_1',
STATS=5
"
# COMMENT
/opt/mssql-tools/bin/sqlcmd -S . -U sa -P "${SA_PASSWORD}" -t 0 -Q "${SQL}"

SQL="SHUTDOWN"
/opt/mssql-tools/bin/sqlcmd -S . -U sa -P "${SA_PASSWORD}" -t 0 -Q "${SQL}"

while [ `ps -aux | grep sqlservr | grep -v grep | wc -l` -ne 0 ]
do
    echo "Wait"
    sleep 5s
done
# ps -aux | grep sqlservr | grep -v grep | awk '{print "kill -9", $2}'| bash

rm /tmp/setupdb.sh
/opt/mssql/bin/sqlservr 
