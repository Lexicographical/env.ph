import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home.dart';
import 'constants.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'env.ph',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          hintColor: btnColor
        ),
        home: HomePage(title: 'env.ph'));
  }
}