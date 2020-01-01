<?php

namespace App\Controllers;

class UpdateController extends BaseController
{

    public function insertNewData($req, $response)
    {
        if (!isset($req->getQueryParams()["api_key"],
            $req->getQueryParams()["pm1"],
            $req->getQueryParams()["pm2_5"],
            $req->getQueryParams()["pm10"],
            $req->getQueryParams()["humidity"],
            $req->getQueryParams()["temperature"],
            $req->getQueryParams()["voc"],
            $req->getQueryParams()["carbon_monoxide"]
        )) {
            return $response->withStatus(400)->withJson(['error' => true, 'message' => 'Missing parameters']);
        } else {
            $api_key = $req->getQueryParams()["api_key"];
            $src_id = $this->verifyApiKey($api_key);
            if (!$src_id) {
                return $response->withStatus(400)->withJson(['error' => true, 'message' => 'Invalid API Key']);
            }

            $sql_data = "INSERT INTO sensor_data
            (src_id, entry_id, entry_time, pm1, pm2_5, pm10, humidity, temperature, voc, carbon_monoxide)
            VALUES (?, ?, NOW(), ?, ?, ?, ?, ?, ?, ?)";
            $stmt_data = $this->mysqli->prepare($sql_data);

            if (!$stmt_data) {
                error("Error occured: " . $this->mysqli->error, array("src" => "UpdateController:insertNewData", "breakpoint" => "1"));
                return $response->withStatus(400)->withJson(['error' => true, 'message' => 'Error occured.']);
            } else {
                $entry_id = $this->getLastEntryId($src_id);
                $pm1 = $req->getQueryParams()["pm1"];
                $pm2_5 = $req->getQueryParams()["pm2_5"];
                $pm10 = $req->getQueryParams()["pm10"];
                $humidity = $req->getQueryParams()["humidity"];
                $temperature = $req->getQueryParams()["temperature"];
                $voc = $req->getQueryParams()["voc"];
                $carbon_monoxide = $req->getQueryParams()["carbon_monoxide"];

                $stmt_data->bind_param("iiddddddd", $src_id, $entry_id,
                    $pm1, $pm2_5, $pm10, $humidity, $temperature, $voc, $carbon_monoxide);
                $res = $stmt_data->execute();
                if (!$res) {
                    error("Error executing update: " . $stmt->error, array("src" => "UpdateController:insertNewData", "breakpoint" => "2"));
                    return $response->withStatus(400)->withJson(['error' => true, 'message' => 'Error executing update.']);
                }
                $stmt_data->close();
                return $response->withStatus(200);
            }
        }
    }

    private function verifyApiKey($api_key)
    {
        $sql = "SELECT src_id FROM sensor_map WHERE api_key=?";
        $stmt = $this->mysqli->prepare($sql);
        $stmt->bind_param("s", $api_key);
        $res = $stmt->execute();

        if (!$res) {
            error("Error querying database to get API key", array("src" => "UpdateController:verifyApiKey", "src_id" => $api_key));
            return false;
        } else {
            $row = $stmt->get_result()->fetch_assoc();
            if ($row == null) {
                error("Error no sensor found with api_key " . $api_key, array("src" => "UpdateController:verifyApiKey", "api_key" => $api_key));
                return false;
            } else {
                return $row['src_id'];
            }
        }
    }

    private function getLastEntryId($src_id)
    {
        $sql = "SELECT MAX(entry_id) FROM sensor_data WHERE src_id=?";
        $stmt = $this->mysqli->prepare($sql);
        $stmt->bind_param("i", $src_id);
        $res = $stmt->execute();

        if (!$res) {
            error("Error querying database to get last entry id",
                array("src" => "UpdateController:getLastEntryId", "src_id" => $src_id));
            return false;
        } else {
            $row = $stmt->get_result()->fetch_assoc();
            if ($row == null) {
                error("Error no sensor found with src_id " . $src_id,
                    array("src" => "UpdateController:getLastEntryId", "src_id" => $src_id));
                return false;
            } else {
                $entry_id = $row["MAX(entry_id)"];
                if ($entry_id === null) {
                    $entry_id = 0;
                }
                return $entry_id + 1;
            }
        }
    }
}
