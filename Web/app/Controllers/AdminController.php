<?php

namespace App\Controllers;

class AdminController extends BaseController
{
    public function getAllUsers($req, $response)
    {
        $out = [];
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
    public function getAllSensors($req, $response)
    {
        $out = [];
        $e = $req->getAttribute('user');
        $stmt = $this->mysqli->prepare("SELECT src_id, location_name FROM sensor_map;");
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
                if ($diff->days > 0) {
                    $d = $diff->days;
                    if ($d !== 1) {
                        $tmp["status"] = "Offline for $days days.";
                    } else {
                        $tmp["status"] = "Offline for $days day.";
                    }

                    $tmp['status_color'] = "red";
                } else if ($diff->h > 0) {
                    $h = $diff->h;
                    if ($h !== 1) {
                        $tmp["status"] = "Offline for $h hours.";
                    } else {
                        $tmp["status"] = "Offline for $h hour.";
                    }

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
    public function promoteUser($req, $response, $args)
    {
        $tmp = [];
        $e = $req->getAttribute('user');
        $stmt = $this->mysqli->prepare("UPDATE users SET type='admin' WHERE id=?;");
        $stmt->bind_param("i", $args['id']);
        $res = $stmt->execute();
        return $response->withStatus(204);
    }
    public function demoteUser($req, $response, $args)
    {
        $tmp = [];
        $e = $req->getAttribute('user');
        $stmt = $this->mysqli->prepare("UPDATE users SET type='user' WHERE id=?;");
        $stmt->bind_param("i", $args['id']);
        $res = $stmt->execute();
        return $response->withStatus(204);
    }
}
