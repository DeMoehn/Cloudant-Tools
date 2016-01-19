#!/bin/bash

# Include the config-file
source config.sh

# Function to add API Key to database
function addAPI {
  mecho "Adding a new security doc for database: $1 on $TARGET..."
  curl -X PUT "https://$TARGET/_api/v2/db/$1/_security" -u "$USER:$PW" -d @api.json -H 'Content-Type: application/json'
  sleep 1 # Just a little slowdown to not hammer the cluster
}

# Function to change security doc by adding API Key to database security document
function changeSecurity {
  mecho "Changing the security doc of database: $1 to add API Key on $TARGET..."
  jq '.cloudant = .cloudant + { "'"$TARGET_KEY"'":["_reader","_writer","_replicator"] }'  secDoc.json > secDocNew.json
  curl -X PUT "https://$TARGET/_api/v2/db/$1/_security" -u "$USER:$PW" -d @secDocNew.json -H 'Content-Type: application/json'
  sleep 1 # Just a little slowdown to not hammer the cluster
}

function getSecurityDoc {
  mecho "\nRequesting the security doc of database: $1 on $TARGET..."
  curl -X GET "https://$TARGET/_api/v2/db/$1/_security" -u "$USER:$PW" -H 'Content-Type: application/json' > secDoc.json

  CHECKDOC=$(jq '._id' secDoc.json)
  CHECKAPI=$(jq '.cloudant.'"$TARGET_KEY"'' secDoc.json)

  if [ $CHECKAPI = null ]; # Check if our API Key already exists in the security document
  then
    mecho "Adding API Key to database..."
    if [ $CHECKDOC = null ]; # Check if security document exists at all
    then
      mecho "Security Doc doesn't exist, creating a new one..."
      addAPI $1
    else
      mecho "Security Doc does exist, carefully updating..."
      changeSecurity $1
    fi
  else
    mecho "API Key already exists, do nothing..."
  fi

  #null
  sleep 1 # Just a little slowdown to not hammer the cluster
}

# Run trough the list of databases
for index in "${array[@]}" ; do
    DBNAME="${index%%::*}"
    SHARDSIZE="${index##*::}"
    getSecurityDoc $DBNAME
done
