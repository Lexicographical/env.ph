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
/*
air_tile.dart
Data model
OOP model representing a single data entry for air data
 */
class AirTile {

  String createdAt;
  String entryId;
  String temp;
  String humidity;
  String gasSensor;
  String carbonMonoxide;
  String pM_1;
  String pM_2_5;
  String pM_10;

  AirTile(
      {
        this.createdAt,
        this.entryId,
        this.temp,
        this.humidity,
        this.gasSensor,
        this.carbonMonoxide,
        this.pM_1,
        this.pM_2_5,
        this.pM_10
      });

  factory AirTile.fromJson(Map<String, dynamic> json) {
    return AirTile(
        createdAt: json["created_at"],
        entryId: json["entryId"],
        temp: json["field1"],
        humidity: json["field2"],
        gasSensor: json["field3"],
        carbonMonoxide: json["field4"],
        pM_1: json["field5"],
        pM_2_5: json["field6"],
        pM_10: json["field7"],


    );
  }

}

