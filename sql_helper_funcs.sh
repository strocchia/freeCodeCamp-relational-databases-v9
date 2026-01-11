#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
DB_TABLE="user_info"

echo $($PSQL "truncate $DB_TABLE")
echo $($PSQL "alter sequence ${DB_TABLE}_user_id_seq restart with 1")