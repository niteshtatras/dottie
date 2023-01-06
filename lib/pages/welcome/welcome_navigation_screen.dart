import 'dart:developer';
import 'package:dottie_inspector/pages/welcome/welcome_inspection_page.dart';
import 'package:dottie_inspector/pages/welcome/welcome_template_screen.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/utils/connectivity/my_connectivity.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WelcomeNavigationScreen extends StatefulWidget {
  static String tag = 'welcome-navigation-screen';
  const WelcomeNavigationScreen({Key key}) : super(key: key);

  @override
  _WelcomeNavigationScreenState createState() => _WelcomeNavigationScreenState();
}

class _WelcomeNavigationScreenState extends State<WelcomeNavigationScreen> {

  int _selectedIndex = 0;
  bool isDarkMode = false;
  Color themeColor = AppColor.BLACK_COLOR;

  void _onItemTapped(int index) {
    log("SelectedIndex===$index");
    setState(() {
      _selectedIndex = index;
    });
  }

  final pages = [
    WelcomeTemplateScreenPage(),
    WelcomeInspectionPage(),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getThemeData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void getThemeData() async {
    await PreferenceHelper.getPreferenceData(PreferenceHelper.THEME_MODE).then((value){
      setState(() {
        var themeMode = value == null ? "" : value;
        log("ThemeData===$themeMode");
        if(themeMode == "auto") {
          var brightness = MediaQuery.of(context).platformBrightness;
          themeMode = Brightness.dark ==  brightness ? "dark" : "light";
        }
        isDarkMode = themeMode == "dark";
        themeColor = isDarkMode ? AppColor.WHITE_COLOR : AppColor.BLACK_COLOR;

        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: isDarkMode ? Colors.black : AppColor.WHITE_COLOR,
          statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        ));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.PAGE_COLOR,
      appBar: EmptyAppBar(isDarkMode: isDarkMode),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColor.BLACK_COLOR,
        elevation: 0,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        unselectedItemColor: Color(0xff808080),
        selectedItemColor: AppColor.WHITE_COLOR,
        selectedFontSize: 14,
        unselectedFontSize: 14,
        iconSize: 28,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
                "assets/new_ui/Ic_home.png",
                height: 28,
                width: 28,
              color: _selectedIndex == 0
                  ? AppColor.WHITE_COLOR
                  : Color(0xff808080),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/new_ui/ic_inspections.png",
              height: 28,
              width: 28,
              color: _selectedIndex == 1
                    ? AppColor.WHITE_COLOR
                    : Color(0xff808080),
            ),
            label: 'Inspections',
          ),
        ],
      ),
    );
  }
}
