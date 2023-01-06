import 'package:dottie_inspector/deadCode/signIn/create_account.dart';
import 'package:dottie_inspector/deadCode/signIn/reset_password.dart';
import 'package:dottie_inspector/main/splash.dart';
import 'package:dottie_inspector/main/welcome_intro_page.dart';
import 'package:dottie_inspector/pages/dynamicInspection/dynamic_general_page.dart';
import 'package:dottie_inspector/pages/inspectionMain/inspection_adding_customer.dart';
import 'package:dottie_inspector/deadCode/safety_equipment_screen.dart';
import 'package:dottie_inspector/deadCode/welcome_new_screen.dart';
import 'package:dottie_inspector/pages/signInPages/login_page_1.dart';
import 'package:dottie_inspector/deadCode/signIn/login_page.dart';
import 'package:dottie_inspector/pages/welcome/welcome_navigation_screen.dart';
import 'package:dottie_inspector/pages/welcome/welcome_template_screen.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'deadCode/review/review_general_page.dart';

/*void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,Ø
    DeviceOrientation.portraitDown,
  ]);
  runApp(MyApp());
}*/

/*void main() {
//  https://api.dev.edu-collab.com/
  GlobalInstance.apiBaseUrl = 'https://dev.getmydottie.com/';
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SharedPreferences.getInstance().then((prefs) {
    var configuredApp = new AppConfig(
      appName: 'Inspector-Dottie',
      envName: 'development',
      apiBaseUrl: 'https://dev.getmydottie.com/',
      child: new MyApp(prefs: prefs),
    );
    runApp(configuredApp);
  });
}*/

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  static String version;

  MyApp({this.prefs});

  final routes = <String, WidgetBuilder>{
    CreateAccountPage.tag: (context) => CreateAccountPage(),
    LoginPage.tag: (context) => LoginPage(),
    LoginPage1.tag: (context) => LoginPage1(),
    WelcomeIntroPage.tag: (context) => WelcomeIntroPage(),
    WelcomeNavigationScreen.tag: (context) => WelcomeNavigationScreen(),
    WelcomeNewScreenPage.tag: (context) => WelcomeNewScreenPage(),
    WelcomeTemplateScreenPage.tag: (context) => WelcomeTemplateScreenPage(),

    ReviewGeneralPage.tag: (context) => ReviewGeneralPage(),
    // Chapter Pages End

    // Dynamic page tag
    DynamicGeneralPage.tag: (context) => DynamicGeneralPage(),

    SafetyEquipmentInspectionPage.tag: (context) =>
        SafetyEquipmentInspectionPage(),
    InspectionAddCustomer.tag: (context) => InspectionAddCustomer(),
    '/resetpassword': (context) => ResetPasswordPage()
  };

  static final navigatorKey = new GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inspector Dottie',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primarySwatch: customColor,
      ),
      debugShowCheckedModeBanner: false,
      routes: routes,
      home: SplashPage(),
    );
  }

  final MaterialColor customColor =
      MaterialColor(0xff229DF5, const <int, Color>{
    50: AppColor.THEME_PRIMARY,
    100: AppColor.THEME_PRIMARY,
    200: AppColor.THEME_PRIMARY,
    300: AppColor.THEME_PRIMARY,
    400: AppColor.THEME_PRIMARY,
    500: AppColor.THEME_PRIMARY,
    600: AppColor.THEME_PRIMARY,
    700: AppColor.THEME_PRIMARY,
    800: AppColor.THEME_PRIMARY,
    900: AppColor.THEME_PRIMARY,
  });
}
