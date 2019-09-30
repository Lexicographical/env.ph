<?php

namespace App\Middleware;

class IPMiddleware extends BaseMiddleware
{
    public function __invoke($request, $response, $next)
    {
        $path = $request->getUri()->getPath();
        $params = $request->getUri()->getQuery();
        if ($path !== "/favicon.ico") {
            $cinfo = getConnectionInfo($this->container->geoip_api_key, $this->container->mysqli);
            $ip = $cinfo["ip"];
            $stmt1 = $this->container->mysqli->prepare("SELECT COUNT(*) FROM action_log WHERE ip=? AND entry_time > (time(now()) - INTERVAL 60 MINUTE);");
            $stmt1->bind_param("s", $ip);
            $stmt1->execute();
            $result = $stmt1->get_result();
            $r1 = $result->fetch_array();
            $stmt1->close();
            if ($r1[0] > $_ENV['RATE_LIMIT_AFTER']) {
                return $response->withHeader('X-RateLimit-Limit', $_ENV['RATE_LIMIT_AFTER'])->withHeader('X-RateLimit-Remaining', $_ENV['RATE_LIMIT_AFTER'] - $r1[0])->withStatus(429)->withJson(['error' => true, 'message' => 'Rate limit exceeded for the past hour. Please try again later.']);
            } else {
                $stmt = $this->container->mysqli->prepare("INSERT INTO action_log (ip, request, params) VALUES (?, ?, ?)");
                $stmt->bind_param("sss", $ip, $path, $params);
                $res = $stmt->execute();
                $stmt->close();
                if (!$res) {
                    return $response->withStatus(500)->withJson(['error' => true, 'code' => 15101, 'message' => 'Error occured']);
                }

            }
        }
        $response->withHeader('X-RateLimit-Limit', $_ENV['RATE_LIMIT_AFTER'])->withHeader('X-RateLimit-Remaining', $_ENV['RATE_LIMIT_AFTER'] - $r1[0]);
        return $next($request, $response);
    }
}
