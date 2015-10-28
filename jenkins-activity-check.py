#!/usr/bin/env python

import sys
import requests
import boto.ec2.autoscale
from datetime import datetime

MAX_INACTIVE_PERIOD = 2

# Now get the last time a task ran and check if that happened more that 2 hours ago.
req = requests.get("http://localhost/api/json?tree=jobs[lastBuild[timestamp]]")
if req.status_code != 200:
   print "Cannot check jenkins, retrying in a few minutes"

shutdown = True

for job in req.json()['jobs']:
   back_then = datetime.utcfromtimestamp(job['lastBuild']['timestamp'] / 1000)
   now = datetime.utcnow()
   td = now - back_then
   if td.seconds / 3600 < MAX_INACTIVE_PERIOD:
      shutdown = False
      break

if shutdown:
   # What is my region ?
   req = requests.get("http://169.254.169.254/latest/meta-data/services/domain")
   region = req.text()
   # All we need to do is to launch a scaling down activity
   as_conn = boto.ec2.autoscale.connect_to_region(region)
   as_group = as_conn.get_all_groups(names=[autoscaling_group_name])
   as_group.set_capacity(0)
   print "Shutdown due to lack of activity"
   sys.exit(1)
else:
   sys.exit(0)
   
