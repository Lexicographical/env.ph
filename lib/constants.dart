/*
 * env.ph - An Environmental Parameter Monitoring Tool
 * Copyright (C) 2019 Philippine Innovation Network
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';


final String url = "http://thingspeak.com/channels/772942/feed.json";
final List<String> langs = ["EN", "TG"];
int lang_idx = 0;


final List<String> dataTypes = [
  "Temperature",
  "Humidity",
  "Gas Sensor",
  "CO Gas",
  "PM 1.0",
  "PM 2.5",
  "PM 10"
];

final List<String> symbols = [
  "ºC",
  "%",
   "ppm",
  "ppm",
  "μm / m3",
  "μm / m3",
  "μm / m3"
];

final List<List<String>> minMax = [
  ["15","50"],
  ["35", "75"],
  ["0","300"],
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
  Color(0xffFFE44F),
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
    TextStyle(fontFamily: 'Avenir', fontSize: 16.5, height: startupLineHeight);
final TextStyle dataTileLabelStyle = TextStyle(
    fontFamily: 'Avenir',
    fontSize: 20,
    height: startupLineHeight,
    fontWeight: FontWeight.w700);
final TextStyle styleDataTileValue =
    TextStyle(fontFamily: 'Avenir', fontSize: 22, height: startupLineHeight);
final TextStyle styleLinearProgressLabel =
    TextStyle(fontFamily: 'Avenir', fontSize: 10, height: startupLineHeight);
final TextStyle styleSafeLabel =
    TextStyle(fontFamily: 'Avenir', fontSize: 15, height: startupLineHeight);

final Padding dataTilePadding =
    Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0));
