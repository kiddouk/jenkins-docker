#!/usr/bin/env python

import sys
import requests
import boto.ec2.autoscale
from datetime import datetime

REGION=sys.argv[1]
ASG=sys.argv[2]

MAX_INACTIVE_PERIOD = 2

# Now get the last time a task ran and check if that happened more that 2 hours ago.
req = requests.get("http://localhost/api/json?tree=jobs[lastBuild[timestamp]]")
if req.status_code != 200:
   print "Cannot check jenkins, retrying in a few minutes"

shutdown = True
jobs = req.json()['jobs']
for job in jobs:
   back_then = datetime.utcfromtimestamp(job['lastBuild']['timestamp'] / 1000)
   now = datetime.utcnow()
   td = now - back_then
   if td.seconds / 3600 < MAX_INACTIVE_PERIOD:
      shutdown = False
      break

# No need to shutdown if we have no task, we may need some setup first
if len(jobs) == 0:
   shutdown = false

   
if shutdown:
   # All we need to do is to launch a scaling down activity
   as_conn = boto.ec2.autoscale.connect_to_region(REGION)
   as_group = as_conn.get_all_groups(names=[ASG])[0]
   as_group.set_capacity(0)
   print "Shutdown due to lack of activity"
   sys.exit(1)
else:
   sys.exit(0)
   
