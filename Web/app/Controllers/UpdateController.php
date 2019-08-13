<?php

namespace App\Controllers;

class UpdateController extends BaseController {
    private function verifyApiKey($mysql, $src_id, $api_key) {
        $sql = "SELECT api_key FROM sensor_map WHERE src_id=?";
        $stmt = $mysql->prepare($sql);
        $stmt->bind_param("i", $src_id);
        $res = $stmt->execute();

        if (!$res) {
            error("Error querying database to get API key", array("src" => "UpdateController::verifyApiKey", "src_id" => $src_id));
            return false;
        } else {
            $row = $stmt->get_result()->fetch_assoc();
            if ($row == null) {
                error("Error no sensor found with src_id " . $src_id, array("src" => "UpdateController:verifyApiKey", "src_id" => $src_id));
                return false;
            } else {
                $db_api_key = $row["api_key"];
                return $api_key === $db_api_key;
            }
        }
    }

    public function update($req, $response) {
        if (!isset($req->getQueryParams()["src_id"],
            $req->getQueryParams()["api_key"],
            $req->getQueryParams()["field1"],
            $req->getQueryParams()["field2"],
            $req->getQueryParams()["field3"],
            $req->getQueryParams()["field4"],
            $req->getQueryParams()["field5"],
            $req->getQueryParams()["field6"],
            $req->getQueryParams()["field7"]
        )) {
            return $response->withStatus(400)->withJson(['error' => true, 'message' => 'Missing parameters']);
        } else {
            $src_id = $req->getQueryParams()["src_id"];
            $api_key = $req->getQueryParams()["api_key"];

            if (!verifyApiKey($this->mysqli, $src_id, $api_key)) {
                return $response->withStatus(400)->withJson(['error' => true, 'message' => 'API Key is invalid!']);
            }

            $sql_data = "INSERT INTO sensor_data
            (src_id, entry_id, entry_time, pm1, pm2_5, pm10, humidity, temperature, voc, carbon_monoxide)
            VALUES (?, ?, NOW(), ?, ?, ?, ?, ?, ?, ?)";
            $stmt_data = $this->$mysqli->prepare($sql_data);

            if (!$stmt_data) {
                error("Error occured: ".$mysqli->error, array("src" => "UpdateController::update", "breakpoint" => "1"));
                return $response->withStatus(400)->withJson(['error' => true, 'message' => 'Error occured.']);
            } else {
                $entry_id = getLastEntryId();
                $pm1 = $req->getQueryParams()["field1"];
                $pm2_5 = $req->getQueryParams()["field2"];
                $pm10 = $req->getQueryParams()["field3"];
                $humidity = $req->getQueryParams()["field4"];
                $temperature = $req->getQueryParams()["field5"];
                $voc = $req->getQueryParams()["field6"];
                $carbon_monoxide = $req->getQueryParams()["field7"];

                $stmt_data->bind_param("iiddddddd", $src_id, $entry_id,
                    $pm1, $pm2_5, $pm10, $humidity, $temperature, $voc, $carbon_monoxide);
                $res = $stmt_data->execute();
                if (!$res) {
                    error("Error executing update: ".$stmt->error, array("src" => "UpdateController::update", "breakpoint" => "2"));
                    return $response->withStatus(400)->withJson(['error' => true, 'message' => 'Error executing update.']);
                }
                $stmt_data->close();
                info("Inserted new data", array("src_id" => $src_id, "count" => $count));
            }
        }
    }
}