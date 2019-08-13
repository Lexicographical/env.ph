<?php
use Slim\Exception\NotFoundException;
require_once "utility.php";

// 15101-3
$app->add(new App\Middleware\IPMiddleware($container));

$app->get("/", function($req, $res) {
	return $res->withJson(["message" => "Hello, World! This is the Amihan API Server where real magic happens."]);
});

$app->get("/secure", function($req, $res) {
    $e = $req->getAttribute('user');
	return $res->withJson(["message" => "Hello, World! This is the Amihan API Server where real magic happens."]);
})->add(new App\Middleware\JWTMiddleware($container));

$app->group("/auth", function() {
    $this->post("/register", "AuthController:register");
    $this->post("/login", "AuthController:authenticate");
});

$app->group('/query', function() {
    // 120xx
    $this->get("/data", "QueryController:data");
    $this->get("/data/zip", "QueryController:zip");
    // 121xx
    $this->get("/data_app", "QueryController:app");
    // 122xx
    $this->get("/sensor", "QueryController:sensor");
    // 130xx
    $this->get("/list", "QueryController:list");
});

$app->map(['GET', 'POST', 'PUT', 'DELETE', 'PATCH'], '/{routes:.+}', function($req, $res) { $handler = $this->notFoundHandler; return $handler($req, $res); });