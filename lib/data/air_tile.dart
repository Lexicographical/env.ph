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

