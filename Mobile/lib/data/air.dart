import 'package:env_ph/utility/util_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:env_ph/constants.dart';
import 'package:env_ph/tiles/data_tile.dart';
import 'package:env_ph/data/air_tile.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'package:intl/intl.dart';
import 'package:env_ph/data/history.dart';
import 'package:location/location.dart';
import 'package:env_ph/constants.dart';

import 'package:env_ph/data/locations.dart';

DataFeed dataFeed;
int location_id = 814176;

var pageOptions = [AirPage(), HistoryPage(), Text("HE")];

class AirControl extends StatefulWidget {
  AirControlState createState() => AirControlState();
}

class AirControlState extends State<AirControl> {
  int _selectedPage = 0;

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedPage,
            onTap: (int index) {
              setState(() {
                _selectedPage = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.scatter_plot),
                title: Container(),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                title: Container(),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                title: Container(),
              ),
            ]),
        body: pageOptions.elementAt(_selectedPage));
  }
}

class AirPage extends StatefulWidget {
  @override
  AirPageState createState() => AirPageState();
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

Future<DataFeed> getSensorJsonData(int id) async {

  var response = await http.get(url + id.toString());

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON
    var data = json.decode(response.body);

    dataFeed = new DataFeed.fromJson(data);

  } else {
    // If that call was not successful, throw an error.
  }

  return dataFeed;
}

class AirPageState extends State<AirPage> {
  bool loaded = false;
  DataFeed dataFeed;

  void initState() {

    td.text = "Bonuan Gueset, Dagupan, 2400 Pangasinan";

    loaded = true;
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

  void updateLayout(bool nGeneral, int nDataType) {
    setState(() {
      dataType = nDataType;
    });
  }

  List<Widget> generateDataTiles(DataFeed feed) {


      List<DataTile> data = List(dataTypes.length);

      data[0] = DataTile(0, feed.latest[0].temp.toString());
      data[1] = DataTile(1, feed.latest[0].humidity.toString());
      data[2] = DataTile(2, feed.latest[0].carbonMonoxide.toString());
      data[3] = DataTile(3, feed.latest[0].carbonMonoxide.toString());
      data[4] = DataTile(4, feed.latest[0].pM_1.toString());
      data[5] = DataTile(5, feed.latest[0].pM_1.toString());
      data[6] = DataTile(6, feed.latest[0].pM_2_5.toString());


    return data;
  }

  void toggleLang() {
    setState(() {
      lang_idx++;
      lang_idx %= langs.length;
    });
  }

  List<String> locations;


  bool typing = false;
  TextEditingController td = TextEditingController();

  List<String> items = [];


  @override
  Widget build(BuildContext context) {


    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
        body: Stack(
      children: <Widget>[
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
                        padding: EdgeInsets.all(10))))),
        Positioned(
          top: 95,
          left: 25,
          child: Container(
            height: 80,
            width: width,
            child: Text("AIR QUALITY", style: TextStyle(fontFamily: "Avenir", fontWeight: FontWeight.w900, fontSize: 40, color: colorText)),
          )
        ),

        Positioned(
            top: height / 5,
            left: 25,
            child: Container(
                height: height / 4,
                width: width - 50,
                child: FutureBuilder(
                    future: getLocationJsonData(),
                    builder: (context, snapshot) {

                      if (snapshot.data != null) {

                        locations = List(snapshot.data.sensors.length);
                        for (var i = 0; i < snapshot.data.sensors.length; i++) {
                          locations[i] = snapshot.data.sensors[i].location_name;

                          utilSensorLocations[snapshot.data.sensors[i].location_name] = Coordinate(snapshot.data.sensors[i].longitude, snapshot.data.sensors[i].latitude);

                        }

                        return Stack(children: [TextField(
                          onTap: () {
                            td.clear();
                            setState((){
                              typing = true;
                            });
                          },
                          controller: td,
                          decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    new BorderSide(color: colorBtn, width: 2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    new BorderSide(color: colorBtn, width: 2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              prefixIcon:
                                  Icon(Icons.my_location, color: colorBtn)),
                          onChanged: (text) {

                            List<String> dummySearchList = List<String>();


                            dummySearchList.addAll(locations);

                            List<String> dummyListData = List<String>();

                            dummySearchList.forEach((item) {

                              if (item.contains(text)) {
                                dummyListData.add(item);
                              }
                            });

                            setState(
                                () {
                                  items.clear();
                                  items.addAll(dummyListData);
                                }
                            );
                            return;
                          },
                          onEditingComplete: () {
                            setState(() {
                              typing = false;
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                            });
                            setState(() {
                              items.clear();
                              items.addAll(locations);
                            });
                          },
                        ),

                          typing ? Positioned(
                            top:  65,
                            left: 25,
                            child: Container(
                                width: width - 50,
                                height: 250,
                                child: ListView.builder(
                                    itemCount: items.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        onTap: () {
                                          td.text = items[index];
                                          location_id =
                                          snapshot.data.sensors[index].src_id;

                                          setState(() {
                                            typing = false;
                                          });


                                          FocusScope.of(context)
                                              .requestFocus(new FocusNode());
                                        },
                                        leading: Icon(Icons.location_on),
                                        title: Text('${items[index]}'),
                                      );
                                    })),
                          ) : Container(),


                        ]);
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    }))),
        !typing ? Positioned(
          top: -20,
          left: 0,
          child:
        Container(
          width: width,
            height: 750,
            child: FutureBuilder(
                future: getSensorJsonData(location_id),
                builder: (context, snapshot) {
                  if (snapshot.data != null) {

                    return Container(
                        height: MediaQuery.of(context).size.height / 2,
                        margin: EdgeInsets.fromLTRB(
                            20, MediaQuery.of(context).size.height / 2.75, 0, 0),
                        child: GridView.count(
                          // Create a grid with 2 columns. If you change the scrollDirection to
                          // horizontal, this would produce 2 rows.
                            crossAxisCount: 1,
                            scrollDirection: Axis.horizontal,
                            mainAxisSpacing: 2,
                            childAspectRatio:
                            (width) / (MediaQuery.of(context).size.height / 3),
                            children: generateDataTiles(snapshot.data)));

                  } else {
                    return Center(child:CircularProgressIndicator());
                  }
                }
            )
        )) : Container()

      ],
    ));
  }
}
