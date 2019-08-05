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
import 'package:env_ph/data/locations.dart';
import 'package:flutter/services.dart';

int location_id = 814176;

class HistoryPage extends StatefulWidget {
  @override
  HistoryPageState createState() => HistoryPageState();
}

Future<Locations> getLocationJsonData() async {
  Locations sensorLocations;

  var sensorResponse = await http.get(urlLocations);

  if (sensorResponse.statusCode == 200) {
    // If the call to the server was successful, parse the JSON
    var locationsData = json.decode(sensorResponse.body);

    sensorLocations = new Locations.fromJson(locationsData);
  } else {
    // If that call was not successful, throw an error.
  }

  return sensorLocations;
}

Future<DataFeed> getJsonData(int src_id) async {
  var response = await http.get(url + src_id.toString());

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
    td.text = "Bonuan Gueset, Dagupan, 2400 Pangasinan";

    loaded = true;
    getJsonData(location_id);
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
            selectedWeek = false;
          } else {
            selectedDay = false;
          }
          break;
        case 1:
          if (!selectedMonth) {
            selectedMonth = true;
            selectedDay = false;
            selectedWeek = false;
          } else {
            selectedMonth = false;
          }
          break;
        case 2:
          if (!selectedWeek) {
            selectedWeek = true;
            selectedMonth = false;
            selectedDay = false;
          } else {
            selectedWeek = false;
          }
          break;
      }
    });
  }

  String selectedData = 'Temp'; // Option 2
  List<double> dataFactors;

  bool selectedDay = false;
  bool selectedWeek = false;
  bool selectedMonth = true;

  int idx = dataTypes.indexOf("Temp");

  var length;
  List<AirTile> data;

  List<String> locations;

  bool typing = false;
  bool empty = false;
  TextEditingController td = TextEditingController();

  List<String> items = [];

  String temporary;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              child: FutureBuilder(
                  future: getLocationJsonData(),
                  builder: (context, snapshot) {
                    if (snapshot.data != null) {
                      locations = List(snapshot.data.sensors.length);

                      for (var i = 0; i < snapshot.data.sensors.length; i++) {
                        locations[i] = snapshot.data.sensors[i].location_name;
                        utilSensorLocations[
                                snapshot.data.sensors[i].location_name] =
                            Coordinate(snapshot.data.sensors[i].longitude,
                                snapshot.data.sensors[i].latitude);
                      }

                      return Stack(children: [
                        Positioned(
                            top: height / 5,
                            left: 25,
                            child: Container(
                                height: height / 4,
                                width: width - 50,
                                child: Stack(children: [
                                  TextField(
                                    onTap: () {
                                      temporary = td.text;

                                      td.clear();

                                      setState(() {
                                        items.clear();

                                        for (var i = 0;
                                            i < snapshot.data.sensors.length;
                                            i++) {
                                          String location = (snapshot
                                              .data.sensors[i].location_name);
                                          items.add(location);
                                        }
                                        typing = true;
                                      });
                                    },
                                    controller: td,
                                    decoration: InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: new BorderSide(
                                              color: colorBtn, width: 2),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: new BorderSide(
                                              color: colorBtn, width: 2),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        prefixIcon: Icon(Icons.my_location,
                                            color: colorBtn)),
                                    onChanged: (text) {
                                      List<String> dummySearchList =
                                          List<String>();

                                      dummySearchList.addAll(locations);

                                      List<String> dummyListData =
                                          List<String>();

                                      dummySearchList.forEach((item) {
                                        if (item.contains(text)) {
                                          dummyListData.add(item);
                                        }
                                      });

                                      setState(() {
                                        items.clear();
                                        items.addAll(dummyListData);
                                      });
                                      return;
                                    },
                                    onEditingComplete: () {
                                      setState(() {
                                        typing = false;
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());
                                        td.text = temporary;

                                        items.clear();
                                        items.addAll(locations);
                                      });
                                    },
                                  ),
                                  typing
                                      ? Positioned(
                                          top: 80,
                                          left: 20,
                                          child: Container(
                                              width: width - 50,
                                              height: 140,
                                              child: ListView.builder(
                                                  itemCount: items.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return ListTile(
                                                      onTap: () {
                                                        td.text = items[index];
                                                        location_id = snapshot
                                                            .data
                                                            .sensors[index]
                                                            .src_id;

                                                        setState(() {
                                                          typing = false;
                                                        });

                                                        FocusScope.of(context)
                                                            .requestFocus(
                                                                new FocusNode());
                                                      },
                                                      leading: Icon(
                                                          Icons.location_on),
                                                      title: Text(
                                                          '${items[index]}'),
                                                    );
                                                  })))
                                      : Container(),
                                ])))
                      ]);
                    } else {
                      return Stack(
                        children: [
                          Positioned(
                            top: width / 2,
                            left: height / 2,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ],
                      );
                    }
                  })),
          !typing
              ? Positioned(
                  top: 200,
                  left: 25,
                  child: Container(
                      width: width - 50,
                      height: height - 50,
                      child: FutureBuilder(
                        future: getJsonData(location_id),
                        builder: (context, snapshot) {
                          if (snapshot.data != null) {

                            if (selectedDay) {
                              length = snapshot.data.day.length;
                              data = snapshot.data.day;
                            } else if (selectedWeek) {
                              length = snapshot.data.week.length;
                              data = snapshot.data.week;
                            } else if (selectedMonth) {
                              length = snapshot.data.month.length;
                              data = snapshot.data.month;
                            }

                            data.removeWhere((value) => value == null);

                            if (length < 1) {
                              empty = true;
                            }

                            dataFactors = List(length);

                            switch (idx) {
                              case 0:
                                for (int i = 0; i < length; i++) {
                                  dataFactors[i] =
                                      double.parse(data[i].temp.toString());
                                }
                                break;
                              case 1:
                                for (int i = 0; i < length; i++) {
                                  dataFactors[i] =
                                      double.parse(data[i].humidity.toString());
                                }
                                break;
                              case 2:
                                for (int i = 0; i < length; i++) {
                                  dataFactors[i] = double.parse(
                                      data[i].carbonMonoxide.toString());
                                }
                                break;
                                break;
                              case 3:
                                for (int i = 0; i < length; i++) {
                                  dataFactors[i] =
                                      double.parse(data[i].pM_1.toString());
                                  print(dataFactors[i]);
                                }
                                break;
                              case 4:
                                for (int i = 0; i < length; i++) {
                                  dataFactors[i] =
                                      double.parse(data[i].pM_2_5.toString());
                                }
                                break;
                              case 5:
                                for (int i = 0; i < length; i++) {
                                  dataFactors[i] =
                                      double.parse(data[i].pM_10.toString());
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
                                  top: height / 8.20,
                                  left: width / 3.65,
                                  child: Container(
                                      padding:
                                          EdgeInsets.fromLTRB(15, 5, 15, 5),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 2, color: colorBtn),
                                      ),
                                      child: Theme(
                                          data: Theme.of(context).copyWith(
                                              brightness: Brightness.light),
                                          child: DropdownButton(
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Color(0xff666666),
                                                  fontFamily: 'Avenir',
                                                  fontWeight: FontWeight.w900),
                                              items: dataTypes.map(
                                                  (String dropDownStringItem) {
                                                return DropdownMenuItem<String>(
                                                    value: dropDownStringItem,
                                                    child: Text(
                                                        dropDownStringItem));
                                              }).toList(),
                                              onChanged:
                                                  (String newValueSelected) {
                                                selectedData = newValueSelected;
                                                setState(() {
                                                  idx = dataTypes
                                                      .indexOf(selectedData);
                                                });
                                              },
                                              value: selectedData)))),
                              Positioned(
                                  top: width - 200,
                                  left: (width - 350) / 2,
                                  child: Row(children: [
                                    Container(
                                        margin:
                                            EdgeInsets.fromLTRB(10, 0, 0, 0),
                                        width: 90,
                                        height: 45,
                                        child: RaisedButton(
                                          color: Colors.white,
                                          padding: const EdgeInsets.all(0.0),
                                          child: Container(
                                              width: 90,
                                              height: 45,
                                              child: Center(
                                                  child: Text('Day',
                                                      style: selectedDay
                                                          ? TextStyle(
                                                              fontSize: 15,
                                                              fontFamily:
                                                                  'Avenir',
                                                              color:
                                                                  Colors.white)
                                                          : TextStyle(
                                                              fontSize: 15,
                                                              fontFamily:
                                                                  'Avenir',
                                                              color: Colors
                                                                  .black))),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20)),
                                                gradient: LinearGradient(
                                                  colors: selectedDay
                                                      ? <Color>[
                                                          colorBtn,
                                                          colorBtnSelected,
                                                        ]
                                                      : <Color>[
                                                          Color(0xfffff),
                                                          Color(0xffFFF),
                                                        ],
                                                ),
                                              )),
                                          onPressed: () {
                                            toggleData(0);
                                          },
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                        )),
                                    Container(
                                        margin:
                                            EdgeInsets.fromLTRB(10, 0, 0, 0),
                                        width: 90,
                                        height: 45,
                                        child: RaisedButton(
                                          color: Colors.white,
                                          padding: const EdgeInsets.all(0.0),
                                          child: Container(
                                              width: 150,
                                              height: 45,
                                              child: Center(
                                                  child: Text('Month',
                                                      style: selectedMonth
                                                          ? TextStyle(
                                                              fontSize: 15,
                                                              fontFamily:
                                                                  'Avenir',
                                                              color:
                                                                  Colors.white)
                                                          : TextStyle(
                                                              fontSize: 15,
                                                              fontFamily:
                                                                  'Avenir',
                                                              color: Colors
                                                                  .black))),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20)),
                                                gradient: LinearGradient(
                                                  colors: selectedMonth
                                                      ? <Color>[
                                                          colorBtn,
                                                          colorBtnSelected,
                                                        ]
                                                      : <Color>[
                                                          Color(0xfffff),
                                                          Color(0xffFFF),
                                                        ],
                                                ),
                                              )),
                                          onPressed: () {
                                            toggleData(1);
                                          },
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                        )),
                                    Container(
                                        margin:
                                            EdgeInsets.fromLTRB(10, 0, 0, 0),
                                        width: 90,
                                        height: 45,
                                        child: RaisedButton(
                                          color: Colors.white,
                                          padding: const EdgeInsets.all(0.0),
                                          child: Container(
                                              width: 150,
                                              height: 45,
                                              child: Center(
                                                  child: Text('Week',
                                                      style: selectedWeek
                                                          ? TextStyle(
                                                              fontSize: 15,
                                                              fontFamily:
                                                                  'Avenir',
                                                              color:
                                                                  Colors.white)
                                                          : TextStyle(
                                                              fontSize: 15,
                                                              fontFamily:
                                                                  'Avenir',
                                                              color: Colors
                                                                  .black))),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20)),
                                                gradient: LinearGradient(
                                                  colors: selectedWeek
                                                      ? <Color>[
                                                          colorBtn,
                                                          colorBtnSelected,
                                                        ]
                                                      : <Color>[
                                                          Color(0xfffff),
                                                          Color(0xffFFF),
                                                        ],
                                                ),
                                              )),
                                          onPressed: () {
                                            toggleData(2);
                                          },
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                        )),
                                  ])),
                              Positioned(
                                  top: width - 100,
                                  left: height / 50,
                                  child: Row(children: [
                                    RotatedBox(
                                        quarterTurns: 3,
                                        child: new Text(
                                            selectedData +
                                                "  (" +
                                                symbols[idx] +
                                                ") ",
                                            style: TextStyle(fontSize: 17))),
                                    Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(15, 0, 0, 0)),
                                    Column(children: [
                                      Text(maximum.toString()),
                                      Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 30, 0, 0)),
                                      Text(data4.toString()),
                                      Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 30, 0, 0)),
                                      Text(data3.toString()),
                                      Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 30, 0, 0)),
                                      Text(data2.toString()),
                                      Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 30, 0, 0)),
                                      Text(minimum.toString()),
                                    ])
                                  ])),
                              Positioned(
                                  top: width - 100,
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
                                              colors: [
                                                Color(0xff05DCB6),
                                                Color(0xff0AF5F0)
                                              ],
                                            ),
                                          ))))
                            ]);
                          } else {
                            return Stack(
                              children: [
                                Positioned(
                                  top: width / 2,
                                  left: height / 2,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      )),
                )
              : Container()
        ],
      ),
    );
  }
}

class CustomRadioButton extends StatelessWidget {
  final bool isSelected;
  final callback;

  CustomRadioButton({this.isSelected, this.callback});

  bool typing = false;

  TextEditingController td = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 45,
      child: RaisedButton(
        padding: const EdgeInsets.all(0.0),
        child: Container(
            width: 150,
            height: 45,
            child: Center(
                child: Text('Day',
                    style: TextStyle(fontSize: 15, fontFamily: 'Avenir'))),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              gradient: LinearGradient(
                colors: isSelected
                    ? <Color>[
                        Color(0xFF0D47A1),
                        Color(0xFF1976D2),
                        Color(0xFF42A5F5),
                      ]
                    : <Color>[
                        Color(0xffeee),
                        Color(0xffFFF),
                      ],
              ),
            )),
        onPressed: callback,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
    );
  }
}

//
