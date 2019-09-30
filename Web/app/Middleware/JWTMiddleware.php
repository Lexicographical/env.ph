<?php

namespace App\Middleware;

use Lcobucci\JWT\Parser;
use Lcobucci\JWT\ValidationData;

class JWTMiddleware extends BaseMiddleware
{
    public function __invoke($request, $response, $next)
    {
        if (!isset($request->getHeaders()['HTTP_AUTHORIZATION'])) {
            return $response->withStatus(401)->withJson(['error' => true, 'message' => "JWT Token Required"]);
        }

        $token = explode(" ", $request->getHeaders()['HTTP_AUTHORIZATION'][0])[1];
        $token = (new Parser())->parse((string) $token);
        $data = new ValidationData();
        $data->setIssuer('https://api.amihan.xyz');
        $data->setAudience('https://amihan.xyz');
        if (!$token->validate($data)) {
            return $response->withStatus(401)->withJson(['error' => true, 'message' => "JWT Token Not Valid"]);
        }

        $request = $request->withAttribute('user', $token->getHeader('jti'));
        return $next($request, $response);
    }
}
