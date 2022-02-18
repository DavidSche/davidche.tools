#!/bin/bash

# `gitea dump` doesn't currently back up LFS data as well, only git repos
# It primarily backs up the SQL DB, and also the config / logs
# We'll backup like this:
#   * "gitea dump" to backup the DB and config etc
#   * tar / bzip all the repos since they will be skipped
#     * Not rotated because git data is immutable (normally) so has all data
#   * rsync LFS data directly from /volume/docker/gitea/git/lfs
#     * No need for rotation since all files are immutable
#
# This means our backup folder will contain:
#   * /gitea_data.zip - containing the gitea data
#   * /repositories/ - containing the bundles, structured owner/name.bundle
#   * /lfs/ - containing all the direct LFS data
#
# Stop on errors
set -e

# Gitea config / SQL DB backup rotation
CONTAINER=git_gitea_server
# Backup dir from our perspective
HOST_BACKUP_DIR="/volume1/backups/gitea"
# Git repo dir from our perspective (it's outside container)
HOST_GIT_REPO_DIR="/volume1/docker/gitea/git/repositories"
# Git LFS dir from our perspective (it's outside container)
HOST_GIT_LFS_DIR="/volume1/docker/gitea/git/lfs"
# Where we work on things (host and container)
TEMP_DIR="/tmp"

GITEA_DATA_FILENAME="gitea_backup.zip"
HOST_BACKUP_FILE="$HOST_BACKUP_DIR/$GITEA_DATA_FILENAME"

# Back up to temp files then copy on success to prevent syncing incomplete/bad files
CONTAINER_BACKUP_FILE_TEMP="$TEMP_DIR/gitea_dump_temp.zip"
docker exec -u git -i $(docker ps -qf "name=$CONTAINER") bash -c "rm -f $CONTAINER_BACKUP_FILE_TEMP"

echo Backing up Gitea data to $HOST_BACKUP_FILE via $CONTAINER:$CONTAINER_BACKUP_FILE_TEMP
docker exec -u git -i $(docker ps -qf "name=$CONTAINER") bash -c "/app/gitea/gitea dump --skip-repository --skip-log --file $CONTAINER_BACKUP_FILE_TEMP"
# copy this into backup folder (in container)
docker cp $(docker ps -qf "name=$CONTAINER"):$CONTAINER_BACKUP_FILE_TEMP $HOST_BACKUP_FILE

echo Backing up git repositories
# Git repos are in 2-level structure, owner/repository
# Again we MUST tar to a TEMP file and move into place when successful
GITREPO_BACKUP_FILE="$HOST_BACKUP_DIR/gitrepos_backup.tar.bz2"
GITREPO_BACKUP_FILE_TEMP=`mktemp -p $TEMP_DIR gitrepos_backup.tar.bz2.XXXXXX`
tar cjf $GITREPO_BACKUP_FILE_TEMP -C $HOST_GIT_REPO_DIR .
mv -f $GITREPO_BACKUP_FILE_TEMP $GITREPO_BACKUP_FILE

echo Backing up LFS data
# This syncs path/to/lfs to backup/dir/
# This will then be replicated directly to B2
# Yes this means we're storing LFS data twice but I prefer this to syncing to B2
# directly from the data dir, it makes the B2 sync simpler (just the whole folder)
rsync -rLptgo $HOST_GIT_LFS_DIR $HOST_BACKUP_DIR/

echo Gitea backup completed successfully
