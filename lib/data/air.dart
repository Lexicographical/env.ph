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
/*
air.dart
UI builder
Builds the page that displays the air data
 */
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:env_ph/constants.dart';
import 'package:env_ph/variables.dart';
import 'package:env_ph/home.dart';
import 'package:env_ph/tiles/data_tile.dart';
import 'package:env_ph/tiles/history_tile.dart';
import 'package:env_ph/routes/pageroutes.dart';
import 'package:env_ph/data/air_tile.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
List<AirTile> air_data_list;

class AirPage extends StatefulWidget {
  @override
  AirPageState createState() => AirPageState();
}

Future<List<AirTile>> getJsonData() async {
  var response = await http.get(url);

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON
    var data = json.decode(response.body);
    var rest = data["feeds"] as List;
    air_data_list =
        rest.map<AirTile>((json) => AirTile.fromJson(json)).toList();
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
  return air_data_list;



}
class AirPageState extends State<AirPage> {
  void initState() {
    super.initState();
    getJsonData();
  }

  void updateLayout(bool nGeneral, int nDataType) {
    setState(() {
      general = nGeneral;
      dataType = nDataType;
    });
  }

  List<Widget> generateDataTiles() {
    List<DataTile> data = List(dataTypes.length);

    data[0] = DataTile(0, updateLayout, air_data_list[air_data_list.length - 1].temp);
    data[1] = DataTile(1, updateLayout, air_data_list[air_data_list.length - 1].humidity);
    data[2] = DataTile(2, updateLayout, air_data_list[air_data_list.length - 1].gasSensor);
    data[3] = DataTile(3, updateLayout, air_data_list[air_data_list.length - 1].carbonMonoxide);
    data[4] = DataTile(4, updateLayout, air_data_list[air_data_list.length - 1].pM_1);
    data[5] = DataTile(5, updateLayout, air_data_list[air_data_list.length - 1].pM_2_5);
    data[6] = DataTile(6, updateLayout, air_data_list[air_data_list.length - 1].pM_10);

    return data;
  }

  List<Widget> generateHistoryTiles() {
    List<HistoryTile> data = List(air_data_list.length);

    var count = air_data_list.length - 1;

    switch (dataType) {
      case 0:
        for (var i = 0; i < air_data_list.length; i++) {

            data[i] = HistoryTile(
                air_data_list[count].temp.toString(),
                DateTime.parse(air_data_list[count].createdAt), dataType);
            count--;
          }

        break;
      case 1:
        for (var i = 0; i < air_data_list.length; i++) {

            data[i] = HistoryTile(
                air_data_list[count].humidity.toString(),
                DateTime.parse(air_data_list[count].createdAt), dataType);
            count--;
          }


        break;

      case 2:
        for (var i = 0; i < air_data_list.length; i++) {
          data[i] = HistoryTile(
              air_data_list[count].gasSensor.toString(),
              DateTime.parse(air_data_list[count].createdAt), dataType);
          count--;
        }
        break;

      case 3:
        for (var i = 0; i < air_data_list.length; i++) {
          data[i] = HistoryTile(
              air_data_list[count].carbonMonoxide.toString(),
              DateTime.parse(air_data_list[count].createdAt), dataType);
          count--;
        }
        break;

      case 4:
        for (var i = 0; i < air_data_list.length; i++) {
          data[i] = HistoryTile(
              air_data_list[count].pM_1.toString(),
              DateTime.parse(air_data_list[count].createdAt), dataType);
          count--;
        }
        break;

      case 5:
        for (var i = 0; i < air_data_list.length; i++) {
          data[i] = HistoryTile(
              air_data_list[count].pM_2_5.toString(),
              DateTime.parse(air_data_list[count].createdAt), dataType);
          count--;
        }
        break;

      case 6:
        for (var i = 0; i < air_data_list.length; i++) {

          data[i] = HistoryTile(
              air_data_list[count].pM_10.toString(),
              DateTime.parse(air_data_list[count].createdAt), dataType);
          count--;
        }
        break;

      default: {
        data = List(0);
      }

    }

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
      return Scaffold(
          body: FutureBuilder(
              future: getJsonData(),
              builder: (context, snapshot) {
                return snapshot.data != null
                    ? new Stack(
                  fit: StackFit.expand,
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
                        top: 10,
                        left: 10,
                        child: IconButton(
                          icon: Icon(Icons.keyboard_arrow_left,
                              color: colorBtn),
                          iconSize: 50,
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                                SlideLeftRoute(widget: HomePage()));
                          },
                        )),
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
                            child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    general = true;
                                  });
                                },
                                iconSize: 150,
                                icon: Image(
                                  image: AssetImage(
                                      "assets/images/env_air_button_plain.png"),
                                )))),
                    Positioned(
                        top: 130,
                        right: 20,
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                    general
                                        ? "AIR QUALITY"
                                        : dataTypes[dataType],
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
                                Text("Dagpuan, Pangasinan",
                                    style: styleLocationText)
                              ],
                            )
                          ],
                        )),
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 300, 10, 0),
                      child: Column(
                        children: <Widget>[
                          Expanded(
                              child: GridView.count(
                                // Create a grid with 2 columns. If you change the scrollDirection to
                                // horizontal, this would produce 2 rows.
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 9 / 10,
                                children: general
                                    ? generateDataTiles()
                                    : generateHistoryTiles(),
                              ))
                        ],
                      ),
                    )
                  ],
                )
                    : Center(child: CircularProgressIndicator());
              }));
    }
  }

//
