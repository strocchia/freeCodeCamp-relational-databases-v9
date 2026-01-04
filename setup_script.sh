#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

TRUNC=$($PSQL "truncate table customers, appointments")
echo $TRUNC
ALTER_CUSTOMER_SEQ=$($PSQL "alter sequence customers_customer_id_seq restart with 1")
echo $ALTER_CUSTOMER_SEQ
ALTER_APPOINTMENT_SEQ=$($PSQL "alter sequence appointments_appointment_id_seq restart with 1")
echo $ALTER_APPOINTMENT_SEQ