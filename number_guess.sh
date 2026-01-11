#!/bin/bash

# echo -e "\n~~~Random number guessing game~~~\n"

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
## Hint: can dump db with 'pg_dump -cC --inserts -U freecodecamp number_guess > number_guess.sql' on command line

SECRET_NUMBER=$((RANDOM % 1000 + 1))

echo "Enter your username:"
read USERNAME

# Look up user id by username
USER_ID=$($PSQL "select user_id from user_info where username='$USERNAME'")

if [[ $USER_ID ]]
then
  echo $($PSQL "select username, games_played, best_game from user_info where user_id='$USER_ID'") | while IFS='|' read USERNAME GAMES_PLAYED BEST_GUESSES
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GUESSES guesses."
  done
else
  INSERT_USER_RESULT=$($PSQL "insert into user_info (username) values ('$USERNAME')")
  if ! [[ -z $INSERT_USER_RESULT ]]
  then
    USERNAME=$($PSQL "select username from user_info where username='$USERNAME'")
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  fi
fi

# get 'games played' and 'best guesses' from the database
GAMES_PLAYED=$($PSQL "select games_played from user_info where username = '$USERNAME'")
BEST_GUESSES=$($PSQL "select best_game from user_info where username = '$USERNAME'")

num_guesses=0

MAIN_FUNC() {
  if [[ $num_guesses -eq 0 ]];
  then
    echo -e "\nGuess the secret number between 1 and 1000:"
    read GUESS
    ((num_guesses++))
  fi

  while [[ $GUESS != $SECRET_NUMBER ]];
  do
    if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
      echo "That is not an integer, guess again:"
    elif [[ $GUESS -lt $SECRET_NUMBER ]];
    then
      echo "It's higher than that, guess again:"
    elif [[ $GUESS -gt $SECRET_NUMBER ]];
    then
      echo "It's lower than that, guess again:"
    fi

    read GUESS
    ((num_guesses++))
  done

  echo "You guessed it in $num_guesses tries. The secret number was $SECRET_NUMBER. Nice job!"

  if [[ $BEST_GUESSES -eq 0 ]]
  then
    # this is default condition (first time user)
    NEW_BEST_GUESSES=$num_guesses
  elif [[ $num_guesses -lt $BEST_GUESSES ]]
  then
    NEW_BEST_GUESSES=$num_guesses
  else
    # number of guesses is greater than BEST_GUESSES
    NEW_BEST_GUESSES=$BEST_GUESSES
  fi

  UPDATE_USER_DATA=$($PSQL "update user_info set games_played = ($GAMES_PLAYED+1), best_game = $NEW_BEST_GUESSES where username = '$USERNAME'")
  if ! [[ -z $UPDATE_USER_DATA ]]
  then
    exit 0
  fi
}

MAIN_FUNC
