class AirTile {
   String createdAt;
   double temp;
   double humidity;
   double carbonMonoxide;
   double carbonDioxide;
   double pM_1;
   double pM_2_5;
   double pM_10;

  AirTile(
      {this.createdAt,
      this.temp,
      this.humidity,
      this.carbonMonoxide,
      this.carbonDioxide,
      this.pM_1,
      this.pM_2_5,
      this.pM_10});


  factory AirTile.fromJson(Map<String, dynamic> json) {

    return new AirTile(
      createdAt: json["entry_time"],
      temp: json["temperature"].toDouble(),
      humidity: json["humidity"].toDouble(),
      carbonMonoxide: json["carbon_monoxide"].toDouble(),
      carbonDioxide: json["carbon_dioxide"].toDouble(),
      pM_1: json["pm1"].toDouble(),
      pM_2_5: json["pm2_5"].toDouble(),
      pM_10: json["pm10"].toDouble(),

    );
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


