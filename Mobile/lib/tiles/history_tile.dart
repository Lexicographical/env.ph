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
                style: styleDataTileValue,
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
