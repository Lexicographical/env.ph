<?php
require_once __DIR__."/../vendor/autoload.php";
$dotenv = Dotenv\Dotenv::create(__DIR__.'/../');
if (file_exists(__DIR__.'/../.env')) $dotenv->load();
$mysqli = new mysqli($_ENV['MYSQL_DBHOST'], $_ENV['MYSQL_USERNAME'], $_ENV['MYSQL_PASSWORD'], $_ENV['MYSQL_DB']);
$guzzle = new \GuzzleHttp\Client();

if (!file_exists("update.log")) {

}

$ids = [814173, 814176, 814180, 814241, 810768];

function formatDate($date) {
    return str_replace("Z", "", str_replace("T", " ", $date));
}

foreach ($ids as &$src_id) {
    $guzzleResponse = $guzzle->request('GET', "https://thingspeak.com/channels/".$src_id."/feed.json", ['http_errors' => false]);
    if ($guzzleResponse->getStatusCode() == 404) echo "$src_id: ERROR 404";
    else {
        $jobj = json_decode($guzzleResponse->getBody());
        $channel = $jobj->channel;
        $location_name = str_replace("Location: ", "", explode("\n", $channel->description)[0]);
        $latitude = $channel->latitude;
        $longitude = $channel->longitude;
        $creation_date = formatDate($channel->created_at);
        $last_update = formatDate($channel->updated_at);
        $last_entry_id = $channel->last_entry_id;
        $feed = $jobj->feeds;
        $getLastEntryIdStmt = $mysqli->prepare("SELECT last_entry_id FROM sensor_map WHERE src_id=?");
        if (!$getLastEntryIdStmt) echo "$src_id: ERROR 12201: $err";
        $getLastEntryIdStmt->bind_param("i", $src_id);
        $res = $getLastEntryIdStmt->execute();
        if (!$res) echo "$src_id: ERROR 12202: 'Error querying database. $getLastEntryIdStmt->error";
        else {
            $getLastEntryIdRow = $getLastEntryIdStmt->get_result()->fetch_assoc();
            if ($getLastEntryIdRow != null) $cache_id = $getLastEntryIdRow['last_entry_id'];
            else $cache_id = -1;
        }
        $getLastEntryIdStmt->close();
        if ($cache_id < 0) {
            // New sensor. Register
            // Action Code: 1 
            $sql = "INSERT INTO sensor_map
            (src_id, location_name, latitude, longitude, creation_time, last_update, last_entry_id)
            VALUES (?, ?, ?, ?, ?, ?, ?)";
            $stmt = $mysqli->prepare($sql);
            $stmt->bind_param("isddssi", $src_id, $location_name, $latitude, $longitude, $creation_date, $last_update, $last_entry_id);
            $res = $stmt->execute();
            if (!$res) {
                echo "$src_id: ERROR 11011: Error registering new sensor. $stmt->error";
            }
            $stmt->close();
        }
        if ($cache_id < $last_entry_id) {
            // New data available
            // Action Code: 2
            $sql_data = "INSERT INTO sensor_data
            (src_id, entry_id, entry_time, pm1, pm2_5, pm10, humidity, temperature, voc, carbon_monoxide)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            $stmt_data = $mysqli->prepare($sql_data);

            $sql_update = "UPDATE sensor_map
                SET last_update = CASE
                    WHEN last_update < ? THEN ?
                    ELSE last_update
                END,
                last_entry_id = CASE
                    WHEN last_entry_id < ? THEN ?
                    ELSE last_entry_id
                END
                WHERE src_id=?";
            $stmt_update = $mysqli->prepare($sql_update);

            if ($stmt_data === FALSE || $stmt_update === FALSE) {
                echo "$src_id: ERROR 11002: $mysqli->error";
            } else {
                $count = 0;
                foreach ($feed as $entry) {
                    $entry_id = $entry->entry_id;
                    if ($entry_id > $cache_id) {
                        $count++;
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
                            echo "$src_id: ERROR 11003: $stmt_data->error";
                        }
                        $stmt_update->bind_param("ssiii", $entry_time, $entry_time, $entry_id, $entry_id, $src_id);
                        $res = $stmt_update->execute();   
                        if (!$res) {
                            echo "$src_id: ERROR 11004: $stmt_update->error";
                        }
                    }
                }
                $stmt_data->close();
                $stmt_update->close();
                echo "$src_id: $count entries inserted for sensor.<br>";
            }
        } else {
            echo "$src_id: No new data.<br>";
        }
    }
    echo "\n";
}
