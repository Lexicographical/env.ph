<?php
require_once __DIR__."/../vendor/autoload.php";
$dotenv = Dotenv\Dotenv::create(__DIR__.'/../');
if (file_exists(__DIR__.'/../.env')) $dotenv->load();
$config = [
	'settings' => [
        'determineRouteBeforeAppMiddleware' => true,
        'displayErrorDetails' => isset($_ENV['ENVIRONMENT']) && $_ENV['ENVIRONMENT'] !== "production"
	]
];
$container = new \Slim\Container($config);

$container['guzzle'] = function ($container) {
    return new \GuzzleHttp\Client();
};

$container['mysqli'] = function ($container) {
    return new mysqli($_ENV['MYSQL_DBHOST'], $_ENV['MYSQL_USERNAME'], $_ENV['MYSQL_PASSWORD'], $_ENV['MYSQL_DB']);
};

$container['geoip_api_key'] = function ($container) {
    return $_ENV["GEOIP_API_KEY"];
};

$container['notFoundHandler'] = function ($container) {
    return function ($req, $res) use ($container) {
        return $res->withJson(['error' => true, 'code' => 13000, 'message' => '[Error 13000] Unknown action']);
    };
};

$container['errorHandler'] = function ($container) {
    return function ($req, $res, $e) use ($container) {
        if (isset($_ENV['ENVIRONMENT']) && $_ENV['ENVIRONMENT'] !== "production") return $res->write($e);
        else return $res->withJson(['error' => true, 'code' => null, 'message' => 'Internal Server Error']);
    };
};

$app = new \Slim\App($container);

$app->options('/{routes:.+}', function ($request, $response, $args) {
    return $response;
});

$app->add(function ($req, $res, $next) {
    $response = $next($req, $res);
    return $response
            ->withHeader('Access-Control-Allow-Origin', '*')
            ->withHeader('Access-Control-Allow-Headers', 'X-Requested-With, Content-Type, Accept, Origin, Authorization')
            ->withHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS');
});

require_once "routes.php";