#!/bin/sh
SCRIPT_DIR=$(dirname "$(realpath "$0")")
################################################
#imports
. "$SCRIPT_DIR"/headers/variables.sh
. "$SCRIPT_DIR"/headers/mysql.sh
. "$SCRIPT_DIR"/headers/docker.sh
. "$SCRIPT_DIR"/headers/validate_env.sh
. "$SCRIPT_DIR"/headers/app.sh
################################################

printf "Validating .env file...\n\n"
if ! [ -f "$SCRIPT_DIR/.env" ]; then
  cp "$SCRIPT_DIR"/.env.example "$SCRIPT_DIR"/.env
    ################################################
    # Update or add PUID and PGID in the .env file

    update_env_var "PUID" "$DEFAULT_PUID" "$ENV_FILE"
    update_env_var "PGID" "$DEFAULT_PGID" "$ENV_FILE"
    printf ".env file validated.\n\n"
    ################################################
fi
printf ".env file looks ok.\n\n"

printf "Validating nginx site file...\n\n"
if ! [ -f "$NGINX_REAL_SITE_PATH" ]; then

  cp "$NGINX_EXAMPLE_SITE_PATH" "$NGINX_REAL_SITE_PATH"
  printf "nginx site file validated.\n\n"
fi
printf "nginx site file looks ok.\n\n"

printf "Validating main db file...\n\n"
if ! [ -f "$MAIN_DB_FILE_PATH" ]; then
  create_sql_file_if_not_exist "$MYSQL_ENTRY_POINT_CREATE_MAIN_DB_CONTENT" "$MAIN_DB_FILE_PATH"
  printf "main db file validated.\n\n"
fi
printf "Validating test db file...\n\n"
if ! [ -f "$TEST_DB_FILE_PATH" ]; then
  create_sql_file_if_not_exist "$MYSQL_ENTRY_POINT_CREATE_TEST_DB_CONTENT" "$TEST_DB_FILE_PATH"
  printf "test db file validated.\n\n"
fi
printf "db files looks ok.\n\n"

if [ "$FIRST_ARG" = "build" ]; then
  docker_down
  docker_build
  docker_up
  init_app
fi

if [ "$FIRST_ARG" = "up" ]; then
  docker_up
  exit 0
fi

if [ "$FIRST_ARG" = "down" ]; then
  docker_down
  exit 0
fi

################################################
# Check if the line already exists in the file #

if ! grep -qxF "$hosts" /etc/hosts; then
    # If the line doesn't exist, append it to the file
    echo "$hosts" | sudo tee -a /etc/hosts > /dev/null
    echo "host appended successfully."
    exit 0
fi
################################################

