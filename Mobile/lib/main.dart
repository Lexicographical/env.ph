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
main.dart
Central script for running the app. Please avoid cluttering this file. When
possible, migrate function and variable definitions to separate files.
 */
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
