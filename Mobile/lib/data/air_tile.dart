class AirTile {
   String createdAt;
   double temp;
   double humidity;
   double carbonMonoxide;
   double pM_1;
   double pM_2_5;
   double pM_10;

  AirTile(
      {this.createdAt,
      this.temp,
      this.humidity,
      this.carbonMonoxide,
      this.pM_1,
      this.pM_2_5,
      this.pM_10});


  factory AirTile.fromJson(Map<String, dynamic> json) {


    if (json["entry_time"] != 0) {

      return new AirTile(
        createdAt: json["entry_time"] as String,
        temp: double.parse(json["temperature"].toString()),
        humidity: double.parse(json["humidity"].toString()),
        carbonMonoxide: double.parse(json["carbon_monoxide"].toString()),
        pM_1: double.parse(json["pm1"].toString()),
        pM_2_5: double.parse(json["pm2_5"].toString()),
        pM_10: double.parse(json["pm10"].toString()),

      );
    } else {
      return null;
    }

  }

}

class DataFeed {
  final List<AirTile> latest;
  final List<AirTile> day;
  final List<AirTile> week;
  final List<AirTile> month;
  final List<AirTile> year;

  DataFeed({
    this.latest,
    this.day,
    this.week,
    this.month,
    this.year
  });

  factory DataFeed.fromJson(Map<String, dynamic> json) {

    var list1 = json['latest'] as List;
    List<AirTile> latest = list1.map((i) => AirTile.fromJson(i)).toList();

    var list2 = json['day'] as List;

    List<AirTile> day = list2.map((i) => AirTile.fromJson(i)).toList();

    var list3 = json['week'] as List;
    List<AirTile> week = list3.map((i) => AirTile.fromJson(i)).toList();

    var list4 = json['month'] as List;
    List<AirTile> month = list4.map((i) => AirTile.fromJson(i)).toList();

    var list5 = json['year'] as List;
    List<AirTile> year = list5.map((i) => AirTile.fromJson(i)).toList();


    return DataFeed(
      latest: latest,
      day: day,
      week: week,
      month: month,
      year: year
    );
  }



}


