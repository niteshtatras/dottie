import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dottie_inspector/deadCode/signIn/create_password_screen_page_1.dart';
import 'package:dottie_inspector/pages/signInPages/login_page_1.dart';
import 'package:dottie_inspector/pages/signInPages/register_user_1.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/SlideRightRoute.dart';
import 'package:dottie_inspector/utils/custom_toast.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:dottie_inspector/widget/GradientText.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Toggle this to cause an async error to be thrown during initialization
// and to test that runZonedGuarded() catches the error
const _kShouldTestAsyncErrorOnInit = false;

// Toggle this for testing Crashlytics in your app locally.
const _kTestingCrashlytics = true;

class WelcomeIntroPage extends StatefulWidget {
  static String tag = "welcome-intro-page";

  @override
  _WelcomeIntroPageState createState() => _WelcomeIntroPageState();
}

class _WelcomeIntroPageState extends State<WelcomeIntroPage> {
  CarouselController controller = CarouselController();

  String title = "Hello, Inspector";
  String subTitle = "Grow your business and bottom line with pool inspections";
  int _current = 0;
  List<Widget> indicatorList = List();

  // FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  AllHttpRequest request = new AllHttpRequest();

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
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
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
    getPreferenceData();
    fetchLinkData();
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

  void fetchLinkData() async {
    // FirebaseDynamicLinks.getInitialLInk does a call to firebase to get us the real link because we have shortened it.
    // var link = await FirebaseDynamicLinks.instance.getInitialLink();
    //
    // // This link may exist if the app was opened fresh so we'll want to handle it the same way onLink will.
    // handleLinkData(link);
    // print("Link=====$link");
    //
    // // This will handle incoming links if the application is already opened
    //
    // dynamicLinks.onLink.listen((dynamicLinkData) {
    //   handleLinkData(dynamicLinkData);
    // }).onError((error) {
    //   print('onLink error');
    //   print(error.message);
    // });
  }

  void handleLinkData(data) {
    // final Uri deepLink = data?.link;
    print("DynamicLink=====$data");
    final Uri deepLink = data?.link;
    print("DynamicLinkData=====$deepLink");
    if(deepLink != null) {
      final queryParams = deepLink.queryParameters;
      print("queryParams===$queryParams");
      if(queryParams.length > 0) {
        if(queryParams["verifyString"] != null) {
          String verify = queryParams["verifyString"];
          verifyEmailAddress(verify);
        } else if(queryParams["verifyReset"] != null) {
          String verifyReset = queryParams["verifyReset"];
          verifyResetPassword(verifyReset);
        }
      }
    }

    // if(deepLink != null) {
    //   if(deepLink.path == "/resetpassword"){
    //     Navigator.push(context, SlideRightRoute(page: CreatePasswordScreenPage1()));
    //   } else {
    //     print("No link path available");
    //   }
    // }
  }

  List<Widget> getImageSliderList(){
    List<Widget> imageSliders = List();
    for(int i=0; i<4; i++){
      imageSliders.add(Container(
        key: Key("$i"),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(top: 0.0),
              alignment: Alignment.center,
              child: Image.asset(
                i==0
                  ? 'assets/intro1/ic_intro1.png'
                  : i == 1
                  ? 'assets/intro1/intro_2.png'
                  : i == 2
                  ? 'assets/intro1/intro_3.png'
                  : 'assets/intro1/intro_4.png',
                height: 320.0,
                width: _current == 0
                    ? 220.0
                    : _current == 1
                    ? 300.0
                    : _current == 2
                    ? 220
                    : 300,
                fit: BoxFit.fill,
              ),
            )
           /* i == 0 || i == 2
            ? Container(
              margin: EdgeInsets.only(top: 16.0),
              alignment: Alignment.center,
              child: Image.asset(
                i==0 ? 'assets/intro/ic_splash1.png' : 'assets/intro/ic_splash4.png',
                height: 340.0,
                width: 200.0,
              ),
            )
            : Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    i==1 ? 'assets/intro/ic_splash2.png' : 'assets/intro/ic_splash3.png',
                    height: 170.0,
                    width: 320.0,
                  ),
                  SizedBox(height: 0.0,),
                  Image.asset(
                    i==1 ? 'assets/intro/ic_splash5.png' : 'assets/intro/ic_splash6.png',
                    height: 170.0,
                    width: 320.0,
                  ),
                ],
              ),
            ),*/
          ],
        ),
      ));
    }
    return imageSliders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? AppColor.BLACK_COLOR : AppColor.PAGE_COLOR,
      appBar: EmptyAppBar(isDarkMode: isDarkMode),
      body: Container(
        child: Stack(
          children: [
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 32.0, left: 32.0, right: 32.0),
                        child: _current == 0
                            ? GradientText(
                          '$title',
                          style: TextStyle(
                            fontSize: 40.0,
                            fontWeight: FontWeight.w700,
                          ),
                          gradient: LinearGradient(
                              colors: AppColor.gradientColor(1.0)
                          ),
                        )
                        : Text(
                            '$title',
                            style: TextStyle(
                                color: themeColor,
                                fontSize: 40.0,
                                fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                          ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16.0, left: 32.0, right: 32.0),
                    height: 64,
                    child: Text(
                      '$subTitle',
                      style: TextStyle(
                          color: themeColor,
                          fontSize: TextSize.headerText,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                          height: 1.5,
                      ),
                      maxLines: 2,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16.0),
                    child: CarouselSlider(
                      options: CarouselOptions(
                        aspectRatio: 6.0,
                        enlargeCenterPage: false,
                        scrollDirection: Axis.horizontal,
                        autoPlay: false,
                        disableCenter: false,
                        height: 340,
                        viewportFraction: _current == 0
                            ? 0.60
                            : _current == 1
                            ? 0.75
                            : _current == 2
                            ? 0.60
                            : 0.75,
                        enableInfiniteScroll: false,
                        onPageChanged: (index, res){
                          setState(() {
                            _current = index;

                            if(index==0){
                              title = "Hello, Inspector";
                              subTitle = "Grow your business and bottom line with pool inspections";
                            } else if(index==1){
                              title = "Showcase\nyour expertise";
                              subTitle = "Optionally include a maintenance proposal with your inspections";
                            } else if(index==2){
                              title = "Generate\nLeads";
                              subTitle = "A comprehensive report that you can email directly to your client";
                            } else {
                              title = "Find\nOpportunities";
                              subTitle = "No better way than inspecting equipment";
                            }
                          });
                        }
                      ),
                      items: getImageSliderList(),
                      carouselController: controller,
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: getImageSliderList().map((url) {
                      return Container(
                        width: 12.0,
                        height: 12.0,
                        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: ValueKey("$_current") == url.key
                          ? LinearGradient(colors: AppColor.gradientColor(1.0))
                          : LinearGradient(
                              colors: [
                                Color(0xffE5E5E5),
                                Color(0xffE5E5E5)
                              ]
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

         /*   // Get Started
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                child: InkWell(
                  onTap: (){
                    Navigator.push(
                        context,
                        SlideRightRoute(
                            page: RegisterUser1Page()
                        )
                    );
                  },
                  child: Container(
                    height: 64.0,
                    margin: EdgeInsets.only(left: 48.0, right: 48.0, bottom: 64.0, top: 12.0),
                    decoration: BoxDecoration(
                        color: AppColor.TYPE_PRIMARY,
                        borderRadius: BorderRadius.all(Radius.circular(32.0))
                    ),
                    child: Center(
                      child: Text(
                        'GET STARTED',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColor.WHITE_COLOR,
                          fontSize: TextSize.subjectTitle,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),*/

            // Already account
            Positioned(
                bottom: 0.0,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    InkWell(
                      onTap: (){
                        Navigator.push(
                            context,
                            SlideRightRoute(
                                page: LoginPage1()
                            )
                        );
                        // throw "This is a crash!";

                        // FirebaseCrashlytics.instance.crash();
                        // var result = [];
                        // log("Result==${result[10]}");
                      },
                      child: Container(
                        height: 64.0,
                        margin: EdgeInsets.only(left: 32.0, right: 32.0, bottom: 8.0, top: 12.0),
                        decoration: BoxDecoration(
                            color: themeColor,
                            borderRadius: BorderRadius.all(Radius.circular(32.0))
                        ),
                        child: Center(
                          child: Text(
                            'Sign In',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDarkMode ? AppColor.BLACK_COLOR : AppColor.WHITE_COLOR,
                              fontSize: TextSize.subjectTitle,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: (){
                        Navigator.push(
                            context,
                            SlideRightRoute(
                                page: RegisterUser1Page()
                            )
                        );
                      },
                      child: Container(
                        height: 64.0,
                        margin: EdgeInsets.only(left: 32.0, right: 32.0, bottom: 25.0, top: 0.0),
                        decoration: BoxDecoration(
                            color: isDarkMode ? Color(0xff1f1f1f) : Color(0xffE5E5E5),
                            borderRadius: BorderRadius.all(Radius.circular(32.0)),
                            border: Border.all(
                                color: AppColor.TRANSPARENT,
                                width: 3.0
                            )
                        ),
                        child: Center(
                          child: Text(
                            'Create Account',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: themeColor,
                              fontSize: TextSize.subjectTitle,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
            )

          ],
        ),
      ),
    );
  }

  ///////////////////////////API INTEGRATION////////////////////////
  Future<void> verifyEmailAddress(verifyString) async {
    FocusScope.of(context).requestFocus(FocusNode());
    var str1 = Uri.encodeQueryComponent(verifyString);
    print("Original String    $verifyString");
    print("Encoded String     $str1");
    var str = str1.replaceAll("/","%252f").replaceAll("+", "%252b");
    print("Final String $str");

    var  response = await request.getUnAuthRequest("unauth/verify/$str");

    if (response != null) {
      print(response);
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage('${response['reason']}');
//        _scaffoldKey.currentState.showSnackBar(HelperClass.showSnackBar(context, '${response['reason']}'));
      } else {
        PreferenceHelper.setToken("${response['token']}");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt(PreferenceHelper.LAST_REFRESH, DateTime.now().millisecondsSinceEpoch);

        /*Navigator.push(
            context,
            SlideRightRoute(
                page: SignUpOnBoardingQuestionPage()
            )
        );*/
        Navigator.push(
            context,
            SlideRightRoute(
                page: CreatePasswordScreenPage1(
                  type: "register",
                )
            )
        );
      }
    }
  }

  Future<void> verifyResetPassword(verifyString) async {
    FocusScope.of(context).requestFocus(FocusNode());
    var str1 = Uri.encodeQueryComponent(verifyString);
    print("Original String    $verifyString");
    print("Encoded String     $str1");
    var str = str1.replaceAll("/","%252f").replaceAll("+", "%252b");
    print("Final String $str");

    var  response = await request.getUnAuthRequest("unauth/resetverify/$str");

    if (response != null) {
      print(response);
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage('${response['reason']}');
//        _scaffoldKey.currentState.showSnackBar(HelperClass.showSnackBar(context, '${response['reason']}'));
      } else {
        PreferenceHelper.setToken("${response['token']}");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt(PreferenceHelper.LAST_REFRESH, DateTime.now().millisecondsSinceEpoch);

        /*Navigator.push(
            context,
            SlideRightRoute(
                page: SignUpOnBoardingQuestionPage()
            )
        );*/
        Navigator.push(
            context,
            SlideRightRoute(
                page: CreatePasswordScreenPage1(
                  type: "register",
                )
            )
        );
      }
    }
  }
}
