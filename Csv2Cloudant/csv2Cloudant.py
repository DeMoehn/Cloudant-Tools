#!/usr/bin/python

import multiprocessing
import requests
import csv
import json
import simplejson
import sys
import cloudant
import time
import re
import time, datetime

##############################################
# Please edit: ACCOUNTNAME, USERNAME, PASSWORD and DATABASE #
##############################################

# Use: account = cloudant.Account() if connecting to a local CouchDB
account = cloudant.Account("http://ACCOUNTNAME.cloudant.com") # Enter your Accountname to connect to Cloudant
login = account.login('USERNAME', 'PASSWORD') # Enter your Accountname/Username and Password
assert login.status_code == 200

# Print connection
response = account.get()
print response.json() # Indicated if the script was able to connect to the database

# Create database object
db = account.database('DATABASE') # Enter your database

##########
# End of edit #
##########

# Dict of table names and their csv representations
csv_lookup = {
    "first": sys.argv[1] # Could be enhanced to have multiple CSVs
}

# Function to do a Database BULK request
def cloudantRequest(data, ttype):
    r = db.bulk_docs(*data)
    if r.status_code in [200, 201, 202]: # on OK, Created or Accepted
        print "Process (1): "+ttype+" uploaded successful - ",(10000*roundCount)
    else:
        print r.status_code
        print r.text

# Lists of JSON data, which we'll upload to Cloudant
pickup_data = []
dropoff_data = []
request_data = []
# Sevaral counters
count = 0 # Counts all documents in one round of 10.000 documents, reset to 0 after round
roundCount = 0 # Counts all rounds of bulk requests
allCount = 0 # Counts all documents troughout all rounds

# Iterations
for table, filepath in csv_lookup.iteritems():
    # get our data
    with open(filepath, 'rU') as f:
        reader = csv.DictReader(f, skipinitialspace=True, quotechar='"', delimiter=',') # Create a new CSV Reader with comma separated CSV

        # Put data into JSON lists body
        for row in csv.DictReader(f):
            count += 1

            ###################
            # Do your own parsing here #
            ###################

            #Calculate UNIX time (Needed for own purpose)
            timeToScan = row["pickup_datetime"]
            regex = ur'^(\d+)-(\d+)-(\d+) (\d+)\:(\d+)\:(\d+)'
            match = re.findall(regex, timeToScan)
            myList = str(match[0])[1:-1].replace("'", "").replace(" ", "").split(",")
            date = datetime.datetime(int(myList[0]), int(myList[1]), int(myList[2]), int(myList[3]), int(myList[4]), int(myList[5]))
            unixPickupTime = str(time.mktime(date.timetuple()))

            # Transform 1st set of JSON
            allCount +=1
            pickup_data.append({"_id": "pickup:"+row["medallion"]+":"+row["hack_license"]+":"+unixPickupTime, "type": "Feature", "geometry": {  "type": "Point", "coordinates": [float(row["pickup_longitude"]), float(row["pickup_latitude"])]}, "properties": {"pickup_datetime": row["pickup_datetime"], "type": "pickup"}})

            # Transform 2nd set of JSON
            allCount +=1
            dropoff_data.append({"_id": "dropoff:"+row["medallion"]+":"+row["hack_license"]+":"+unixPickupTime, "type": "Feature", "geometry": {  "type": "Point", "coordinates": [float(row["dropoff_longitude"]), float(row["dropoff_latitude"])]}, "properties": {"dropoff_datetime": row["dropoff_datetime"], "type": "dropoff"}})

            # Transform 3rd set of JSON
            allCount +=1
            request_data.append({"_id": "trip:"+row["medallion"]+":"+row["hack_license"]+":"+unixPickupTime, "type": "trip", "vendor_id":row["vendor_id"], "rate_code":row["rate_code"],"store_and_fwd_flag":row["store_and_fwd_flag"], "passenger_count":row["passenger_count"],"trip_time_in_secs":row["trip_time_in_secs"],"trip_distance":row["trip_distance"]})

            ####################
            # End your own parsing here #
            ####################

            if count == 10000: # Does a BULK request every 10.000 docs
                print "Process (1): More than 10000" # May be enhanced to do multi-processing
                roundCount += 1

                # Save all JSON Lists
                cloudantRequest(pickup_data, "Pickup") # Do bulk request for 1st JSON set
                cloudantRequest(dropoff_data, "Dropoff") # Do bulk request for 2nd JSON set
                cloudantRequest(request_data, "Trip") # Do bulk request for 3rd JSON set

                # Clear all JSON Lists
                pickup_data = []
                dropoff_data = []
                request_data = []

                count = 0

# Finally show how many docs have been processed in how many rounds
print "Process (1): Finished at:", (10000*roundCount), "with #docs: ", allCount
