import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'constants.dart';
import 'data/air.dart';
import 'data/water.dart';
import 'package:env_ph/routes/pageroutes.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
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
        Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(SlideRightRoute(widget: AirPage()));
                },
                iconSize: 150,
                icon: Image(
                    image: AssetImage("assets/images/env_air_button.png"))),
            Text("AIR QUALITY", style: styleHomeText),
            Padding(
              padding: EdgeInsets.all(30),
            ),
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(SlideRightRoute(widget: WaterPage()));
                },
                iconSize: 150,
                icon: Image(
                    image: AssetImage("assets/images/env_water_button.png"))),
            Text("WATER QUALITY", style: styleHomeText),
          ],
        )),
      ],
    ));
  }
}
