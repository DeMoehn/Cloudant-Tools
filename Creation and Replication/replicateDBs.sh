#!/bin/bash

# Include the config-file
source config.sh

# Check if continuous replication should be used
function checkContinuous {
  echo -e "${CYAN}Use continuous replication? (y/n)${NC}"
  read  CONT
  if [ $CONT = "y" ];
  then
    mecho "Using continuous replication"
  elif [ $CONT = "n" ]
  then
    mecho "Using no continuous replication"
  else
    mecho "Incorrect command: use y/n"
    checkContinuous
  fi
}
checkContinuous

# Check for the username for user context property
function checkCTXUser {
  echo -e "${CYAN}Enter the username for the user context property:${NC}"
  read  CTXUser
}

# Check if user context property should be used (Need if the creator of the replication is not the Admin (e.g. Superadmin, API))
function checkCTX {
  echo -e "${CYAN}Use user context property (Needed if you're not the admin)? (y/n)${NC}"
  read  CTX
  if [ $CTX = "y" ];
  then
    mecho "Using user context property"
    checkCTXUser
  elif [ $CTX = "n" ]
  then
    mecho "Using no user context property"
  else
    mecho "Incorrect command: use y/n"
    checkCTX
  fi
}
checkCTX

# Main Function
function makeRequest {
  DOC='{"_id": "'"$1"'","source": "https://'"$SOURCE_KEY"':'"$SOURCE_PW"'@'"$SOURCE"'/'"$1"'", "create_target": false, "target": "https://'"$TARGET_KEY"':'"$TARGET_PW"'@'"$TARGET"'/'"$1"'"'

  if [ $CONT = "y" ];
  then
    OCONT='"continuous": true'
    DOC="$DOC, $OCONT"
  fi

  if [ $CTX = "y" ];
  then
    OCTX='"user_ctx": {"name": "'"$CTXUser"'","roles": ["_admin","_reader","_writer","fx_loggedIn"]}'
    DOC="$DOC, $OCTX"
  fi

  DOC="$DOC}"
  echo "$DOC" > repl.json

  mecho "Creating Replication for: $1 on $TARGET..."
  curl -X POST "https://$TARGET/_replicator" -u "$USER:$PW" -H 'Content-Type: application/json' -d @repl.json
  sleep 1
}

# Run trough list of DBs
for index in "${array[@]}" ; do
    DBNAME="${index%%::*}"
    makeRequest $DBNAME
done
