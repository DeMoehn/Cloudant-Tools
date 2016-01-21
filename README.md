# CloudantTools
Tools for monitoring, replicating and creating databases

## Creation and Replication
Bash scripts to automatically create databases on target clusters (or only add API KEYs to existing ones) and automatically create replication jobs with a auto-generated API KEY.

## Monitor Replication
This is an easy Python Notebook where you can enter a source and a target database and compare the active replications to better understand the current status.

## Csv2Cloudant
Simple Python script to run trough a list of CSV documents, do some custom parsing of the data (e.g. transform and split into multiple JSON documents) and do bulk requests to the database every x documents.
