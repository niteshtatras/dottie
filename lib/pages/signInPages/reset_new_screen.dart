import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dottie_inspector/connection_mixin.dart';
import 'package:dottie_inspector/pages/signInPages/reset_confirm_account.dart';
import 'package:dottie_inspector/pages/signInPages/confirm_account.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/SlideRightRoute.dart';
import 'package:dottie_inspector/utils/custom_toast.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:dottie_inspector/widget/bottom_general_button_widget.dart';
import 'package:dottie_inspector/widget/gradient/grediant_box_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appavailability/flutter_appavailability.dart';
import 'package:progress_hud/progress_hud.dart';

class ResetPasswordNewPage extends StatefulWidget {
  @override
  _ResetPasswordNewPageState createState() => _ResetPasswordNewPageState();
}

class _ResetPasswordNewPageState extends State<ResetPasswordNewPage> with MyConnection{

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _allFieldValidate = false;
  bool _menuVisible = false;
  ScrollController _pageScrollController = new ScrollController();

  TextEditingController emailController = new TextEditingController();
  FocusNode emailFocus = FocusNode();
  bool isEmailFocus = false;

  String checkEmailTitle = "Check your email";
  String checkEmailSubTitle1 = "";
  String checkEmailSubTitle2 = "";

  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;

  bool isDarkMode = false;
  Color themeColor = AppColor.BLACK_COLOR;

  bool _isInternetAvailable = true;

  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
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

    initConnectivity();
  }

  @override
  void initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      log('Couldn\'t check connectivity status', error: e);
      return;
    }

    connectionSubscription();

    if (!mounted) {
      return Future.value(null);
    }

    return updateConnectionStatus(result);
  }

  @override
  void connectionSubscription() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      updateConnectionStatus(result);
    });
  }

  @override
  void updateConnectionStatus(result) {
    setState(() {
      _connectivityResult = result;
      if (_connectivityResult == ConnectivityResult.none) {
        _isInternetAvailable = false;
      } else if ((_connectivityResult == ConnectivityResult.mobile) || (_connectivityResult == ConnectivityResult.wifi)) {
        _isInternetAvailable = true;
      }

      log("IsInternetAvailable====$_isInternetAvailable");
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    // connectivity.disposeStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? AppColor.BLACK_COLOR : AppColor.PAGE_COLOR,
      appBar: EmptyAppBar(isDarkMode: isDarkMode),
      // appBar: AppBar(
      //   centerTitle: true,
      //   elevation: 0.0,
      //   backgroundColor: AppColor.PAGE_COLOR,
      //   /*actions: <Widget>[
      //     Visibility(
      //       visible: _menuVisible,
      //       child: IconButton(
      //         padding: EdgeInsets.all(16.0),
      //         icon: Icon(
      //           Icons.more_horiz,
      //           color: AppColor.TYPE_PRIMARY,
      //         ),
      //         onPressed: (){
      //           bottomSelectNavigation(context);
      //         },
      //       ),
      //     ),
      //   ],*/
      //   leading: IconButton(
      //     onPressed: (){
      //       Navigator.pop(context);
      //     },
      //     icon:  Image.asset(
      //       'assets/ic_back_button.png',
      //       height: 24.0,
      //       width: 24.0,
      //     ),
      //   ),
      //   title: Text(
      //     'Reset Password',
      //     style: TextStyle(
      //       color: AppColor.TYPE_PRIMARY,
      //       fontSize: TextSize.headerText,
      //       fontWeight: FontWeight.w600
      //     ),
      //   ),
      // ),
      body: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
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
                  child: Stack(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(top: 10.0),
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Let’s find your Inspector Dottie account',
                              style: TextStyle(
                                  color: themeColor,
                                  fontSize: TextSize.greetingTitleText,
                                  fontWeight: FontWeight.w700,

                              ),
                            ),
                          ),

                          Container(
                            margin: EdgeInsets.only(top: 16.0),
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              "We’ll send you the info that you need to reset your password",
                              style: TextStyle(
                                  color: themeColor,
                                  fontSize: TextSize.subjectTitle,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2
                              ),
                            ),
                          ),

                          //Email Address
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 0.0),
                            child: Form(
                              key: _formKey,
                              child:  Container(
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.only(top: 32.0, bottom: 0.0, left: 16.0,right: 16.0),
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
                                        if(isEmailValidated(emailController.text.toString())) {
                                          setState(() {
                                            _autoValidate = true;
                                            _allFieldValidate = _formKey.currentState.validate();
                                          });
                                        }
                                      },
                                      validator: validateEmail,
                                      textInputAction: TextInputAction.done,
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
                                            color: AppColor.TYPE_PRIMARY.withOpacity(0.6)
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
                                          if(_autoValidate)
                                            _allFieldValidate = _formKey.currentState.validate();
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),

          Visibility(
            visible: !isEmailFocus,
            child: Positioned(
              bottom: 32.0,
              left: 20.0,
              right: 20.0,
              child: GestureDetector(
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  if (_formKey.currentState.validate() && _allFieldValidate) {
                    //    If all data are correct then save data to out variables
                    if(_isInternetAvailable) {
                      _formKey.currentState.save();
                      forgotPassword();
                    } else {
                      HelperClass.showSnackBar(context, "Please check your internet connection");
                    }
                  }
                  else {
                  //    If all data are not valid then start auto validation.
                    setState(() {
                      _autoValidate = true;
                      emailFocus.requestFocus(FocusNode());
                    });
                  }
                },
                child: Container(
                  height: 64.0,
                  margin: EdgeInsets.only(left: 48.0, right: 48.0, bottom: 34.0, top: 12.0),
                  decoration: BoxDecoration(
                      color: _allFieldValidate
                          ? themeColor
                          : AppColor.DIVIDER,
                      borderRadius: BorderRadius.all(Radius.circular(32.0))
                  ),
                  child: Center(
                    child: Text(
                      'Send Instructions ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: (_allFieldValidate)
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

          /*//Submit Button
          Positioned(
            bottom: 32.0,
            left: 20.0,
            right: 20.0,
            child: GestureDetector(
              onTap: (){
                if(_menuVisible){
//                  //ResetPasswordPage
//                  Navigator.push(
//                      context,
//                      MaterialPageRoute(
//                          builder: (context) => ResetPasswordPage(
//                              type : 'forgot'
//                          )
//                      )
//                  );
                  openEmailApp();
                } else {
                  if (_formKey.currentState.validate() && _allFieldValidate) {
                    //    If all data are correct then save data to out variables
                    _formKey.currentState.save();
                    forgotPassword("send");
                  }
                  else {
                    //    If all data are not valid then start auto validation.
                    setState(() {
                      _autoValidate = true;
                      emailFocus.requestFocus(FocusNode());
                    });
                  }
                }
              },
              child: Container(
                height: 56.0,
                decoration: BoxDecoration(
                    color: _allFieldValidate ? AppColor.THEME_PRIMARY : AppColor.DEACTIVATE,
                    borderRadius: BorderRadius.all(Radius.circular(4.0))
                ),
                child: Center(
                  child: Text(
                    _menuVisible ? 'OPEN MAIL APP' :'SEND INSTRUCTIONS ',
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
*/
          _progressHUD
        ],
      ),
    );
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

  void openEmailApp() {
    try{
      AppAvailability.launchApp(Platform.isIOS ? "message://" : "com.google.android.gm").then((_) {
        print("App Email launched!");
      }).catchError((err) {
        HelperClass.showSnackBar(context, "App Email not found!");
        print("err====$err");
      });
    } catch(e) {
      HelperClass.showSnackBar(context, "Email App not found!");
    }
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

  bottomSelectNavigation(context){
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
        ),
        backgroundColor: Colors.white,
        builder: (context){
          return StatefulBuilder(
            builder: (context1, myState){
              return SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 12.0,),
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                          forgotPassword();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                          child: Text(
                            'Resend Email ',
                            style: TextStyle(
                                fontSize: TextSize.headerText,
                                color: AppColor.TYPE_PRIMARY,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'WorkSans'
                            ),
                          ),
                        ),
                      ),
                      Divider(
                        height: 1.0,
                        color: AppColor.SEC_DIVIDER,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                              fontSize: TextSize.headerText,
                              color: AppColor.TYPE_SECONDARY,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'WorkSans'
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0,),
                    ],
                  ),
                ),
              );
            },
          );
        }
    );
  }

  Future<void> forgotPassword() async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());

    var requestJson = {
      "email": "${emailController.text.toString().trim()}"
    };
    var requestParam = json.encode(requestJson);
    var  response = await request.postUnAuthRequest("unauth/forgotInspectorPwd", requestParam);
    _progressHUD.state.dismiss();

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage("${response['reason']}");
      } else {
        Navigator.push(
          context,
          SlideRightRoute(
            page: ResetConfirmAccountPage(
              email: "${emailController.text.toString().trim()}"
            )
          )
        );
      }
    }
  }
}
