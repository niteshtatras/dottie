import 'dart:convert';
import 'dart:io';

import 'package:dottie_inspector/main/welcome_intro_page.dart';
import 'package:dottie_inspector/deadCode/signIn/reset_password.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/SlideRightRoute.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:dottie_inspector/widget/bottom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appavailability/flutter_appavailability.dart';
import 'package:progress_hud/progress_hud.dart';

import '../../deadCode/signIn/login_page.dart';

class ConfirmAccountPage extends StatefulWidget {
  final formData;

  const ConfirmAccountPage({Key key, this.formData}) : super(key: key);

  @override
  _ConfirmAccountPageState createState() => _ConfirmAccountPageState();
}

class _ConfirmAccountPageState extends State<ConfirmAccountPage> {
  String checkEmailTitle = "Email sent!";
  String checkEmailSubTitle1 = "We sent a message ";
  String checkEmailSubTitle2 = " so you can create a new password.";
  Map formData;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;

  bool isDarkMode = false;
  Color themeColor = AppColor.BLACK_COLOR;

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

    formData = widget.formData ?? {};
  }

  void getThemeData() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? AppColor.BLACK_COLOR : AppColor.PAGE_COLOR,
      appBar: EmptyAppBar(isDarkMode: isDarkMode),
      // appBar: AppBar(
      //   centerTitle: true,
      //   elevation: 0.0,
      //   backgroundColor: AppColor.WHITE_COLOR,
        /*actions: <Widget>[
          IconButton(
            padding: EdgeInsets.all(16.0),
            icon: Icon(
              Icons.more_horiz,
              color: AppColor.TYPE_PRIMARY,
            ),
            onPressed: (){
              bottomSelectNavigation(context);
            },
          ),
        ],*/
        /*leading: IconButton(
          padding: EdgeInsets.only(left: 16.0, right: 16.0),
          icon: Icon(Icons.keyboard_backspace,color: AppColor.TYPE_PRIMARY,size: 32.0,),
          onPressed: (){
            Navigator.pop(context);
          },
        ),*/
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
      //     'Confirm Account',
      //     style: TextStyle(
      //         color: AppColor.TYPE_PRIMARY,
      //         fontSize: TextSize.headerText,
      //         fontWeight: FontWeight.w600
      //     ),
      //   ),
      // ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: InkWell(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 20.0,),
                        Image(
                          image: AssetImage('assets/ic_confirm_account.png'),
                          fit: BoxFit.cover,
                          height: 240.0,
                          width: 280.0,
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 16.0),
                          child: Text(
                            'Almost done!',
                            style: TextStyle(
                                color: themeColor,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.normal,
                                height: 1.3
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.symmetric(vertical: 16.0,horizontal: 48.0),
                          child: Text.rich(
                            TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'To continue creating your account, look for a confirmation email sent to ',
                                    style: TextStyle(
                                        color: themeColor,
                                        fontSize: TextSize.subjectTitle,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FontStyle.normal,
                                        height: 1.3
                                    ),
                                  ),
                                  TextSpan(
                                    text: '${formData['email']}',
                                    style: TextStyle(
                                        color: themeColor,
                                        fontSize: TextSize.subjectTitle,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FontStyle.normal,
                                        height: 1.3
                                    ),
                                  ),
                                ]
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          Color(0xffF8F6F4).withOpacity(0.0),
                          Color(0xffF8F6F4).withOpacity(0.20),
                        ]
                    )
                ),
                child: Container(
                  height: 64.0,
                  margin: EdgeInsets.only(left: 48.0, right: 48.0, bottom: 34.0, top: 12.0),
                  decoration: BoxDecoration(
                      color: themeColor,
                      borderRadius: BorderRadius.all(Radius.circular(32.0))
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            if(await HelperClass.internetConnectivity()) {
                             registerEmailAddress();
                            } else {
                             HelperClass.openSnackBar(context);
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.only(left: 24.0),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Resend',
                              style: TextStyle(
                                color: isDarkMode
                                    ?  AppColor.BLACK_COLOR
                                    : AppColor.WHITE_COLOR,
                                fontSize: TextSize.subjectTitle,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            if(await HelperClass.internetConnectivity()) {
                              openEmailApp();
                            } else {
                              HelperClass.openSnackBar(context);
                            }
                          },
                          child: Container(
                            alignment: Alignment.centerRight,
                            margin: EdgeInsets.only(right: 24.0),
                            child: Text(
                              'Open Mail App',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDarkMode
                                    ?  AppColor.BLACK_COLOR
                                    : AppColor.WHITE_COLOR,
                                fontSize: TextSize.subjectTitle,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            _progressHUD
          ],
        ),
      ),
    );
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
                      InkWell(
                        onTap: (){
                          Navigator.pop(context);
                          registerEmailAddress();
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

  Future<void> registerEmailAddress() async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());

    var requestJson = {
      "firstname": formData['first_name'],
      "lastname": formData['last_name'],
      "email": formData['email'],
      "avatar": formData['avatar'],
      "password": formData['password']
    };
    var requestParam = json.encode(requestJson);
    var response;
    if(formData['avatar'] == "") {
      response = await request.postUnAuthRequest("unauth/inspectorSetup", requestParam);
    } else {
      response = await request.registerNewUserWithImage("unauth/inspectorSetup", requestJson);
    }

    _progressHUD.state.dismiss();

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        HelperClass.showSnackBar(context, "${response['reason']}");
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ConfirmAccountPage(
                  formData: formData,
                )
            )
        );
      }
    }
  }
}
