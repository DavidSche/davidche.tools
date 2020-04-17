
-- SELECT * FROM domain.Accounts;

-- SELECT TOP (5) [id]
--       ,[name]
--       ,[email]
--       ,[emailRecovery]
--       ,[password]
--       ,[active]
--       ,[registered]
--       ,[logged]
--       ,[photo]
--   FROM [quickstart].[domain].[Accounts]


-- SELECT count(*) FROM [quickstart].[domain].[Accounts] as acc WHERE acc.logged = 1 

-- /opt/mssql-tools/bin/sqlcmd -S 0.0.0.0 -d $DB_MSSQL_DATABASE -U $DB_MSSQL_USER -P $DB_MSSQL_PASSWORD -Q 'SET NOCOUNT ON; SELECT TOP (5) id, name, email FROM [quickstart].[domain].[Accounts]'


-- SELECT TOP (5) id, name, email FROM [quickstart].[domain].[Accounts] as acc WHERE acc.active = 0 and acc.logged = 0


SELECT count(*) FROM [quickstart].[domain].[Accounts] as acc WHERE acc.registered BETWEEN '19870601' AND '20190120'













