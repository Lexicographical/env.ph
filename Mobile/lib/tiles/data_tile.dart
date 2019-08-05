import 'package:flutter/material.dart';
import 'package:env_ph/constants.dart';

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
