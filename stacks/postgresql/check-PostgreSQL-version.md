# How to remotely check PostgreSQL version

Post author By milosz
Post date April 4, 2014

Today I will shortly describe how you can remotely check the PostgreSQL version and use it inside shell scripts. This ability comes in handy at times, as it can be used to perform different tasks depending on the returned database version.

## The first method – the descriptive one

The easiest way to get a detailed database version is to execute the following SQL query.

```sql
postgres=# SELECT version();
version
-----------------------------------------------------------------------------------------------
PostgreSQL 9.1.12 on x86_64-unknown-linux-gnu, compiled by gcc (Debian 4.7.2-5) 4.7.2, 64-bit
(1 row)
```

You can use this query inside a simple shell script to iterate over database servers.

```shell
#!/bin/sh
# Simple shell script designed to display PostgreSQL version for selected servers

# PostgreSQL servers
servers="localhost    \
         192.168.1.145 \
         192.168.1.138 \
         192.168.0.130"

# PostgreSQL settings
PGUSER=pguser
PGPASSWORD=pgpass
PGDATABASE=postgres

# print version for each server
for server in $servers; do
  export PGUSER PGPASSWORD PGDATABASE
  export PGHOST=$server
  echo -n "$server:\t"
  psql -A -t -c "select version()"
done
```


Sample script output:

```shell
localhost:      PostgreSQL 9.1.12 on x86_64-unknown-linux-gnu, compiled by gcc (Debian 4.7.2-5) 4.7.2, 64-bit
192.168.1.145:  PostgreSQL 8.4.20 on i486-pc-linux-gnu, compiled by GCC gcc-4.4.real (Debian 4.4.5-8) 4.4.5, 32-bit
192.168.1.138:  PostgreSQL 9.1.12 on i686-pc-linux-gnu, compiled by gcc (Ubuntu/Linaro 4.8.1-10ubuntu8) 4.8.1, 32-bit
192.168.0.130:  PostgreSQL 9.1.12 on i686-pc-linux-gnu, compiled by gcc (Ubuntu/Linaro 4.8.1-10ubuntu8) 4.8.1, 32-bit

```

## The second method – the parsable one

To get an easily parsable database version, use the following SQL query.

```sql
postgres=# SHOW server_version;
server_version
----------------
9.1.12
(1 row)
```

Now you can split the version into a major and minor number using a shell script.

```shell
#!/bin/sh
# Shell script designed to check major and minor PostgreSQL version for desired servers

# PostgreSQL servers
servers="localhost \
        192.168.1.145 \
        192.168.1.138 \
        192.168.0.130"

# current/previous major, minor version number
curr_major="9.1"
curr_minor="11"
prev_major="8.4"
prev_minor="21"

# PostgreSQL settings
PGUSER=pguser
PGPASSWORD=pgpass
PGDATABASE=postgres

# iterate over each server
for server in $servers; do
  export PGUSER PGPASSWORD PGDATABASE
  export PGHOST=$server

  version=$(psql -A -t -c "show server_version")
  major=$(echo $version | cut -d. -f1,2)
  minor=$(echo $version | cut -d. -f3)

  if [ "$major" = "$curr_major" ]; then
    if [ "$minor" -lt "$curr_minor" ]; then
      echo "$server:\tPlease update server to the latest version ($minor -> $curr_minor)";
    else
      echo "$server:\tAlready using current version ($version)"
    fi
  elif [ "$major" = "$prev_major" ]; then
    if [ "$minor" -lt "$prev_minor" ]; then
      echo "$server:\tPlease update server to the latest version ($major.$minor -> $major.$prev_minor)";
    else
      echo "$server:\tAlready using current version ($version)"
    fi
  else
    echo "$server:\tSkipped - Version mismatch ($major)"
  fi
done
```

Sample script output.

```shell
localhost:      Already using current version (9.1.12)
192.168.1.145:  Please update server to the latest version (8.4.20 -> 8.4.21)
192.168.1.138:  Already using current version (9.1.12)
192.168.0.130:  Already using current version (9.1.12)
```

## Third method – the comparable one

To get the database version as a number, execute the following SQL query.

```sql
postgres=# SHOW server_version_num;
server_version_num
--------------------
90112
(1 row)
```

Use it to quickly compare version numbers using a shell script.

```shell
#!/bin/sh
# Shell script designed to check minimal/preferred PostgreSQL version for desired servers

# PostgreSQL servers
servers="localhost \
        192.168.1.145 \
        192.168.1.138 \
        192.168.0.130"

# minimal and preferred version number
minimal_version="80420"
preffered_version="90112"

# PostgreSQL settings
PGUSER=pguser
PGPASSWORD=pgpass
PGDATABASE=postgres

# iterate over each server
for server in $servers; do
  export PGUSER PGPASSWORD PGDATABASE
  export PGHOST=$server

  version=$(psql -A -t -c "show server_version_num")

  if [ "$version" -ge  "$preffered_version" ]; then
    echo "$server:\tRequirements fully met ($version)"
  else
    if [ "$version" -ge "$minimal_version" ]; then
      echo "$server:\tMinimal requirements met ($version)"
    else
      echo "$server:\tRequirements are not met ($version)"
    fi
  fi
done
```

Sample script output:

```shell
localhost:      Requirements fully met (90112)
192.168.1.145:  Minimal requirements met (80420)
192.168.1.138:  Requirements fully met (90112)
192.168.0.130:  Requirements fully met (90112)
```

## References

[PostgreSQL versioning and release support policy](https://www.postgresql.org/support/versioning/)
[PostgreSQL documentation](https://www.postgresql.org/docs/)

-------

# How to non interactively provide password for the PostgreSQL interactive terminal

Post author  By milosz
Post date  March 23, 2014

There are two ways to non interactively provide a password for the psql command (PostgreSQL interactive terminal). Each method allows you to quickly write shell scripts using terminal-based PostgreSQL utilities as you can provide user credentials from the password file or environment variables.

## Provide password using the password file
To use this method, create .pgpass file inside your home directory and restrict its permissions so it would not be ignored by utilities.

```shell
$ touch ~/.pgpass
$ chmod 0600 ~/.pgpass
```

Each line defines user credentials using the following structure.

```shell
server:port:database:username:password
```

Please note that every field other than a password can be replaced with an asterisk to match anything. Everything else is self-explanatory, so I will jump directly to the example.

```shell
localhost:5432:bookmarks:milosz:JOAvaDtW8SRZ2w7S
10.0.0.15:5432:wikidb:mediawiki:631j7ZtLvSF4fyIR
10.0.0.113:*:*:development:iGsxFMziuwLdEEqw
```

As a user with a defined PostgreSQL password file, you can use PostgreSQL utilities without a password prompt to perform desired tasks.

```shell
$ psql -w -U milosz bookmarks -c "select * from domains"
$ pg_dump -w -c -U development -h 10.0.0.113 bookmarks | \
gzip --best > bookmarks.sql.gz
```

You are not forced to use the ~/.pgpass file as you can define PGPASSFILE variable to use an entirely different password file.

```shell
$ PGPASSFILE=~/.pg/.altpgpass pg_dump -c -w -U milosz bookmarks
$ export PGPASSFILE=~/.altpgpass
$ psql -w -U mediawiki -h 10.0.0.15 wikidb  -c "select * from user"
```

As you probably noticed, I am using -w parameter, so the utilities mentioned above will fail if the password is not available.

## Provide password using environment variables

Instead of using a password file, you can define PGHOST, PGPORT, PGDATABASE, PGUSER and PGPASSWORD environment variables.

```shell
$ PGHOST=10.0.0.15 PGPORT=5432 \
PGDATABASE=wikidb \
PGUSER=mediawiki PGPASSWORD=631j7ZtLvSF4fyIR \
pg_dump -w -c | gzip --best > wikidb.sql.gz

$ PGHOST=10.0.0.15 \
PGUSER=development PGPASSWORD=iGsxFMziuwLdEEqw \
psql bookmarks  -c "select * from domains"

$ PGUSER=milosz PGPASSWORD=JOAvaDtW8SRZ2w7S \
psql bookmarks -c "select * from favorites"
```


## References
[PostgreSQL 9.3.4 Documentation – libpq – The Password File](https://www.postgresql.org/docs/9.3/static/libpq-pgpass.html)
[PostgreSQL 9.3.4 Documentation – libpq – Environment Variables](https://www.postgresql.org/docs/9.3/static/libpq-envars.html)

Tags


[来源](https://blog.sleeplessbeastie.eu/2014/03/23/how-to-non-interactively-provide-password-for-the-postgresql-interactive-terminal/)