#!/bin/bash
set -euxo pipefail;

echo "Enable AlwaysOn availability groups...";
/opt/mssql/bin/mssql-conf set hadr.hadrenabled 1;

echo "Restart the mssql-server.service...";
systemctl restart mssql-server.service &

echo "Starting the SQL Server Service...";
/opt/mssql/bin/sqlservr &

echo "Please wait while SQL Server warms up...";
sleep 13s;

echo "Initializing cluster after 13 seconds of wait...";

# echo "Initializing cluster script execution...";
# /opt/mssql-tools/bin/sqlcmd -S 0.0.0.0 -d $DB_MSSQL_DATABASE -U $DB_MSSQL_USER -P $DB_MSSQL_PASSWORD \
#                             -i ./scripts/cluster.sql;

echo "Finished initializing the cluster.";
