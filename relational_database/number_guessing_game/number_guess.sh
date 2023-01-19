#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"


echo -e "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

if [[ $USER_ID -ne 0 ]]
then
  GAMES_PLAYED=$($PSQL "SELECT total_games FROM users WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$USER_ID")
  # output game history information
  echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  # add user to the database
  echo -e "Welcome, $USERNAME! It looks like this is your first time here."
  # adding to the database ONLY at the end of a game (i.e. when they get it right)
fi

echo -e "Guess the secret number between 1 and 1000:"
NUMBER=$((RANDOM%1000+1))
echo $NUMBER
GUESSES=1

read INPUT

# check if a game is active
while [[ $INPUT -ne $NUMBER ]]
do
  (( GUESSES++ ))

  # check the guessed number and return a clue

  # check if the input is a valid number
  if [[ ! $INPUT =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    # is input > or < RANDOM
    if (( $INPUT > $NUMBER ))
    then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
  fi

  read INPUT
done

echo -e "You guessed it in $GUESSES tries. The secret number was $NUMBER. Nice job!"


if [[ $USER_ID -ne 0 ]]
then
  # user exists, update stats

  # Increment # of games played for user
  NUM_GAMES=$($PSQL "SELECT total_games FROM users WHERE user_id=$USER_ID")
  (( NUM_GAMES++ ))
  INCREMENT_NUM_GAMES=$($PSQL "UPDATE users SET total_games=$NUM_GAMES WHERE user_id=$USER_ID")

  # Add to the database if $GUESSES is > currently stored.
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$USER_ID")

  if [[ $GUESSES -lt $BEST_GAME ]]
  then
    UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game=$GUESSES WHERE user_id=$USER_ID")
  fi

else
  # user doesn't exist, initialize stats
  INSERT_USER=$($PSQL "INSERT INTO users(username, total_games, best_game) VALUES('$USERNAME', 1, $GUESSES)")
fi
