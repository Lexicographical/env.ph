import 'package:flutter/material.dart';
import 'package:env_ph/constants.dart';
import 'package:env_ph/constants.dart';

class DataTile extends StatefulWidget {
  int idx = 0;
  var callback;

  DataTile(int idx, var callback) {
    this.idx = idx;
    this.callback = callback;
  }

  @override
  DataTileState createState() => DataTileState(idx, callback);
}

class DataTileState extends State<DataTile> {
  int idx = 0;
  var callback;

  DataTileState(int idx, var callback) {
    this.idx = idx;
    this.callback = callback;
  }

  @override
  Widget build(BuildContext context) {
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
                  "0.7 ppm",
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
                  "SAFE LEVEL",
                  style: styleSafeLabel,
                  textAlign: TextAlign.center,
                )
              ],
            )));
  }
}
