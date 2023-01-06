import 'dart:async';

import 'package:dottie_inspector/main/welcome_intro_page.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/widget/GradientText.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../pages/welcome/welcome_navigation_screen.dart';

class SplashPage extends StatefulWidget{
  static String tag = 'splash-page';

  @override
  _SplashPageState createState() => new _SplashPageState();
}

// Toggle this to cause an async error to be thrown during initialization
// and to test that runZonedGuarded() catches the error
const _kShouldTestAsyncErrorOnInit = false;

// Toggle this for testing Crashlytics in your app locally.
const _kTestingCrashlytics = true;

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {

  double progress = 0;
  Timer timer;
  var token = "";
  bool isUserLoggedIn = false;
  Future<void> _initializeFlutterFireFuture;

  bool isDarkMode = false;
  Color themeColor = AppColor.BLACK_COLOR;

  Future<void> _testAsyncErrorOnInit() async {
    Future<void>.delayed(const Duration(seconds: 2), () {
      final List<int> list = <int>[];
      print(list[100]);
    });
  }

  Future<void> _initializeFlutterFire() async {
    /// Wait for Firebase to initialize
    print("Firebase crashlytics initialize");

    if (_kTestingCrashlytics) {
      // Force enable crashlytics collection enabled if we're testing it.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    } else {
      // Else only enable it in non-debug builds.
      // You could additionally extend this to allow users to opt-in.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
    }

    if (_kShouldTestAsyncErrorOnInit) {
      await _testAsyncErrorOnInit();
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeFlutterFireFuture = _initializeFlutterFire();
    _getUserPreferenceData();
    getPreferenceData();
  }

  void getPreferenceData() async {
    await PreferenceHelper.getPreferenceData(PreferenceHelper.THEME_MODE).then((value){
      setState(() {
        var themeMode = value == null ? "" : value;
        if(themeMode == "auto") {
          var brightness = MediaQuery.of(context).platformBrightness;
          themeMode = Brightness.dark ==  brightness ? "dark" : "light";
        }
        isDarkMode = themeMode == "dark";
        themeColor = isDarkMode ? AppColor.WHITE_COLOR : AppColor.BLACK_COLOR;

        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: isDarkMode ? Colors.black : AppColor.THEME_PRIMARY.withOpacity(0.4),
          statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        ));
      });
    });
  }

  _getUserPreferenceData() async {
    var isLoggedIn = await PreferenceHelper.getToken(mainType: 1);
    var userName = await PreferenceHelper.getPreferenceData(PreferenceHelper.USER_NAME) ?? "";
    token = isLoggedIn ?? "";
    setState(() {
      isUserLoggedIn = token != "" && userName != "";
    });
    startTimeout();
  }

  startTimeout() async {
//    var duration = const Duration(seconds: 5);
//    return Timer(duration, handleTimeout);
    var lang = await PreferenceHelper.getPreferenceData(PreferenceHelper.LANGUAGE);
    if(lang == null) {
      PreferenceHelper.setPreferenceData(PreferenceHelper.LANGUAGE, "en");
    }
    timer = Timer.periodic(Duration(milliseconds: 20), (timer) {
      final updated = ((this.progress + 0.01).clamp(0.0, 1.0) * 100);
      setState(() {
        this.progress = updated.round() / 100;
      });
      // print(progress);
      if(progress == 1.0){

        timer.cancel();
        print("progress stop");
        PreferenceHelper.setPreferenceData("drawerMenu", drawerMenu.home.toString());
        ///
        if(!isUserLoggedIn){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WelcomeIntroPage()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WelcomeNavigationScreen()));
//          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SafetyEquipmentInspectionPage()));
        }
      ///
       /* Navigator.push(
          context,
          SlideRightRoute(
            page: GeneralHeaterGFCISelectionPage()
          )
        );*/
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? AppColor.BLACK_COLOR : AppColor.BG_PRIMARY,
      appBar: EmptyAppBar(isDarkMode: isDarkMode,),
      body: FutureBuilder(
        future: _initializeFlutterFireFuture,
        builder: (context, snapshot) {
          switch(snapshot.connectionState) {
            case ConnectionState.done:
              if(snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }
              return Container(
                  color: isDarkMode ? AppColor.BLACK_COLOR : AppColor.BG_PRIMARY,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(70.0),
                        child: CircleAvatar(
                          radius: 70.0,
                          child: Image(
                            image: AssetImage('assets/ic_inspector_logo.png'),
                            fit: BoxFit.cover,
                            height: 150.0,
                            width: 150.0,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          // FirebaseCrashlytics.instance.crash();
                          // FirebaseCrashlytics.instance
                          //     .log('This is a log example');
                          // ScaffoldMessenger.of(context)
                          //     .showSnackBar(const SnackBar(
                          //   content: Text(
                          //       'The message "This is a log example" has been logged \n'
                          //           'Message will appear in Firebase Console once app has crashed and reopened'),
                          //   duration: Duration(seconds: 5),
                          // ));
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                          alignment: Alignment.center,
                          child: Image(
                            image: AssetImage(
                              isDarkMode
                                ? 'assets/ic_dark_logo_dottie.png'
                                : 'assets/logo_dottie.png',
                            ),
                            fit: BoxFit.cover,
                            height: 50.0,
                            width: 120.0,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: token != '',
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 32.0, vertical: 0.0),
                          alignment: Alignment.center,
                          child: Center(
                            child: GradientText(
                              'Welcome Back',
                              gradient: LinearGradient(
                                  colors: AppColor.gradientColor(1.0)
                              ),
                              style: TextStyle(
                                  color: AppColor.TYPE_PRIMARY,
                                  fontSize: TextSize.pageTitleText,
                                  fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8.0,),
                      Container(
                        width: 150.0,
                        margin: EdgeInsets.only(top: 8.0, bottom: 20),
                        child: LinearPercentIndicator(
                          animationDuration: 200,
                          backgroundColor: Color(0xff1f1f1f),
                          percent: progress,
                          lineHeight: 8.0,
                          linearGradient: LinearGradient(
                              colors: AppColor.gradientColor(1.0)
                          ),
                        ),
                      ),
                    ],
                  ));

            default:
              return const Center(child: Text('Loading'));
          }
        },
      )
    );
  }
}