#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

NUMBEROFGUESSES=0

GENERATESECRETNUMBER () {
  # random number generation
  SECRETNUMBER=$(( $RANDOM % 1000 + 1 ))
}

GETUSERNAME () {
  echo "Enter your username: "
  read USERNAME
}

CHECKIFNEWUSER () {
  CURRENTUSER=$($PSQL "SELECT name FROM users WHERE name = '$USERNAME'")
  if [[ -z $CURRENTUSER ]]
  then
   # if new user
    echo "Welcome, $USERNAME!  It looks like this is your first time here."
    INSERTNAME=$($PSQL "INSERT INTO users (name) VALUES ('$USERNAME')")
    NAMEID=$($PSQL "SELECT name_id FROM users WHERE name = '$USERNAME'")    
   else
   # if currrent user
    NAMEID=$($PSQL "SELECT name_id FROM users WHERE name = '$USERNAME'")  
    # display greeting
    GAMESPLAYED=$($PSQL "SELECT COUNT(name_id) FROM games WHERE name_id = $NAMEID")
    BESTGAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE name_id = $NAMEID")
    echo Welcome back, $USERNAME! You have played $GAMESPLAYED games, and your best game took $BESTGAME guesses.   
   fi
}  

PLAYGAME () {
  echo "Guess the secret number between 1 and 1000:"
  while [[ 1 ]]
  do
    read GUESSEDNUMBER
    if [[ ! $GUESSEDNUMBER =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
      continue
    fi
    if (( $GUESSEDNUMBER > $SECRETNUMBER ))
    then
      echo "It's lower than that, guess again:"
      NUMBEROFGUESSES=$(( $NUMBEROFGUESSES + 1 ))
      continue
    fi
    if (( $GUESSEDNUMBER < $SECRETNUMBER ))
    then
      echo "It's higher than that, guess again:"
      NUMBEROFGUESSES=$(( $NUMBEROFGUESSES + 1 ))
      continue
    fi
    if (( $GUESSEDNUMBER == $SECRETNUMBER ))
    then
      NUMBEROFGUESSES=$(( $NUMBEROFGUESSES + 1 ))  
      echo "You guessed it in $NUMBEROFGUESSES tries. The secret number was $SECRETNUMBER. Nice job!"
      break
    fi
  done
 }

 RECORDTHEGAME () {
   INSERTGAME=$($PSQL "INSERT INTO games (name_id, number_of_guesses, secret_number) VALUES ($NAMEID, $NUMBEROFGUESSES, $SECRETNUMBER)")
 }


GENERATESECRETNUMBER
GETUSERNAME
CHECKIFNEWUSER
PLAYGAME
RECORDTHEGAME
