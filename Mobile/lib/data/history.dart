import 'package:env_ph/utility/util_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:env_ph/constants.dart';
import 'package:env_ph/data/air_tile.dart';

import 'package:env_ph/data/air_tile.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'package:intl/intl.dart';
import 'package:env_ph/data/air.dart';
import 'dart:math';


int location_id = 810768;


class HistoryPage extends StatefulWidget {
  @override
  HistoryPageState createState() => HistoryPageState();
}

Future<DataFeed> getJsonData() async {

  var response = await http.get(url + location_id.toString());

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON
    var data = json.decode(response.body);

    DataFeed dataFeed = new DataFeed.fromJson(data);

  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }

  return dataFeed;

}

class HistoryPageState extends State<HistoryPage> {
  bool loaded = false;

  void initState() {
    loaded = true;
    getJsonData();
    super.initState();
    location.onLocationChanged().listen((value) {
      if (loaded) {
        setState(() {
          userLocation = value;
        });
      }
    });
  }

  void dispose() {
    loaded = false;
    super.dispose();
  }

  void toggleLang() {

    setState(() {
      lang_idx++;
      lang_idx %= langs.length;
    });
  }

  void toggleData(int i) {
    setState(() {
      switch (i) {
        case 0:
          if (!selectedDay) {
            selectedDay = true;
            selectedMonth = false;
            selectedYear = false;
          } else {
            selectedDay = false;
          }
          break;
        case 1:
          if (!selectedMonth) {
            selectedMonth = true;
            selectedDay = false;
            selectedYear = false;
          } else {
            selectedMonth = false;
          }
          break;
        case 2:
          if (!selectedYear) {
            selectedYear = true;
            selectedMonth = false;
            selectedDay = false;
          } else {
            selectedYear = false;
          }
          break;
      }
    });
  }

  String selectedData = 'Temperature'; // Option 2
  List<double> dataFactors;

  bool selectedDay = true;
  bool selectedWeek = false;
  bool selectedMonth = false;
  bool selectedYear = false;

  var length;
  List<AirTile> data;

  @override
  Widget build(BuildContext context) {


    final width = MediaQuery
        .of(context)
        .size
        .width;
    final height = MediaQuery
        .of(context)
        .size
        .height;

    return Scaffold(
        body: FutureBuilder(
            future: getJsonData(),
            builder: (context, snapshot) {

              if (snapshot.data != null) {
                
                int idx = dataTypes.indexOf(selectedData);

                print(snapshot.data.week[0].temp);

                if(selectedDay) {
                  length = snapshot.data.day.length;
                  data = snapshot.data.day;
                } else if (selectedMonth) {
                  length = snapshot.data.month.length;
                  data = snapshot.data.month;
                } else if (selectedYear) {
                  length = snapshot.data.year.length;
                  data = snapshot.data.year;
                }

                dataFactors = List(length);


                switch (idx) {
                  case 0:
                    for (int i = 0; i < length; i++) {
                      dataFactors[i] = double.parse(data[i].temp.toString());
                    }
                    break;
                  case 1:
                    for (int i = 0; i < length; i++) {
                      dataFactors[i] = double.parse(data[i].humidity.toString());
                    }
                    break;
                  case 2:
                    for (int i = 0; i < length; i++) {
                      dataFactors[i] =
                          double.parse(data[i].carbonMonoxide.toString());
                    }
                    break;
                  case 3:
                    for (int i = 0; i < length; i++) {
                      dataFactors[i] =
                          double.parse(data[i].carbonDioxide.toString());
                    }
                    break;
                  case 4:
                    for (int i = 0; i < length; i++) {
                      dataFactors[i] = double.parse(data[i].pM_1.toString());
                      print(dataFactors[i]);
                    }
                    break;
                  case 5:
                    for (int i = 0; i < length; i++) {
                      dataFactors[i] = double.parse(data[i].pM_2_5.toString());
                    }
                    break;
                  case 6:
                    for (int i = 0; i < length; i++) {
                      dataFactors[i] = double.parse(data[i].pM_10.toString());
                    }
                    break;
                }

                var minimum = (dataFactors.reduce(min)).toInt();
                var maximum = (dataFactors.reduce(max)).toInt();
                var step = (maximum - minimum) / 5;
                var data2 = (minimum + step).toInt();
                var data3 = (minimum + 2 * step).toInt();
                var data4 = (minimum + 3 * step).toInt();


                return Stack(children: <Widget>[

                Positioned(
                    top: 10,
                    right: 10,
                    child: Hero(
                        tag: "toggleLang",
                        child: FittedBox(
                            child: RawMaterialButton(
                                onPressed: toggleLang,
                                child: Text(langs[lang_idx],
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Avenir',
                                        fontSize: 15)),
                                shape: CircleBorder(),
                                fillColor: colorBtn,
                                splashColor: colorBtnSelected,
                                elevation: 2,
                                padding: EdgeInsets.all(5))))),
                Positioned(
                    top: height / 7.20,
                    left: width / 3.5,
                    child: Container(
                        padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                        decoration: BoxDecoration(
                          border: Border.all(width: 2, color: colorBtn),
//                      boxShadow: [
//                        BoxShadow(
//                          color: Colors.blue,
//                          blurRadius: 1.0, // has the effect of softening the shadow
//                          spreadRadius: 1.0, // has the effect of extending the shadow
//                          offset: Offset(
//                            2.0, // horizontal, move right 10
//                            2.0, // vertical, move down 10
//                          ),
//                        )
//                      ]
                        ),
                        child: Theme(
                            data:
                            Theme.of(context).copyWith(
                                brightness: Brightness.light),
                            child: DropdownButton(
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Color(0xff666666),
                                    fontFamily: 'Avenir',
                                    fontWeight: FontWeight.w900),
                                items: dataTypes.map((
                                    String dropDownStringItem) {
                                  return DropdownMenuItem<String>(
                                      value: dropDownStringItem,
                                      child: Text(dropDownStringItem));
                                }).toList(),
                                onChanged: (String newValueSelected) {
                                  selectedData = newValueSelected;

                                  setState(() {});
                                },
                                value: selectedData)))),
                Positioned(
                    top: 225,
                    left: width / 5.1,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Icon(Icons.location_on, color: colorBtn, size: 50),
                            Padding(padding: EdgeInsets.fromLTRB(0, 0, 5, 0)),
                            Text(getClosestLocation(),
                                style: TextStyle(
                                    fontFamily: 'Avenir', fontSize: 20))
                          ],
                        ),
                      ],
                    )),
                Positioned(
                    top: width - 100,
                    left: height / 17,
                    child: Row(children: [

                      Container(
                          margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                          width: 90,
                          height: 45,
                          child: RaisedButton(
                            color: Colors.white,
                            padding: const EdgeInsets.all(0.0),
                            child: Container(
                                width: 150,
                                height: 45,
                                child: Center(child: Text('Day',
                                    style: selectedDay ? TextStyle(fontSize: 15,
                                        fontFamily: 'Avenir',
                                        color: Colors.white) : TextStyle(
                                        fontSize: 15,
                                        fontFamily: 'Avenir',
                                        color: Colors.black))),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(20)),
                                  gradient: LinearGradient(
                                    colors: selectedDay ? <Color>[
                                      colorBtn,
                                      colorBtnSelected,
                                    ] : <Color>[
                                      Color(0xfffff),
                                      Color(0xffFFF),
                                    ],
                                  ),
                                )),
                            onPressed: () {
                              toggleData(0);
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          )
                      ),

                      Container(
                          margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                          width: 90,
                          height: 45,
                          child: RaisedButton(
                            color: Colors.white,
                            padding: const EdgeInsets.all(0.0),
                            child: Container(
                                width: 150,
                                height: 45,
                                child: Center(child: Text('Month',
                                    style: selectedMonth ? TextStyle(
                                        fontSize: 15,
                                        fontFamily: 'Avenir',
                                        color: Colors.white) : TextStyle(
                                        fontSize: 15,
                                        fontFamily: 'Avenir',
                                        color: Colors.black))),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(20)),
                                  gradient: LinearGradient(
                                    colors: selectedMonth ? <Color>[
                                      colorBtn,
                                      colorBtnSelected,
                                    ] : <Color>[
                                      Color(0xfffff),
                                      Color(0xffFFF),
                                    ],
                                  ),
                                )),
                            onPressed: () {
                              toggleData(1);
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          )
                      ),

                      Container(
                          margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                          width: 90,
                          height: 45,
                          child: RaisedButton(
                            color: Colors.white,
                            padding: const EdgeInsets.all(0.0),
                            child: Container(
                                width: 150,
                                height: 45,
                                child: Center(child: Text('Year',
                                    style: selectedYear ? TextStyle(
                                        fontSize: 15,
                                        fontFamily: 'Avenir',
                                        color: Colors.white) : TextStyle(
                                        fontSize: 15,
                                        fontFamily: 'Avenir',
                                        color: Colors.black))),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(20)),
                                  gradient: LinearGradient(
                                    colors: selectedYear ? <Color>[
                                      colorBtn,
                                      colorBtnSelected,
                                    ] : <Color>[
                                      Color(0xfffff),
                                      Color(0xffFFF),
                                    ],
                                  ),
                                )),
                            onPressed: () {
                              toggleData(2);
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          )
                      ),


                    ])),
                Positioned(
                    top: width,
                    left: height / 50,
                    child: Row(children: [
                      RotatedBox(
                          quarterTurns: 3,
                          child: new Text(
                              selectedData + "  (" + symbols[idx] + ") ",
                              style: TextStyle(fontSize: 17))),
                      Padding(padding: EdgeInsets.fromLTRB(15, 0, 0, 0)),
                      Column(children: [
                        Text(maximum.toString()),
                        Padding(padding: EdgeInsets.fromLTRB(0, 30, 0, 0)),
                        Text(data4.toString()),
                        Padding(padding: EdgeInsets.fromLTRB(0, 30, 0, 0)),
                        Text(data3.toString()),
                        Padding(padding: EdgeInsets.fromLTRB(0, 30, 0, 0)),
                        Text(data2.toString()),
                        Padding(padding: EdgeInsets.fromLTRB(0, 30, 0, 0)),
                        Text(minimum.toString()),
                      ])
                    ])),
                Positioned(
                    top: width,
                    left: width - 325,
                    child: Align(
                        alignment: Alignment.center,
                        child: Container(
                            width: 300,
                            height: 200,
                            child: Sparkline(
                              data: dataFactors,
                              fillMode: FillMode.below,
                              pointsMode: PointsMode.all,
                              pointSize: 0,
                              pointColor: Colors.blue,
                              fillGradient: new LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: [Color(0xff05DCB6), Color(0xff0AF5F0)],
                              ),
                            ))))
              ]);

              } else {
                return CircularProgressIndicator();
              }

            }
        ));
  }

}

class CustomRadioButton extends StatelessWidget {

  CustomRadioButton({this.isSelected, this.callback});

  final bool isSelected;
  final callback;


  @override
  Widget build (BuildContext context) {

    return Container(
        width: 90,
        height: 45,
        child: RaisedButton(
          padding: const EdgeInsets.all(0.0),

          child: Container(
              width: 150,
              height: 45,
              child: Center(child: Text('Day',
                  style: TextStyle(fontSize: 15, fontFamily: 'Avenir'))),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                gradient: LinearGradient(
                  colors: isSelected ? <Color>[
                    Color(0xFF0D47A1),
                    Color(0xFF1976D2),
                    Color(0xFF42A5F5),
                  ] :  <Color>[
                    Color(0xffeee),
                    Color(0xffFFF),
                  ],
                ),
              )),
          onPressed: callback,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0),
          ),
        )
    );

  }
}

//
