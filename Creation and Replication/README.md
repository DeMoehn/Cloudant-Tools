# Creation and Replication
Simple bash scripts to create sharded databases and replicate data from a source database

## How it works
* The scripts need a config.sh file with target database admin credentials and source admin credentials or API Key to work
* The scripts will automatically create an API Key for the target database
* The scripts will create the needed databases on the target database (with configurable sharding) and change the security documents via "createDBs.sh"
* OPTIONAL: If the databases already exist you may use "apikey.sh" to change the security documents to add the automatic API key
* Use "replicateDBs.sh" to trigger replication from source to target

## How to use
* Edit the configSAMPLE.sh under "START CONFIGURATION"
* Enter your databases to create and replicate in the format <DBname>::<ShardSize> (If no sharding needed use 0)
* Enter Target Admin credentials (to create DBs and target API Key)
* Enter Source Admin or API credentials
* Rename file to config.sh
* Use "createDBs.sh" to create the DBs from the list on the target cluster
* Use "replicate.sh" to trigger the replication jobs from source to target

## Hints
* Make sure to make files executable with ‘chmod +x MyFile.sh‘ or use ‘sh MyFile.sh’
* Tool "./jq" is needed to process JSON (https://stedolan.github.io/jq/). If you don't have it already you definitely need it to work with JSON in bash anyway.
* Tool "curl" is needed to make HTTP Requests from command line (http://curl.haxx.se). You should really have that anyway.
