/*
 * Project Amihan - An Environmental Parameter Monitoring Tool
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

import 'package:flutter/material.dart';
import 'package:amihan/constants.dart';

class DataTile extends StatefulWidget {
  int idx = 0;
  String val;

  DataTile(int idx, String val) {
    this.idx = idx;
    this.val = val;
  }

  @override
  DataTileState createState() => DataTileState(idx, val);
}

class DataTileState extends State<DataTile> {
  int idx = 0;
  String val;

  DataTileState(int idx, String val) {
    this.idx = idx;
    this.val = val;
  }

  @override
  Widget build(BuildContext context) {

    double ratio = double.parse(val) / int.parse(minMax[idx][1]);
    int status;
    if(ratio <= 0.4) {
      status = 0;
    } else if (ratio > 0.4 && ratio <= 0.75) {
      status = 1;
    } else {
      status = 2;
    }

    return GestureDetector(
        child: Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                  color: colorFloatShadow,
                  offset: Offset(0, 0),
                  blurRadius: 5,
                  spreadRadius: 5)
            ], color: colorCardBg),
            margin: EdgeInsets.all(5),
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  child:
                Text(
                  dataTypes[this.idx],
                  style: TextStyle(
                      color: statusColors[status],
                      fontFamily: 'Avenir',
                      fontSize: 15,
                      height: startupLineHeight,
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                  decoration: BoxDecoration(
                      border: Border.all(width: 3, color: statusColors[status])),
                ),

                Padding(padding: EdgeInsets.all(10)),
                Text(
                  val.toString() + " " + symbols[idx],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Avenir',
                      fontSize: 20,
                      height: startupLineHeight),
                ),
                Padding(padding: EdgeInsets.all(10)),
                LinearProgressIndicator(

                  value: ratio,
                  backgroundColor: colorUnprogress,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColors[status]),
                ),
              ],
            )));
  }
}
