#!/bin/bash
set -euxo pipefail;

echo "Starting the initial container settings...";
./setup/setup-init.sh;

if [ $DB_MSSQL_APPLY_CLUSTER = 'Y' ]; then
    echo "Starting configuring cluster for SQL Server...";
    ./setup/setup-cluster.sh;
fi

if [ $DB_MSSQL_APPLY_DATABASE = 'Y' ]; then
    echo "Starting configuring database in SQL Server...";
    ./setup/setup-database.sh;
fi

if [ $DB_MSSQL_APPLY_CLUSTER = 'N' ] && [ $DB_MSSQL_APPLY_DATABASE = 'N' ]; then
    echo "Starting the SQL Server Service...";
    /opt/mssql/bin/sqlservr &
fi
