#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

# Clear out the table contents
# echo $($PSQL "TRUNCATE customers, appointments") 

echo -e "\n~~~ Schedule Salon Appointment ~~~\n"

MAIN_MENU() {
  PRINT_SERVICES=$($PSQL "SELECT * FROM services")
  echo "$PRINT_SERVICES" | while read NUMBER BAR NAME
  do
    echo -e "$NUMBER) $NAME"
  done

  # echo -e "\nEnter a service ID"
  read SERVICE_ID_SELECTED

  # Check service is a valid number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    echo -e "\nThe selected service is not a number. Please try again."
    MAIN_MENU
  fi

  # Check service is valid in the database
  SERVICE_VALID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_VALID ]]
  then
    echo -e "\nThe selected service does not exist. Please try again."
    MAIN_MENU
  fi

  # Get other appointment information
  echo -e "\nWhat is your phone number?"
  read CUSTOMER_PHONE

  # Get customer name & insert to table if they don't exist
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_ID ]]
  then
    echo -e "\nYou're new here! What's your name?"
    read CUSTOMER_NAME

    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    echo "$INSERT_CUSTOMER"

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  fi

  echo -e "\nWhat time would you like the appointment?"
  read SERVICE_TIME

  # Add appointment
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  # Get extra information
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  # Formatted information
  FORMATTED_CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')
  FORMATTED_SERVICE_NAME=$(echo $SERVICE_NAME | sed -r 's/^ *| *$//g')

  # Output confirmation
  echo -e "\nI have put you down for a $FORMATTED_SERVICE_NAME at $SERVICE_TIME, $FORMATTED_CUSTOMER_NAME."

}

MAIN_MENU