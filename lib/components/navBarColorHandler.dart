import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void setNavBarColor(AdaptiveThemeMode? themeMode) {
  if(themeMode == AdaptiveThemeMode.dark) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.blueGrey[900],
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  } else {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.lightGreen[200],
        systemNavigationBarIconBrightness: Brightness.dark
    ));
  }
}