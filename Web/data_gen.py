from datetime import datetime
from dateutil.relativedelta import relativedelta
import json
import random

fn = open("data.json", "w")
jobj = []

# pm1 -> co
labels = ["pm1", "pm2_5", "pm10", "humidity", "temperature", "carbon_dioxide", "carbon_monoxide"]
ranges = [
    [20, 25],
    [22, 27],
    [30, 35],
    [50, 80],
    [22, 28],
    [80, 90],
    [130, 140]
]

src_id=810768
entry_id=1
months = 12
weeks = 4
days = 7
hours = 24
for i in range(months):
    td = datetime.now() - relativedelta(months=months-i) + relativedelta(seconds=entry_id)
    entry_time = td.strftime("%Y-%m-%d %H:%M:%S")
    tmp = {}
    tmp["entry_id"] = entry_id
    entry_id += 1
    tmp["entry_time"] = entry_time
    for j in range(len(labels)):
        tmp[labels[j]] = random.randrange(ranges[j][0], ranges[j][1])
    jobj.append(tmp)

for i in range(weeks):
    td = datetime.now() - relativedelta(weeks=weeks-i) + relativedelta(seconds=entry_id)
    entry_time = td.strftime("%Y-%m-%d %H:%M:%S")
    tmp = {}
    tmp["entry_id"] = entry_id
    entry_id += 1
    tmp["entry_time"] = entry_time
    for j in range(len(labels)):
        tmp[labels[j]] = random.randrange(ranges[j][0], ranges[j][1])
    jobj.append(tmp)
    
for i in range(days):
    td = datetime.now() - relativedelta(days=days-i) + relativedelta(seconds=entry_id)
    entry_time = td.strftime("%Y-%m-%d %H:%M:%S")
    tmp = {}
    tmp["entry_id"] = entry_id
    entry_id += 1
    tmp["entry_time"] = entry_time
    for j in range(len(labels)):
        tmp[labels[j]] = random.randrange(ranges[j][0], ranges[j][1])
    jobj.append(tmp)
    
for i in range(hours):
    td = datetime.now() - relativedelta(hours=hours-i) + relativedelta(seconds=entry_id)
    entry_time = td.strftime("%Y-%m-%d %H:%M:%S")
    tmp = {}
    tmp["entry_id"] = entry_id
    entry_id += 1
    tmp["entry_time"] = entry_time
    for j in range(len(labels)):
        tmp[labels[j]] = random.randrange(ranges[j][0], ranges[j][1])
    jobj.append(tmp)
    
jobj = json.dumps(jobj)
print(jobj)
fn.write(jobj)
fn.close()
    
    