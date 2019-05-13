import 'package:flutter/material.dart';

final List<String> langs = ["EN", "TG"];
int lang_idx = 0;
final List<String> dataTypes = [
  "Benzene",
  "Formaline",
  "Methane",
  "PM 1.0",
  "PM 2.5",
  "PM 10"
];
bool general = true;
int dataType = 0;

final Color colorText = Color(0xff06CBC0);
final Color colorBtn = Color(0xff05DCB6);
final Color colorBtnSelected = Color(0xff07CBC0);
final Color colorNavButtonUnfocus = Color(0xff9e9e9e);
final Color colorNavButtonFocus = Color(0xff07CBC0);
final Color colorFloatShadow = Color(0x10000000);
final Color colorProgress = Color(0xff05DCB6);
final Color colorUnprogress = Color(0x10000000);
final Color colorCardBg = Color(0xffffffff);
final double startupBoxHeightFactor = 0.8;
final double startupLineHeight = 1;

final TextStyle styleStartupText = TextStyle(
    fontFamily: 'Avenir',
    color: colorText,
    fontSize: 30,
    height: startupLineHeight);
final TextStyle styleHomeText = TextStyle(
    fontFamily: 'Avenir',
    color: colorText,
    fontSize: 25,
    fontWeight: FontWeight.w700,
    height: startupLineHeight);
final TextStyle styleDataTypeText = TextStyle(
    fontFamily: 'Avenir',
    color: colorText,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: startupLineHeight);
final TextStyle styleLocationText =
    TextStyle(fontFamily: 'Avenir', fontSize: 18, height: startupLineHeight);
final TextStyle dataTileLabelStyle = TextStyle(
    fontFamily: 'Avenir',
    fontSize: 15,
    height: startupLineHeight,
    fontWeight: FontWeight.w700);
final TextStyle styleDataTileValue =
    TextStyle(fontFamily: 'Avenir', fontSize: 13, height: startupLineHeight);
final TextStyle styleLinearProgressLabel =
    TextStyle(fontFamily: 'Avenir', fontSize: 10, height: startupLineHeight);
final TextStyle styleSafeLabel =
    TextStyle(fontFamily: 'Avenir', fontSize: 13, height: startupLineHeight);

final Padding dataTilePadding =
    Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0));
