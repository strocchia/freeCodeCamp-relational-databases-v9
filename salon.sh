#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "$($PSQL "select * from services order by service_id")" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID)" "$SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "Service ID must be an integer."
  else
    # try to find service id
    SERVICE_ID=$($PSQL "select service_id from services where service_id = '$SERVICE_ID_SELECTED'")

    if [[ -z $SERVICE_ID ]]
    then
      MAIN_MENU "I could not find that service, what would you like today?"
    else
      # get service name for db entry later
      SERVICE_NAME=$($PSQL "select name from services where service_id = '$SERVICE_ID'")
      FORMATTED_SERVICE_NAME=$(echo $SERVICE_NAME | sed 's/ //g')

      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_ID ]]
      then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        FORMATTED_CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed 's/ //g')
        echo $FORMATTED_CUSTOMER_NAME

        INSERT_CUSTOMER=$($PSQL "insert into customers (phone, name) values ('$CUSTOMER_PHONE', '$FORMATTED_CUSTOMER_NAME')")

        echo -e "\nWhat time would you like your cut, Fabio?"
        read SERVICE_TIME

        # get customer ID again, since it should now exist
        CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")

        INSERT_APPOINTMENT=$($PSQL "insert into appointments (customer_id, service_id, time) values ('$CUSTOMER_ID', '$SERVICE_ID', '$SERVICE_TIME')")
        echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $FORMATTED_CUSTOMER_NAME."
      else
        # customer id exists; find customer name using that criteria
        CUSTOMER_NAME=$($PSQL "select name from customers where phone = '$CUSTOMER_PHONE'")
        FORMATTED_CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed 's/ //g')
        echo $FORMATTED_CUSTOMER_NAME

        echo -e "\nWhat time would you like your cut, $FORMATTED_CUSTOMER_NAME?"
        read SERVICE_TIME

        INSERT_APPOINTMENT=$($PSQL "insert into appointments (customer_id, service_id, time) values ('$CUSTOMER_ID', '$SERVICE_ID', '$SERVICE_TIME')")
        echo -e "\nI have put you down for a $FORMATTED_SERVICE_NAME at $SERVICE_TIME, $FORMATTED_CUSTOMER_NAME."
      fi
    fi
  fi
}

MAIN_MENU