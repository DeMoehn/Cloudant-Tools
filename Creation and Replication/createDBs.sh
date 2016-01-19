#!/bin/bash

# Include the config-file
source config.sh

# Check if sharding should be used (not supported with Multi-Tennant)
function checkSharding {
  echo -e "${CYAN}Use sharding (Cloudant DBaaS does not support sharding)? (y/n)${NC}"
  read  SHARDING
  if [ $SHARDING = "y" ];
  then
    mecho "Using shards"
  elif [ $SHARDING = "n" ]
  then
    mecho "Using no shards"
  else
    mecho "Incorrect command: use y/n"
    checkSharding
  fi
}
checkSharding

# Function to create databases
function createDatabase {
  if [ $SHARDING = "y" ]; # Check if sharding is wanted
  then
    mecho "\nCreating database: $1 with $2 shards on $TARGET..."
    curl -X PUT "https://$TARGET/$1?q=$2" -u "$USER:$PW"
  else
    mecho "\nCreating database: $1 (no sharding option) $TARGET..."
    curl -X PUT "https://$TARGET/$1" -u "$USER:$PW"
  fi
  sleep 1 # Just a little slowdown to not hammer the cluster
}

# Function to add API Key
function addAPI {
  mecho "Changing the security doc of database: $1 to add API Key on $TARGET..."
  curl -X PUT "https://$TARGET/_api/v2/db/$1/_security" -u "$USER:$PW" -d @api.json -H 'Content-Type: application/json'
  sleep 1 # Just a little slowdown to not hammer the cluster
}

# Run trough the list of databases
for index in "${array[@]}" ; do
    DBNAME="${index%%::*}"
    SHARDSIZE="${index##*::}"
    createDatabase $DBNAME $SHARDSIZE
    addAPI $DBNAME
done
