import 'package:env_ph/utility/util_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'constants.dart';
import 'startup.dart';
import 'home.dart';
import 'package:env_ph/data/air.dart';
import 'package:env_ph/data/water.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    initLocations();
    SystemChrome.setEnabledSystemUIOverlays([]);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'env.ph',
        theme: ThemeData(primarySwatch: Colors.blue, hintColor: colorBtn),
        initialRoute: "/",
        routes: {
          "/home": (context) => HomePage(),
          "/air": (context) => AirPage(),
          "/water": (context) => WaterPage(),
        },
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en'),
          const Locale('tl'),
        ],
        home: StartupPage());
  }
}
