<?php

/*
TODO
download data in csv
subset: date start end
subset: location
subset: sensor id
*/

/*
Action code guide
1abcd
=====
a: generic action type
1 - update
2 - query
3 - list
5 - misc function calls
=====
b: specific action
[1]
0 - single
1 - batch

[2]
0 - general query
1 - app query

[3]
0 - list sensors
======
c,d: error codes per specific action
*/

// 150xx
function formatDate($date) {
    return str_replace("Z", "", str_replace("T", " ", $date));
}

// 151xx
function arrayToCSV($array, $header, &$out, $delimeter=',') {
    $length = sizeof($array);
    $str = "";
    if ($length > 0) {
        $width = sizeof($array[0]);
        if ($width == sizeof($header)) {
            for ($i = 0; $i < $width; $i++) {
                $str .= $header[$i];
                if ($width-1 !== $i) $str .= $delimeter;
            }
            for ($i = 0; $i < $length; $i++) {
                $str .= "\r\n";
                for ($j = 0; $j < $width; $j++) {
                    $str .= $array[$i][$j];
                    if ($width-1 !== $j) $str .= $delimeter;
                }
            }
        } else {
            $out["error"] = true;
            $out["code"] = 15100;
            $out["message"] = "Array width does not match header width";
        }
    }
    return $str;
}

$app->get("/", function($req, $res) {
	return $res->withJson(["message" => "Hello, World! This is the Amihan API Server where real magic happens."]);
});

// 110xx
$app->get("/update/batch", function($req, $response) {
    if (isset($req->getQueryParams()['src_id'])) {
        $src_id = $req->getQueryParams()['src_id'];
        $guzzleResponse = $this->guzzle->request('GET', "https://thingspeak.com/channels/".$src_id."/feed.json", ['http_errors' => false]);
        if ($guzzleResponse->getStatusCode() == 404) {
            return $response->withStatus(404)->withJson(['error' => true, 'code' => 11000, 'message' => 'Unknown src_id']);
        } else {
            $jobj = json_decode($guzzleResponse->getBody());
            $channel = $jobj->channel;
            $src_id = $channel->id;
            $location_name = str_replace("Location: ", "", explode("\n", $channel->description)[0]);
            $latitude = $channel->latitude;
            $longitude = $channel->longitude;
            $creation_date = formatDate($channel->created_at);
            $last_update = formatDate($channel->updated_at);
            $last_entry_id = $channel->last_entry_id;
            $feed = $jobj->feeds;
            $getLastEntryId = $this->guzzle->request('GET', 'http://localhost/query/sensor?src_id='.$src_id, ['http_errors' => false]);
            $jobj2 = json_decode($getLastEntryId->getBody());
            if (isset($jobj2->error)) {
                $cache_id = -1;
            } else {
                $cache_id = $jobj2->last_entry_id;
            }
            if ($cache_id < 0) {
                // New sensor. Register
                // Action Code: 1 
                $sql = "INSERT INTO sensor_map
                (src_id, location_name, latitude, longitude, creation_time, last_update, last_entry_id)
                VALUES (?, ?, ?, ?, ?, ?, ?)";
                $stmt = $this->mysqli->prepare($sql);
                $stmt->bind_param("isddssi", $src_id, $location_name, $latitude, $longitude, $creation_date, $last_update, $last_entry_id);
                $res = $stmt->execute();
                if (!$res) {
                    return $response->withStatus(500)->withJson(['error' => true, 'code' => 11001, 'message' => 'Error registering new sensor. '.$stmt->error]);
                }
                $stmt->close();
            }
            if ($cache_id < $last_entry_id) {
                // New data available
                // Action Code: 2
                $sql_data = "INSERT INTO sensor_data
                (src_id, entry_id, entry_time, pm1, pm2_5, pm10, humidity, temperature, voc, carbon_monoxide)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                $stmt_data = $this->mysqli->prepare($sql_data);

                $sql_update = "UPDATE sensor_map
                    SET last_update = CASE
                        WHEN last_update < ? THEN ?
                        ELSE last_update
                    END,
                    last_entry_id = CASE
                        WHEN last_entry_id < ? THEN ?
                        ELSE last_entry_id
                    END";
                $stmt_update = $this->mysqli->prepare($sql_update);

                if ($stmt_data === FALSE || $stmt_update === FALSE) {
                    return $response->withStatus(500)->withJson(['error' => true, 'code' => 11002, 'message' => $mysqli->error]);
                } else {
                    $count = 0;
                    foreach ($feed as $entry) {
                        $count++;
                        $entry_id = $entry->entry_id;
                        $entry_time = formatDate($entry->created_at);
                        $pm1 = $entry->field1;
                        $pm2_5 = $entry->field2;
                        $pm10 = $entry->field3;
                        $humidity = $entry->field4;
                        $temperature = $entry->field5;
                        $voc = $entry->field6;
                        $carbon_monoxide = $entry->field7;

                        $stmt_data->bind_param("iisddddddd", $src_id, $entry_id, $entry_time,
                            $pm1, $pm2_5, $pm10, $humidity, $temperature, $voc, $carbon_monoxide);
                        $res = $stmt_data->execute();
                        if (!$res) {
                            return $response->withStatus(500)->withJson(['error' => true, 'code' => 11003, 'message' => $stmt_data->error]);
                        }
                        $stmt_update->bind_param("ssii", $entry_time, $entry_time, $entry_id, $entry_id);
                        $res = $stmt_update->execute();   
                        if (!$res) {
                            return $response->withStatus(500)->withJson(['error' => true, 'code' => 11004, 'message' => $stmt_update->error]); 
                        }
                    }
                    $stmt_data->close();
                    $stmt_update->close();
                    return $response->withJson(['error' => false, 'result' => "$count entries inserted for sensor $src_id"]); 
                }
            } else {
                return $response->withJson(['error' => false, 'result' => "No new data for sensor $src_id"]); 
            }
        }
    } else {
     return $response->withStatus(400)->withJson(['error' => true, 'code' => 11005, 'message' => 'Missing src_id']);
    }
});

// 120xx
$app->get("/query/data", function($req, $response) {
    $src_id = isset($req->getQueryParams()['src_id']) ? $req->getQueryParams()['src_id'] : false;
    $date_start = isset($req->getQueryParams()['date_start']) ? $req->getQueryParams()['date_start'] : false;
    $date_end = isset($req->getQueryParams()['date_end']) ? $req->getQueryParams()['date_end'] : false;

    $res = false;
    $stmt = null;
    if ($src_id && $date_start && $date_end) {
        $sql = "SELECT src_id, entry_time, pm1, pm2_5, pm10, humidity, temperature, voc, carbon_monoxide FROM sensor_data WHERE src_id=? AND entry_time >= ? AND entry_time <= ? ORDER BY entry_time DESC";
        $stmt = $this->mysqli->prepare($sql);
        $stmt->bind_param("iss", $src_id, $date_start, $date_end);
        $res = $stmt->execute();
    } else if ($src_id) {
        $sql = "SELECT src_id, entry_time, pm1, pm2_5, pm10, humidity, temperature, voc, carbon_monoxide FROM sensor_data WHERE src_id=? ORDER BY entry_time DESC";
        $stmt = $this->mysqli->prepare($sql);
        $stmt->bind_param("i", $src_id);
        $res = $stmt->execute();
    } else if ($date_start && $date_end) {
        $sql = "SELECT src_id, entry_time, pm1, pm2_5, pm10, humidity, temperature, voc, carbon_monoxide FROM sensor_data WHERE entry_time >= ? AND entry_time <= ? ORDER BY entry_time DESC";
        $stmt = $this->mysqli->prepare($sql);
        $stmt->bind_param("ss", $date_start, $date_end);
        $res = $stmt->execute();
    } else if ($date_start) {
        $sql = "SELECT src_id, entry_time, pm1, pm2_5, pm10, humidity, temperature, voc, carbon_monoxide FROM sensor_data WHERE entry_time >= ? ORDER BY entry_time DESC";
        $stmt = $this->mysqli->prepare($sql);
        $stmt->bind_param("s", $date_start);
        $res = $stmt->execute();
    } else if ($date_end) {
        $sql = "SELECT src_id, entry_time, pm1, pm2_5, pm10, humidity, temperature, voc, carbon_monoxide FROM sensor_data WHERE entry_time <= ? ORDER BY entry_time DESC";
        $stmt = $this->mysqli->prepare($sql);
        $stmt->bind_param("s", $date_end);
        $res = $stmt->execute();
    } else {
        $sql = "SELECT src_id, entry_time, pm1, pm2_5, pm10, humidity, temperature, voc, carbon_monoxide FROM sensor_data ORDER BY entry_time DESC";
        $stmt = $this->mysqli->prepare($sql);
        $res = $stmt->execute();
    }

    if (!$res) {
        return $response->withStatus(500)->withJson(['error' => true, 'code' => 12000, 'message' => 'Error executing query']);
    } else {
        $result = $stmt->get_result();
        $stmt->close();
        
        $format = "json";
        if (isset($req->getQueryParams()['format'])) {
            $format = $req->getQueryParams()['format'];
            if ($format != "json" && $format != "csv" && $format != "tsv") {
                return $response->withStatus(500)->withJson(['error' => true, 'code' => 12001, 'message' => 'Invalid format specified']);
            }
        }
        $data_labels = array("src_id", "entry_time", "pm1", "pm2_5", "pm10",
            "humidity", "temperature", "voc", "carbon_monoxide");
        
        if ($format == "csv" || $format == "tsv")  {
            $output = array();
            while (($row = $result->fetch_array()) != null) {
                $tmp = array();
                for ($i = 0; $i < sizeof($data_labels); $i++) {
                    array_push($tmp, $row[$i]);
                }
                $output[] = $tmp;
            }
            $csv = arrayToCSV($output, $data_labels, $out, $format == "tsv" ? "\t" : ",");
            return $response->withHeader('Content-type', "text/$format")->withHeader('Content-Disposition', "attachment; filename=data.$format")->write($csv);
        } else {
            $output = array();
            while ($row = $result->fetch_array()) {
                $tmp = array();
                foreach ($data_labels as $label) {
                    $tmp[$label] = $row[$label];
                }
                $output[] = $tmp;
            }
            return $response->withJson($output);
        }
    }
});

// 121xx
$app->get("/query/data_app", function($req, $response) {
    $src_id = $req->getQueryParams()['src_id'];
    $ref_time = $req->getQueryParams()['timestamp'];

    if (!isset($src_id) && !isset($ref_time)) {
        return $response->withStatus(400)->withJson(['error' => true, 'code' => 12100, 'message' => 'Missing parameters']);
    }

    $sql_arr = array();
    $sql_arr[] = "SELECT entry_time, pm1, pm2_5, pm10, 
    humidity, temperature, voc, carbon_monoxide
    FROM sensor_data
    WHERE src_id=? AND
        entry_time <= ?
    ORDER BY entry_time DESC
    LIMIT 1";
    $sql_arr[] = "SELECT entry_time,
                AVG(pm1),
                AVG(pm2_5),
                AVG(pm10),
                AVG(humidity),
                AVG(temperature),
                AVG(voc),
                AVG(carbon_monoxide)
            FROM sensor_data
            WHERE src_id=? AND
                entry_time >= ? - INTERVAL 24 HOUR
            GROUP BY HOUR(entry_time)";
    $sql_arr[] = "SELECT entry_time,
                AVG(pm1),
                AVG(pm2_5),
                AVG(pm10),
                AVG(humidity),
                AVG(temperature),
                AVG(voc),
                AVG(carbon_monoxide)
            FROM sensor_data
            WHERE src_id=? AND
                entry_time >= ? - INTERVAL 7 DAY
            GROUP BY DAY(entry_time)";
    $sql_arr[] = "SELECT entry_time,
                AVG(pm1),
                AVG(pm2_5),
                AVG(pm10),
                AVG(humidity),
                AVG(temperature),
                AVG(voc),
                AVG(carbon_monoxide)
            FROM sensor_data
            WHERE src_id=? AND
                entry_time >= ? - INTERVAL 4 WEEK
            GROUP BY WEEK(entry_time)";
    $sql_arr[] = "SELECT entry_time,
            AVG(pm1),
            AVG(pm2_5),
            AVG(pm10),
            AVG(humidity),
            AVG(temperature),
            AVG(voc),
            AVG(carbon_monoxide)
        FROM sensor_data
        WHERE src_id=? AND
            entry_time >= ? - INTERVAL 12 MONTH
        GROUP BY MONTH(entry_time)";
    
    $limits = array(1, 24, 7, 4, 12);
    $time_labels = array("latest", "day", "week", "month", "year");
    $data_labels = array("entry_time", "pm1", "pm2_5", "pm10",
    "humidity", "temperature", "voc", "carbon_monoxide");
    $output = array();
    for ($i = 0; $i < sizeof($sql_arr); $i++) {
        $sql = $sql_arr[$i];
        $stmt = $this->mysqli->prepare($sql);
        $stmt->bind_param("is", $src_id, $ref_time);
        $stmt->execute();

        $result = $stmt->get_result();
        $unit = array();

        for ($count = 0; $count < $limits[$i]; $count++) {
            $tmp = array();
            if ($row = $result->fetch_array()) {
                for ($j = 0; $j < sizeof($data_labels); $j++) {
                    $tmp[$data_labels[$j]] = $row[$j];
                }
            } else {
                for ($j = 0; $j < sizeof($data_labels); $j++) {
                    $tmp[$data_labels[$j]] = 0;
                }
            }
            $unit[$count] = $tmp;
        }
        $output[$time_labels[$i]] = $unit;
        $stmt->close();
    }
    return $response->withJson($output);
});

// 122xx
$app->get("/query/sensor", function($req, $response) {
    if (!isset($req->getQueryParams()['src_id'])) {
        return $response->withStatus(400)->withJson(['error' => true, 'code' => 12200, 'message' => 'Missing src_id']);
    } else {
        $src_id = $req->getQueryParams()['src_id'];
        $sql = "SELECT * FROM sensor_map WHERE src_id=?";
        $stmt = $this->mysqli->prepare($sql);
        if (!$stmt) {
            return $response->withStatus(500)->withJson(['error' => true, 'code' => 12201, 'message' => $err]);
        }
        $stmt->bind_param("i", $src_id);
        $res = $stmt->execute();
        if (!$res){
            return $response->withStatus(500)->withJson(['error' => true, 'code' => 12202, 'message' => 'Error querying database. '.$stmt->error]);
        } else {
            $result = $stmt->get_result();
            $row = $result->fetch_assoc();
            if ($row != null) { 
                return $response->withJson($row);
            }
            else {
                return $response->withStatus(404)->withJson(['error' => true, 'code' => 12203, 'message' => 'No entry found for sensor '.$src_id]);
            }
        }
        $stmt->close();
    }
});

// 130xx
$app->get("/list", function($req, $response) {
    $sql = "SELECT src_id, location_name, latitude, longitude FROM sensor_map";
    $stmt = $this->mysqli->prepare($sql);
    $res = $stmt->execute();
    if (!$res) {
        return $response->withStatus(500)->withJson(['error' => true, 'code' => 13000, 'message' => 'Error querying database']);
    } else {
        $result = $stmt->get_result();
        $count = 0;
        $out["sensors"] = array();
        while (($row = $result->fetch_array()) != null) {
            $count++;
            $tmp = array();
            $tmp["src_id"] = $row["src_id"];
            $tmp["location_name"] = $row["location_name"];
            $tmp["latitude"] = $row["latitude"];
            $tmp["longitude"] = $row["longitude"];
            $out["sensors"][] = $tmp;
        }
        $out["count"] = $count;
        return $response->withJson($out);
    }
});