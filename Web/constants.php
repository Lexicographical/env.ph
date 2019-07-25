<?php
include_once("auth.php");

$tdata = "sensor_data";
$tloc = "sensor_map";

$credentials = getDBCredentials();
$host = $credentials["host"];
$db = $credentials["db"];
$user = $credentials["user"];
$pw = $credentials["password"];