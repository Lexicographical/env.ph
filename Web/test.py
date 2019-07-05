import json
import urllib.parse
import urllib.request

url = "http://localhost/Website/env/index.php"
req = "https://thingspeak.com/channels/810768/feed.json"
response = urllib.request.urlopen(req)
jstr = response.read()
j = json.loads(jstr)

info = j["channel"]
data = j["feeds"]
src_id = info["id"]

def registerSensor():
    global info, url, src_id
    location_name = "Dagupan"
    latitude = 16.0433
    longitude = 120.3333
    last_update = "2019-06-28 13:00:00"
    # last_update = info["updated_at"].replace("T", " ").replace("Z", "")
    last_entry_id = info["last_entry_id"]

    values_register = {
        "action": "register",
        "src_id": src_id,
        "location_name": location_name,
        "latitude": latitude,
        "longitude": longitude,
        "last_update": last_update,
        "last_entry_id": last_entry_id
    }

    data = urllib.parse.urlencode(values_register)
    req = url + "?" + data
    print(data)
    # response = urllib.request.urlopen(req)
    # print(response.read())

def uploadData():
    global data, url, src_id
    values_data = {
        "action": "data",
        "src_id": src_id,
    }

    for entry in data:
        values_data["entry_id"] = entry["entry_id"]
        values_data["entry_time"] = entry["created_at"].replace("T", " ").replace("Z", "")
        values_data["pm1"] = entry["field1"]
        values_data["pm2_5"] = entry["field2"]
        values_data["pm10"] = entry["field3"]
        values_data["humidity"] = entry["field4"]
        values_data["temperature"] = entry["field5"]
        values_data["carbon_dioxide"] = entry["field6"]
        values_data["carbon_monoxide"] = entry["field7"]
        data = urllib.parse.urlencode(values_data)
        req = url + "?" + data
        response = urllib.request.urlopen(req)
        print(response.read())

# print(jstr)
# uploadData()
registerSensor()