<?php

namespace App\Controllers;

class SensorController extends BaseController
{
    public function createSensors($req, $response)
    {
        $e = $req->getAttribute('user');
        if (!empty($e)) {
            $name = $req->getParsedBody()['name'];
            $api_key = uniqid("amihan_", true);
            $locData = $this->guzzle->request('GET', 'https://geocoder.api.here.com/6.2/geocode.json?app_id=' . $_ENV['HERE_MAPS_APP_ID'] . '&app_code=' . $_ENV['HERE_MAPS_APP_CODE'] . '&searchtext=' . $name . ' Philippines');
            $locInfo = json_decode($locData->getBody(), true);
            $stmt = $this->mysqli->prepare("INSERT INTO sensor_map (`location_name`, `user_id`, `api_key`, `longitude`, `latitude`) VALUES (?, (SELECT id FROM users WHERE email=?), ?, ?, ?);");
            $stmt->bind_param("sssdd", $name, $e, $api_key, $locInfo['Response']['View'][0]['Result'][0]['Location']['DisplayPosition']['Longitude'], $locInfo['Response']['View'][0]['Result'][0]['Location']['DisplayPosition']['Latitude']);
            $res = $stmt->execute();
            $row = $stmt->get_result();
            return $response->withStatus(204);
        } else {
            return $response->withStatus(401)->withJson(['error' => true, 'message' => 'No User Found']);
        }
    }

    public function renameSensor($req, $response) {
        $params = $req->getQueryParams();
        if (!isset($params["src_id"],
                   $params["api_key"],
                   $params["location_name"])) {
            return $response->withStatus(400)->withJson(['error' => true, 'message' => 'Missing parameters']);
        } else {
            $src_id = $params["src_id"];
            $api_key = $params["api_key"];
            
            if (!authenticateAPIRequest($api_key, $src_id)) {
                return $response->withStatus(400)->withJson(['error' => true, 'message' => 'Invalid API Key']);
            } else {
                $location_name = $params["location_name"];
                $sql = "UPDATE sensor_map SET location_name = ? WHERE src_id = ?";
                $stmt = $this->mysqli->prepare($sql);
                $stmt->bind_param("si", $location_name, $src_id);
                $res = $stmt->execute();

                if (!$res) {
                    error("Error renaming sensor: " . $stmt->error, array("src" => "SensorController:renameSensor"));
                    return $response->withStatus(400)->withJson(['error' => true, 'message' => 'Error renaming sensor.']);
                }
                $stmt_data->close();
                return $response->withStatus(200);
            }
        }
    }

    public function deleteSensor($req, $response) {
        $params = $req->getQueryParams();
        if (!isset($params["src_id"],
                   $params["api_key"])) {
            return $response->withStatus(400)->withJson(['error' => true, 'message' => 'Missing parameters']);
        } else {
            $src_id = $params["src_id"];
            $api_key = $params["api_key"];
            
            if (!authenticateAPIRequest($api_key, $src_id)) {
                return $response->withStatus(400)->withJson(['error' => true, 'message' => 'Invalid API Key']);
            } else {
                $sql = "DELETE FROM sensor_map WHERE src_id=?";
                $stmt = $this->mysqli->prepare($sql);
                $stmt->bind_param("i", $src_id);
                $res = $stmt->execute();

                if (!$res) {
                    error("Error deleting sensor: " . $stmt->error, array("src" => "SensorController:deleteSensor"));
                    return $response->withStatus(400)->withJson(['error' => true, 'message' => 'Error deleting sensor.']);
                }
                $stmt_data->close();
                return $response->withStatus(200);
            }
        }
    }

    private function authenticateAPIRequest($api_key, $src_id) {
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
                return $row['src_id'] == $src_id;
            }
        }
    }
}
