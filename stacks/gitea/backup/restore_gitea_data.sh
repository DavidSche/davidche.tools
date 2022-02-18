#!/bin/bash

# See backup_gitea.sh
# Source to restore should include:
#  - gitea_backup.zip
#  - gitrepos_backup.tar.bz2
#  - lfs/*/*/*


# Exit on error
set -e

usage () {
    echo "Script for restoring Gitea data from a backup. Will REPLACE existing data!!"
    echo "You probably DON'T WANT THIS SCRIPT directly, it only gets the data files back"
    echo "Look at restore_gitea_container.sh for a fully automated Docker container & DB restore"
    echo "Usage:"
    echo "  restore_gitea_data.sh [--dry-run] <source_dir> <dest_dir> <sql_file_dest>"
    echo ""
    echo "Params:"
    echo "  source_dir          : Directory containing Gitea backup"
    echo "  dest_dir            : Directory to write data to (host, mapped to /data in container)"
    echo "  sql_file_dest       : Full file path of where to place gitea-db.sql from backup"
    echo "Options:"
    echo "  --dry-run           : Don't actually perform actions, just report"
    echo ""
}
if [[ "$1" == "--help" ]]; then
    usage
    exit 0
fi

DRYRUN=0
SOURCE=""
DATADIR=""
SQLDEST=""
USER_UID=1000
GROUP_GID=1000

while (( "$#" )); do
    if [[ "$1" == "--dry-run" ]]; then
        DRYRUN=1
    else
        if [[ "$1" == -* ]]; then
            echo Unrecognised option $1
            usage
            exit 3
        # Populate positional args
        elif [[ "$SOURCE" == "" ]]; then
            SOURCE=$1
        elif [[ "$DATADIR" == "" ]]; then
            DATADIR=$1
        else
            SQLDEST=$1
        fi
    fi
    shift # $2 becomes $1..
done

if [[ "$SOURCE" == "" ]]; then
    echo "Required: source folder"
    usage
    exit 3
fi

if [[ "$DATADIR" == "" ]]; then
    echo "Required: destination data dir"
    usage
    exit 3
fi

echo Checking required files exist in $SOURCE
if [[ ! -f "$SOURCE/gitea_backup.zip" ]]; then
    echo "ERROR: Missing file in restore $SOURCE/gitea_backup.zip"
    exit 5
fi
if [[ ! -f "$SOURCE/gitrepos_backup.tar.bz2" ]]; then
    echo "ERROR: Missing file in restore $SOURCE/gitrepos_backup.tar.bz2"
    exit 5
fi
if [[ ! -d "$SOURCE/lfs" ]]; then
    echo "ERROR: Missing directory in restore $SOURCE/lfs"
    exit 5
fi

# The only thing we can't restore is the gitea/ssh folder, which contains the
# server SSH keys. We leave that for Gitea to re-create on first start
echo Checking container data
if [[ ! -d "$DATADIR/gitea" ]]; then
    if (( $DRYRUN )); then
        echo "Would have created $DATADIR/gitea"
    else
        echo "Creating $DATADIR/gitea"
        mkdir -p $DATADIR/gitea
        chown -R $USER_UID:$GROUP_GID $DATADIR/gitea
        chmod -R u+rwX,go+rX,go-w $DATADIR/gitea
    fi
fi
if [[ ! -d "$DATADIR/git/repositories" ]]; then
    if (( $DRYRUN )); then
        echo "Would have created $DATADIR/git/repositories"
    else
        echo "Creating $DATADIR/git/repositories"
        mkdir -p $DATADIR/git/repositories
        chown -R $USER_UID:$GROUP_GID $DATADIR/git/repositories
        chmod -R u+rwX,go+rX,go-w $DATADIR/git/repositories
    fi
fi
if [[ ! -d "$DATADIR/git/lfs" ]]; then
    if (( $DRYRUN )); then
        echo "Would have created $DATADIR/git/lfs"
    else
        echo "Creating $DATADIR/git/lfs"
        mkdir -p $DATADIR/git/lfs
        chown -R $USER_UID:$GROUP_GID $DATADIR/git/lfs
        chmod -R u+rwX,go+rX,go-w $DATADIR/git/lfs
    fi
fi


GITEA_DATA_FILE="$SOURCE/gitea_backup.zip"
echo "** Step 1 of 3: Gitea data START **"
echo "Copying Gitea files back from $GITEA_DATA_FILE"
# gitea_backup.zip contains:

# gitea-db.sql  - database dump in SQL form
# app.ini       - same as custom/conf/app.ini
#
# custom/       - All subfolders go back to data folder
#   conf/
#   log/
#   queues/
#   gitea.db    - The actual SQLite DB file, seems the same?
#   indexers/
#   sessions/
#   avatars/
# data/         - Again, all subfolders go back to data, same as custom??
#   conf/
#   log/
#   queues/
#   gitea.db   - Actual sqlite data file
#   indexers/
#   sessions/
#   avatars/
# log/          - Log files, we don't need these (will remove from backup script)

# So there seems to be a lot of duplication in this dump
# Even when I don't "gitea dump" with -C it still creates custom/ and data/
# I think we only want the /data dir
# Extract all to temp then copy

TEMPDIR=`mktemp -d`
# protect! because we're going to rm -rf this later
if [[ ! "$TEMPDIR" == /tmp/* ]]; then
    echo Error: expected mktemp to give us a dir in /tmp, being careful & aborting
fi
echo "Extracting archive..."
# We have to use 7z because that comes pre-installed on Synology but unzip doesn't
# Send to /dev/null as 7z writes a bunch of crap that doesn't translate well to some terminals
7z x -o$TEMPDIR $GITEA_DATA_FILE > /dev/null 2>&1
# Unfortunately 7z doesn't restore file permissions / ownership
# Docker Gitea has everything owned by 1000:1000
echo "Fixing permissions"
chown -R $USER_UID:$GROUP_GID $TEMPDIR
# And permissions are 755/644 for dirs / files
# The capital X only sets x bit on dirs, not files, which gives us 755/644
chmod -R u+rwX,go+rX,go-w $TEMPDIR
GITEA_DEST="$DATADIR/gitea"
if (( $DRYRUN )); then
    echo "Would have copied data directory $TEMPDIR/data to $GITEA_DEST"
    echo "This was the structure:"
    ls -la $TEMPDIR/data
else
    echo "Copying data directory $TEMPDIR/data to $GITEA_DEST"
    # Note -p is ESSENTIAL to preserve ownership
    cp -p -R -f $TEMPDIR/data/* $GITEA_DEST/
fi

if [[ ! "$SQLDEST" == "" ]]; then
    if (( $DRYRUN )); then
        echo "Would have copied $TEMPDIR/gitea-db.sql to $SQLDEST"
    else
        echo "Copying $TEMPDIR/gitea-db.sql to $SQLDEST"
        # Note -p is ESSENTIAL to preserve ownership
        cp -p -f $TEMPDIR/gitea-db.sql $SQLDEST
    fi
fi

rm -rf $TEMPDIR
echo "** Step 1 of 3: Gitea data DONE **"

# Now do repositories
# tar preserves owner/permissions, and we tarred relative to data/git/repositories
# so we can do this direct
# remove all existing data so it's clean
GIT_REPO_FILE="$SOURCE/gitrepos_backup.tar.bz2"
GIT_REPO_DEST="$DATADIR/git/repositories"
echo "** Step 2 of 3: Git repository data START **"
echo "Restoring git repository data"
if (( $DRYRUN )); then
    echo "Would have deleted $GIT_REPO_DEST/*"
    echo "Would have extracted $GIT_REPO_FILE to $GIT_REPO_DEST"
    echo "Repositories were: "
    # equivalent of depth = 2
    tar --exclude="*/*/*/*" -tf $GIT_REPO_FILE

else
    echo "Cleaning existing repo data"
    rm -rf $GIT_REPO_DEST/*
    echo "Extracting $GIT_REPO_FILE to $GIT_REPO_DEST"
    tar -xf $GIT_REPO_FILE -C $GIT_REPO_DEST
fi
echo "Git repositories done"
echo "** Step 2 of 3: Git repository data DONE **"


echo "** Step 3 of 3: Git-LFS data START **"
echo "Restoring Git-LFS data"
GIT_LFS_SRC="$SOURCE/lfs"
GIT_LFS_DEST="$DATADIR/git/lfs"
# There is no reason to delete LFS data since it's all immutable
# Instead rsync back like we did during backup
if (( $DRYRUN )); then
    echo "Would have synced LFS data from $GIT_LFS_SRC to $GIT_LFS_DEST"
else
    echo "Syncing LFS data from $GIT_LFS_SRC to $GIT_LFS_DEST"
    rsync -rLptgo $GIT_LFS_SRC/* $GIT_LFS_DEST/

    echo "Fixing LFS permissions"
    chown -R $USER_UID:$GROUP_GID $GIT_LFS_DEST
    # And permissions are 755/644 for dirs / files
    # The capital X only sets x bit on dirs, not files, which gives us 755/644
    chmod -R u+rwX,go+rX,go-w $GIT_LFS_DEST

fi

echo "** Step 3 of 3: Git-LFS data DONE **"
echo "Gitea data restored successfully"
