#!/bin/bash
set -euxo pipefail;


/opt/mssql-tools/bin/sqlcmd -S 0.0.0.0 -d $DB_MSSQL_DATABASE -U $DB_MSSQL_USER -P $DB_MSSQL_PASSWORD \
                            -i ./scripts/cluster.sql;


