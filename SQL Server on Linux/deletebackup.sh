#!/bin/bash
BACKUPDIR=/var/opt/mssql/backup
DELETETARGET=8

# Database Backup
cnt=$(find $BACKUPDIR/*.bak -mtime $DELETETARGET 2>/dev/null | wc -l)
if [ $cnt -ne 0 ] ; then
   for target in `find $BACKUPDIR/*.bak -mtime $DELETETARGET`;do
        echo "Delete Database Backup File [$target]"
	rm $target
   done
else
   echo "Target Database Backup File Does Not Exists"
fi

# Transaction Log Backup
cnt=$(find $BACKUPDIR/*.trn -mtime $DELETETARGET 2>/dev/null | wc -l)
if [ $cnt -ne 0 ] ; then
   for target in `find $BACKUPDIR/*.trn -mtime $DELETETARGET`;do
        echo "Delete Transaction Log Backup File [$target]"
        rm $target
   done
else
   echo "Target Transactin Log Backup File Does Not Exists"
fi


