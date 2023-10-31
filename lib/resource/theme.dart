import 'package:flutter/material.dart';

import '../utils/hex_color.dart';
import 'dimens.dart';

// Define Theme and can use directly to the app
var lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: HexColor("1FB0E6"),
    textTheme: TextTheme(
      bodyMedium: TextStyle(
          color: HexColor("#2D3142"),
          fontSize: textFontSize_14,
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.bold),
        headline1: TextStyle(
            color: HexColor("#2D3142"),
            fontSize: textFontSize_14,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.bold)

    ));
