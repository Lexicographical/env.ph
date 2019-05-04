import 'package:flutter/material.dart';
import 'constants.dart';

// TODO: Slide transitions between each page

final List<Widget> pages = [Page1(), Page2(), Page3()];
final TextStyle startupTextStyle = TextStyle(
    fontFamily: 'Avenir',
    color: textColor,
    fontSize: 30,
    height: startupLineHeight);
bool acceptedTerms = false;

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final List<String> langs = ["EN", "TG"];
  int lang_idx = 0;
  int page_idx = 0;

  void toggleLang() {
    setState(() {
      lang_idx++;
      lang_idx %= langs.length;
    });
  }

  void navPage(int i) {
    setState(() {
      page_idx = i;
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
                    fillColor: btnColor,
                    splashColor: btnSelectedColor,
                    elevation: 2,
                    padding: EdgeInsets.all(20)))),
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
                      color:
                          (page_idx == 0) ? navButtonFocus : navButtonUnfocus,
                      shape: new CircleBorder(),
                      onPressed: () {
                        navPage(0);
                      },
                    ),
                    width: 20),
                SizedBox(
                    child: RaisedButton(
                      color:
                          (page_idx == 1) ? navButtonFocus : navButtonUnfocus,
                      shape: new CircleBorder(),
                      onPressed: () {
                        navPage(1);
                      },
                    ),
                    width: 20),
                SizedBox(
                    child: RaisedButton(
                      color:
                          (page_idx == 2) ? navButtonFocus : navButtonUnfocus,
                      shape: new CircleBorder(),
                      onPressed: () {
                        navPage(2);
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
                  text: TextSpan(style: startupTextStyle, children: <TextSpan>[
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
                style: startupTextStyle,
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
                color: textColor,
                fontSize: 20),
            textAlign: TextAlign.center,
          ),
          Expanded(
              flex: 1,
              child: Container(
                  margin: EdgeInsets.all(20),
                  decoration:
                      BoxDecoration(border: Border.all(color: btnColor)),
                  child: SingleChildScrollView(
                    child: Text(
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam dictum sapien convallis, auctor ligula non, consequat erat. Fusce facilisis velit id nunc ullamcorper iaculis. Proin egestas sed mi nec feugiat. Aenean efficitur cursus nunc ac imperdiet. Nam luctus elit maximus velit euismod dictum. Ut posuere lobortis tellus ut dapibus. Cras et tristique eros, sit amet rutrum risus. Donec vitae risus ac turpis semper accumsan. Nullam pulvinar porttitor ipsum id condimentum. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin rhoncus purus posuere felis malesuada sagittis. Aliquam nunc quam, viverra eget lorem in, laoreet ultricies dui. Aliquam molestie nulla magna, et euismod enim efficitur sit amet. Nunc nulla sapien, venenatis id gravida scelerisque, feugiat vitae nisl. Integer vitae justo fringilla lacus dignissim interdum.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontFamily: 'Avenir',
                            fontSize: 15,
                            color: textColor)),
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
                activeColor: btnSelectedColor,
                checkColor: Colors.white,
              ),
              Text("I AGREE TO THE TERMS AND CONDITIONS",
                  style: TextStyle(
                      fontWeight: FontWeight.w100,
                      fontFamily: 'Avenir',
                      color: textColor))
            ],
          ),
          Container(
              child: MaterialButton(
                child: Text("LET'S GO!",
                    style: TextStyle(
                        fontFamily: 'Avenir',
                        fontSize: 20,
                        color: textColor,
                        fontWeight: FontWeight.w500)),
                onPressed: () {
                  print("Go");
                },
              ),
              decoration:
                  BoxDecoration(border: Border.all(color: btnColor, width: 3)))
        ],
      ),
    );
  }
}
