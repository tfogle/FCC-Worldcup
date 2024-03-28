#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

#Truncate tables before entering all data
echo $($PSQL "TRUNCATE teams, games")
#Read contents of csv file
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != 'year' ]]
  then
    #get team_id of winner team
    TEAM_ID_WINNER=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    #if winner not found
    if [[ -z $TEAM_ID_WINNER ]]
    then
      #insert new winner team
      INSERT_WINNER_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER')")
      if [[ $INSERT_WINNER_TEAM_RESULT == 'INSERT 0 1' ]]
      then
        echo Inserted into teams, $WINNER
      fi
    fi
    #get team_id of opponent
    TEAM_ID_OPPONENT=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    #if opponent not found
    if [[ -z $TEAM_ID_OPPONENT ]]
    then
      #insert new opponent team
      INSERT_OPPONENT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT')")
      if [[ $INSERT_OPPONENT_TEAM_RESULT == 'INSERT 0 1' ]]
      then
        echo Inserted into teams, $OPPONENT
      fi
    fi
    #get new winner team_id
    TEAM_ID_WINNER=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    #get new opponent team_id
    TEAM_ID_OPPONENT=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    #get game_id
    GAME_ID=$($PSQL "SELECT game_id FROM games WHERE winner_id='$TEAM_ID_WINNER' AND opponent_id='$TEAM_ID_OPPONENT'")
    #if game_id not found
    if [[ -z $GAME_ID ]]
    then
      #insert new game
      INSERT_GAME_ID_RESULT=$($PSQL "INSERT INTO games(year, round, winner_goals, opponent_goals, winner_id, opponent_id) VALUES ($YEAR,'$ROUND',$WINNER_GOALS,$OPPONENT_GOALS,$TEAM_ID_WINNER,$TEAM_ID_OPPONENT)")
      if [[ $INSERT_GAME_ID_RESULT == 'INSERT 0 1' ]]
      then
        echo Inserted into games, $YEAR $ROUND $WINNER_GOALS $OPPONENT_GOALS $TEAM_ID_WINNER $TEAM_ID_OPPONENT
      fi
    fi
  fi
done
