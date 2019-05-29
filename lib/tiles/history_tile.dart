import 'package:flutter/material.dart';
import 'package:env_ph/constants.dart';
import 'package:intl/intl.dart';

class HistoryTile extends StatefulWidget {
  double val;
  DateTime dt;

  HistoryTile(double val, DateTime dt) {
    this.val = val;
    this.dt = dt;
  }

  @override
  HistoryTileState createState() => HistoryTileState(val, dt);
}

class HistoryTileState extends State<HistoryTile> {
  double val;
  DateTime dt;

  HistoryTileState(double val, DateTime dt) {
    this.val = val;
    this.dt = dt;
  }

  @override
  Widget build(BuildContext context) {
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
              val.toStringAsFixed(2) + " ppm",
              style: dataTileLabelStyle,
              textAlign: TextAlign.center,
            ),
            Padding(padding: EdgeInsets.all(5)),
            Text(
              "SAFE LEVEL",
              style: styleDataTileValue,
              textAlign: TextAlign.center,
            ),
            Padding(padding: EdgeInsets.all(5)),
            LinearProgressIndicator(
              value: 0.7 / 20,
              backgroundColor: colorUnprogress,
              valueColor: AlwaysStoppedAnimation<Color>(colorProgress),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("0 ppm", style: styleLinearProgressLabel),
                Text("20 ppm", style: styleLinearProgressLabel)
              ],
            ),
            Padding(padding: EdgeInsets.all(5)),
            Text(
              DateFormat.yMMMd().format(dt),
              style: styleSafeLabel,
              textAlign: TextAlign.center,
            )
          ],
        ));
  }
}
