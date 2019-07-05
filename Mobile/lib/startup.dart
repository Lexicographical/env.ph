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
startup.dart
UI builder
Builds the startup page that is displayed the first time the user opens the app.
 */
import 'package:env_ph/home.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'variables.dart';
import 'package:env_ph/routes/pageroutes.dart';

bool acceptedTerms = false;

class StartupPage extends StatefulWidget {
  StartupPage({Key key}) : super(key: key);

  @override
  StartupPageState createState() => StartupPageState();
}

class StartupPageState extends State<StartupPage>{
  final pages = [Page1(), Page2(), Page3()];
  int page_idx = 0;
  final navigatorKey = GlobalKey<NavigatorState>();

  void switchPage(int page) {
    setState(() {
      page_idx = page;
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
            top: 20,
            left: 10,
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
                                fontSize: 20)),
                        shape: CircleBorder(),
                        fillColor: colorBtn,
                        splashColor: colorBtnSelected,
                        elevation: 2,
                        padding: EdgeInsets.all(20))))),
        pages[page_idx],
        Positioned(
            left: 130,
            width: 100,
            bottom: 20,
            child: Center(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(
                    child: RaisedButton(
                      color: (page_idx == 0)
                          ? colorNavButtonFocus
                          : colorNavButtonUnfocus,
                      shape: new CircleBorder(),
                      onPressed: () {
                        switchPage(0);
//                        Navigator.of(nav).pushReplacementNamed("startup/page1");
                      },
                    ),
                    width: 20),
                SizedBox(
                    child: RaisedButton(
                      color: (page_idx == 1)
                          ? colorNavButtonFocus
                          : colorNavButtonUnfocus,
                      shape: new CircleBorder(),
                      onPressed: () {
                        switchPage(1);
//                        Navigator.of(context)
//                            .pushReplacementNamed("startup/page2");
                      },
                    ),
                    width: 20),
                SizedBox(
                    child: RaisedButton(
                      color: (page_idx == 2)
                          ? colorNavButtonFocus
                          : colorNavButtonUnfocus,
                      shape: new CircleBorder(),
                      onPressed: () {
                        switchPage(2);
//                        Navigator.of(context)
//                            .pushReplacementNamed("startup/page3");
                      },
                    ),
                    width: 20),
              ],
            ))),
      ],
    ));
  }
}

class Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: startupBoxHeightFactor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image(image: AssetImage("assets/images/starting_page_people.png")),
          Container(
              child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(style: styleStartupText, children: <TextSpan>[
                    TextSpan(
                        text: 'The',
                        style: TextStyle(height: startupLineHeight)),
                    TextSpan(
                        text: ' env.ph ',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            height: startupLineHeight)),
                    TextSpan(
                        text:
                            'team seeks to build a platform that provides environmental forecasts in real time.',
                        style: TextStyle(height: startupLineHeight)),
                  ])),
              padding: EdgeInsets.all(10)),
        ],
      ),
    );
  }
}

class Page2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: startupBoxHeightFactor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image(image: AssetImage("assets/images/starting_page_data.png")),
          Container(
              child: Text(
                "Take control of your health and lifestyle by regularly monitoring the environment around you.",
                style: styleStartupText,
                textAlign: TextAlign.center,
              ),
              padding: EdgeInsets.all(10)),
        ],
      ),
    );
  }
}

class Page3 extends StatefulWidget {
  @override
  Page3State createState() => Page3State();
}

class Page3State extends State<Page3> {
  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: startupBoxHeightFactor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FractionallySizedBox(
            widthFactor: 0.6,
            child: Image(image: AssetImage("assets/images/icon.png")),
          ),
          Text(
            "TERMS AND CONDITIONS",
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontFamily: 'Avenir',
                color: colorText,
                fontSize: 20),
            textAlign: TextAlign.center,
          ),
          Expanded(
              flex: 1,
              child: Container(
                  margin: EdgeInsets.all(20),
                  decoration:
                      BoxDecoration(border: Border.all(color: colorBtn)),
                  child: SingleChildScrollView(
                    child: Text(
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam dictum sapien convallis, auctor ligula non, consequat erat. Fusce facilisis velit id nunc ullamcorper iaculis. Proin egestas sed mi nec feugiat. Aenean efficitur cursus nunc ac imperdiet. Nam luctus elit maximus velit euismod dictum. Ut posuere lobortis tellus ut dapibus. Cras et tristique eros, sit amet rutrum risus. Donec vitae risus ac turpis semper accumsan. Nullam pulvinar porttitor ipsum id condimentum. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin rhoncus purus posuere felis malesuada sagittis. Aliquam nunc quam, viverra eget lorem in, laoreet ultricies dui. Aliquam molestie nulla magna, et euismod enim efficitur sit amet. Nunc nulla sapien, venenatis id gravida scelerisque, feugiat vitae nisl. Integer vitae justo fringilla lacus dignissim interdum.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontFamily: 'Avenir',
                            fontSize: 15,
                            color: colorText)),
                  ),
                  padding: EdgeInsets.all(20))),
          Row(
            children: <Widget>[
              Checkbox(
                value: acceptedTerms,
                onChanged: (bool state) {
                  setState(() {
                    acceptedTerms = state;
                  });
                },
                activeColor: colorBtnSelected,
                checkColor: Colors.white,
              ),
              Text("I AGREE TO THE TERMS AND CONDITIONS",
                  style: TextStyle(
                      fontWeight: FontWeight.w100,
                      fontFamily: 'Avenir',
                      color: colorText))
            ],
          ),
          Container(
              child: MaterialButton(
                child: Text("LET'S GO!",
                    style: TextStyle(
                        fontFamily: 'Avenir',
                        fontSize: 20,
                        color: colorText,
                        fontWeight: FontWeight.w500)),
                onPressed: () {
                  print("Go");
                  if (acceptedTerms) {
                    Navigator.of(context).pushReplacement(FadeRoute(widget: HomePage()));
                  }
                },
              ),
              decoration:
                  BoxDecoration(border: Border.all(color: colorBtn, width: 3)))
        ],
      ),
    );
  }
}
