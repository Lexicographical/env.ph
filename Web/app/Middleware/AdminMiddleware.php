<?php

namespace App\Middleware;

class AdminMiddleware extends BaseMiddleware
{
    public function __invoke($request, $response, $next) {
        $stmt = $this->container->mysqli->prepare("SELECT type FROM users WHERE email=?;");
        $e = $request->getAttribute('user');
        $stmt->bind_param("s", $e);
        $res = $stmt->execute();
        if (!$res) {
            error("Error querying database: " . $this->mysqli->error, array("src" => "QueryController::list", "breakpoint" => "1"));
            return $response->withStatus(500)->withJson(['error' => true, 'message' => 'Error querying database']);
        } else {
            $result = $stmt->get_result();
            $row = $result->fetch_array();
            if ($row[0] !== "admin") return $response->withStatus(403)->withJson([ 'error' => true, 'message' => "Insufficient Privileges" ]);
            else return $next($request, $response);
        }
    }
}
