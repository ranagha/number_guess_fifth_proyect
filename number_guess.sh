#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

TRIES=1
RANDOM_NUMBER=$((1 + RANDOM % 1000))
echo "Enter your username:"

read USERNAME;

FULL_USER=$($PSQL "select name, games, best from users where name='$USERNAME';")
GAMES_OLD=$((1))
BEST_OLD=$((999))
if [[ -z $FULL_USER ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else 
  echo "$FULL_USER" | while read USERNAME_BACK BAR GAMES BAR BEST
  do
    echo "Welcome back, $USERNAME! You have played $GAMES games, and your best game took $BEST guesses."
    GAMES_OLD=$((GAMES))
    BEST_OLD=$((BEST))
  done
fi

echo "Guess the secret number between 1 and 1000:"

read PREDICTION

while [[ $RANDOM_NUMBER -ne $PREDICTION ]]
do
  if [[ ! $PREDICTION =~ ^[0-9]+$ ]] 
  then
    echo "That is not an integer, guess again:"
  else
    if [[ $RANDOM_NUMBER -lt $PREDICTION ]]
    then
      echo "It's lower than that, guess again:"
         else 
      echo "It's higher than that, guess again:"
    fi 
    TRIES=$((TRIES + 1))
  fi
  read PREDICTION
done

echo "You guessed it in $TRIES tries. The secret number was $RANDOM_NUMBER. Nice job!"

if [[ -z $FULL_USER ]]
then
  INSERT_RESULT=$($PSQL "insert into users(name, games, best) values ('$USERNAME', 1, $TRIES);")
else
  if [[ $TRIES -lt $BEST_OLD ]]
  then
    BEST_OLD=$((TRIES))
  fi
  GAMES_UPDATED=$((GAMES_OLD + 1))
  UPDATE_RESULT=$($PSQL "update users set games=$GAMES_UPDATED, best=$BEST_OLD where name='$USERNAME';")
fi
