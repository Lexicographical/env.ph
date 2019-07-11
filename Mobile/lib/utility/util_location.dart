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

import 'package:location/location.dart';
import 'package:env_ph/constants.dart';
import 'dart:math';


class Coordinate {
  double latitude;
  double longitude;

  Coordinate(double latitude, double longitude) {
    this.latitude = latitude;
    this.longitude = longitude;
  }

  double distance(Coordinate other) {
    var dx = other.longitude - longitude;
    var dy = other.latitude - latitude;
    return sqrt(dx*dx +dy*dy);
  }
}

Map<String, Coordinate> sensorLocations = Map<String, Coordinate>();

// TODO: update sensor GPS locations here
void initLocations() {
  location = new Location();
  sensorLocations["Dagupan, Pangasinan"] = Coordinate(16.0433, 120.3333);
}

String getClosestLocation() {
  if (userLocation == null) {
    return "n/a";
  }
  Coordinate current = Coordinate(userLocation["latitude"], userLocation["longitude"]);
  double closest = -1;
  String location = "n/a";
  for (String locName in sensorLocations.keys) {
    double dist = current.distance(sensorLocations[locName]);
    if (closest < 0 || closest > dist) {
      closest = dist;
      location = locName;
    }
  }

  return location;
}