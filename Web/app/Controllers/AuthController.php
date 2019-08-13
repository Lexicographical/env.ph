<?php

namespace App\Controllers;

use Lcobucci\JWT\Builder;
use Lcobucci\JWT\Signer\Key;
use Lcobucci\JWT\Signer\Hmac\Sha256;

class AuthController extends BaseController {
    public function register($req, $response) {
        $user = $req->getParsedBody();
        if (!(isset($user['name']) && isset($user['email']) && isset($user['password']))) return $response->withStatus(400)->withJson(["error" => true, "message" => "Missing parameters."]);
        $e = $user['email'];
        $stmt = $this->mysqli->prepare("SELECT COUNT(*) FROM users WHERE email=?;");
        $stmt->bind_param("s", $e);
        $res = $stmt->execute();
        $row = $stmt->get_result()->fetch_array();
        $stmtc = $this->mysqli->prepare("SELECT COUNT(*) FROM users;");
        $resc = $stmtc->execute();
        $rowc = $stmtc->get_result()->fetch_array();
        if ($row[0] > 0) return $response->withStatus(400)->withJson(["error" => true, "message" => "User $e already exists."]);
        if ($rowc[0] > 0) $stmt = $this->mysqli->prepare("INSERT INTO users (name, email, password, type) VALUES (?, ?,  ?, 'user');");
        else $stmt = $this->mysqli->prepare("INSERT INTO users (name, email, password, type) VALUES (?, ?,  ?, 'admin');");
        $p = password_hash($user['password'], PASSWORD_BCRYPT);
        $stmt->bind_param("sss", $user['name'], $e, $p);
        $res = $stmt->execute();
        $time = time();
        $signer = new Sha256();
        if (isset($_ENV['SECRET_KEY'])) $key = $_ENV['SECRET_KEY'];
        else $key = 'Project Amihan --- this is a secret please change this.';
        $token = (new Builder())->issuedBy('https://api.amihan.xyz')->permittedFor('https://amihan.xyz')->identifiedBy($e, true)->getToken($signer, new Key($key));
        return $response->withJson(['token' => (String) $token, 'email' => $e, 'name' => $user['name']]);
    }
    public function authenticate($req, $response) {
        $user = $req->getParsedBody();
        if (!(isset($user['email']) && isset($user['password']))) return $response->withStatus(400)->withJson(["error" => true, "message" => "Missing parameters."]);
        $e = $user['email'];
        $p = $user['password'];
        $stmt = $this->mysqli->prepare("SELECT * FROM users WHERE email=?");
        $stmt->bind_param("s", $e);
        $res = $stmt->execute();
        $row = $stmt->get_result()->fetch_array();
        if (!isset($row[0])) return $response->withStatus(401)->withJson(["error" => true, "message" => "User not found"]);
        if (!password_verify($p, $row['password'])) return $response->withStatus(401)->withJson(["error" => true, "message" => "Incorrect Password"]);
        $time = time();
        $signer = new Sha256();
        if (isset($_ENV['SECRET_KEY'])) $key = $_ENV['SECRET_KEY'];
        else $key = 'Project Amihan --- this is a secret please change this.';
        $token = (new Builder())->issuedBy('https://api.amihan.xyz')->permittedFor('https://amihan.xyz')->identifiedBy($e, true)->getToken($signer, new Key($key));
        return $response->withJson(['token' => (String) $token, 'email' => $e, 'name' => $row['name']]);
    }
}