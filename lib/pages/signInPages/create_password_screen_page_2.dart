import 'dart:convert';

import 'package:dottie_inspector/main/welcome_intro_page.dart';
import 'package:dottie_inspector/pages/signInPages/profile_image_screen.dart';
import 'package:dottie_inspector/deadCode/signIn/password_success.dart';
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

class CreatePasswordScreenPage2 extends StatefulWidget {
  final formData;

  const CreatePasswordScreenPage2({Key key, this.formData}) : super(key: key);
  @override
  _CreatePasswordScreenPage2State createState() => _CreatePasswordScreenPage2State();
}

class _CreatePasswordScreenPage2State extends State<CreatePasswordScreenPage2> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _passwordController = TextEditingController();

  FocusNode _passwordFocus = FocusNode();

  bool isPasswordFocus = false;

  bool _obscurePasswordTextVisible = false;
  bool _obscurePasswordText = true;
  bool isFocusOn = true;

  bool isPasswordCompleted = false;
  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;

  Map formData;
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

    _passwordFocus.addListener(() {
      setState(() {
        isPasswordFocus = _passwordFocus.hasFocus;
        isFocusOn = !_passwordFocus.hasFocus;
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
                  child: GestureDetector(
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
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 10.0, left: 24.0, right: 24.0),
                            child: Text(
                              'Let’s create a new password',
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
                              'It’ll be our little secrete 💋️',
                              style: TextStyle(
                                color: themeColor,
                                fontSize: TextSize.subjectTitle,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ),


                          ///Password
                          Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.only(top: 32.0, bottom: 0.0, left: 16.0,right: 16.0),
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
                                    color: themeColor.withOpacity(1.0),
                                    fontWeight: FontWeight.w700,
                                    fontStyle: FontStyle.normal,),
                                  textAlign: TextAlign.center,
                                ),
                                TextFormField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocus,
                                  textInputAction: TextInputAction.done,
                                  keyboardType: TextInputType.text,
                                  textCapitalization: TextCapitalization.sentences,
                                  textAlign: TextAlign.start,
                                  onFieldSubmitted: (term) {
                                    _passwordFocus.unfocus();
                                  },
                                  decoration: InputDecoration(
                                    fillColor: AppColor.TRANSPARENT,
                                    hintText: "Something Secure",
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(top: 12.0),
                                    hintStyle: TextStyle(
                                        fontSize: TextSize.headerText,
                                        fontWeight: FontWeight.w700,
                                        color: isDarkMode
                                            ? Color(0xff545454)
                                            : Color(0xff808080)
                                    ),
                                    suffixIcon: Visibility(
                                        visible: _obscurePasswordTextVisible,
                                        child: GestureDetector(
                                          onTap: (){
                                            setState(() {
                                              _obscurePasswordText = !_obscurePasswordText;
                                            });
                                          },
                                          child: Text(
                                            _obscurePasswordText ? 'SHOW' : "HIDE",
                                            style: TextStyle(
                                                fontSize: TextSize.headerText,
                                                color: themeColor,
                                                fontWeight: FontWeight.w600,
                                                fontStyle: FontStyle.normal
                                            ),
                                          ),
                                        )
                                    ),
                                  ),
                                  obscureText: _obscurePasswordText,
                                  onChanged: (value){
                                    validatePassword(value);
                                    print(value);
                                    print(isPasswordCompleted);
                                    setState(() {
                                      _obscurePasswordTextVisible = value.isNotEmpty;
                                    });
                                  },
                                  style: TextStyle(
                                      color: themeColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: TextSize.headerText
                                  ),
                                  inputFormatters: [LengthLimitingTextInputFormatter(40)],
                                ),
                              ],
                            ),
                          ),

                          ///Hint
                          Container(
                            margin: EdgeInsets.only(top: 16.0, left: 24.0, right: 24.0),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Contains ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: TextSize.subjectTitle,
                                      color: themeColor.withOpacity(0.92)
                                    )
                                  ),
                                  TextSpan(
                                      text: "capital, lowercase, number,",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: TextSize.subjectTitle,
                                          color: themeColor
                                      )
                                  ),
                                  TextSpan(
                                      text: " and ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: TextSize.subjectTitle,
                                          color: themeColor.withOpacity(0.92)
                                      )
                                  ),
                                  TextSpan(
                                      text: "8+ characters",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: TextSize.subjectTitle,
                                          color: themeColor
                                      )
                                  ),
                                ]
                              ),
                            ),
                          ),
                        ],
                      ),
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
                child: GestureDetector(
                  onTap: (){
                    if(isPasswordCompleted) {
                      Map formDataLocal = {
                        "email": formData['email'],
                        "first_name": formData['first_name'],
                        "last_name": formData['last_name'],
                        "password": "${_passwordController.text.toString().trim()}",
                      };

                      print(formDataLocal);
                      Navigator.pushReplacement(
                          context,
                          SlideRightRoute(
                              page: ProfileImageScreen(
                                formData: formDataLocal,
                              )
                          )
                      );
                    }
                  },
                  child: Container(
                    height: 64.0,
                    margin: EdgeInsets.only(left: 48.0, right: 48.0, bottom: 64.0, top: 12.0),
                    decoration: BoxDecoration(
                        color: isPasswordCompleted
                            ? themeColor
                            : AppColor.DIVIDER,
                        borderRadius: BorderRadius.all(Radius.circular(32.0))
                    ),
                    child: Center(
                      child: Text(
                        'Continue',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: (isPasswordCompleted)
                              ? isDarkMode
                              ?  AppColor.BLACK_COLOR
                              : AppColor.WHITE_COLOR
                              : Color(0xff808080),
                          fontSize: TextSize.subjectTitle,
                          fontWeight: FontWeight.w700,
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
      ),
    );
  }

  void validatePassword(value){
    String  pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = new RegExp(pattern);

    setState(() {
      isPasswordCompleted = regExp.hasMatch(value);
    });
  }
}
