#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"


MAIN_MENU(){
  if [[ $1 ]]
  then
   echo -e "\n$1"
  fi

  # get service id
  SERVICE_ID=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICE_ID" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done
  
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-5]+$ ]]
  then
    MAIN_MENU "Please select a valid number. What would you like today?"
  else
    SERVICE_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    FORMATTED_SERVICE_SELECTED=$(echo $SERVICE_SELECTED | sed 's/ //')
    GET_CUSTOMER_INFO
  fi

}

GET_CUSTOMER_INFO(){
  # get customer information
  echo "Please enter your phone number:"
  read CUSTOMER_PHONE
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_ID ]]
  then
    #ask for name
    echo "I don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    # get phone number
    PHONE_NUM_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    # get new customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE' ")
  fi
  GET_APPT_INFO
}

GET_APPT_INFO(){
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
  echo "What time would you like your $FORMATTED_SERVICE_SELECTED,$CUSTOMER_NAME?"
  read SERVICE_TIME
  INSERT_SERVICE_TIME=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  
  echo "I have put you down for a $FORMATTED_SERVICE_SELECTED at $SERVICE_TIME,$CUSTOMER_NAME."
}

MAIN_MENU "Welcome to my salon, how can I help you?"
