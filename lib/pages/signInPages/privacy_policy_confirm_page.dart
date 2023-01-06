import 'dart:convert';

import 'package:dottie_inspector/main/welcome_intro_page.dart';
import 'package:dottie_inspector/pages/signInPages/login_page_1.dart';
import 'package:dottie_inspector/pages/signInPages/confirm_account.dart';
import 'package:dottie_inspector/deadCode/signIn/login_page.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/SlideRightRoute.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:dottie_inspector/widget/GradientText.dart';
import 'package:dottie_inspector/widget/custome_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyConfirmPage extends StatefulWidget {
  final formData;

  const PrivacyPolicyConfirmPage({Key key, this.formData}) : super(key: key);
  @override
  _PrivacyPolicyConfirmPageState createState() => _PrivacyPolicyConfirmPageState();
}

class _PrivacyPolicyConfirmPageState extends State<PrivacyPolicyConfirmPage> {
  bool _allFieldValidate = false;
  bool privacyPolicy = false;
  bool termCondition = false;
  Map formData;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;

  bool isDarkMode = false;
  Color themeColor = AppColor.BLACK_COLOR;

  @override
  void initState() {
    // TODO: implement initState
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode ? AppColor.BLACK_COLOR : AppColor.PAGE_COLOR,
      appBar: EmptyAppBar(isDarkMode: isDarkMode),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: InkWell(
                    onTap: () async  {
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 10.0, left: 24.0, right: 24.0),
                          child: Text(
                            'Privacy policy & Terms and Conditions',
                            style: TextStyle(
                              color: themeColor,
                              fontSize: TextSize.greetingTitleText,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 8.0, left: 24.0, right: 24.0),
                          child: Text(
                            'We care about your privacy.',
                            style: TextStyle(
                              color: themeColor,
                              fontSize: TextSize.subjectTitle,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),

                        SizedBox(height: 56,),

                        //Privacy Policy
                        GestureDetector(
                          onTap: (){
                            setState(() {
                              privacyPolicy = !privacyPolicy;
                              _allFieldValidate = privacyPolicy && termCondition;
                            });
                          },
                          child: Center(
                            child: Container(
                              margin: EdgeInsets.only(left: 8.0),
                              height: 48.0,
                              width: 48.0,
                              child: Image.asset(
                                privacyPolicy
                                    ? 'assets/complete_inspection/ic_check_icon.png'
                                    : 'assets/complete_inspection/ic_unchecked_icon.png',
                                height: 150,
                                width: 150,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'I have read and agree with the',
                                style: TextStyle(
                                    color: themeColor,
                                    fontSize: TextSize.subjectTitle,
                                    fontWeight: FontWeight.w700,
                                    fontStyle: FontStyle.normal,
                                    height: 1.3
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 5.0,),
                              GestureDetector(
                                onTap: (){
                                  _launchURL("https://dev.inspectordottie.com/Privacy-Policy");
                                },
                                child: GradientText(
                                  'Privacy Policy',
                                  style: TextStyle(
                                      color: themeColor,
                                      fontSize: TextSize.subjectTitle,
                                      fontWeight: FontWeight.w700,
                                      fontStyle: FontStyle.normal,
                                      height: 1.3
                                  ),
                                  gradient: LinearGradient(
                                      colors: AppColor.gradientColor(1.0)
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 40,),

                        // Terms & Conditions
                        GestureDetector(
                          onTap: (){
                            setState(() {
                              termCondition = !termCondition;
                              _allFieldValidate = privacyPolicy && termCondition;
                            });
                          },
                          child: Center(
                            child: Container(
                              margin: EdgeInsets.only(left: 8.0),
                              height: 48.0,
                              width: 48.0,
                              child: Image.asset(
                                termCondition
                                    ? 'assets/complete_inspection/ic_check_icon.png'
                                    : 'assets/complete_inspection/ic_unchecked_icon.png',
                                height: 150,
                                width: 150,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'I have read and agree with the',
                                style: TextStyle(
                                    color: themeColor,
                                    fontSize: TextSize.subjectTitle,
                                    fontWeight: FontWeight.w700,
                                    fontStyle: FontStyle.normal,
                                    height: 1.3
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 5.0,),
                              GestureDetector(
                                onTap: (){
                                  _launchURL("https://dev.inspectordottie.com/Terms-of-Service");
                                },
                                child: GradientText(
                                  'Terms and Conditions',
                                  style: TextStyle(
                                      color: themeColor,
                                      fontSize: TextSize.subjectTitle,
                                      fontWeight: FontWeight.w700,
                                      fontStyle: FontStyle.normal,
                                      height: 1.3
                                  ),
                                  gradient: LinearGradient(
                                      colors: AppColor.gradientColor(1.0)
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Submit Button
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: InkWell(
                onTap: () async {
                  if(_allFieldValidate){
                    registerEmailAddress();
                    // if(await HelperClass.internetConnectivity()) {
                    //   registerEmailAddress();
                    // } else {
                    //   HelperClass.openSnackBar(context);
                    // }
                  }
                },
                child: Container(
                  height: 64.0,
                  margin: EdgeInsets.only(left: 48.0, right: 48.0, bottom: 64.0, top: 12.0),
                  decoration: BoxDecoration(
                      color: _allFieldValidate
                          ? themeColor
                          : AppColor.DIVIDER,
                      borderRadius: BorderRadius.all(Radius.circular(32.0))
                  ),
                  child: Center(
                    child: Text(
                      'Continue',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: (_allFieldValidate)
                            ? isDarkMode
                            ?  AppColor.BLACK_COLOR
                            : AppColor.WHITE_COLOR
                            : Color(0xff808080),
                        fontSize: TextSize.subjectTitle,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

  void _launchURL(_url) async {
    if (!await launch(_url)) throw 'Could not launch $_url';
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
