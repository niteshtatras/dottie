import 'dart:convert';

import 'package:dottie_inspector/pages/signInPages/login_page_1.dart';
import 'package:dottie_inspector/deadCode/signIn/forgot_password.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/custom_toast.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:dottie_inspector/widget/bottom_general_button_widget.dart';
import 'package:dottie_inspector/widget/bottom_general_dark_button_widget.dart';
import 'package:dottie_inspector/widget/gradient/grediant_box_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:progress_hud/progress_hud.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _allFieldValidate = false;
  bool matchPassword = false;

  TextEditingController _currentPasswordController = new TextEditingController();
  TextEditingController _newPasswordController = new TextEditingController();
  TextEditingController _confirmPasswordController = new TextEditingController();

  FocusNode _currentPasswordFocus = FocusNode();
  FocusNode _newPasswordFocus = FocusNode();
  FocusNode _confirmPasswordFocus = FocusNode();

  bool isCurrentPasswordFocus = false;
  bool isNewPasswordFocus = false;
  bool isConfirmPasswordFocus = false;
  bool isFocusOn = true;
  var elevation = 0.0;

  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;

  bool currentPasswordVisible = true;
  bool newPasswordVisible = true;
  bool confirmPasswordVisible = true;

  bool currentPasswordTextVisible = false;
  bool newPasswordTextVisible = false;
  bool confirmPasswordTextVisible = false;
  ScrollController _scrollController = ScrollController();

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

    _currentPasswordFocus.addListener(() {
      setState(() {
        isCurrentPasswordFocus = _currentPasswordFocus.hasFocus;
        isFocusOn = !_currentPasswordFocus.hasFocus;
      });
    });

    _newPasswordFocus.addListener(() {
      setState(() {
        isNewPasswordFocus = _newPasswordFocus.hasFocus;
        isFocusOn = !_newPasswordFocus.hasFocus;
      });
    });

    _confirmPasswordFocus.addListener(() {
      setState(() {
        isConfirmPasswordFocus = _confirmPasswordFocus.hasFocus;
        isFocusOn = !_confirmPasswordFocus.hasFocus;
      });
    });

    _scrollController.addListener(() {
      setState(() {
        if(_scrollController.position.pixels > _scrollController.position.minScrollExtent){
          elevation = HelperClass.ELEVATION_1;
        } else {
          elevation = HelperClass.ELEVATION;
        }
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
      backgroundColor: isDarkMode ? AppColor.BLACK_COLOR : AppColor.PAGE_COLOR,
      appBar: EmptyAppBar(isDarkMode: isDarkMode),
      // appBar: AppBar(
      //   centerTitle: true,
      //   elevation: elevation,
      //   backgroundColor: AppColor.PAGE_COLOR,
      //   leading: GestureDetector(
      //     onTap: (){
      //       Navigator.pop(context);
      //     },
      //     child: Container(
      //       padding: EdgeInsets.all(16.0),
      //       child: Image.asset(
      //         'assets/ic_close.png',
      //         fit: BoxFit.cover,
      //         height: 28.0,
      //         width: 28.0,
      //       ),
      //     ),
      //   ),
      //   title: Text(
      //     'Change Password',
      //     style: TextStyle(
      //         color: AppColor.TYPE_PRIMARY,
      //         fontSize: TextSize.headerText,
      //         fontWeight: FontWeight.w600
      //     ),
      //   ),
      // ),
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
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
                      Expanded(
                        flex: 9,
                        child: Visibility(
                          visible: elevation != 0,
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              'Change Password',
                              style: TextStyle(
                                  color: themeColor,
                                  fontSize: TextSize.headerText,
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(),
                      ),
                    ],
                  ),
                ),
                Visibility(
                    visible: elevation != 0,
                    child: Divider(
                      height: 0.5,
                      thickness: 1,
                      color: isDarkMode ? AppColor.DIVIDER.withOpacity(0.4) : AppColor.DIVIDER,
                    )
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            child: Text(
                              'Change Password',
                              style: TextStyle(
                                  color: themeColor,
                                  fontSize: TextSize.greetingTitleText,
                                  fontWeight: FontWeight.w700
                              ),
                            ),
                          ),

                          Form(
                            key: _formKey,
                            autovalidateMode: AutovalidateMode.disabled,
                            child: Container(
                              margin: EdgeInsets.only(top: 24.0,left: 16, right: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [

                                  //Current Password
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                    padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isCurrentPasswordFocus && isDarkMode
                                              ? AppColor.gradientColor(0.32)
                                              : isCurrentPasswordFocus
                                              ? AppColor.gradientColor(0.16)
                                              : isDarkMode
                                              ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                                              : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
                                        ),
                                        borderRadius: BorderRadius.circular(32.0),
                                        border: GradientBoxBorder(
                                            gradient: LinearGradient(
                                              colors: isCurrentPasswordFocus
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
                                          'Current Password',
                                          style: TextStyle(
                                              fontSize: TextSize.subjectTitle,
                                              color: themeColor,
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FontStyle.normal,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        TextFormField(
                                          controller: _currentPasswordController,
                                          focusNode: _currentPasswordFocus,
                                          validator: (value){
                                            return validatePassword(value, "current password");
                                          },
                                          textInputAction: TextInputAction.next,
                                          textAlign: TextAlign.start,
                                          onFieldSubmitted: (term) {
                                            _currentPasswordFocus.unfocus();
                                            FocusScope.of(context).requestFocus(_newPasswordFocus);
                                            if(validatingString()){
                                              setState(() {
                                                _allFieldValidate = _formKey.currentState.validate();
                                                matchPassword = _newPasswordController.text.toString() == _confirmPasswordController.text.toString();
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
                                                visible: currentPasswordTextVisible,
                                                child: GestureDetector(
                                                  onTap: (){
                                                    setState(() {
                                                      currentPasswordVisible = !currentPasswordVisible;
                                                    });
                                                  },
                                                  child: Text(
                                                    currentPasswordVisible ? 'SHOW' : "HIDE",
                                                    style: TextStyle(
                                                        fontSize: TextSize.headerText,
                                                        color: themeColor,
                                                        fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                )
                                            ),
                                          ),
                                          obscureText: currentPasswordVisible,
                                          onChanged: (value){
                                              setState(() {
                                                currentPasswordTextVisible = value.isNotEmpty;
                                                if(_autoValidate) {
                                                  _allFieldValidate = _formKey.currentState.validate();
                                                  matchPassword = _newPasswordController.text.toString() == _confirmPasswordController.text.toString();
                                                }
                                              });
                                          },
                                          style: TextStyle(
                                              color: themeColor,
                                              fontWeight: FontWeight.w700,
                                              fontSize: TextSize.headerText,
                                              letterSpacing: currentPasswordVisible ? 2.0 : 0.0
                                          ),
                                          inputFormatters: [LengthLimitingTextInputFormatter(40)],
                                        ),
                                      ],
                                    ),
                                  ),

                                  //New Password
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                    padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isNewPasswordFocus && isDarkMode
                                              ? AppColor.gradientColor(0.32)
                                              : isNewPasswordFocus
                                              ? AppColor.gradientColor(0.16)
                                              : isDarkMode
                                              ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                                              : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
                                        ),
                                        borderRadius: BorderRadius.circular(32.0),
                                        border: GradientBoxBorder(
                                            gradient: LinearGradient(
                                              colors: isNewPasswordFocus
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
                                          'New Password',
                                          style: TextStyle(
                                            fontSize: TextSize.subjectTitle,
                                            color: themeColor,
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FontStyle.normal,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        TextFormField(
                                          controller: _newPasswordController,
                                          focusNode: _newPasswordFocus,
                                          validator: (value){
                                            return validatePassword(value, "new password");
                                          },
                                          textInputAction: TextInputAction.next,
                                          textAlign: TextAlign.start,
                                          onFieldSubmitted: (term) {
                                            _newPasswordFocus.unfocus();
                                            FocusScope.of(context).requestFocus(_confirmPasswordFocus);
                                            if(validatingString()){
                                              setState(() {
                                                _allFieldValidate = _formKey.currentState.validate();
                                                matchPassword = _newPasswordController.text.toString() == _confirmPasswordController.text.toString();
                                              });
                                            }
                                          },
                                          obscuringCharacter: "\u2B24",
                                          decoration: InputDecoration(
                                            fillColor: AppColor.TRANSPARENT,
                                            hintText: "Something secure",
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
                                                visible: newPasswordTextVisible,
                                                child: GestureDetector(
                                                  onTap: (){
                                                    setState(() {
                                                      newPasswordVisible = !newPasswordVisible;
                                                    });
                                                  },
                                                  child: Text(
                                                    newPasswordVisible ? 'SHOW' : "HIDE",
                                                    style: TextStyle(
                                                      fontSize: TextSize.headerText,
                                                      color: themeColor,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                )
                                            ),
                                          ),
                                          obscureText: newPasswordVisible,
                                          onChanged: (value){
                                              setState(() {
                                                newPasswordTextVisible = value.isNotEmpty;
                                                if(_autoValidate) {
                                                  _allFieldValidate = _formKey.currentState.validate();
                                                  matchPassword = _newPasswordController.text.toString() == _confirmPasswordController.text.toString();
                                                }
                                              });
                                          },
                                          style: TextStyle(
                                              color: themeColor,
                                              fontWeight: FontWeight.w700,
                                              fontSize: TextSize.headerText,
                                              letterSpacing: newPasswordVisible ? 2.0 : 0.0
                                          ),
                                          inputFormatters: [LengthLimitingTextInputFormatter(40)],
                                        ),
                                      ],
                                    ),
                                  ),

                                  Container(
                                    margin: EdgeInsets.only(top: 8.0 ,left: 40.0, right: 40.0),
                                    child: Text.rich(
                                      TextSpan(
                                          text: 'Contains ',
                                          style: TextStyle(
                                              color: themeColor,
                                              fontWeight: FontWeight.w400,
                                              fontSize: TextSize.subjectTitle
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: 'capital, lowercase, number,',
                                              style: TextStyle(
                                                  color: themeColor,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: TextSize.subjectTitle
                                              ),
                                            ),
                                            TextSpan(
                                              text: ' and ',
                                              style: TextStyle(
                                                  color: themeColor,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: TextSize.subjectTitle
                                              ),
                                            ),
                                            TextSpan(
                                              text: '8+ characters',
                                              style: TextStyle(
                                                  color: themeColor,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: TextSize.subjectTitle
                                              ),
                                            )
                                          ]
                                      ),
                                    ),
                                  ),

                                  //Confirm Password
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin: EdgeInsets.only(top: 24.0, bottom: 0.0),
                                    padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isConfirmPasswordFocus && isDarkMode
                                              ? AppColor.gradientColor(0.16)
                                              : isConfirmPasswordFocus
                                              ? AppColor.gradientColor(0.32)
                                              : isDarkMode
                                              ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                                              : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
                                        ),
                                        borderRadius: BorderRadius.circular(32.0),
                                        border: GradientBoxBorder(
                                            gradient: LinearGradient(
                                              colors: isConfirmPasswordFocus
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
                                          'Confirm Password',
                                          style: TextStyle(
                                            fontSize: TextSize.subjectTitle,
                                            color: themeColor,
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FontStyle.normal,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        TextFormField(
                                          controller: _confirmPasswordController,
                                          focusNode: _confirmPasswordFocus,
                                          validator:  validateConfirmPassword,
                                          textInputAction: TextInputAction.done,
                                          textAlign: TextAlign.start,
                                          onFieldSubmitted: (term) {
                                            _confirmPasswordFocus.unfocus();
                                            if(validatingString()){
                                              setState(() {
                                                _allFieldValidate = _formKey.currentState.validate();
                                                matchPassword = _newPasswordController.text.toString() == _confirmPasswordController.text.toString();
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
                                                visible: confirmPasswordTextVisible,
                                                child: GestureDetector(
                                                  onTap: (){
                                                    setState(() {
                                                      confirmPasswordVisible = !confirmPasswordVisible;
                                                    });
                                                  },
                                                  child: Text(
                                                    confirmPasswordVisible ? 'SHOW' : "HIDE",
                                                    style: TextStyle(
                                                      fontSize: TextSize.headerText,
                                                      color: themeColor,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                )
                                            ),
                                          ),
                                          obscureText: confirmPasswordVisible,
                                          onChanged: (value){
                                            setState(() {
                                              confirmPasswordTextVisible = value.isNotEmpty;
                                              if(_autoValidate) {
                                                _allFieldValidate = _formKey.currentState.validate();
                                                matchPassword = _newPasswordController.text.toString() == _confirmPasswordController.text.toString();
                                              }
                                            });
                                          },
                                          style: TextStyle(
                                              color: themeColor,
                                              fontWeight: FontWeight.w700,
                                              fontSize: TextSize.headerText,
                                              letterSpacing: confirmPasswordVisible ? 2.0 : 0.0
                                          ),
                                          inputFormatters: [LengthLimitingTextInputFormatter(40)],
                                        ),
                                      ],
                                    ),
                                  ),

                               /*   //Current Password
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal:20.0,),
                                    child:  Text(
                                      'Current Password',
                                      style: TextStyle(
                                          color: AppColor.TYPE_PRIMARY.withOpacity(0.6),
                                          fontSize: TextSize.subjectTitle,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Work Sans'
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 8.0 ,left: 20.0, right: 20.0, bottom: 8.0),
                                    child: TextFormField(
                                      controller: _currentPasswordController,
                                      focusNode: _currentPasswordFocus,
                                      validator: (value){
                                        return validateString(value, "current password");
                                      },
                                      onFieldSubmitted: (term) {
                                        _currentPasswordFocus.unfocus();
                                        FocusScope.of(context).requestFocus(_newPasswordFocus);
                                      },
                                      autofocus: false,
                                      textInputAction: TextInputAction.next,
                                      textAlign: TextAlign.start,
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                        fillColor: AppColor.WHITE_COLOR,
                                        filled: true,
                                        hintText: "Type your password...",
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16.0),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16.0),
                                            borderSide: BorderSide(
                                              color: AppColor.THEME_PRIMARY,
                                              width: 3,
                                            )
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(16)),
                                          borderSide:
                                          BorderSide(width: 1, color: AppColor.TRANSPARENT),
                                        ),
                                        hintStyle: TextStyle(
                                          fontSize: TextSize.subjectTitle,
                                          fontWeight: FontWeight.w500,
                                          color: AppColor.TYPE_SECONDARY,
                                        ),
                                          suffix: GestureDetector(
                                            onTap: (){
                                              setState(() {
                                                currentPasswordVisible = !currentPasswordVisible;
                                              });
                                            },
                                            child: Container(
                                              margin: EdgeInsets.only(right: 5.0),
                                              child: Text(
                                                _currentPasswordController.text.length == 0 ? "" : currentPasswordVisible ? "SHOW" : "HIDE",
                                                style: TextStyle(
                                                    fontSize: TextSize.subjectTitle,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColor.TYPE_PRIMARY.withOpacity(0.80)
                                                ),
                                              ),
                                            ),
                                          )
                                      ),
                                      obscureText: currentPasswordVisible,
                                      style: TextStyle(
                                          color: AppColor.TYPE_PRIMARY,
                                          fontWeight: FontWeight.w600,
                                          fontSize: TextSize.headerText),
                                      inputFormatters: [LengthLimitingTextInputFormatter(40)],
                                      onChanged: (value){
                                        setState(() {
                                          _allFieldValidate = _formKey.currentState.validate();
                                        });
                                      },
                                    ),
                                  ),

                                  //New Password
                                  Container(
                                    margin: EdgeInsets.only(top: 24.0, left: 20.0, right: 20.0),
                                    child:  Text(
                                      'New Password',
                                      style: TextStyle(
                                          color: AppColor.TYPE_PRIMARY.withOpacity(0.6),
                                          fontSize: TextSize.subjectTitle,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Work Sans'
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 8.0, left: 20.0, right: 20.0),
                                    child: TextFormField(
                                      controller: _newPasswordController,
                                      focusNode: _newPasswordFocus,
                                      validator: (value){
                                        return validatePassword(value, "new");
                                      },
                                      onFieldSubmitted: (term) {
                                        _newPasswordFocus.unfocus();
                                        FocusScope.of(context).requestFocus(_confirmPasswordFocus);
                                      },
                                      autofocus: false,
                                      textInputAction: TextInputAction.next,
                                      textAlign: TextAlign.start,
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                        fillColor: AppColor.WHITE_COLOR,
                                        filled: true,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16.0),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16.0),
                                            borderSide: BorderSide(
                                              color: AppColor.THEME_PRIMARY,
                                              width: 3,
                                            )
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(16)),
                                          borderSide:
                                          BorderSide(width: 1, color: AppColor.TRANSPARENT),
                                        ),
                                          suffix: GestureDetector(
                                            onTap: (){
                                              setState(() {
                                                newPasswordVisible = !newPasswordVisible;
                                              });
                                            },
                                            child: Container(
                                              margin: EdgeInsets.only(right: 5.0),
                                              child: Text(
                                                _newPasswordController.text.length == 0 ? "" : newPasswordVisible ? "SHOW" : "HIDE",
                                                style: TextStyle(
                                                    fontSize: TextSize.subjectTitle,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColor.TYPE_PRIMARY.withOpacity(0.80)
                                                ),
                                              ),
                                            ),
                                          )
                                      ),
                                      obscureText: newPasswordVisible,
                                      style: TextStyle(
                                          color: AppColor.TYPE_PRIMARY,
                                          fontWeight: FontWeight.w600,
                                          fontSize: TextSize.headerText),
                                      inputFormatters: [LengthLimitingTextInputFormatter(40)],
                                      onChanged: (value){
                                        setState(() {
                                          _allFieldValidate = _formKey.currentState.validate();
                                          matchPassword = _newPasswordController.text.toString() == _confirmPasswordController.text.toString();
                                        });
                                      },
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 8.0 ,left: 20.0, right: 20.0),
                                    child: Text.rich(
                                      TextSpan(
                                        text: 'Contains ',
                                        style: TextStyle(
                                          color: AppColor.TYPE_PRIMARY.withOpacity(0.8),
                                          fontWeight: FontWeight.w400,
                                          fontSize: TextSize.subjectTitle
                                        ),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: 'capital, lowercase, number,',
                                            style: TextStyle(
                                                color: AppColor.TYPE_PRIMARY.withOpacity(0.8),
                                                fontWeight: FontWeight.w700,
                                                fontSize: TextSize.subjectTitle
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' and ',
                                            style: TextStyle(
                                                color: AppColor.TYPE_PRIMARY.withOpacity(0.8),
                                                fontWeight: FontWeight.w400,
                                                fontSize: TextSize.subjectTitle
                                            ),
                                          ),
                                          TextSpan(
                                            text: '8+ characters',
                                            style: TextStyle(
                                                color: AppColor.TYPE_PRIMARY.withOpacity(0.8),
                                                fontWeight: FontWeight.w700,
                                                fontSize: TextSize.subjectTitle
                                            ),
                                          )
                                        ]
                                      ),
                                    ),
                                  ),

                                  //Confirm Password
                                  Container(
                                    padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 24.0),
                                    child:  Text(
                                      'Confirm Password',
                                      style: TextStyle(
                                          color: AppColor.TYPE_PRIMARY.withOpacity(0.6),
                                          fontSize: TextSize.subjectTitle,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Work Sans'
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 8.0, bottom: 8.0, left: 20.0, right: 20.0),
                                    child: TextFormField(
                                      controller: _confirmPasswordController,
                                      focusNode: _confirmPasswordFocus,
                                      validator: (value){
                                        return validatePassword(value, "confirm");
                                      },
                                      autofocus: false,
                                      textInputAction: TextInputAction.done,
                                      textAlign: TextAlign.start,
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                        fillColor: AppColor.WHITE_COLOR,
                                        filled: true,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16.0),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16.0),
                                            borderSide: BorderSide(
                                              color: AppColor.THEME_PRIMARY,
                                              width: 3,
                                            )
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(16)),
                                          borderSide:
                                          BorderSide(width: 1, color: AppColor.TRANSPARENT),
                                        ),
                                        suffix: GestureDetector(
                                          onTap: (){
                                            setState(() {
                                              confirmPasswordVisible = !confirmPasswordVisible;
                                            });
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(right: 5.0),
                                            child: Text(
                                              _confirmPasswordController.text.length == 0 ? "" : confirmPasswordVisible ? "SHOW" : "HIDE",
                                              style: TextStyle(
                                                  fontSize: TextSize.subjectTitle,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColor.TYPE_PRIMARY.withOpacity(0.80)
                                              ),
                                            ),
                                          ),
                                        )
                                      ),
                                      obscureText: confirmPasswordVisible,
                                      style: TextStyle(
                                          color: AppColor.TYPE_PRIMARY,
                                          fontWeight: FontWeight.w600,
                                          fontSize: TextSize.headerText),
                                      inputFormatters: [LengthLimitingTextInputFormatter(40)],
                                      onChanged: (value){
                                        setState(() {
                                          _allFieldValidate = _formKey.currentState.validate();
                                          matchPassword = _newPasswordController.text.toString() == _confirmPasswordController.text.toString();
                                        });
                                      },
                                    ),
                                  ),*/
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 160.0,),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Visibility(
              visible: isFocusOn,
              child: BottomGeneralButton(
                isActive: _allFieldValidate && matchPassword,
                buttonName: "Update",
                onStartButton: () async {
                  if(_formKey.currentState.validate() && _allFieldValidate && matchPassword){
                    _formKey.currentState.save();
                    updatePassword();
                    // if(await HelperClass.internetConnectivity()) {
                    //   updatePassword();
                    // } else {
                    //   HelperClass.openSnackBar(context);
                    // }
                  } else {
                    setState(() {
                      _currentPasswordFocus.requestFocus(FocusNode());
                      _autoValidate = true;
                    });
                  }
                },
              ),
            ),

           /* //Submit Button
            Positioned(
              bottom: 16.0,
              left: 20.0,
              right: 20.0,
              child: GestureDetector(
                onTap: (){
                  if(_formKey.currentState.validate() && _allFieldValidate && matchPassword){
                    *//*Map nameData = {
                      "first_name": "${_firstNameController.text.toString().trim()}",
                      "last_name": "${_lastNameController.text.toString().trim()}"
                    };
                    Navigator.of(context).pop({"data":nameData});*//*
                    updatePassword();
                  } else {
                    setState(() {
                      _currentPasswordFocus.requestFocus(FocusNode());
                      _autoValidate = true;
                    });
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(top: 24.0),
                  height: 56.0,
                  decoration: BoxDecoration(
                      color: _allFieldValidate && matchPassword ? AppColor.THEME_PRIMARY : AppColor.TYPE_DISABLE,
                      borderRadius: BorderRadius.all(Radius.circular(16.0))
                  ),
                  child: Center(
                    child: Text(
                      'UPDATE PASSWORD',
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
            ),*/

            _progressHUD
          ],
        ),
      ),
    );
  }

  bool validatingString() {
    return isValidatePassword(_currentPasswordController.text.toString().trim())
        && isValidatePassword(_newPasswordController.text.toString().trim())
        && isValidatePassword(_currentPasswordController.text.toString().trim())
        && (_newPasswordController.text.toString() == _confirmPasswordController.text.toString());
  }

  String validateString(String value, String type) {
    if(value!='' && value!=null) {
      if(!value.startsWith(' '))
        return null;
      else
        return 'Enter your $type';
    }
    else {
      return 'Enter your $type';
    }
  }

  String validateConfirmPassword(String value) {
    Pattern pattern = "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@\$%^&*-]).{8,}\$";
    RegExp regex = new RegExp(pattern);
    bool isMatch = _newPasswordController.text.toString().trim() == _confirmPasswordController.text.toString().trim();

    if(value != '') {
      if (!regex.hasMatch(value))
        return 'Enter a valid password';
      else if(!isMatch)
        return 'New password and confirm password is not match';
      else
        return null;
    } else {
      return 'Enter your confirm password';
    }
  }

  String validatePassword(String value, String type) {
    Pattern pattern = "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@\$%^&*-]).{8,}\$";
    RegExp regex = new RegExp(pattern);

    if(value != '') {
      if (!regex.hasMatch(value))
        return 'Enter a valid password';
      else
        return null;
    } else {
      return 'Enter your '+ type=='new' ? 'new' : 'confirm' + ' password';
    }
  }

  bool isValidatePassword(String value) {
    Pattern pattern = "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@\$%^&*-]).{8,}\$";
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

  void updatePassword() async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var requestJson = {"password": "${_confirmPasswordController.text.toString().trim()}"};

    var requestParam = json.encode(requestJson);
    var response = await request.postRequest("auth/me/setPassword", requestParam);
    _progressHUD.state.dismiss();

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage('${response['reason']}');
      } else {
        CustomToast.showToastMessage('Password changed successfully');
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage1(),
            ),
            ModalRoute.withName(LoginPage1.tag)
        );
      }
    }
  }
}
