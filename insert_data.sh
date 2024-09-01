#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

#DROP DATABASE IF EXISTS worldcup;
#CREATE DATABASE worldcup;
#USE worldcup;

#DROP TABLE IF EXISTS games;
echo "$($PSQL "DROP TABLE IF EXISTS games")"

#DROP TABLE IF EXISTS teams;
echo "$($PSQL "DROP TABLE IF EXISTS teams")"


#CREATE TABLE teams(
#  team_id SERIAL PRIMARY KEY,
#  name VARCHAR(50) UNIQUE NOT NULL
#);

#"CREATE TABLE teams()"
#"ALTER TABLE teams ADD COLUMN team_id SERIAL PRIMARY KEY"
#"ALTER TABLE teams ADD COLUMN name VARCHAR(50) UNIQUE NOT NULL"

echo "$($PSQL "CREATE TABLE teams()")"
echo "$($PSQL "ALTER TABLE teams ADD COLUMN team_id SERIAL PRIMARY KEY")"
echo "$($PSQL "ALTER TABLE teams ADD COLUMN name VARCHAR(50) UNIQUE NOT NULL")"


#CREATE TABLE games(
#  game_id SERIAL PRIMARY KEY,
#  year INT NOT NULL,
#  round VARCHAR(50) NOT NULL,
#  winner_goals INT NOT NULL, 
#  opponent_goals INT NOT NULL, 
#  winner_id INT NOT NULL,
#  opponent_id INT NOT NULL,
#  FOREIGN KEY (winner_id) REFERENCES teams(team_id),
#  FOREIGN KEY (opponent_id) REFERENCES teams(team_id)
#);

echo "$($PSQL "CREATE TABLE games()")"
echo "$($PSQL "ALTER TABLE games ADD COLUMN game_id SERIAL PRIMARY KEY")"
echo "$($PSQL "ALTER TABLE games ADD COLUMN year INT NOT NULL")"
echo "$($PSQL "ALTER TABLE games ADD COLUMN round VARCHAR(50) NOT NULL")"
echo "$($PSQL "ALTER TABLE games ADD COLUMN winner_goals INT NOT NULL")"
echo "$($PSQL "ALTER TABLE games ADD COLUMN opponent_goals INT NOT NULL")"
echo "$($PSQL "ALTER TABLE games ADD COLUMN winner_id INT NOT NULL")"
echo "$($PSQL "ALTER TABLE games ADD COLUMN opponent_id INT NOT NULL")"
echo "$($PSQL "ALTER TABLE games ADD CONSTRAINT FK_WinnerID FOREIGN KEY (winner_id) REFERENCES teams(team_id)")"
echo "$($PSQL "ALTER TABLE games ADD CONSTRAINT FK_OpponentID FOREIGN KEY (opponent_id) REFERENCES teams(team_id)")"


# AHORA TENGO QUE INSERTAR LOS DATOS

# Procesa cada línea de games.csv, saltando la primera línea
tail -n +2 games.csv | while IFS=, read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # COMPRUEBO SI EXISTE EL EQUIPO GANADOR
  WINNER_QUERY=$($PSQL "SELECT name FROM teams WHERE name = '$WINNER'")

  # Si el equipo ganador no existe, lo agrego a la tabla teams
  if [[ -z $WINNER_QUERY ]]
  then
    $PSQL "INSERT INTO teams(name) VALUES('$WINNER')"
  fi

  # COMPRUEBO SI EXISTE EL EQUIPO PERDEDOR
  OPPONENT_QUERY=$($PSQL "SELECT name FROM teams WHERE name = '$OPPONENT'")

  # Si el equipo perdedor no existe, lo agrego a la tabla teams
  if [[ -z $OPPONENT_QUERY ]]
  then
    $PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')"
  fi

  # RECUPERO EL WINNER ID
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")

  # RECUPERO EL OPPONENT ID
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")

  # Si ambos IDs no están vacíos, inserto el partido en la tabla games
  if [[ -n $WINNER_ID && -n $OPPONENT_ID ]]
  then 
    $PSQL "INSERT INTO games(year, round, winner_goals, opponent_goals, winner_id, opponent_id) \
    VALUES($YEAR, '$ROUND', $WINNER_GOALS, $OPPONENT_GOALS, $WINNER_ID, $OPPONENT_ID)"
  fi

done
