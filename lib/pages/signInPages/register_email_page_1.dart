import 'dart:convert';

import 'package:dottie_inspector/main/welcome_intro_page.dart';
import 'package:dottie_inspector/deadCode/signIn/create_password_screen_page_1.dart';
import 'package:dottie_inspector/pages/signInPages/create_password_screen_page_2.dart';
import 'package:dottie_inspector/pages/signInPages/confirm_account.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/SlideRightRoute.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:dottie_inspector/widget/gradient/grediant_box_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_hud/progress_hud.dart';

class RegisterEmailPage1 extends StatefulWidget {
  final nameData;

  const RegisterEmailPage1({Key key, this.nameData}) : super(key: key);

  @override
  _RegisterEmailPage1State createState() => _RegisterEmailPage1State();
}

class _RegisterEmailPage1State extends State<RegisterEmailPage1> {
  final _emailController = TextEditingController();
  final FocusNode emailFocus = FocusNode();
  bool isEmailFocus = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _allFieldValidate = false;
  Map nameData;

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

    nameData = widget.nameData ?? {};

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
        // appBar: AppBar(
        //   centerTitle: true,
        //   elevation: 0.0,
        //   backgroundColor: AppColor.PAGE_COLOR,
        //   /*leading: IconButton(
        //     padding: EdgeInsets.only(left: 16.0, right: 16.0),
        //     icon: Icon(
        //       Icons.arrow_back_ios,
        //       color: AppColor.TYPE_PRIMARY,
        //       size: 32.0,
        //     ),
        //     onPressed: () {
        //       Navigator.pop(context);
        //     },
        //   ),*/
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
        //     '',
        //     style: TextStyle(
        //         color: AppColor.TYPE_PRIMARY,
        //         fontSize: TextSize.headerText,
        //         fontWeight: FontWeight.w600),
        //   ),
        // ),
        body: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 10.0, left: 24.0, right: 24.0),
                            child: Text(
                              'What’s your\nemail?',
                              style: TextStyle(
                                  color: themeColor,
                                  fontSize: TextSize.greetingTitleText,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.normal,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 16.0, left: 24.0, right: 24.0),
                            child: Text(
                              'We’ll send you one of those fancy emails that contains a confirmation link.',
                              style: TextStyle(
                                  color: themeColor,
                                  fontSize: TextSize.subjectTitle,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.normal,
                              ),
                            ),
                          ),

                          //Email Address
                          Form(
                            key: _formKey,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            child: Container(
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
                                        color: themeColor.withOpacity(1.0),
                                        fontWeight: FontWeight.w700,
                                        fontStyle: FontStyle.normal,),
                                    textAlign: TextAlign.center,
                                  ),
                                  TextFormField(
                                    controller: _emailController,
                                    focusNode: emailFocus,
                                    onFieldSubmitted: (term) {
                                      emailFocus.unfocus();
                                      if(isEmailValidated(_emailController.text.toString())) {
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
                                        if(_autoValidate)
                                          _allFieldValidate = _formKey.currentState.validate();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 200.0,)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Visibility(
                visible: !isEmailFocus,
                child: GestureDetector(
                  onTap: (){
                    if(_allFieldValidate){
                      Map formData = {
                        "email": "${_emailController.text.toString().trim()}",
                        "first_name": nameData['first_name'],
                        "last_name": nameData['last_name']
                      };
                      // registerEmailAddress(formData);
                      print(formData);
                      Navigator.pushReplacement(
                          context,
                          SlideRightRoute(
                            page: CreatePasswordScreenPage2(
                              formData: formData,
                            )
                          )
                      );
                    } else {
                      setState(() {
                        _autoValidate = true;
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
                        'Continue',
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

            _progressHUD
          ],
        ),
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

  Future<void> registerEmailAddress(formData) async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());

    var requestJson = {
      "firstname": formData['first_name'],
      "lastname": formData['last_name'],
      "email": formData['email']
    };
    var requestParam = json.encode(requestJson);
    var  response = await request.postUnAuthRequest("unauth/inspectorSetup", requestParam);
    _progressHUD.state.dismiss();

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        HelperClass.showSnackBar(context, '${response['reason']}');
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
