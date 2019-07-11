import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';


final String url = "http://gramliu.com/env/index.php?action=query_data&src_id=810768&timestamp=2019-07-03-19";
final List<String> langs = ["EN", "TG"];
int lang_idx = 0;
var location;
Map<String, double> userLocation;

final List<String> dataTypes = [
  "Temperature",
  "Humidity",
  "CO Gas",
  "CO₂ Gas",
  "PM 1.0",
  "PM 2.5",
  "PM 10",
];

final List<String> symbols = [
  "ºC",
  "%",
  "ppm",
  "ppm",
  "μm / m³",
  "μm / m³",
  "μm / m³"
];

final List<List<String>> minMax = [
  ["20","50"],
  ["35", "85"],
  ["0", "100"],
  ["0", "100"],
  ["0", "75"],
  ["0", "75"],
  ["0", "75"]
];

final List<String> statusLabels = [
  "SAFE",
  "MODERATE",
  "DANGEROUS"
];

bool general = true;
int dataType = 0;

Future<Database> database;

final List<Color> statusColors = [
  Color(0xff05DCB6),
  Color(0xffFFC145),
  Color(0xffE25856),

];

final Color colorText = Color(0xff06CBC0);
final Color colorBtn = Color(0xff05DCB6);
final Color colorBtnSelected = Color(0xff07CBC0);
final Color colorNavButtonUnfocus = Color(0xff9e9e9e);
final Color colorNavButtonFocus = Color(0xff07CBC0);
final Color colorFloatShadow = Color(0x10000000);
final Color colorProgress = Color(0xff05DCB6);
final Color colorUnprogress = Color(0x10000000);
final Color colorCardBg = Color(0xffffffff);
final double startupBoxHeightFactor = 0.8;
final double startupLineHeight = 1;

final TextStyle styleStartupText = TextStyle(
    fontFamily: 'Avenir',
    color: colorText,
    fontSize: 30,
    height: startupLineHeight);
final TextStyle styleHomeText = TextStyle(
    fontFamily: 'Avenir',
    color: colorText,
    fontSize: 25,
    fontWeight: FontWeight.w700,
    height: startupLineHeight);
final TextStyle styleDataTypeText = TextStyle(
    fontFamily: 'Avenir',
    color: colorText,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: startupLineHeight);
final TextStyle styleLocationText =
    TextStyle(fontFamily: 'Avenir', fontSize: 15, height: startupLineHeight);
final TextStyle styleDataTileValue =
    TextStyle(fontFamily: 'Avenir', fontSize: 35, height: startupLineHeight);
final TextStyle styleLinearProgressLabel =
    TextStyle(fontFamily: 'Avenir', fontSize: 15, height: startupLineHeight);
final TextStyle styleSafeLabel =
    TextStyle(fontFamily: 'Avenir', fontSize: 18, height: startupLineHeight);

final Padding dataTilePadding =
    Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0));
