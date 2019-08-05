/*
 * Project Amihan - An Environmental Parameter Monitoring Tool
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

import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import "package:amihan/constants.dart";

class AirData {
  final int timestamp;
  final double pm1;
  final double pm2_5;
  final double pm10;
  final double co2;

  AirData({this.timestamp, this.pm1, this.pm2_5, this.pm10, this.co2});

  Map<String, dynamic> toMap() {
    return {
      "timestamp": timestamp,
      "pm1": pm1,
      "pm2_5": pm2_5,
      "pm10": pm10,
      "co2": co2
    };
  }
}

void initDB() async {
  database = openDatabase(
    join(await getDatabasesPath().toString(), "air.db"),
    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE AIR("
            "timestamp INTEGER PRIMARY KEY,"
            "pm1 REAL,"
            "pm2_5 REAL,"
            "pm10 REAL,"
            "co2 REAL)"
      );
    },
    version: 1
  );
}

Future<void> insertData(AirData data) async {
  final Database db = await database;
  await db.insert(
    "AIR",
    data.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace
  );
}

void dummyPush() async {
  AirData d1 = AirData(
      timestamp: DateTime.now().millisecondsSinceEpoch,
      pm1: 0.7,
      pm2_5: 0.8,
      pm10: 0.9,
      co2: 0.3);
  await insertData(d1);
}