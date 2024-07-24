#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

$($PSQL " TRUNCATE TABLE games, teams;")

cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ 'winner' != $WINNER  && ! -z $WINNER ]]
  then 
    # Winner Logic
    WINNER_ID=$($PSQL "SELECT team_id FROM teams where name like '$WINNER';")
    echo $WINNER

    if [[ -z "$WINNER_ID" ]]
    then
      echo 'Inserting into Teams table...'
      INSERT_WINNER_INTO_TEAMS=$($PSQL "INSERT INTO teams(name) values('$WINNER');")
     
      if [[ $INSERT_WINNER_INTO_TEAMS == 'INSERT 0 1' ]]
      then 
        echo "Inserted into Teams:" $WINNER
        WINNER_ID=$($PSQL "SELECT team_id FROM teams where name like '$WINNER';")
      fi

    fi

    # Opponent Logic
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams where name like '$OPPONENT';")
    echo $OPPONENT

    if [[ -z "$OPPONENT_ID" ]]
    then
      echo 'Inserting into Teams table...'
      INSERT_OPPONENT_INTO_TEAMS=$($PSQL "INSERT INTO teams(name) values('$OPPONENT');")
      if [[ $INSERT_OPPONENT_INTO_TEAMS == 'INSERT 0 1' ]]
      then 
        echo "Inserted into Teams:" $OPPONENT
        OPPONENT_ID=$($PSQL "SELECT team_id FROM teams where name like '$OPPONENT';")
      fi

    fi

    # Game logic
    GAME_ID=$($PSQL "SELECT game_id FROM games where winner_id = '$WINNER_ID' AND opponent_id = '$OPPONENT_ID';")
    echo "$WINNER-$OPPONENT"

    if [[ -z "$GAME_ID" ]]
    then
        echo 'Inserting into Game Table...'
        INSERT_GAME_INTO_GAMES=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) values($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")

        if [[ $INSERT_GAME_INTO_GAMES == 'INSERT 0 1' ]]
        then 
          echo "Inserted into Games: $WINNER $WINNER_GOALS-$OPPONENT_GOALS $OPPONENT, $ROUND | Winner: $WINNER"
          GAME_ID=$($PSQL "SELECT game_id FROM games where winner_id = '$WINNER_ID' AND opponent_id = '$OPPONENT_ID';")
        fi

    fi
  fi

done
