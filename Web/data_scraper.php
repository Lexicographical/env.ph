<?php
include("constants.php");

function formatDate($date) {
    return str_replace("Z", "", str_replace("T", " ", $date));
}

function getLastEntryId($src_id, &$out) {
    global $host;
    $url = "http://$host/amihan/index.php?action=query_sensor&src_id=$src_id";
    $jstr = file_get_contents($url);
    $jobj = json_decode($jstr, true);

    if ($jobj["error"] || $jstr === false) {
        return -1;
    } else {
        return $jobj["last_id"];
    }
}

function batch_update($mysqli, $link_id, &$out) {
    global $urls, $tdata, $tloc;
    set_time_limit(60);

    $url = "https://thingspeak.com/channels/$link_id/feed.json";

    $jstr = file_get_contents($url);
    $jobj = json_decode($jstr, true);

    $channel = $jobj["channel"];

    $src_id = $channel["id"];
    $location_name = str_replace("Location: ", "", explode("\n", $channel["description"])[0]);
    $latitude = $channel["latitude"];
    $longitude = $channel["longitude"];
    $creation_date = formatDate($channel["created_at"]);
    $last_update = formatDate($channel["updated_at"]);
    $last_entry_id = $channel["last_entry_id"];

    $feed = $jobj["feeds"];

    $cache_id = getLastEntryId($src_id, $out);

    $out["cache"] = $cache_id;
    $out["last"] = $last_entry_id;
    header('Content-type:application/json');
    if ($cache_id < 0) {
        // New sensor. Register
        // Action Code: 1 
        $sql = "INSERT INTO $tloc
        (src_id, location_name, latitude, longitude, creation_time, last_update, last_entry_id)
        VALUES (
            ?,
            ?,
            ?,
            ?,
            ?,
            ?,
            ?
        )";
        $stmt = $mysqli->prepare($sql);
        $stmt->bind_param("isddssi", $src_id, $location_name, $latitude, $longitude, $creation_date, $last_update, $last_entry_id);
        $res = $stmt->execute();
        if (!$res) {
            $out["error"] = true;
            $out["result"][] = "[Error 13010] " . $stmt->error;
        } 
        $stmt->close();
    }
    if ($cache_id < $last_entry_id) {
        // New data available
        // Action Code: 2
        $sql_data = "INSERT INTO $tdata
        (src_id, entry_id, entry_time, pm1, pm2_5, pm10, humidity, temperature, voc, carbon_monoxide)
        VALUES (
            ?,
            ?,
            ?,
            ?,
            ?,
            ?,
            ?,
            ?,
            ?,
            ?
        )";
        $stmt_data = $mysqli->prepare($sql_data);

        $sql_update = "UPDATE $tloc
            SET last_update = CASE
                WHEN last_update < ? THEN ?
                ELSE last_update
            END,
            last_entry_id = CASE
                WHEN last_entry_id < ? THEN ?
                ELSE last_entry_id
            END";
        $stmt_update = $mysqli->prepare($sql_update);

        if ($stmt_data === FALSE || $stmt_update === FALSE) {
            $out["error"] = true;
            $out["result"][] = "[Error 13020] " . $mysqli->error;
        } else {
            $count = 0;
            foreach ($feed as $entry) {
                $count++;
                $entry_id = $entry["entry_id"];
                $entry_time = formatDate($entry["created_at"]);
                $pm1 = $entry["field1"];
                $pm2_5 = $entry["field2"];
                $pm10 = $entry["field3"];
                $humidity = $entry["field4"];
                $temperature = $entry["field5"];
                $voc = $entry["field6"];
                $carbon_monoxide = $entry["field7"];

                $stmt_data->bind_param("iisddddddd", $src_id, $entry_id, $entry_time,
                    $pm1, $pm2_5, $pm10, $humidity, $temperature, $voc, $carbon_monoxide);
                $res = $stmt_data->execute();
                if (!$res) {
                    $out["error"] = true;
                    $out["result"][] = "[Error 13021] " . $stmt_data->error;
                }

                $stmt_update->bind_param("ssii", $entry_time, $entry_time, $entry_id, $entry_id);
                $res = $stmt_update->execute();    
                if (!$res) {
                    $out["error"] = true;
                    $out["result"][] = "[Error 13022] " . $stmt_update->error;
                }
            }
            $stmt_data->close();
            $stmt_update->close();
            $out["result"][] = "$count entries inserted for sensor $src_id";
        }
    } else {
        $out["result"][] = "No new data for sensor $src_id";
    }
}