#!/bin/bash

PSQL=("psql --username=freecodecamp --dbname=periodic_table -Atc")

if [[ ! $1 ]]
then
  echo Please provide an element as an argument.
else
  # if input is a number
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    # try to find by atomic_number
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = $1")
  fi

  # try to find by symbol
  if [[ -z $ATOMIC_NUMBER ]]
  then
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$1'")
  fi

  # try to find by name
  if [[ -z $ATOMIC_NUMBER ]]
  then
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$1'")
  fi

  if [[ -z $ATOMIC_NUMBER ]]
  then
    echo I could not find that element in the database.
  else
    echo $($PSQL "SELECT name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements JOIN properties USING(atomic_number) JOIN types USING(type_id) WHERE atomic_number = $ATOMIC_NUMBER") | while IFS="|" read NAME SYMBOL TYPE MASS MELT BOIL
    do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
    done
  fi
fi
