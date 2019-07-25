<?php

function formatDate($date) {
    return str_replace("Z", "", str_replace("T", " ", $date));
}
$app->get("/", function($req, $res) {
	return $res->withJson(["message" => "Hello, World! This is the Amihan API Server where real magic happens."]);
});

$app->get("/data", function($req, $response) {
    $src_id = $req->getQueryParams("src_id")['src_id'];
    $entry_id = $req->getQueryParams("entry_id")['entry_id'];
    $entry_time = $req->getQueryParams("entry_time")['entry_time'];
    $pm1 = $req->getQueryParams("pm1")['pm1'];
    $pm2_5 = $req->getQueryParams("pm2_5")['pm2_5'];
    $pm10 = $req->getQueryParams("pm10")['pm10'];
    $humidity = $req->getQueryParams("humidity")['humidity'];
    $temperature = $req->getQueryParams("temperature")['temperature'];
    $voc = $req->getQueryParams("voc")['voc'];
    $carbon_monoxide = $req->getQueryParams("carbon_monoxide")['carbon_monoxide'];

    $sql_data = "INSERT INTO sensor_data
    (src_id, entry_id, entry_time, pm1, pm2_5, pm10, humidity, temperature, voc, carbon_monoxide)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    $stmt = $this->mysqli->prepare($sql_data);
    $stmt->bind_param("iisddddddd", $src_id, $entry_id, $entry_time, $pm1, $pm2_5, $pm10,
        $humidity, $temperature, $voc, $carbon_monoxide);
    $res = $stmt->execute();
    if (!$res) {
        $out["error"] = true;
        $out["result"][] = "[Error 12010] " . $stmt->error;
    }
    $stmt->close();

    $sql_update = "UPDATE $tloc
    SET last_update = CASE
        WHEN last_update < ? THEN ?
        ELSE last_update
    END,
    last_entry_id = CASE
        WHEN last_entry_id < ? THEN ?
        ELSE last_entry_id
    END";

    $stmt = $this->mysqli->prepare($sql_update);
    $stmt->bind_param("ssii", $entry_time, $entry_time, $entry_id, $entry_id);
    $res = $stmt->execute();    
    if (!$res) {
        $out["error"] = true;
        $out["result"][] = "[Error 12011] " . $stmt->error;
    }
    $stmt->close();
    return $response->withJson($out);
});

$app->get("/query/data", function($req, $response) {
    $src_id = $req->getQueryParams("src_id")['src_id'];
    if (isset($req->getQueryParams("timestamp")['timestamp'])) $ref_time = $req->getQueryParams("timestamp")['timestamp'];

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

$app->get("/query/sensor", function($req, $response) {
    if (!isset($req->getQueryParams("src_id")['src_id'])) return $response->withStatus(404)->withJson(['error' => true, 'code' => 12040, 'message' => '[Error 12040] Missing src_id']);
    else {
        $src_id = $req->getQueryParams("src_id")['src_id'];
        $sql = "SELECT last_entry_id FROM sensor_map WHERE src_id=?";
        $stmt = $this->mysqli->prepare($sql);
        $stmt->bind_param("i", $src_id);
        $res = $stmt->execute();
        if (!$res) return $response->withStatus(404)->withJson(['error' => true, 'code' => 12031, 'message' => '[Error 12031] '.$stmt->error]);
        else {
            $result = $stmt->get_result();
            $row = $result->fetch_array();
            if ($row != null) return $response->withJson(['last_id' => $row[0]]);
            else return $response->withStatus(404)->withJson(['error' => true, 'code' => 12032, 'message' => '[Error 12032] '.$stmt->error]);
        }
        $stmt->close();
    }
});

$app->get("/list", function($req, $response) {
    $sql = "SELECT src_id, location_name, latitude, longitude FROM sensor_map";
    $stmt = $this->mysqli->prepare($sql);
    $res = $stmt->execute();
    if (!$res) return $response->withStatus(404)->withJson(['error' => true, 'code' => 12050, 'message' => '[Error 12050] '.$stmt->error]);
    else {
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

$app->get("/update", function($req, $response) {
    if (isset($req->getQueryParams("src_id")['src_id'])) {
        $src_id = $req->getQueryParams("src_id")['src_id'];
        $guzzleResponse = $this->guzzle->request('GET', "https://thingspeak.com/channels/".$src_id."/feed.json", ['http_errors' => false]);
        if ($guzzleResponse->getStatusCode() == 404) return $response->withStatus(404)->withJson(['error' => true, 'code' => '*****', 'message' => '[Error *****] Unknown src_id']);
        else {
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
            $getLastEntryId = $this->guzzle->request('GET', 'http://localhost/amihan/public/query/sensor?src_id='.$src_id, ['http_errors' => false]);
            $jobj2 = json_decode($getLastEntryId->getBody());
            if (isset($jobj2->error)) $cache_id = -1;
            else $cache_id = $jobj2->last_id;
            if ($cache_id < 0) {
                // New sensor. Register
                // Action Code: 1 
                $sql = "INSERT INTO sensor_map
                (src_id, location_name, latitude, longitude, creation_time, last_update, last_entry_id)
                VALUES (?, ?, ?, ?, ?, ?, ?)";
                $stmt = $this->mysqli->prepare($sql);
                $stmt->bind_param("isddssi", $src_id, $location_name, $latitude, $longitude, $creation_date, $last_update, $last_entry_id);
                $res = $stmt->execute();
                if (!$res) return $response->withStatus(404)->withJson(['error' => true, 'code' => 13010, 'message' => '[Error 13010] '.$stmt->error]);
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

                if ($stmt_data === FALSE || $stmt_update === FALSE) return $response->withStatus(404)->withJson(['error' => true, 'code' => 13020, 'message' => '[Error 13020] '.$this->mysqli->error]);
                else {
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
                        if (!$res) return $response->withStatus(404)->withJson(['error' => true, 'code' => 13021, 'message' => '[Error 13021] '.$stmt_data->error]);

                        $stmt_update->bind_param("ssii", $entry_time, $entry_time, $entry_id, $entry_id);
                        $res = $stmt_update->execute();   
                        if (!$res) return $response->withStatus(404)->withJson(['error' => true, 'code' => 13022, 'message' => '[Error 13022] '.$stmt_update->error]); 
                    }
                    $stmt_data->close();
                    $stmt_update->close();
                    return $response->withStatus(404)->withJson(['error' => false, 'result' => "$count entries inserted for sensor $src_id"]); 
                }
            } else {
                return $response->withStatus(404)->withJson(['error' => false, 'result' => "No new data for sensor $src_id"]); 
            }
        }
    } else return $response->withStatus(404)->withJson(['error' => true, 'code' => 12040, 'message' => '[Error 12040] Missing src_id']);
});
