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

class Sensor {
  int src_id;
  String location_name;
  double longitude;
  double latitude;

  Sensor(
      {this.src_id,
        this.location_name,
        this.longitude,
        this.latitude,
     });

  factory Sensor.fromJson(Map<String, dynamic> json) {

    return new Sensor(
      src_id: json["src_id"],
      location_name: json["location_name"],
      latitude: json["latitude"],
      longitude: json["longitude"]
    );

  }

}

class Locations {
  final List<Sensor> sensors;

  Locations({
    this.sensors,
  });

  factory Locations.fromJson(Map<String, dynamic> json) {

    var list1 = json['sensors'] as List;
    List<Sensor> sensors = list1.map((i) => Sensor.fromJson(i)).toList();


    return Locations(
        sensors: sensors,
    );
  }



}


