<?php

namespace App\Controllers;

class AdminController extends BaseController  {
    public function getAllUsers($req, $response) {
        $out=[];
        $sql = "SELECT id, name, email, type, created_at FROM users;";
        $stmt = $this->mysqli->prepare($sql);
        $res = $stmt->execute();
        if (!$res) {
            error("Error querying database: " . $this->mysqli->error, array("src" => "QueryController::list", "breakpoint" => "1"));
            return $response->withStatus(500)->withJson(['error' => true, 'message' => 'Error querying database']);
        } else {
            $result = $stmt->get_result();
            while (($row = $result->fetch_assoc()) != null) {
                $out[] = $row;
            }
            return $response->withJson($out);
        }
    }
    public function getAllDevices() {

    }
}
