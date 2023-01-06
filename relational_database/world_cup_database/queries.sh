#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=worldcup --no-align --tuples-only -c"

# Do not change code above this line. Use the PSQL variable above to query your database.

echo -e "\nTotal number of goals in all games from winning teams:"
echo "$($PSQL "SELECT SUM(winner_goals) FROM games")"

echo -e "\nTotal number of goals in all games from both teams combined:"
echo "$($PSQL "SELECT SUM(winner_goals + opponent_goals) FROM games")"

echo -e "\nAverage number of goals in all games from the winning teams:"
echo "$($PSQL "SELECT AVG(winner_goals) FROM games")"

echo -e "\nAverage number of goals in all games from the winning teams rounded to two decimal places:"
echo "$($PSQL "SELECT ROUND(AVG(winner_goals), 2) FROM games")"

echo -e "\nAverage number of goals in all games from both teams:"
echo "$($PSQL "SELECT AVG(winner_goals + opponent_goals) FROM games")"

echo -e "\nMost goals scored in a single game by one team:"
# New assumption - this does NOT have to be one command... i'll use variables and multiple queries!
# "$($PSQL "")"
#
# Although this works, the directions say to only use 1 line
# MAX_GOALS_WINNER="$($PSQL "SELECT MAX(winner_goals) FROM games")"
# MAX_GOALS_OPPONENT="$($PSQL "SELECT MAX(opponent_goals) FROM games")"
# if (( MAX_GOALS_WINNER >= MAX_GOALS_OPPONENT ))
# then
#   echo $MAX_GOALS_WINNER
# else
#   echo $MAX_GOALS_OPPONENT
# fi

# Okay... WHAT WAS I THINKING WHEN I CODED ^^ !!
# Logically, the most goals scored in a single match will ALWAYS be in the winning column!
# If an opponent (losing) team scores a lot of goals, the column still does NOT need to be checked
# because the winning team will HAVE to have scored more goals!
# Thus, only need to check the winning team column. 
echo "$($PSQL "SELECT MAX(winner_goals) FROM games")"

echo -e "\nNumber of games where the winning team scored more than two goals:"
echo "$($PSQL "SELECT COUNT(*) FROM games WHERE winner_goals > 2;")"

echo -e "\nWinner of the 2018 tournament team name:"
echo "$($PSQL "SELECT name FROM games LEFT JOIN teams ON games.winner_id = teams.team_id WHERE year=2018 AND round='Final'")"

# AH - i need to join from teams -> games (two joins, then I can filter out the other entries! 
# SELECT * FROM teams FULL JOIN games ON teams.team_id = games.winner_id FULL JOIN games AS g ON teams.team_id = g.opponent_id WHERE (games.year=2014 OR g.year=2014) AND (games.round='Eighth-Final' or g.round='Eighth-Final') ORDER BY name;
# SELECT name FROM teams FULL JOIN games ON teams.team_id = games.winner_id FULL JOIN games AS g ON teams.team_id = g.opponent_id WHERE (games.year=2014 OR g.year=2014) AND (games.round='Eighth-Final' or g.round='Eighth-Final') GROUP BY name ORDER BY name;

# There has to be a better way to accomplish this query, but I can't think of it right now.
echo -e "\nList of teams who played in the 2014 'Eighth-Final' round:"
echo "$($PSQL "SELECT name FROM teams FULL JOIN games ON teams.team_id = games.winner_id FULL JOIN games AS g ON teams.team_id = g.opponent_id WHERE (games.year=2014 OR g.year=2014) AND (games.round='Eighth-Final' or g.round='Eighth-Final') GROUP BY name ORDER BY name;")"

echo -e "\nList of unique winning team names in the whole data set:"
echo "$($PSQL "SELECT name FROM games LEFT JOIN teams ON games.winner_id = teams.team_id GROUP BY name ORDER BY name")"

echo -e "\nYear and team name of all the champions:"
echo "$($PSQL "SELECT year, name FROM games LEFT JOIN teams ON games.winner_id = teams.team_id WHERE round='Final' ORDER BY year")"

echo -e "\nList of teams that start with 'Co':"
echo "$($PSQL "SELECT name FROM teams WHERE name LIKE 'Co%'")"


# SELECT * FROM games FULL JOIN teams ON games.winner_id = teams.team_id FULL JOIN teams AS t ON games.opponent_id = t.team_id;