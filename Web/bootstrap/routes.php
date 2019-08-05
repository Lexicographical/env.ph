<?php
use Slim\Exception\NotFoundException;
require_once "utility.php";

// 15101-3
$app->add(function($request, $response, $next) {
    $response = $next($request, $response);
    $apiKey = $this->get("geoip_api_key");
    $cinfo = getConnectionInfo($apiKey);
    $path = $request->getUri()->getPath();
    $params = $request->getUri()->getQuery();
    $ip = $cinfo["ip"];

    $sql = "INSERT INTO action_log (ip, request, params) VALUES (?, ?, ?)";
    $stmt = $this->get("mysqli")->prepare($sql);
    $stmt->bind_param("sss", $ip, $path, $params);
    $res = $stmt->execute();
    $stmt->close();
    if (!$res) {
        return $response->withStatus(500)->withJson(['error' => true, 'code' => 15101, 'message' => 'Error occured']);
    }

    $sql = "SELECT EXISTS(SELECT * FROM ip_map WHERE ip=? LIMIT 1) as count;";
    $stmt = $this->get("mysqli")->prepare($sql);
    $stmt->bind_param("s", $ip);
    $res = $stmt->execute();

    if (!$res) {
        return $response->withStatus(500)->withJson(['error' => true, 'code' => 15102, 'message' => 'Error occured']);
    } else {
        $result = $stmt->get_result();
        $row = $result->fetch_array();
        if ($row[0] == 0) {
            $sql = "INSERT INTO ip_map (ip, city, country, isp) VALUES (?, ?, ?, ?)";
            $stmt = $this->get("mysqli")->prepare($sql);
            $stmt->bind_param("ssss", $ip, $cinfo["city"], $cinfo["country"], $cinfo["isp"]);
            $res = $stmt->execute();
            if (!$res) {
                return $response->withStatus(500)->withJson(['error' => true, 'code' => 15103, 'message' => 'Error occured']);
            }
        }
    }

    return $response;
});

$app->get("/", function($req, $res) {
	return $res->withJson(["message" => "Hello, World! This is the Amihan API Server where real magic happens."]);
});

// 120xx
$app->get("/query/data", function($req, $response) {
    $src_id = isset($req->getQueryParams()['src_id']) ? $req->getQueryParams()['src_id'] : false;
    $date_start = isset($req->getQueryParams()['date_start']) ? $req->getQueryParams()['date_start'] : false;
    $date_end = isset($req->getQueryParams()['date_end']) ? $req->getQueryParams()['date_end'] : false;

    $res = false;
    $stmt = null;
    if ($src_id && $date_start && $date_end) {
        $sql = "SELECT rec_id, src_id, entry_time, pm1, pm2_5, pm10, humidity, temperature, voc, carbon_monoxide FROM sensor_data WHERE src_id=? AND entry_time >= ? AND entry_time <= ? ORDER BY entry_time DESC";
        $stmt = $this->mysqli->prepare($sql);
        $stmt->bind_param("iss", $src_id, $date_start, $date_end);
        $res = $stmt->execute();
    } else if ($src_id) {
        $sql = "SELECT rec_id, src_id, entry_time, pm1, pm2_5, pm10, humidity, temperature, voc, carbon_monoxide FROM sensor_data WHERE src_id=? ORDER BY entry_time DESC";
        $stmt = $this->mysqli->prepare($sql);
        $stmt->bind_param("i", $src_id);
        $res = $stmt->execute();
    } else if ($date_start && $date_end) {
        $sql = "SELECT rec_id, src_id, entry_time, pm1, pm2_5, pm10, humidity, temperature, voc, carbon_monoxide FROM sensor_data WHERE entry_time >= ? AND entry_time <= ? ORDER BY entry_time DESC";
        $stmt = $this->mysqli->prepare($sql);
        $stmt->bind_param("ss", $date_start, $date_end);
        $res = $stmt->execute();
    } else if ($date_start) {
        $sql = "SELECT rec_id, src_id, entry_time, pm1, pm2_5, pm10, humidity, temperature, voc, carbon_monoxide FROM sensor_data WHERE entry_time >= ? ORDER BY entry_time DESC";
        $stmt = $this->mysqli->prepare($sql);
        $stmt->bind_param("s", $date_start);
        $res = $stmt->execute();
    } else if ($date_end) {
        $sql = "SELECT rec_id, src_id, entry_time, pm1, pm2_5, pm10, humidity, temperature, voc, carbon_monoxide FROM sensor_data WHERE entry_time <= ? ORDER BY entry_time DESC";
        $stmt = $this->mysqli->prepare($sql);
        $stmt->bind_param("s", $date_end);
        $res = $stmt->execute();
    } else {
        $sql = "SELECT rec_id, src_id, entry_time, pm1, pm2_5, pm10, humidity, temperature, voc, carbon_monoxide FROM sensor_data ORDER BY entry_time DESC";
        $stmt = $this->mysqli->prepare($sql);
        $res = $stmt->execute();
    }

    if (!$res) return $response->withStatus(500)->withJson(['error' => true, 'code' => 12000, 'message' => 'Error executing query']);
    else {
        $result = $stmt->get_result();
        $stmt->close();
        
        $format = "json";
        if (isset($req->getQueryParams()['format'])) {
            $format = $req->getQueryParams()['format'];
            if ($format != "json" && $format != "csv" && $format != "tsv") {
                return $response->withStatus(500)->withJson(['error' => true, 'code' => 12001, 'message' => 'Invalid format specified']);
            }
        }
        $data_labels = array("rec_id", "src_id", "entry_time", "pm1", "pm2_5", "pm10", "humidity", "temperature", "voc", "carbon_monoxide");
        
        if ($format == "csv" || $format == "tsv")  {
            $output = array();
            while (($row = $result->fetch_array()) != null) {
                $tmp = array();
                for ($i = 0; $i < sizeof($data_labels); $i++) array_push($tmp, $row[$i]);
                $output[] = $tmp;
            }
            $csv = arrayToCSV($output, $data_labels, $out, $format == "tsv" ? "\t" : ",");
            return $response->withHeader('Content-type', "text/$format")->withHeader('Content-Disposition', "attachment; filename=data.$format")->write($csv);
        } else {
            $output = array();
            while ($row = $result->fetch_array()) {
                $tmp = array();
                foreach ($data_labels as $label) $tmp[$label] = $row[$label];
                $output[] = $tmp;
            }
            return $response->withJson($output);
        }
    }
});

$app->get("/query/data/zip", function($req, $response) {
    $src_id = isset($req->getQueryParams()['src_id']) ? $req->getQueryParams()['src_id'] : false;
    $month = isset($req->getQueryParams()['month']) ? $req->getQueryParams()['month'] : false;
    $year = isset($req->getQueryParams()['year']) ? $req->getQueryParams()['year'] : false;
    if ($month && !$year) return $response->withStatus(400)->write("You need to place a year if you're querying a particular month.");
    else if ($year && $month) $cd = (DateTime::createFromFormat('!Ym', $year.$month));
    else if ($year) $cd = (DateTime::createFromFormat('!Y', $year));
    if (isset($cd) && (!((new DateTime())->modify('-1 month') >= $cd))) return $response->withStatus(400)->write("Invalid Date Time (can be set up to one month before current month)");
    if (!$src_id) $src_id_text = "main";
    else $src_id_text = $src_id;
    $filename = "$year/$month/$src_id_text.zip";
    if ($filename === ".zip") $filename = "mainoutput.zip";
    if (!file_exists(getcwd()."../files/$filename") || $filename === "mainoutput.zip" || ($year && !$month) || ($src_id && !$year && !$month)) {
        $res = false;
        $stmt = null;
        $month1 = $month+1;
        if ($month1 === 13) {
            $month1 = 1;
            $y1 = $year+1;
        } else $y1 = $year;
        if ($src_id && $year && $month) {
            $sql = "SELECT rec_id, src_id, entry_time, pm1, pm2_5, pm10, humidity, temperature, voc, carbon_monoxide FROM sensor_data WHERE entry_time BETWEEN '$year-$month-01' AND '$y1-$month1-01' AND src_id=? ORDER BY entry_time DESC;";
            $stmt = $this->mysqli->prepare($sql);
            $stmt->bind_param("i", $src_id);
        } else if ($month && $year) {
            $sql = "SELECT rec_id, src_id, entry_time, pm1, pm2_5, pm10, humidity, temperature, voc, carbon_monoxide FROM sensor_data WHERE entry_time BETWEEN '$year-$month-01' AND '$y1-$month1-01' ORDER BY entry_time DESC;";
            $stmt = $this->mysqli->prepare($sql);
        } else if ($src_id && $year) {
            $y1 = $year+1;
            $sql = "SELECT rec_id, src_id, entry_time, pm1, pm2_5, pm10, humidity, temperature, voc, carbon_monoxide FROM sensor_data WHERE entry_time BETWEEN '$year-01-01' AND '$y1-01-01' AND src_id=? ORDER BY entry_time DESC;";
            $stmt = $this->mysqli->prepare($sql);
            $stmt->bind_param("i", $src_id);
        } else if ($year) {
            $y1 = $year+1;
            $sql = "SELECT rec_id, src_id, entry_time, pm1, pm2_5, pm10, humidity, temperature, voc, carbon_monoxide FROM sensor_data WHERE entry_time BETWEEN '$year-01-01' AND '$y1-01-01' ORDER BY entry_time DESC;";
            $stmt = $this->mysqli->prepare($sql);
        } else if ($src_id) {
            $sql = "SELECT rec_id, src_id, entry_time, pm1, pm2_5, pm10, humidity, temperature, voc, carbon_monoxide FROM sensor_data WHERE src_id=? ORDER BY entry_time DESC";
            $stmt = $this->mysqli->prepare($sql);
            $stmt->bind_param("i", $src_id);
        } else {
            $sql = "SELECT rec_id, src_id, entry_time, pm1, pm2_5, pm10, humidity, temperature, voc, carbon_monoxide FROM sensor_data ORDER BY entry_time DESC";
            $stmt = $this->mysqli->prepare($sql);
        }
        $res = $stmt->execute();
        $result = $stmt->get_result();
        $stmt->close();
        $data_labels = array("rec_id", "src_id", "entry_time", "pm1", "pm2_5", "pm10", "humidity", "temperature", "voc", "carbon_monoxide");
        $output = array();
        while (($row = $result->fetch_array()) != null) {
            $tmp = array();
            for ($i = 0; $i < sizeof($data_labels); $i++) array_push($tmp, $row[$i]);
            $output[] = $tmp;
        }
        $csv = arrayToCSV($output, $data_labels, $out, ",");
        $zipper = new \Chumper\Zipper\Zipper;
        $zipper->make(getcwd()."/../files/$filename")->addString("$filename.csv", $csv)->close();
    }
    return $response->withHeader('Content-type', "application/zip")->withHeader('Content-Disposition', "attachment; filename=$filename")->write(file_get_contents("../files/$filename"));
});

// 121xx
$app->get("/query/data_app", function($req, $response) {
    $src_id = isset($req->getQueryParams()['src_id']) ? $req->getQueryParams()['src_id'] : false;
    $ref_time = isset($req->getQueryParams()['timestamp']) ? $req->getQueryParams()['timestamp'] : date('Y-m-d H:i:s');
    if (!$src_id) return $response->withStatus(400)->withJson(['error' => true, 'code' => 12100, 'message' => 'Missing parameters']);

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
    $data_labels = array("entry_time", "pm1", "pm2_5", "pm10", "humidity", "temperature", "voc", "carbon_monoxide");
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
            if ($row = $result->fetch_array()) for ($j = 0; $j < sizeof($data_labels); $j++) $tmp[$data_labels[$j]] = $row[$j];
            else for ($j = 0; $j < sizeof($data_labels); $j++) $tmp[$data_labels[$j]] = 0;
            $unit[$count] = $tmp;
        }
        $output[$time_labels[$i]] = $unit;
        $stmt->close();
    }
    return $response->withJson($output);
});

// 122xx
$app->get("/query/sensor", function($req, $response) {
    if (!isset($req->getQueryParams()['src_id'])) return $response->withStatus(400)->withJson(['error' => true, 'code' => 12200, 'message' => 'Missing src_id']);
    else {
        $src_id = $req->getQueryParams()['src_id'];
        $sql = "SELECT * FROM sensor_map WHERE src_id=?";
        $stmt = $this->mysqli->prepare($sql);
        if (!$stmt) return $response->withStatus(500)->withJson(['error' => true, 'code' => 12201, 'message' => $err]);
        $stmt->bind_param("i", $src_id);
        $res = $stmt->execute();
        if (!$res) return $response->withStatus(500)->withJson(['error' => true, 'code' => 12202, 'message' => 'Error querying database. '.$stmt->error]);
        else {
            $result = $stmt->get_result();
            $row = $result->fetch_assoc();
            if ($row != null) return $response->withJson($row);
            else return $response->withStatus(404)->withJson(['error' => true, 'code' => 12203, 'message' => 'No entry found for sensor '.$src_id]);
        }
        $stmt->close();
    }
});

// 130xx
$app->get("/list", function($req, $response) {
    $sql = "SELECT src_id, location_name, latitude, longitude FROM sensor_map";
    $stmt = $this->mysqli->prepare($sql);
    $res = $stmt->execute();
    if (!$res) return $response->withStatus(500)->withJson(['error' => true, 'code' => 13000, 'message' => 'Error querying database']);
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

$app->map(['GET', 'POST', 'PUT', 'DELETE', 'PATCH'], '/{routes:.+}', function($req, $res) {
    $handler = $this->notFoundHandler; // handle using the default Slim page not found handler
    return $handler($req, $res);
});