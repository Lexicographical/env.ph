<?php

namespace App\Controllers;

class SensorController extends BaseController {
    public function create($req, $response) {
        $e = $req->getAttribute('user');
        if (!empty($e)) {
            $name = $req->getParsedBody()['name'];
            $api_key = uniqid("amihan_", true);
            $stmt = $this->mysqli->prepare("INSERT INTO sensor_map (`location_name`, `user_id`, `api_key`) VALUES (?, (SELECT id FROM users WHERE email=?), ?);");
            $stmt->bind_param("sss", $name, $e, $api_key);
            $res = $stmt->execute();
            $row = $stmt->get_result();
            return $response->withStatus(204);
        } else return $response->withStatus(401)->withJson([ 'error'=>true, 'message'=>'No User Found' ]);
    }
}
