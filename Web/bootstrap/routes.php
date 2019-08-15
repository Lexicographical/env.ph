<?php
use Slim\Exception\NotFoundException;
require_once "utility.php";

$app->add(new App\Middleware\IPMiddleware($container));

$app->get("/", function($req, $res) {
	return $res->withJson(["message" => "Hello, World! This is the Amihan API Server where real magic happens."]);
});

$app->get("/secure", function($req, $res) {
    $e = $req->getAttribute('user');
	return $res->withJson(["message" => "Hello, World! This is the Amihan API Server where real magic happens."]);
})->add(new App\Middleware\JWTMiddleware($container));

$app->group("/auth", function() use ($container) {
    $this->post("/register", "AuthController:register");
    $this->post("/login", "AuthController:authenticate");
    $this->get("/verify", "AuthController:verify")->add(new App\Middleware\JWTMiddleware($container));
});

$app->group('/query', function() {
    $this->get("/data", "QueryController:data");
    $this->get("/data/zip", "QueryController:zip");
    $this->get("/data_app", "QueryController:app");
    $this->get("/sensor", "QueryController:sensor");
    $this->get("/list", "QueryController:list");
});

$app->group('/user', function() {
    $this->get('/sensors', "QueryController:userSensors");
    $this->post('/create/sensor', "SensorController:create");
})->add(new App\Middleware\JWTMiddleware($container));

$app->group("/update", function() {
    $this->get("/", "UpdateController:update");
});

$app->map(['GET', 'POST', 'PUT', 'DELETE', 'PATCH'], '/{routes:.+}', function($req, $res) { $handler = $this->notFoundHandler; return $handler($req, $res); });