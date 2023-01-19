#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table --tuples-only -c"

# check if an argument was provided
if [[ -z $1 ]]
then
  echo -e "Please provide an element as an argument."
else
  ELEMENT=$1
  
  # Determine if the argument is a number only (atomic_number)
  if [[ $ELEMENT =~ ^[0-9]+$ ]]
  then
    # it's a number
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$ELEMENT")
  else
    # it's not a number
    # Check if the string matches with 'symbol' OR 'name'
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$ELEMENT'")

    if [[ -z $ATOMIC_NUMBER ]]
    then
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name='$ELEMENT'")
    fi
  fi

  # If the atomic_number exists (i.e. there is a ROW for the inputted information) 
  if [[ $ATOMIC_NUMBER -ne 0 ]]
  then
    # Output the information
    echo $($PSQL "SELECT atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, type FROM properties INNER JOIN types USING(type_id) INNER JOIN elements USING(atomic_number) WHERE atomic_number=$ATOMIC_NUMBER") | while read NUM BAR SYMBOL BAR NAME BAR MASS BAR MELT BAR BOIL BAR TYPE
    do
      # NUM BAR SYMBOL BAR NAME BAR MASS BAR MELT BAR BOIL BAR TYPE
      echo -e "The element with atomic number $NUM is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
    done
  else
    echo -e "I could not find that element in the database."
  fi
fi