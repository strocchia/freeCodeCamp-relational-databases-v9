#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ ! $1 ]]
then
  echo "Please provide an element as an argument."
  exit 0
else
  # check if number
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ATOMIC_NUM=$1

    echo $($PSQL "select symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, type from elements 
    join properties using (atomic_number) 
    join types using (type_id) where atomic_number = $ATOMIC_NUM")| while IFS='|' read SYM NAME ATOM_MASS MP_CELS BP_CELS TYPE
    do
      echo "The element with atomic number $ATOMIC_NUM is $NAME ($SYM). It's a $TYPE, with a mass of $ATOM_MASS amu. $NAME has a melting point of $MP_CELS celsius and a boiling point of $BP_CELS celsius."
    done
  else
    # query is a string
    if [[ $1 =~ ^[A-Za-z]+$ ]]
    then

      # check query for valid atomic number
      ATOMIC_NUM=$($PSQL "select atomic_number from elements where (symbol = '$1' or name = '$1')")

      if [[ $ATOMIC_NUM ]]
      then
        # try query with symbol or name condition in where clause
        echo $($PSQL "select symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, type from elements 
        join properties using (atomic_number) 
        join types using (type_id) where (symbol = '$1' or name = '$1')")| while IFS='|' read SYM NAME ATOM_MASS MP_CELS BP_CELS TYPE
        do
          echo "The element with atomic number $ATOMIC_NUM is $NAME ($SYM). It's a $TYPE, with a mass of $ATOM_MASS amu. $NAME has a melting point of $MP_CELS celsius and a boiling point of $BP_CELS celsius."
        done
      else
        echo "I could not find that element in the database."
      fi
    fi
  fi 
fi