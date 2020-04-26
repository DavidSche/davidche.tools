#!/usr/bin/env bash
set -e

#
# Retreive and check mode, which can either be "BACKUP" or "RESTORE".
# Based on the mode, different default options will be set.
#

MODE=${MODE:-BACKUP}
TARBALL=${TARBALL:-}
DB_PORT=${DB_PORT:-3306}
DB_USER=${DB_USER:-root}

case "${MODE^^}" in
    'BACKUP')
        if [[ "${TARBALL^^}" != "" ]]
        then
            OPTIONS="--outputdir=${TARBALL}"
        else
            OPTIONS=${OPTIONS:--c}
        fi
        ;;
    'RESTORE')
        OPTIONS=${OPTIONS:--o}
        ;;
    *)
        echo 'ERROR: Please set MODE environment variable to "BACKUP" or "RESTORE"' >&2
        exit 255
esac

#
# Retreive backup settings and set some defaults.
# Then display the settings on standard out.
#

USER="mybackup"

echo "${MODE} SETTINGS"
echo "================"
echo
echo "  User:               ${USER}"
echo "  UID:                ${BACKUP_UID:=666}"
echo "  GID:                ${BACKUP_GID:=666}"
echo "  Umask:              ${UMASK:=0022}"
echo
echo "  Base directory: i   ${BASE_DIR:=/backup}"
[[ "${MODE^^}" == "RESTORE" ]] && \
echo "  Restore directory:  ${RESTORE_DIR}"
echo
echo "  Options:            ${OPTIONS}"
echo

#
# Detect linked container settings based on Docker's environment variables.
# Display the container informations on standard out.
#

if [[ -z "${DB_HOST}" ]]
then
    echo "ERROR: Couldn't find the SQL host." >&2
    echo >&2
    echo "Please set the DB_HOST environment variable" >&2
    exit 1
fi

if [[ -z "${DB_PASS}" ]]
then
    echo "ERROR: Couldn't find the password for the root user." >&2
    echo >&2
    echo "Please set the DB_PASS environment variable" >&2
    exit 1
fi

echo "DATABASE SETTINGS"
echo "================="
echo
echo "  Host:      ${DB_HOST}"
echo "  Port:      ${DB_PORT}"
echo "  User:      ${DB_USER}"
if [[ -n "${DB_NAME}" ]]
then
    echo "  Database:  ${DB_NAME}"
fi
echo

#
# Change UID / GID of backup user and settings umask.
#

[[ "$(id -u ${USER})" == "${BACKUP_UID}" ]] || usermod  -o -u $BACKUP_UID ${USER}
[[ "$(id -g ${USER})" == "${BACKUP_GID}" ]] || groupmod -o -g $BACKUP_GID ${USER}

umask ${UMASK}

#
# Building common CLI options to use for mydumper and myloader.
#
#

CLI_OPTIONS="-v 3 -h ${DB_HOST} -P ${DB_PORT} -u ${DB_USER} -p ${DB_PASS}"

if [[ -n "${DB_NAME}" ]]
then
    CLI_OPTIONS+=" -B ${DB_NAME}"
fi

CLI_OPTIONS+=" ${OPTIONS}"

#
# When MODE is set to "BACKUP", then mydumper has to be used to backup the database.
#

echo "${MODE^^}"
echo "======="
echo

if [[ "${MODE^^}" == "BACKUP" ]]
then

    printf "===> Creating base directory... "
    mkdir -p ${BASE_DIR}
    echo "DONE"

    printf "===> Changing owner of base directory... "
    chown ${USER}: ${BASE_DIR}
    echo "DONE"

    printf "===> Changing into base directory... "
    cd ${BASE_DIR}
    echo "DONE"

    echo "===> Starting backup..."
    if [[ "${TARBALL^^}" != "" ]]
    then
        exec su -pc "mydumper ${CLI_OPTIONS} && tar -czvf ${TARBALL}.tgz ${TARBALL} && rm -rf ${TARBALL}" ${USER}
    else
        exec su -pc "mydumper ${CLI_OPTIONS}" ${USER}
    fi

#
# When MODE is set to "RESTORE", then myloader has to be used to restore the database.
#

elif [[ "${MODE^^}" == "RESTORE" ]]
then

    printf "===> Changing into base directory... "
    cd ${BASE_DIR}
    echo "DONE"

    if [[ "${TARBALL^^}" != "" ]]
    then
        RESTORE_DIR=${TARBALL}
        rm -rf "${RESTORE_DIR}"
        echo "===> Restoring database from ${RESTORE_DIR}..."
        exec su -pc "tar -xvf ${TARBALL}.tgz ${RESTORE_DIR} && myloader --directory=${RESTORE_DIR} ${CLI_OPTIONS}" ${USER}
    else
        if [[ -z "${RESTORE_DIR}" ]]
        then
            printf "===> No RESTORE_DIR set, trying to find latest backup... "
            RESTORE_DIR=$(find . -maxdepth 1)
            if [[ -n "${RESTORE_DIR}" ]]
            then
                echo "DONE"
            else
                echo "FAILED"
                echo "ERROR: Auto detection of latest backup directory failed!" >&2
                exit 1
            fi
        fi
        echo "===> Restoring database from ${RESTORE_DIR}..."
        exec su -pc "myloader --directory=${RESTORE_DIR} ${CLI_OPTIONS}" ${USER}
    fi
fi
