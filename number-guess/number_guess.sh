#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -qAtc"

NUM=$(($RANDOM % 1000 + 1))

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")

if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $PSQL "INSERT INTO users (name) VALUES ('$USERNAME')"
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")
else
  # get user data
  echo $($PSQL "SELECT COUNT(game_id), MAX(num_guesses) FROM games JOIN users USING (user_id) WHERE user_id=$USER_ID") | while IFS='|' read COUNT MAX
  do
    echo "Welcome back, $USERNAME! You have played $COUNT games, and your best game took $MAX guesses."
  done
fi

echo "Guess the secret number between 1 and 1000:"
read GUESS
NUM_TRIES=1
while [[ $GUESS != $NUM ]]
do
  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    if [[ $GUESS -gt $NUM ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
    NUM_TRIES=$(($NUM_TRIES+1))
  else
    echo "That is not an integer, guess again:"
  fi
  read GUESS
done
echo "You guessed it in $NUM_TRIES tries. The secret number was $NUM. Nice job!"
# store the data
$PSQL "INSERT INTO games (number, num_guesses, user_id) VALUES ($NUM, $NUM_TRIES, $USER_ID)"
