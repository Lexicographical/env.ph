<?php
use Slim\Exception\NotFoundException;
require_once "utility.php";

$app->add(new App\Middleware\IPMiddleware($container));

$app->get("/", function ($req, $res) {
    return $res->withJson(["message" => "Hello, World! This is the Amihan API Server where real magic happens."]);
});

$app->get("/secure", function ($req, $res) {
    $e = $req->getAttribute('user');
    return $res->withJson(["message" => "Hello, World! This is the Amihan API Server where real magic happens."]);
})->add(new App\Middleware\JWTMiddleware($container));

$app->group("/auth", function () use ($container) {
    $this->post("/register", "AuthController:register");
    $this->post("/login", "AuthController:authenticate");
    $this->get("/verify", "AuthController:verify")->add(new App\Middleware\JWTMiddleware($container));
});

$app->group('/query', function () {
    $this->get("/data", "QueryController:getData");
    $this->get("/data/zip", "QueryController:getZippedData");
    $this->get("/data_app", "QueryController:getAppData");
    $this->get("/sensor", "QueryController:getSensorInfo");
    $this->get("/sensor/pm1", "QueryController:getSensorData");
    $this->get("/sensor/pm2_5", "QueryController:getSensorData");
    $this->get("/sensor/pm10", "QueryController:getSensorData");
    $this->get("/sensor/humidity", "QueryController:getSensorData");
    $this->get("/sensor/temperature", "QueryController:getSensorData");
    $this->get("/sensor/voc", "QueryController:getSensorData");
    $this->get("/sensor/carbon_monoxide", "QueryController:getSensorData");
    $this->get("/list", "QueryController:getSensorsList");
});

$app->get("/list", "QueryController:getSensorsList");

$app->group('/user', function () {
    $this->get('/sensors', "QueryController:getUserSensors");
    $this->get('/sensor/{id}', "QueryController:getUserSensor");
    $this->post('/create/sensor', "SensorController:createSensors");
})->add(new App\Middleware\JWTMiddleware($container));

$app->group('/admin', function () {
    $this->get('/users', "AdminController:getAllUsers");
    $this->get('/sensors', "AdminController:getAllSensors");
    $this->get('/promote/{id}', "AdminController:promoteUser");
    $this->get('/demote/{id}', "AdminController:demoteUser");
})->add(new App\Middleware\AdminMiddleware($container))->add(new App\Middleware\JWTMiddleware($container));

$app->group("/update", function () {
    $this->get("/", "UpdateController:insertNewData");
});

$app->map(['GET', 'POST', 'PUT', 'DELETE', 'PATCH'], '/{routes:.+}', function ($req, $res) {$handler = $this->notFoundHandler;return $handler($req, $res);});
