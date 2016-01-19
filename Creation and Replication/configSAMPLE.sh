# -----------------------------------
# --- START CONFIGURATION ---
# -----------------------------------
# --> Rename to "config.sh"!!

#List of Databases to replicate (uncomment lines to do step by step)
# First value: db name | second value: shard size
array=(
  'small_db::4'
  'medium_db::16'
  'large_db::32'
)

echo "--- CONFIG start ---"
# Credentials Admin: Target DB (Admin of target cluster needed to create databases)
USER='Admin Name'
PW='Admin Password'
TARGET='<target>.cloudant.com'
echo "Using Target Admin credentials: $USER | $PW for $TARGET"

# Credentials Admin/API: Source DB (API Reader of source cluster or Admin)
SOURCE_KEY='API Source Key'
SOURCE_PW='API Source PW'
SOURCE='<source>.cloudant.com'
echo "Using Source API credentials: $SOURCE_KEY | $SOURCE_PW for $SOURCE"

# --------------------------------
# --- END CONFIGURATION ---
# --------------------------------

# Target API Key Creation (Creates "target_api.json")
function checkTargetAPI {
  if [ -f "target_api.json" ];
  then
     echo "Reading API Key for $TARGET from file: target_api.json"
     TARGET_KEY=$(jq '.key' target_api.json)
     TARGET_KEY=$(echo $TARGET_KEY| sed "s/\"//g")
     TARGET_PW=$(jq '.password' target_api.json)
     TARGET_PW=$(echo $TARGET_PW| sed "s/\"//g")
  else
     echo "Target API File does not exist yet, creating new one..."
     echo "Creating new API KEY for $TARGET, saving in target_api.json"
     curl -X POST "https://$TARGET/_api/v2/api_keys" -u "$USER:$PW" > target_api.json
     echo "Creating API File api.json ..."
     TARGET_KEY=$(jq '.key' target_api.json)
     echo '{"_id":"_security","cloudant":{"nobody": [],'"$TARGET_KEY"':["_reader","_writer","_replicator"]}}' > api.json
     checkTargetAPI
  fi
}
checkTargetAPI
echo "Using Target API credentials: $TARGET_KEY | $TARGET_PW for $TARGET"
echo "--- CONFIG end ---"
