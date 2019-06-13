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
history_tile.dart
UI component
Data tile tile to present historical data
 */
import 'package:flutter/material.dart';
import 'package:env_ph/constants.dart';
import 'package:intl/intl.dart';

class HistoryTile extends StatefulWidget {
  String val;
  DateTime dt;
  int type;

  HistoryTile(String val, DateTime dt, int type) {
    this.val = val;
    this.dt = dt;
    this.type = type;
  }

  @override
  HistoryTileState createState() => HistoryTileState(val, dt, type);
}

class HistoryTileState extends State<HistoryTile> {
  String val;
  DateTime dt;
  int type;



  HistoryTileState(String val, DateTime dt, type) {
    this.val = val;
    this.dt = dt;
    this.type = type;
  }

  @override
  Widget build(BuildContext context) {

    int status;
    double ratio;

    try {
      ratio = double.parse(val) / double.parse(minMax[type][1]);


      if(ratio <= 0.4) {
        status = 0;
      } else if (ratio > 0.4 && ratio <= 0.75) {
        status = 1;
      } else {
        status = 2;
      }

      return Container(
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
                val + " " + symbols[type],
                style: dataTileLabelStyle,
                textAlign: TextAlign.center,
              ),
              Padding(padding: EdgeInsets.all(5)),
              Text(
                statusLabels[status],
                style: styleSafeLabel,
                textAlign: TextAlign.center,
              ),
              Padding(padding: EdgeInsets.all(5)),
              LinearProgressIndicator(
                value: ratio,
                backgroundColor: colorUnprogress,
                valueColor:

                AlwaysStoppedAnimation<Color>(statusColors[status]),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(minMax[type][0] + symbols[type], style: styleLinearProgressLabel),
                  Text(minMax[type][1]  + symbols[type], style: styleLinearProgressLabel)
                ],
              ),
              Padding(padding: EdgeInsets.all(5)),
              Text(
                DateFormat.yMMMd().format(dt) + "\n" + DateFormat.Hms().format(dt),
                style: styleSafeLabel,
                textAlign: TextAlign.center,
              )
            ],
          ));


    }

    on Exception {
      return Container();
    }

  }
}
