#!/bin/bash

# Imports trakt watchlist into Ombi

## OMBI API data
OMBI_URL="http://localhost:3579" # Ombi base URL
OMBI_APIKEY="xxxxxxxxxx" # Ombi API key you get from Settings->Ombi page

## Trakt API data
TRAKT_CLIENTID="xxxxxxxxxxxx" # Trakt Cliend ID you get from Trakt Apps

# Add trakt users and respective Ombi users in the format [traktuser1]=ombiuser1 [traktuser2]=ombiuser2 
declare -A USERS=([traktuser1]=ombiuser1 [traktuser2]=ombiuser2)

# List of trakt users to ignore importing tv series
declare -A IGNORE_SERIES=([traktuser1]=true)

# Get Trakt Watchlist items and send them to Ombi
for TRAKT_USER in "${!USERS[@]}"; do
    curl --silent \
         --header "Content-Type: application/json" \
         --header "trakt-api-version: 2" \
         --header "trakt-api-key: ${TRAKT_CLIENTID}" \
         "https://api.trakt.tv/users/${TRAKT_USER}/watchlist" |
         jq -r '.[] | "\(.movie.ids.tmdb) \(.show.ids.tvdb)"' |
         while read -r tmdb tvdb; do
             if [ "${tmdb}" != "null" ]; then
                 echo "Adding TheMovieDB $tmdb from $TRAKT_USER Watchlist to Ombi as ${USERS[$TRAKT_USER]}"
                 curl --silent \
                      --header "Content-Type: application/json" \
                      --header "Apikey: ${OMBI_APIKEY}" \
                      --header "UserName: ${USERS[$TRAKT_USER]}" \
                      -X POST -d "{\"theMovieDbId\":${tmdb}}" \
                      "${OMBI_URL}/api/v1/Request/movie"
             elif [ "${tvdb}" != "null" ]; then
                 if [ "${IGNORE_SERIES[$TRAKT_USER]}" == "true" ]; then
                     echo "Ignoring series from $TRAKT_USER"
                     continue
                 fi
                 echo "Adding TVDB $tvdb from $TRAKT_USER Watchlist to Ombi as ${USERS[$TRAKT_USER]}"
                 curl --silent \
                      --header "Content-Type: application/json" \
                      --header "Apikey: ${OMBI_APIKEY}" \
                      --header "UserName: ${USERS[$TRAKT_USER]}" \
                      -X POST -d "{\"tvDbId\":${tvdb}}" \
                      "${OMBI_URL}/api/v1/Request/tv"
             fi
         done
         printf "\n\n"
done