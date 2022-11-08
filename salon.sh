#!/bin/bash

PSQL='psql --username=freecodecamp --dbname=salon --tuples-only -c'
echo -e "\n~~~~ MY SALON ~~~~\n"
echo -e "\nWelcome to my salon how can I help you?\n"

MAIN_MENU () {
if [[ $1 ]]
then 
  echo -e "\n$1"
fi
DISPLAY_SERVICES=$($PSQL "select * from services")
echo "$DISPLAY_SERVICES" | while read SERVICE_ID BAR NAME
 do  
    echo "$SERVICE_ID) $NAME"
done
read SERVICE_ID_SELECTED
}

MAIN_MENU 
RESULTANT_SERVICE_ID=$($PSQL "select service_id from services where service_id=$SERVICE_ID_SELECTED")
if [[ -z $RESULTANT_SERVICE_ID ]] 
then
  MAIN_MENU "I could not find that service. What would you like today?"
else
  echo "What's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_INTO_CUSTOMER=$($PSQL "insert into customers(phone,name) values('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi
  RESULTANT_SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
  echo -e "\nWhat time would you like your $(echo $RESULTANT_SERVICE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')"
  read SERVICE_TIME

  RESULTANT_CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
  INSERT_APPOINTMENT=$($PSQL "insert into appointments(customer_id,service_id, time) values($RESULTANT_CUSTOMER_ID,$RESULTANT_SERVICE_ID, '$SERVICE_TIME')")
  echo "I have put you down for a $(echo $RESULTANT_SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."

fi


