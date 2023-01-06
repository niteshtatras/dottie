//import 'package:dottie_inspector/pages/inspectionMain/welcome_screen.dart';
import 'dart:developer';
import 'dart:io';

import 'package:dottie_inspector/main/welcome_intro_page.dart';
import 'package:dottie_inspector/deadCode/signIn/create_password_screen_page_1.dart';
import 'package:dottie_inspector/pages/signInPages/register_user_1.dart';
import 'package:dottie_inspector/pages/signInPages/reset_new_screen.dart';
import 'package:dottie_inspector/pages/welcome/welcome_navigation_screen.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/SlideRightRoute.dart';
import 'package:dottie_inspector/utils/custom_toast.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:dottie_inspector/widget/GradientText.dart';
import 'package:dottie_inspector/widget/gradient/grediant_box_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage1 extends StatefulWidget {
  static String tag = 'login1-page';

  @override
  _LoginPage1State createState() => _LoginPage1State();
}

class _LoginPage1State extends State<LoginPage1> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _autoValidate = false;
  bool _isFormValidated = false;
  ScrollController _pageScrollController = new ScrollController();

  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  bool isEmailFocus = false;
  bool isPasswordFocus = false;
  bool isFocusOn = true;

  bool _obscureText = true;
  bool _obscureTextVisible = false;

  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;

  bool isDarkMode = false;
  Color themeColor = AppColor.BLACK_COLOR;

  // FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  String _linkMessage;
  bool _isCreatingLink = false;
  final String _testString =
      'To test: long press link and then copy and click from a non-browser '
      "app. Make sure this isn't being tested on iOS simulator and iOS xcode "
      'is properly setup. Look at firebase_dynamic_links/README.md for more '
      'details.';

  final String DynamicLink = 'https://test-app/helloworld';
  final String Link = 'https://reactnativefirebase.page.link/bFkn';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_loadLink);
    _progressHUD = ProgressHUD(
      backgroundColor: Colors.transparent,
      color: Colors.white,
      containerColor: AppColor.LOADER_COLOR,
      borderRadius: 5.0,
      loading: _loading,
      text: 'Loading...',
    );

    emailFocus.addListener(() {
      setState(() {
        isEmailFocus = emailFocus.hasFocus;
        isFocusOn = !emailFocus.hasFocus;
      });
    });
    passwordFocus.addListener(() {
      setState(() {
        isPasswordFocus = passwordFocus.hasFocus;
        isFocusOn = !passwordFocus.hasFocus;
      });
    });

    getPreferenceData();
  }

  void getPreferenceData() async {
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
          statusBarColor: isDarkMode ? Colors.black : AppColor.THEME_PRIMARY.withOpacity(0.4),
          statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        ));
      });
    });
  }

  void _loadLink(_){
    // fetchLinkData();
  }

  void fetchLinkData() async {
    // FirebaseDynamicLinks.getInitialLInk does a call to firebase to get us the real link because we have shortened it.
    // var link = await FirebaseDynamicLinks.instance.getInitialLink();
// //    CustomToast.showToastMessage("Normal Intent == $link");
//
//     // This link may exist if the app was opened fresh so we'll want to handle it the same way onLink will.
//     handleLinkData(link);
//     print("Link=====$link");

    // This will handle incoming links if the application is already opened
    // FirebaseDynamicLinks.instance.onLink(onSuccess: (PendingDynamicLinkData dynamicLink) async {
    //   print("DynamicLink=====$dynamicLink");
    //   handleLinkData(dynamicLink);
    // });
///
//     dynamicLinks.onLink.listen((dynamicLinkData) {
//       print("Dynamic Links");
//       handleLinkData(dynamicLinkData);
//     }).onError((error) {
//        print('onLink error');
//        print(error.message);
//     });
  }

//   void handleLinkData(PendingDynamicLinkData data) {
//     final Uri deepLink = data?.link;
//     if(deepLink != null) {
//       final queryParams = deepLink.queryParameters;
//       if(queryParams.length > 0) {
//         String verify = queryParams["verifyString"];
//         // verify the username is parsed correctly
//         print("Verify String is:{$verify}");
// //        CustomToast.showToastMessage("Verify String is:{$verify}");
//         verifyEmailAddress(verify);
//       }
//     }
//
//     if(deepLink != null) {
//      // CustomToast.showToastMessage("path is:{${deepLink.path}}");
//
//      if(deepLink.path == "/resetpassword"){
//         Navigator.push(context, SlideRightRoute(page: ResetPasswordNewPage()));
//      } else {
//        print("No link path available");
//      }
//     }
//   }

  // Future<Uri> createDynamicLink({@required String userName}) async {
  //   final DynamicLinkParameters parameters = DynamicLinkParameters(
  //     // This should match firebase but without the username query param
  //     uriPrefix: 'https://inspectordottie.page.link',
  //     // This can be whatever you want for the uri, https://yourapp.com/groupinvite?username=$userName
  //     link: Uri.parse('https://inspectordottie.page.link/restpassword?username='),
  //     androidParameters: AndroidParameters(
  //       packageName: 'com.dottie_inspector',
  //       minimumVersion: 1,
  //     ),
  //     iosParameters: IOSParameters(
  //       bundleId: 'com.dottie_inspector',
  //       minimumVersion: '1',
  //       appStoreId: '',
  //     ),
  //   );
  //   // final link = await parameters.;
  //   // final ShortDynamicLink shortenedLink = await DynamicLinkParameters().bui(
  //   //   link,
  //   //   DynamicLinkParametersOptions(shortDynamicLinkPathLength: ShortDynamicLinkPathLength.unguessable),
  //   // );
  //   // print("${shortenedLink.shortUrl}");
  //   // return shortenedLink.shortUrl;
  //   return null;
  // }
  //
  // Future<void> _createDynamicLink(bool short) async {
  //   setState(() {
  //     _isCreatingLink = true;
  //   });
  //
  //   final DynamicLinkParameters parameters = DynamicLinkParameters(
  //     uriPrefix: 'https://reactnativefirebase.page.link',
  //     link: Uri.parse(DynamicLink),
  //     androidParameters: const AndroidParameters(
  //       packageName: 'io.flutter.plugins.firebase.dynamiclinksexample',
  //       minimumVersion: 0,
  //     ),
  //     iosParameters: const IOSParameters(
  //       bundleId: 'io.invertase.testing',
  //       minimumVersion: '0',
  //     ),
  //   );
  //
  //   Uri url;
  //   // if (short) {
  //   //   final ShortDynamicLink shortLink = await dynamicLinks.buildShortLink(parameters);
  //   //   url = shortLink.shortUrl;
  //   // } else {
  //   //   url = await dynamicLinks.buildLink(parameters);
  //   // }
  //
  //   setState(() {
  //     _linkMessage = url.toString();
  //     _isCreatingLink = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode ? AppColor.BLACK_COLOR : AppColor.PAGE_COLOR,
      appBar: EmptyAppBar(isDarkMode: isDarkMode),
      // appBar: AppBar(
      //   centerTitle: true,
      //   elevation: 0.0,
      //   backgroundColor: AppColor.PAGE_COLOR,
       /* leading: IconButton(
          padding: EdgeInsets.only(left: 16.0, right: 16.0),
          icon: Icon(Icons.arrow_back_ios,color: AppColor.TYPE_PRIMARY,size: 32.0,),
          onPressed: (){
            Navigator.pop(context);
          },
        ),*/
        // leading: IconButton(
        //   onPressed: (){
        //     Navigator.pop(context);
        //   },
        //   icon:  Image.asset(
        //     'assets/ic_close_button.png',
        //     height: 44.0,
        //     width: 44.0,
        //   ),
        // ),
        /*title: Container(
          child: Image.asset(
            'assets/welcome/welcome_title.png',
            height: 25.0,
            width: 100.0,
          ),
        ),*/
      // ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: GestureDetector(
                  onTap: () async {
                    var result = await Navigator.of(context).maybePop();
                    print("BackResult====$result");
                    if(!result) {
                      Navigator.pushReplacement(
                        context,
                        SlideRightRoute(
                          page: WelcomeIntroPage()
                        )
                      );
                    }
                  },
                  child: Container(
                    child: Image.asset(
                      isDarkMode
                      ? 'assets/ic_dark_back_button.png'
                      : 'assets/ic_close_button.png',
                      fit: BoxFit.cover,
                      width: 48,
                      height: 48,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _pageScrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () async {
                          // final PendingDynamicLinkData data = await dynamicLinks.getInitialLink();
                          // final Uri deepLink = data?.link;
                          //
                          // if (deepLink != null) {
                          //   Navigator.pushNamed(context, deepLink.path);
                          // }
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: 10.0),
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Hi, kindly sign in',
                            style: TextStyle(
                                color: themeColor,
                                fontSize: TextSize.greetingTitleText,
                                fontWeight: FontWeight.w700,
                              height: 1.4
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      // ElevatedButton(
                      //   onPressed: !_isCreatingLink
                      //       ? () => _createDynamicLink(false)
                      //       : null,
                      //   child: const Text('Get Long Link'),
                      // ),
                      // ElevatedButton(
                      //   onPressed: !_isCreatingLink
                      //       ? () => _createDynamicLink(true)
                      //       : null,
                      //   child: const Text('Get Short Link'),
                      // ),

                      Container(
                        margin: EdgeInsets.only(top: 32.0, left:16, right:16),
                        child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.disabled,
                          child: formUI(),
                        ),
                      ),


//                    Forgot Password
                      InkWell(
                        onTap: (){
                          Navigator.push(
                              context,
                              SlideRightRoute(
                                  page: ResetPasswordNewPage()
                              )
                          );
//                    createDynamicLink(userName: "Nitesh");
                        },
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Container(
                          alignment: Alignment.topRight,
                          padding: EdgeInsets.only(right: 24.0,top: 0.0, bottom: 32.0),
                          child: GradientText(
                            'Forgot Password',
                            style: TextStyle(
                              fontSize: TextSize.subjectTitle,
                              fontWeight: FontWeight.w700
                            ),
                            gradient: LinearGradient(
                                colors: AppColor.gradientColor(1.0)
                            ),
                          ),
                          // child: Text(
                          //   'Forgot Password',
                          //   style: TextStyle(
                          //       color: AppColor.THEME_PRIMARY,
                          //       fontSize: TextSize.subjectTitle,
                          //       fontWeight: FontWeight.w500
                          //   ),
                          //   textAlign: TextAlign.right,
                          // ),
                        ),
                      ),

                      SizedBox(height: 50.0,),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Visibility(
              visible: isFocusOn,
              child: Container(
                child: GestureDetector(
                  onTap: () async {
                      if (_formKey.currentState.validate()) {
                        //    If all data are correct then save data to out variables
                        _formKey.currentState.save();
                        login();
                        // if(await HelperClass.internetConnectivity()) {
                        //   login();
                        // } else {
                        //   HelperClass.openSnackBar(context);
                        // }
                      }
                      else {
                        //    If all data are not valid then start auto validation.
                        setState(() {
                          _autoValidate = true;
                        });
                      }

                    // Navigator.pushAndRemoveUntil(
                    //   context,
                    //   SlideRightRoute(
                    //     page: WelcomeNewScreenPage(),
                    //   ),
                    //   ModalRoute.withName(WelcomeNewScreenPage.tag),
                    // );
                  },
                  child: Container(
                    height: 64.0,
                    margin: EdgeInsets.only(left: 48.0, right: 48.0, bottom: 64.0, top: 12.0),
                    decoration: BoxDecoration(
                        color: _isFormValidated
                          ? themeColor
                          : AppColor.DIVIDER,
                        borderRadius: BorderRadius.all(Radius.circular(32.0))
                    ),
                    child: Center(
                      child: Text(
                        'Sign In',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: (_isFormValidated)
                              ? isDarkMode
                              ?  AppColor.BLACK_COLOR
                              : AppColor.WHITE_COLOR
                              : Color(0xff808080),
                          fontSize: TextSize.subjectTitle,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 24.0,
            left: 0,
            right: 0,
            child:  Visibility(
              visible: isFocusOn,
              child: GestureDetector(
                onTap: (){
                  Navigator.pushReplacement(
                      context,
                      SlideRightRoute(
                          page: RegisterUser1Page()
                      )
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  alignment: Alignment.center,
                  child: Text(
                    "Don't have a Dottie account?",
                    style: TextStyle(
                        color: themeColor,
                        fontSize: TextSize.subjectTitle,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),

          _progressHUD
        ],
      ),
    );
  }

  Widget formUI(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[

        //Email Address
        Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(top: 0.0, bottom: 0.0),
          padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isEmailFocus && isDarkMode
                    ? AppColor.gradientColor(0.32)
                    : isEmailFocus
                    ? AppColor.gradientColor(0.16)
                    : isDarkMode
                    ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                    : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
              ),
              borderRadius: BorderRadius.circular(32.0),
            border: GradientBoxBorder(
              gradient: LinearGradient(
                colors: isEmailFocus
                ? AppColor.gradientColor(1.0)
                : [AppColor.TRANSPARENT, AppColor.TRANSPARENT],
              ),
              width: 3
            )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Email',
                style: TextStyle(
                    fontSize: TextSize.subjectTitle,
                    color: themeColor,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.normal,
                ),
                textAlign: TextAlign.center,
              ),
              TextFormField(
                controller: emailController,
                focusNode: emailFocus,
                onFieldSubmitted: (term) {
                  emailFocus.unfocus();
                  FocusScope.of(context).requestFocus(passwordFocus);
                  if(isEmailValidated(emailController.text.toString())
                    && isPasswordValidated(passwordController.text.toString())) {
                    setState(() {
                      _isFormValidated = _formKey.currentState.validate();
                    });
                  }
                },
                validator: validateEmail,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                    fillColor: AppColor.WHITE_COLOR,
                    hintText: "example@mail.com",
                    filled: false,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(top: 0,),
                    hintStyle: TextStyle(
                        fontSize: TextSize.headerText,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode
                            ? Color(0xff545454)
                            : Color(0xff808080)
                    ),
                ),
                style: TextStyle(
                    color: themeColor,
                    fontWeight: FontWeight.w700,
                    fontSize: TextSize.headerText
                ),
                inputFormatters: [LengthLimitingTextInputFormatter(40)],
                onChanged: (value){
                  setState(() {
                    if(_autoValidate) {
                      _isFormValidated = _formKey.currentState.validate();
                    }
                  });
                },
              ),
            ],
          ),
        ),

        //Password
        Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
          padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPasswordFocus && isDarkMode
                    ? AppColor.gradientColor(0.32)
                    : isPasswordFocus
                    ? AppColor.gradientColor(0.16)
                    : isDarkMode
                    ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                    : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
              ),
              borderRadius: BorderRadius.circular(32.0),
              border: GradientBoxBorder(
                  gradient: LinearGradient(
                    colors: isPasswordFocus
                        ? AppColor.gradientColor(1.0)
                        : [AppColor.TRANSPARENT, AppColor.TRANSPARENT],
                  ),
                  width: 3
              )

          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Password',
                style: TextStyle(
                    fontSize: TextSize.subjectTitle,
                    color: themeColor,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.normal,),
                textAlign: TextAlign.center,
              ),
              TextFormField(
                controller: passwordController,
                focusNode: passwordFocus,
                validator: validatePassword,
                textInputAction: TextInputAction.done,
                textAlign: TextAlign.start,
                onFieldSubmitted: (term) {
                  passwordFocus.unfocus();
                  if(isEmailValidated(emailController.text.toString())
                      && isPasswordValidated(passwordController.text.toString())) {
                    setState(() {
                      _isFormValidated = _formKey.currentState.validate();
                    });
                  }
                },
                obscuringCharacter: "\u2B24",
                decoration: InputDecoration(
                  fillColor: AppColor.TRANSPARENT,
                  hintText: "Password",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 12.0),
                  hintStyle: TextStyle(
                      fontSize: TextSize.headerText,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.0,
                      color: isDarkMode
                        ? Color(0xff545454)
                        : Color(0xff808080)
                  ),
                  suffixIcon: Visibility(
                    visible: _obscureTextVisible,
                    child: GestureDetector(
                      onTap: (){
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      child: Text(
                        _obscureText ? 'SHOW' : "HIDE",
                        style: TextStyle(
                          fontSize: TextSize.headerText,
                          color: themeColor,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal
                        ),
                      ),
                    )
                  ),
                ),
                obscureText: _obscureText,
                onChanged: (value){
                  setState(() {
                    _obscureTextVisible = value.isNotEmpty;
                    if(_autoValidate) {
                      _isFormValidated = _formKey.currentState.validate();
                    }
                  });
                },
                style: TextStyle(
                    color: themeColor,
                    fontWeight: FontWeight.w700,
                    fontSize: TextSize.headerText,
                    letterSpacing: _obscureText ? 2.0 : 0.0
                ),
                inputFormatters: [LengthLimitingTextInputFormatter(40)],
              ),
            ],
          ),
        ),
        SizedBox(height: 16.0,),
      ],
    );
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if(value != '') {
      if (!regex.hasMatch(value))
        return 'Enter your valid email address';
      else
        return null;
    } else {
      return 'Enter your email address';
    }
  }

  bool isEmailValidated(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if(value != '') {
      if (!regex.hasMatch(value))
        return false;
      else
        return true;
    } else {
      return false;
    }
  }

  bool isPasswordValidated(String value) {
    if(value!='' && value!=null) {
      if(!value.startsWith(' '))
        return true;
      else
        return false;
    }
    else {
      return false;
    }
  }

  String validatePassword(String value) {
    if(value!='' && value!=null) {
      if(!value.startsWith(' '))
        return null;
      else
        return 'Enter your valid password';
    }
    else {
      return 'Enter your password';
    }

  }

  _launchURL(String toMailId, String subject, String body) async {
    var url = 'mailto:$toMailId?subject=$subject&body=$body';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  ///////////////////////////API INTEGRATION////////////////////////
  Future<void> verifyEmailAddress(verifyString) async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var str1 = Uri.encodeQueryComponent(verifyString);
    print("Original String    $verifyString");
    print("Encoded String     $str1");
    var str = str1.replaceAll("/","%252f").replaceAll("+", "%252b");
    print("Final String $str");

    var  response = await request.getUnAuthRequest("unauth/verify/$str");
    _progressHUD.state.dismiss();

    if (response != null) {
      print(response);
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage('${response['reason']}');
//        _scaffoldKey.currentState.showSnackBar(HelperClass.showSnackBar(context, '${response['reason']}'));
      } else {
        PreferenceHelper.setToken("${response['token']}");
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

  Future<void> login() async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var requestParam = {
      "email":"${emailController.text.toString().trim()}",
      "password":"${passwordController.text.toString().trim()}"
    };
    var response = await request.login("unauth/login", requestParam);
    _progressHUD.state.dismiss();
    print("Login response get back: $response");

    if (response != null) {
      if (response['success']) {
        var userData = {
          "token": "${response['token']}",
          "refresh_token": "${response['refresh_token']}",
          "user_name": "${emailController.text}"
        };
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt(PreferenceHelper.LAST_REFRESH, DateTime.now().millisecondsSinceEpoch);

        PreferenceHelper.saveUserPreferenceData(userData);
        PreferenceHelper.setPreferenceData("drawerMenu", drawerMenu.home.toString());

        if(response['roles'] != null) {
          if(response['roles'].runtimeType == List) {
            PreferenceHelper.setRoleData(response['roles'].contains("ROLE_Owner"));
          }
        }
        Navigator.pushAndRemoveUntil(
          context,
          SlideRightRoute(
//            builder: (context) => SafetyEquipmentInspectionPage(),
            page: WelcomeNavigationScreen(),
          ),
          ModalRoute.withName(WelcomeNavigationScreen.tag),
        );
      } else {
        HelperClass.showSnackBar(context, '${response['reason']}');
      }
    } else {
      HelperClass.displayDialog(context, "${response['reason']}");
    }
  }
}
