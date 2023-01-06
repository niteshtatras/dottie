import 'dart:convert';

import 'package:dottie_inspector/deadCode/signIn/password_success.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_hud/progress_hud.dart';

class CreatePasswordScreenPage1 extends StatefulWidget {
  final type;

  const CreatePasswordScreenPage1({Key key, this.type}) : super(key: key);
  @override
  _CreatePasswordScreenPage1State createState() => _CreatePasswordScreenPage1State();
}

class _CreatePasswordScreenPage1State extends State<CreatePasswordScreenPage1> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  FocusNode _passwordFocus = FocusNode();
  FocusNode _confirmPasswordFocus = FocusNode();

  bool isPasswordFocus = false;
  bool isConfirmPasswordFocus = false;

  bool _obscurePasswordTextVisible = false;
  bool _obscureConfirmPasswordTextVisible = false;
  bool _obscurePasswordText = true;
  bool _obscureConfirmPasswordText = true;
  bool isFocusOn = true;

  bool isPasswordCompleted = false;
  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;

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

    _passwordFocus.addListener(() {
      setState(() {
        isPasswordFocus = _passwordFocus.hasFocus;
        isFocusOn = !_passwordFocus.hasFocus;
      });
    });

    _confirmPasswordFocus.addListener(() {
      setState(() {
        isConfirmPasswordFocus = _confirmPasswordFocus.hasFocus;
        isFocusOn = !_confirmPasswordFocus.hasFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColor.PAGE_COLOR,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: AppColor.PAGE_COLOR,
        leading: IconButton(
          padding: EdgeInsets.only(left: 16.0, right: 16.0),
          icon: Icon(Icons.arrow_back_ios,color: AppColor.TYPE_PRIMARY,size: 32.0,),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),

      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 10.0, left: 32.0, right: 32.0),
                    child: Text(
                      'Let’s create a\nnew password',
                      style: TextStyle(
                          color: AppColor.TYPE_PRIMARY,
                          fontSize: TextSize.greetingTitleText,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.normal,

                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16.0, left: 32.0, right: 32.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'It’ll be our little secrete',
                          style: TextStyle(
                              color: AppColor.TYPE_PRIMARY.withOpacity(0.8),
                              fontSize: TextSize.subjectTitle,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.normal,

                          ),
                        ),
                        Text(
                          '💋️',
                          style: TextStyle(
                              color: AppColor.RED_COLOR,
                              fontSize: TextSize.subjectTitle,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.normal,

                          ),
                        ),
                      ],
                    ),
                  ),

                  ///Password
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(top: 16.0, bottom: 0.0,  left: 16.0, right: 16.0),
                    padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                    decoration: BoxDecoration(
                        color: isPasswordFocus
                            ? AppColor.THEME_PRIMARY.withOpacity(0.08)
                            : AppColor.WHITE_COLOR,
                        borderRadius: BorderRadius.circular(16.0)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Password',
                          style: TextStyle(
                              fontSize: TextSize.bodyText,
                              color: AppColor.TYPE_PRIMARY,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.normal,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                          textAlign: TextAlign.start,
                          onFieldSubmitted: (term) {
                            _passwordFocus.unfocus();
                            FocusScope.of(context).requestFocus(_confirmPasswordFocus);
                          },
                          decoration: InputDecoration(
                            fillColor: AppColor.TRANSPARENT,
                            hintText: "Something Secure",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(top: 12.0),
                            hintStyle: TextStyle(
                                fontSize: TextSize.headerText,
                                fontWeight: FontWeight.w600,
                                color: AppColor.TYPE_PRIMARY.withOpacity(0.6)
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
                                        color: AppColor.TYPE_PRIMARY,
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
                              color: AppColor.TYPE_PRIMARY,
                              fontWeight: FontWeight.w600,
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
                              fontWeight: FontWeight.w500,
                              fontSize: TextSize.subjectTitle,
                              color: AppColor.TYPE_PRIMARY.withOpacity(0.8)
                            )
                          ),
                          TextSpan(
                              text: "capital, lowercase, number,",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: TextSize.subjectTitle,
                                  color: AppColor.TYPE_PRIMARY.withOpacity(0.8)
                              )
                          ),
                          TextSpan(
                              text: " and ",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: TextSize.subjectTitle,
                                  color: AppColor.TYPE_PRIMARY.withOpacity(0.8)
                              )
                          ),
                          TextSpan(
                              text: "8+ characters",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: TextSize.subjectTitle,
                                  color: AppColor.TYPE_PRIMARY.withOpacity(0.8)
                              )
                          ),
                        ]
                      ),
                    ),
                  ),

                  ///Confirm Password
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                    padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                    decoration: BoxDecoration(
                        color: isConfirmPasswordFocus
                            ? AppColor.THEME_PRIMARY.withOpacity(0.08)
                            : AppColor.WHITE_COLOR,
                        borderRadius: BorderRadius.circular(16.0)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Confirm Password',
                          style: TextStyle(
                              fontSize: TextSize.bodyText,
                              color: AppColor.TYPE_PRIMARY,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.normal,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        TextFormField(
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocus,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,
                          textAlign: TextAlign.start,
                          onFieldSubmitted: (term) {
                            _confirmPasswordFocus.unfocus();
                          },
                          decoration: InputDecoration(
                            fillColor: AppColor.TRANSPARENT,
                            hintText: "Password",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(top: 12.0),
                            hintStyle: TextStyle(
                                fontSize: TextSize.headerText,
                                fontWeight: FontWeight.w600,
                                color: AppColor.TYPE_PRIMARY.withOpacity(0.6)
                            ),
                            suffixIcon: Visibility(
                                visible: _obscureConfirmPasswordTextVisible,
                                child: GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      _obscureConfirmPasswordText = !_obscureConfirmPasswordText;
                                    });
                                  },
                                  child: Text(
                                    _obscureConfirmPasswordText ? 'SHOW' : "HIDE",
                                    style: TextStyle(
                                        fontSize: TextSize.headerText,
                                        color: AppColor.TYPE_PRIMARY,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FontStyle.normal
                                    ),
                                  ),
                                )
                            ),
                          ),
                          obscureText: _obscureConfirmPasswordText,
                          onChanged: (value){
                            validatePassword(value);
                            print(value);
                            print(isPasswordCompleted);
                            setState(() {
                              _obscureConfirmPasswordTextVisible = value.isNotEmpty;
                            });
                          },
                          style: TextStyle(
                              color: AppColor.TYPE_PRIMARY,
                              fontWeight: FontWeight.w600,
                              fontSize: TextSize.headerText
                          ),
                          inputFormatters: [LengthLimitingTextInputFormatter(40)],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
                    if (widget.type == 'register') {
                      resetPassword();
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PasswordSuccessPage()
                          )
                      );
                    }
                  }
                },
                child: Container(
                  height: 64.0,
                  margin: EdgeInsets.only(left: 48.0, right: 48.0, bottom: 34.0, top: 12.0),
                  decoration: BoxDecoration(
                      color: AppColor.TYPE_PRIMARY,
                      borderRadius: BorderRadius.all(Radius.circular(32.0))
                  ),
                  child: Center(
                    child: Text(
                      'UPDATE PASSWORD',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isPasswordCompleted ? AppColor.WHITE_COLOR : AppColor.WHITE_COLOR.withOpacity(0.24),
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

  void validatePassword(value){
    String  pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = new RegExp(pattern);

    setState(() {
      isPasswordCompleted = regExp.hasMatch(value) && (_passwordController.text == _confirmPasswordController.text);
    });
  }

  Future<void> resetPassword() async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());

    var requestJson = {
      "password": "${_passwordController.text.toString().trim()}"
    };
    var requestParam = json.encode(requestJson);
    var  response = await request.postRequest("auth/me/setPassword", requestParam);
    _progressHUD.state.dismiss();

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        HelperClass.showSnackBar(context, '${response['reason']}');
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PasswordSuccessPage()
            )
        );
      }
    }
  }
}
