#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

TRUNCATE=$($PSQL "truncate table games, teams")
echo $TRUNCATE

ALTER_TEAM_SEQUENCE_ID=$($PSQL "alter sequence teams_team_id_seq restart with 1")
ALTER_GAME_SEQUENCE_ID=$($PSQL "alter sequence games_game_id_seq restart with 1")

COUNTER=0
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WIN_GOALS OPP_GOALS
do
  if [[ year != $YEAR ]]
  then
    ((COUNTER++))

    # find winner team
    FIND_WINNER_TEAM=$($PSQL "select name from teams where name = '$WINNER'")

    # if not exists, insert into teams table
    if [[ -z $FIND_WINNER_TEAM ]]
    then
      INSERT_WINNER_RES=$($PSQL "insert into teams (name) values ('$WINNER')")
      echo $COUNTER $INSERT_WINNER_RES
    fi

    # find opponent team
    FIND_OPPONENT_TEAM=$($PSQL "select name from teams where name = '$OPPONENT'")

    # if not exists, insert into teams table
    if [[ -z $FIND_OPPONENT_TEAM ]]
    then
      INSERT_OPPONENT_RES=$($PSQL "insert into teams (name) values ('$OPPONENT')")
      echo $COUNTER $INSERT_OPPONENT_RES
    fi

    # insert game data
    # find winner ID
    WINNER_ID=$($PSQL "select team_id from teams where name = '$WINNER'")
    # find opponent ID
    OPPONENT_ID=$($PSQL "select team_id from teams where name = '$OPPONENT'")
    INSERT_GAME=$($PSQL "insert into games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) values ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WIN_GOALS, $OPP_GOALS)")
    echo $INSERT_GAME

    # if [[ COUNTER -eq 5 ]]
    # then
    #   break
    # fi
  fi
done
