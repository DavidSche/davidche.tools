#!/bin/bash
export LC_ALL=C

archive="$1"

#container_name="root_gitea_1"
CONTAINER=root_gitea_1
CONTAINER_NAME=$(docker ps -qf "name=$CONTAINER")

now=$(date +"%Y%m%d-%H%M%S")
# gitea_dir: it's the directory in the volume attached to the container which contains gitesa' data directory
gitea_dir="/data/containers/gitea"
gitea_data_dir="${gitea_dir}/data"
restore_dir="/tmp/gitea-restore-${now}"
log_file="${restore_dir}/restore-progress.log"
host="127.0.0.1"
port="3307"
database="gitea"
user="root"
password="..."
number_of_args="${#}"

error () {
  printf "%s: %s\n" "$(basename "${BASH_SOURCE}")" "${1}" >&2
  exit 1
}

trap 'error "An unexpected error occurred."' ERR

sanity_check () {
  # Check whether any arguments were passed
  if [ "${number_of_args}" -lt 1 ]; then
      error "Script requires the absolute path of the .tar.gz backup archive as an argument."
  fi
}

restore () {
  mysqldump_args=(
    "-u${user}"
    "-p${password}"
    "-h${host}"
    "-P${port}"
    "--add-drop-table"
    "--single-transaction"
    "--add-locks"
  )

  mysql_args=(
    "-u${user}"
    "-u${user}"
    "-p${password}"
    "-h${host}"
    "-P${port}"
  )

  docker stop "${container_name}" > /dev/null

  cd "${restore_dir}"

  # Save current files
  mkdir -p current/data

  mv "${gitea_data_dir}"/* current/data/

  # Dump current database
  mysqldump "${mysqldump_args[@]}" "${database}" > current/db.sql

  # Restore  files
  tar xfz "${archive}"
  cp -r data/* "${gitea_data_dir}/"

  # Restore database
  mysql "${mysql_args[@]}" "${database}" < db.*.sql

  docker start "${container_name}" > /dev/null
}

printf "\n========================================================================================="
printf "\nGitea Restore"
printf "\n=========================================================================================\n"

mkdir -p "${restore_dir}"

sanity_check && restore 2> "${log_file}"

if [[ -s "${log_file}" ]]
then
  printf "\nRestore failure! Check ${log_file} for more information."
  printf "\n=========================================================================================\n\n"
else
  printf "...SUCCESS!\n"
  printf "You can remove the directory ${restore_dir} if everything looks good."
  printf "\n=========================================================================================\n\n"
fi