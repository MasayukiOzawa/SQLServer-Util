#!/bin/bash
if [ -e /tmp/setupdb.sh ]; then
    /opt/mssql/bin/sqlservr & 
    /bin/bash /tmp/setupdb.sh
else
    /opt/mssql/bin/sqlservr
fi