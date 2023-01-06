import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:flutter/material.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;
  // bool get isDarkMode => themeMode == ThemeMode.dark;
  ThemeData currentTheme;
  bool isDarkMode = false;

  void toggleTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  setLightMode() {
    currentTheme = ThemeData(
      brightness: Brightness.light, // LightMode
      primarySwatch: customColor,
    );
    notifyListeners();
  }

  setDarkMode() {
    currentTheme = ThemeData(
      brightness: Brightness.dark, // DarkMode
      primarySwatch: AppColor.BLACK_COLOR
    );
    notifyListeners();
  }

  getThemeMode() async {
    await PreferenceHelper.getPreferenceData(PreferenceHelper.THEME_MODE).then((value){
      var themeMode = value == null ? "" : value;
      print("ThemeData===$themeMode");
      if(themeMode == "auto") {
        // var brightness = .platformBrightness;
        // themeMode = Brightness.dark ==  brightness ? "dark" : "light";
      }
      isDarkMode = themeMode == "dark";
    });

    notifyListeners();
  }

}

final MaterialColor customColor = MaterialColor(
    0xff229DF5,
    const <int, Color>  {
      50: AppColor.THEME_PRIMARY,
      100:AppColor.THEME_PRIMARY,
      200:AppColor.THEME_PRIMARY,
      300:AppColor.THEME_PRIMARY,
      400:AppColor.THEME_PRIMARY,
      500:AppColor.THEME_PRIMARY,
      600:AppColor.THEME_PRIMARY,
      700:AppColor.THEME_PRIMARY,
      800:AppColor.THEME_PRIMARY,
      900:AppColor.THEME_PRIMARY,
    }
);