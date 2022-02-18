#!/bin/bash

usage () {
    echo "Re-create a Gitea Docker container from a backup"
    echo "Run this inside a docker-compose config folder!"
    echo "If it's the test container (gitea_test) it'll be automated"
    echo "If not, it will give you commands to run to complete the restore"
    echo "Usage:"
    echo "  restore_gitea_container.sh [--unsafe] [--dry-run]"
    echo ""
    echo "Options:"
    echo "  --unsafe            : Perform actions EVEN OUTSIDE gitea_test container"
    echo "                      : BE CAREFUL with this, it will stomp your container"
    echo "  --dry-run           : Only list actions, don't perform them"
    echo ""
}
if [[ "$1" == "--help" ]]; then
    usage
    exit 0
fi

# MAKE SURE we're in the test dir
PWD=`pwd`
MANUAL_GUIDE=0
IS_TEST=1

if [[ ! -f "$PWD/docker-compose.yml" ]]; then
    echo "You must run this inside a folder containing docker-compose.yml! Aborting"
    exit 1
fi

if [[ ! "$PWD" == */docker-compose/gitea_test ]]; then
    echo "HEY! You're not running this in docker-compose/gitea_test"
    echo "So we're assuming this is a live instance and will not execute anything automatically"
    echo "Instead, we'll print the commands you need to run."
    MANUAL_GUIDE=1
    IS_TEST=0
fi

while (( "$#" )); do
    if [[ "$1" == "--dry-run" ]]; then
        MANUAL_GUIDE=1
    elif [[ "$1" == "--unsafe" ]]; then
        while true; do
            echo "Using --unsafe will destroy & re-create this container in all cases"
            echo "  It will probably get the ports wrong, be ready to edit app.ini afterwards!"
            read -p "Are you SURE this is what you want? (y/n)" yn
            case $yn in
                [Yy]* ) break;;
                [Nn]* ) exit;;
                * ) echo "Please answer yes or no.";;
            esac
        done
        MANUAL_GUIDE=0
    else
        if [[ "$1" == -* ]]; then
            echo Unrecognised option $1
            usage
            exit 3
        fi
    fi
    shift # $2 becomes $1..
done


# Generate all paths based on the last path component
# Root of all the host versions of what gets mapped to /data in container
DATAROOT="/volume1/docker"
# Backup source folder, contains gitea_backup.zip, gitrepos_backup.tar.bz2 & lfs
BACKUPSRC="/volume1/backups/gitea"
CONFIG=$(basename $PWD)
DATADIR="/volume1/docker/$CONFIG"

echo "Removing container"
# Use --all in case it's been run manually
if (( $MANUAL_GUIDE )); then
    echo "Run this:"
    echo " > docker-compose stop"
    echo " > docker-compose rm"
else
    docker-compose stop
    docker-compose rm
fi
echo "Removing old Gitea data"
if (( $MANUAL_GUIDE )); then
    echo "Run this:"
    echo " > rm -r $DATADIR/*"
else
    rm -r $DATADIR/*
fi

echo "Re-creating container"
if (( $MANUAL_GUIDE )); then
    echo "Run this:"
    echo " > docker-compose up --no-start"
else
    docker-compose up --no-start
fi

# We now need to bring up the database server to restore the MySQL data
# Bring it up early so that it's got time to start while we do the data copying
echo "Bringing up database to restore"
if (( $MANUAL_GUIDE )); then
    echo "Run this:"
    echo " > docker-compose start db"
else
    docker-compose start db
fi

# Run the restore script to get back the contents of docker/gitea data folder
echo Restoring Gitea, Git and Git-LFS data
# Copy SQL to MySQL's folder (from host perspective)
MYSQLDATADIR="/volume1/docker/${CONFIG}_db"
MYSQLFILE=`mktemp -t gitea-db.sql.XXXXXX`
if (( $MANUAL_GUIDE )); then
    echo "Run this:"
    echo " > ../../backups/restore_gitea_data.sh $BACKUPSRC $DATADIR $MYSQLFILE"
else
    ../../backups/restore_gitea_data.sh $BACKUPSRC $DATADIR $MYSQLFILE
fi

# Restore DB
# We need to make sure it's up, it can take a little time before connections
# are allowed
MYSQL_ATTEMPTS=3
while [[ $MYSQL_ATTEMPTS -gt 0 ]] ; do
    echo "Testing if MySQL is up"
    let MYSQL_ATTEMPTS--
    if docker-compose exec db mysqladmin -uroot -pDB_ROOT_PASSWORD status; then
        break
    fi
    sleep 2
done

# Our docker container creates the gitea user and gitea DB in all cases
# Drop all tables first
# Can't just pipe in data to docker-compose exec because bug https://github.com/docker/compose/issues/3352
# Fixed but not in the Synology version
# We can use main docker but need to parse out the ID for alias 'db'
DB_DOCKER_ID=$(docker-compose ps -q db)
if (( $MANUAL_GUIDE )); then
    echo "Run this:"
    echo " > docker exec -i $DB_DOCKER_ID mysql -uroot -pDB_ROOT_PASSWORD < ../../sql/reset-gitea-mysql.sql"
    echo "> docker exec -i $DB_DOCKER_ID mysql -ugitea -pDB_GITEA_PASSWORD gitea < $MYSQLFILE"
else
    echo "Restoring database....be patient!"
    docker exec -i $DB_DOCKER_ID mysql -uroot -pDB_ROOT_PASSWORD < ../../sql/reset-gitea-mysql.sql
    docker exec -i $DB_DOCKER_ID mysql -ugitea -pDB_GITEA_PASSWORD gitea < $MYSQLFILE
fi

# Clean up
rm -f $MYSQLFILE


# Need to modify app.ini to change ports on URLs
if (( $IS_TEST )); then
    echo Fixing up ports
    if (( $MANUAL_GUIDE )); then
        echo "You need to edit $DATADIR/gitea/conf.app.ini, change:"
        echo " - ROOT_URL         = https://git.yourserver.com:9000/"
        echo " + ROOT_URL         = https://git.yourserver.com:10000/"
        echo " - SSH_PORT         = 9022"
        echo " - SSH_PORT         = 10022"
    else
        sed -i "s/\.com:9000/.com:10000" $DATADIR/gitea/conf/app.ini
        sed -i "s/9022/10022" $DATADIR/gitea/conf/app.ini
    fi
else
    echo "Since this isn't the test environment, you'll need to check $DATADIR/gitea/conf.app.ini manually!"
fi
# This will have created the missing ssh folder w/ server config etc
echo "Restoration complete"
echo "Restarting Server"
if (( $MANUAL_GUIDE )); then
    echo "Run this:"
    echo " > docker-compose up -d"
else
    docker-compose up -d
fi

echo "NOTE: SSH keys will likely not work if you're restoring to another server"
echo "  Users will probably have to remove & re-add their keys in Settings"
