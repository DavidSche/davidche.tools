
SET NOCOUNT ON;
GO

USE master;
GO

-- -----------------------------------------------------
-- IF EXISTS, DROP: quickstart
-- -----------------------------------------------------
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'quickstart')
BEGIN
    DROP DATABASE quickstart;
END
GO

-- -----------------------------------------------------
-- DATABASE: quickstart
-- -----------------------------------------------------
CREATE DATABASE quickstart ON (
    NAME = quickstart_data,
    FILENAME = '/var/opt/mssql/data/quickstart_data.mdf',
    SIZE = 8MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 64MB
) LOG ON (
    NAME = quickstart_log,
    FILENAME = '/var/opt/mssql/data/quickstart_log.ldf',
    SIZE = 8MB,
    MAXSIZE = 128MB,
    FILEGROWTH = 64MB
) COLLATE LATIN1_GENERAL_100_CI_AS_SC; -- OR Latin1_General_CI_AS
GO

USE quickstart;
GO

-- -----------------------------------------------------
-- SCHEMA: domain
-- -----------------------------------------------------
CREATE SCHEMA domain;
GO

-- -----------------------------------------------------
-- TABLE: Accounts
-- -----------------------------------------------------
CREATE TABLE domain.Accounts (
    [id] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [name] nvarchar(66) NOT NULL,
    [email] nvarchar(66) NOT NULL,
    [emailRecovery] nvarchar(66) NOT NULL,
    [password] nvarchar(80) NOT NULL,
    [active] bit NOT NULL,
    [registered] datetime NOT NULL,
    [logged] bit NOT NULL,
    [photo] varbinary(max) NULL
)
GO

CREATE UNIQUE INDEX email_unique ON domain.Accounts (email ASC);
GO
