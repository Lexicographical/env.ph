import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import "package:env_ph/constants.dart";

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