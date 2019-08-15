<?php

namespace App\Controllers;

class SensorController extends BaseController {
    public function create($req, $response) {
        $e = $req->getAttribute('user');
        if (!empty($e)) {
            $name = $req->getParsedBody()['name'];
            $api_key = uniqid("amihan_", true);
            $locData = $this->guzzle->request('GET', 'https://geocoder.api.here.com/6.2/geocode.json?app_id='.$_ENV['HERE_MAPS_APP_ID'].'&app_code='.$_ENV['HERE_MAPS_APP_CODE'].'&searchtext='.$name.' Philippines');
            $locInfo = json_decode($locData->getBody(), true);
            $stmt = $this->mysqli->prepare("INSERT INTO sensor_map (`location_name`, `user_id`, `api_key`, `longitude`, `latitude`) VALUES (?, (SELECT id FROM users WHERE email=?), ?, ?, ?);");
            $stmt->bind_param("sssdd", $name, $e, $api_key, $locInfo['Response']['View'][0]['Result'][0]['Location']['DisplayPosition']['Longitude'], $locInfo['Response']['View'][0]['Result'][0]['Location']['DisplayPosition']['Latitude']);
            $res = $stmt->execute();
            $row = $stmt->get_result();
            return $response->withStatus(204);
        } else return $response->withStatus(401)->withJson([ 'error'=>true, 'message'=>'No User Found' ]);
    }
}
