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


