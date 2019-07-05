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
water.dart
UI builder
Builds the page that displays the water data
 */
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:env_ph/home.dart';
import 'package:env_ph/tiles/data_tile.dart';
import 'package:env_ph/tiles/history_tile.dart';
import 'package:env_ph/routes/pageroutes.dart';
import 'package:env_ph/constants.dart';
import 'package:env_ph/variables.dart';

class WaterPage extends StatefulWidget {
  @override
  WaterPageState createState() => WaterPageState();
}

class WaterPageState extends State<WaterPage> {

  List<Widget> generateDateTiles() {
    return [

    ];
  }

  List<Widget> generateHistoryTiles() {
    return [

    ];
  }

  void updateLayout(bool nGeneral, int nDataType) {
    setState((){
      general = nGeneral;
      dataType = nDataType;
    });
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
        body: new Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Positioned(
                top: 10,
                right: 10,
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
                        padding: EdgeInsets.all(10)))),
            Positioned(
                top: 10,
                left: 10,
                child: IconButton(
                  icon: Icon(Icons.keyboard_arrow_left, color: colorBtn),
                  iconSize: 50,
                  onPressed: () {
                    Navigator.of(context).pushReplacement(SlideLeftRoute(widget: HomePage()));
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
                          image:
                          AssetImage("assets/images/env_air_button_plain.png"),
                        )))),
            Positioned(
                top: 130,
                right: 20,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(general ? "WATER QUALITY" : dataTypes[dataType], style: styleDataTypeText)
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Icon(Icons.location_on, color: colorBtn, size: 50),
                        Padding(padding: EdgeInsets.fromLTRB(0, 0, 5, 0)),
                        Text("Dagpuan, Pangasinan", style: styleLocationText)
                      ],
                    )
                  ],
                )),
            Container(
              margin: EdgeInsets.fromLTRB(0, 300, 0, 0),
              child: Column(
                children: <Widget>[
                  Expanded(
                      child: GridView.count(
                        crossAxisCount: 3,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                        childAspectRatio: 2 / 3,
                        children: general ? generateDateTiles() : generateHistoryTiles(),
                      ))
                ],
              ),
            )
          ],
        ));
  }
}

