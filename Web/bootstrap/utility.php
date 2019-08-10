<?php
use Monolog\Logger;
use Monolog\Handler\StreamHandler;
use Monolog\Formatter\LineFormatter;

$format = "%datetime% > %level_name% > %message% %context% %extra%\n";
$formatter = new LineFormatter($format);

$log = new Logger("route log");
$stream = new StreamHandler("routes.log", Logger::INFO);
$stream->setFormatter($formatter);
$log->pushHandler($stream);

// 15100
function arrayToCSV($array, $header, &$out, $delimeter=',') {
    $length = sizeof($array);
    $str = "";
    if ($length > 0) {
        $width = sizeof($array[0]);
        if ($width == sizeof($header)) {
            for ($i = 0; $i < $width; $i++) {
                $str .= $header[$i];
                if ($width-1 !== $i) $str .= $delimeter;
            }
            for ($i = 0; $i < $length; $i++) {
                $str .= "\r\n";
                for ($j = 0; $j < $width; $j++) {
                    $str .= $array[$i][$j];
                    if ($width-1 !== $j) $str .= $delimeter;
                }
            }
        } else {
            $out["error"] = true;
            $out["code"] = 15100;
            $out["message"] = "Array width does not match header width";
        }
    }
    return $str;
}

function startsWith($str, $prefix) {
    $len = strlen($prefix);
    return (strlen($str) >= $len) && (substr($str, 0, $len) === $prefix);
}

function isLocalIP($ip) {
    if ($ip === "::1" || $ip === "127.0.0.1") return true;
    $prefixes = array("192.168.", "10.");
    foreach ($prefixes as $prefix) {
        if (startsWith($ip, $prefix)) {
            return true;
        }
    }
    if (startsWith($ip, "172.")) {
        $octets = explode(".", $ip);
        $octet2 = (int) $octets[1];
        if ($octet2 >= 16 && $octet2 <= 31) {
            return true;
        }
    }
    return false;
}

function getConnectionInfo($apiKey, $mysqli) {
    global $log;
    if(!empty($_SERVER['HTTP_CLIENT_IP'])) $ip = $_SERVER['HTTP_CLIENT_IP'];
    else if (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) $ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
    else $ip = $_SERVER['REMOTE_ADDR'];
    $s1 = $mysqli->prepare("SELECT * FROM ip_map WHERE ip=? LIMIT 1");
    $s1->bind_param("s", $ip);
    $s1->execute();
    $result = $s1->get_result();
    $row = $result->fetch_array();
    if ($row === null) {
        if (isLocalIP($ip)) {
            return array(
                "ip" => $ip,
                "city" => "local",
                "country" => "local",
                "isp" => "local"
            );
        }
    
        $url = "https://api.ipgeolocation.io/ipgeo?apiKey=".$apiKey."&ip=".$ip;
        $guzzle = new \GuzzleHttp\Client();
        $res = $guzzle->request('GET', $url);
        $info = json_decode($res->getBody());
    
        if (isset($info->message)) {
            $log->info("Unknown ip", array("ip" => $ip, "message" => $info->message));
            return array(
                "ip" => $ip,
                "city" => "unknown",
                "country" => "unknown",
                "isp" => "unknown"
            );
        }
        $stmt = $mysqli->prepare("INSERT INTO ip_map (ip, city, country, isp) VALUES (?, ?, ?, ?)");
        $stmt->bind_param("ssss", $ip, $info->city, $info->country_name, $info->isp);
        $res = $stmt->execute();
        return array(
            "ip" => $ip,
            "city" => $info->city,
            "country" => $info->country_name,
            "isp" => $info->isp
        );
    } else return $row;
}