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
data_tile.dart
UI Component
Data tile to organize and display the received data
 */
import 'package:flutter/material.dart';
import 'package:env_ph/constants.dart';
import 'package:env_ph/constants.dart';

class DataTile extends StatefulWidget {
  int idx = 0;
  var callback;
  String val;

  DataTile(int idx, var callback, String val) {
    this.idx = idx;
    this.callback = callback;
    this.val = val;
  }

  @override
  DataTileState createState() => DataTileState(idx, callback, val);
}

class DataTileState extends State<DataTile> {
  int idx = 0;
  var callback;
  String val;

  DataTileState(int idx, var callback, String val) {
    this.idx = idx;
    this.callback = callback;
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
        onTap: () {
          callback(false, idx);
        },
        child: Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                  color: colorFloatShadow,
                  offset: Offset(0, 0),
                  blurRadius: 5,
                  spreadRadius: 5)
            ], color: colorCardBg),
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  dataTypes[this.idx],
                  style: dataTileLabelStyle,
                  textAlign: TextAlign.left,
                ),
                Padding(padding: EdgeInsets.all(5)),
                Text(
                  val.toString() + " " + symbols[idx],
                  style: styleDataTileValue,
                  textAlign: TextAlign.center,
                ),
                Padding(padding: EdgeInsets.all(5)),
                LinearProgressIndicator(
                  value: ratio,
                  backgroundColor: colorUnprogress,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColors[status]),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(minMax[idx][0] + symbols[idx] , style: styleLinearProgressLabel),
                    Text(minMax[idx][1]  + symbols[idx], style: styleLinearProgressLabel)
                  ],
                ),
                Padding(padding: EdgeInsets.all(5)),
                Text(
                  statusLabels[status],
                  style: styleSafeLabel,
                  textAlign: TextAlign.center,
                )
              ],
            )));
  }
}
