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

DataFeed dataFeed;


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

Future<DataFeed> getJsonData() async {
  var response = await http.get(url);

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON
    var data = json.decode(response.body);

    dataFeed = new DataFeed.fromJson(data);


  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }

  return dataFeed;

}

class AirPageState extends State<AirPage> {
  bool loaded = false;

  void initState() {
    loaded = true;
    super.initState();
    getJsonData();
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

  List<Widget> generateDataTiles() {

    List<DataTile> data = List(dataTypes.length);

    data[0] = DataTile(0, dataFeed.latest[0].temp.toString());
    data[1] = DataTile(1, dataFeed.latest[0].humidity.toString());
    data[2] = DataTile(2, dataFeed.latest[0].carbonMonoxide.toString());
    data[3] = DataTile(3, dataFeed.latest[0].carbonMonoxide.toString());
    data[4] = DataTile(4, dataFeed.latest[0].pM_1.toString());
    data[5] = DataTile(5, dataFeed.latest[0].pM_1.toString());
    data[6] = DataTile(6, dataFeed.latest[0].pM_2_5.toString());

    return data;
  }

  void toggleLang() {
    setState(() {
      lang_idx++;
      lang_idx %= langs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
        body: FutureBuilder(
            future: getJsonData(),
            builder: (context, snapshot) {
              return snapshot.data != null
                  ? new Stack(
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
                            top: 100,
                            left: -50,
                            child: Container(
                                decoration: BoxDecoration(boxShadow: [
                                  BoxShadow(
                                      color: colorFloatShadow,
                                      offset: Offset(0, 0),
                                      blurRadius: 20,
                                      spreadRadius: 5),
                                ], shape: BoxShape.circle),
                                child: Image(
                                      width: width / 2.37,
                                      height: width / 2.37,
                                      image: AssetImage(
                                          "assets/images/env_air_button_plain.png"),
                                    ))),
                        Positioned(
                            top: 125,
                            right: 20,
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text("AIR QUALITY",
                                        style: styleDataTypeText)
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Icon(Icons.location_on,
                                        color: colorBtn, size: 50),
                                    Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 0, 5, 0)),
                                    Text(getClosestLocation(),
                                        style: styleLocationText)
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                        child: Text(
                                          "UPDATED AS OF " + "\n" +
                                            DateFormat.yMMMd().format(DateTime.parse(
                                                dataFeed.latest[0].createdAt)) + " (" + DateFormat.Hm().format(DateTime.parse(
                                              dataFeed.latest[0].createdAt)) + ")",
                                          style: TextStyle(
                                              fontFamily: 'Avenir',
                                              fontSize: 15),
                                          textAlign: TextAlign.center,
                                        ),
                                        margin:
                                            EdgeInsets.fromLTRB(0, 10, 0, 0))
                                  ],
                                ),
                              ],
                            )),
                        Container(
                            height: MediaQuery.of(context).size.height / 2,
                            margin: EdgeInsets.fromLTRB(
                                20,
                                MediaQuery.of(context).size.height / 2.75,
                                0,
                                0),
                            child: GridView.count(
                              // Create a grid with 2 columns. If you change the scrollDirection to
                              // horizontal, this would produce 2 rows.
                              crossAxisCount: 1,
                              scrollDirection: Axis.horizontal,
                              mainAxisSpacing: 2,
                              childAspectRatio:
                                  (width) /
                                      (MediaQuery.of(context).size.height / 3),
                              children: generateDataTiles()
                            )


                        )],
                    )
                  : Center(child: CircularProgressIndicator());
            }));
  }
}

