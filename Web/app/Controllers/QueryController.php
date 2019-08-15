<?php

namespace App\Controllers;

class QueryController extends BaseController {
    public function data($req, $response) {
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

        if (!$res) {
            error("Error executing query: ".$stmt->error, array("src" => "QueryController::data", "breakpoint" => "1"));
            return $response->withStatus(500)->withJson(['error' => true, 'message' => 'Error executing query']);
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
            $data_labels = array("rec_id", "src_id", "entry_time", "pm1", "pm2_5", "pm10", "humidity", "temperature", "voc", "carbon_monoxide");
            
            if ($format == "csv" || $format == "tsv")  {
                $output = array();
                while (($row = $result->fetch_array()) != null) {
                    $tmp = array();
                    for ($i = 0; $i < sizeof($data_labels); $i++) {
                        if ($i === 2) {
                            date_default_timezone_set('UTC');
                            $row[$i] = (new \DateTime($row[$i]))->setTimezone(new \DateTimeZone('Asia/Manila'))->format('Y-m-d H:i:s');
                        }
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
                        if ($label === "entry_time") {
                            date_default_timezone_set('UTC');
                            $tmp[$label] = (new \DateTime($row[$label]))->setTimezone(new \DateTimeZone('Asia/Manila'))->format('Y-m-d H:i:s');
                        }
                        else $tmp[$label] = $row[$label];
                    }
                    $output[] = $tmp;
                }
                return $response->withJson($output);
            }
        }
    }
    public function zip($req, $response) {
        $src_id = isset($req->getQueryParams()['src_id']) ? $req->getQueryParams()['src_id'] : false;
        $month = isset($req->getQueryParams()['month']) ? $req->getQueryParams()['month'] : false;
        $year = isset($req->getQueryParams()['year']) ? $req->getQueryParams()['year'] : false;
        if ($month && !$year) {
            return $response->withStatus(400)->write("You need to place a year if you're querying a particular month.");
        } else if ($year && $month) $cd = (\DateTime::createFromFormat('!Ym', $year.$month));
        else if ($year) $cd = (\DateTime::createFromFormat('!Y', $year));
        if (isset($cd) && (!((new \DateTime())->modify('-1 month') >= $cd))) {
            return $response->withStatus(400)->write("Invalid Date Time (can be set up to one month before current month)");
        }
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
                for ($i = 0; $i < sizeof($data_labels); $i++) {
                    if ($i === 2) {
                        date_default_timezone_set('UTC');
                        $row[$i] = (new \DateTime($row[$i]))->setTimezone(new \DateTimeZone('Asia/Manila'))->format('Y-m-d H:i:s');
                    }
                    array_push($tmp, $row[$i]);
                }
                $output[] = $tmp;
            }
            $csv = arrayToCSV($output, $data_labels, $out, ",");
            $zipper = new \Chumper\Zipper\Zipper;
            $zipper->make(getcwd()."/../files/$filename")->addString("$filename.csv", $csv)->close();
        }
        return $response->withHeader('Content-type', "application/zip")->withHeader('Content-Disposition', "attachment; filename=$filename")->write(file_get_contents("../files/$filename"));
    }
    public function app($req, $response) {
        $src_id = isset($req->getQueryParams()['src_id']) ? $req->getQueryParams()['src_id'] : false;
        $ref_time = isset($req->getQueryParams()['timestamp']) ? $req->getQueryParams()['timestamp'] : date('Y-m-d H:i:s');
        if (!$src_id) {
            return $response->withStatus(400)->withJson(['error' => true, 'message' => 'Missing parameters']);
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
                if ($row = $result->fetch_array()) for ($j = 0; $j < sizeof($data_labels); $j++) {
                    if ($j === 0) {
                        date_default_timezone_set('UTC');
                        $tmp[$data_labels[$j]] = (new \DateTime($row[$j]))->setTimezone(new \DateTimeZone('Asia/Manila'))->format('Y-m-d H:i:s');
                    } else $tmp[$data_labels[$j]] = $row[$j];
                }
                else for ($j = 0; $j < sizeof($data_labels); $j++) $tmp[$data_labels[$j]] = 0;
                $unit[$count] = $tmp;
            }
            $output[$time_labels[$i]] = $unit;
            $stmt->close();
        }
        return $response->withJson($output);
    }
    public function sensor($req, $response) {
        if (!isset($req->getQueryParams()['src_id'])) {
            return $response->withStatus(400)->withJson(['error' => true, 'message' => 'Missing src_id']);
        } else {
            $src_id = $req->getQueryParams()['src_id'];
            $sql = "SELECT * FROM sensor_map WHERE src_id=?";
            $stmt = $this->mysqli->prepare($sql);
            if (!$stmt) {
                error($this->mysqli->error, array("src" => "QueryController::sensor", "breakpoint" => "1"));
                return $response->withStatus(500)->withJson(['error' => true, 'message' => "An error occured"]);
            }
            $stmt->bind_param("i", $src_id);
            $res = $stmt->execute();
            if (!$res) {
                error("Error querying database: ".$stmt->error, array("src" => "QueryController::sensor", "breakpoint" => "2"));
                return $response->withStatus(500)->withJson(['error' => true, 'message' => 'Error querying database.']);
            } else {
                $result = $stmt->get_result();
                $row = $result->fetch_assoc();
                if ($row != null) return $response->withJson($row);
                else {
                    return $response->withStatus(404)->withJson(['error' => true, 'message' => 'No entry found for sensor '.$src_id]);
                }
            }
            $stmt->close();
        }
    }
    public function list ($req, $response) {
        $sql = "SELECT src_id, location_name, latitude, longitude FROM sensor_map";
        $stmt = $this->mysqli->prepare($sql);
        $res = $stmt->execute();
        if (!$res) {
            error("Error querying database: " . $this->mysqli->error, array("src" => "QueryController::list", "breakpoint" => "1"));
            return $response->withStatus(500)->withJson(['error' => true, 'message' => 'Error querying database']);
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
    }
    public function userSensors ($req, $response) {
        $out = [];
        $e = $req->getAttribute('user');
        $stmt = $this->mysqli->prepare("SELECT src_id, location_name FROM sensor_map WHERE user_id = (SELECT id FROM users WHERE email=?);");
        $stmt->bind_param("s", $e);
        $res = $stmt->execute();
        $result = $stmt->get_result();
        while (($row = $result->fetch_array()) != null) {
            $tmp = array();
            $stmt2 = $this->mysqli->prepare("SELECT entry_time FROM sensor_data WHERE src_id=? ORDER BY entry_time DESC LIMIT 1;");
            $stmt2->bind_param("s", $row['src_id']);
            $res2 = $stmt2->execute();
            $result2 = $stmt2->get_result();
            $row2 = $result2->fetch_array();
            date_default_timezone_set('UTC');
            if (!empty($row2[0])) {
                $tmp["last_contact"] = (new \DateTime($row2[0]))->setTimezone(new \DateTimeZone('Asia/Manila'))->format('F d, Y - H:i:s A');
                $diff = ((new \DateTime($row2[0]))->diff(new \DateTime()));
                if ($diff->d > 0) {
                    $d = $diff->d;
                    if ($d !== 1) $tmp["status"] = "Offline for $d days.";
                    else $tmp["status"] = "Offline for $d day.";
                    $tmp['status_color'] = "red";
                } else if ($diff->h > 0) {
                    $h = $diff->h;
                    if ($h !== 1) $tmp["status"] = "Offline for $h hours.";
                    else $tmp["status"] = "Offline for $h hour.";
                    $tmp['status_color'] = "orange";
                } else {
                    $tmp["status"] = "Active";
                    $tmp['status_color'] = "green";
                }
            } else {
                $tmp["last_contact"] = "Never";
                $tmp["status"] = "No Data";
                $tmp['status_color'] = "black";
            }
            $tmp["src_id"] = $row["src_id"];
            $tmp["location_name"] = $row["location_name"];
            $out[] = $tmp;
        }
        return $response->withJson($out);
    }
}