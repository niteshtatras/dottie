import 'dart:convert';
import 'dart:io';

import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/custom_toast.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:dottie_inspector/widget/bottom_general_button_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appavailability/flutter_appavailability.dart';
import 'package:progress_hud/progress_hud.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.PAGE_COLOR,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: AppColor.PAGE_COLOR,
        actions: <Widget>[
          Visibility(
            visible: _menuVisible,
            child: IconButton(
              padding: EdgeInsets.all(16.0),
              icon: Icon(
                Icons.more_horiz,
                color: AppColor.TYPE_PRIMARY,
              ),
              onPressed: (){
                bottomSelectNavigation(context);
              },
            ),
          ),
        ],
        leading: InkWell(
          onTap: (){
            Navigator.pop(context);
          },
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Image.asset(
              'assets/ic_close.png',
              fit: BoxFit.cover,
              height: 28.0,
              width: 28.0,
            ),
          ),
        ),
        title: Text(
          'Reset Password',
          style: TextStyle(
            color: AppColor.TYPE_PRIMARY,
            fontSize: TextSize.headerText,
            fontWeight: FontWeight.w600
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: <Widget>[
          SingleChildScrollView(
            child: Stack(
              children: [
                !_menuVisible
                ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    //Email Address
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Form(
                        // autovalidate: _autoValidate,
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child:  Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(top: 40.0, bottom: 0.0, left: 16.0,right: 16.0),
                          padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                          decoration: BoxDecoration(
                              color: isEmailFocus
                                  ? AppColor.THEME_PRIMARY.withOpacity(0.08)
                                  : AppColor.WHITE_COLOR,
                              borderRadius: BorderRadius.circular(16.0)
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Email',
                                style: TextStyle(
                                    fontSize: TextSize.bodyText,
                                    color: AppColor.TYPE_PRIMARY.withOpacity(1.0),
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.normal,
                                    fontFamily: "WorkSans"),
                                textAlign: TextAlign.center,
                              ),
                              TextFormField(
                                controller: emailController,
                                focusNode: emailFocus,
                                onFieldSubmitted: (term) {
                                  emailFocus.unfocus();
                                },
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
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.TYPE_PRIMARY.withOpacity(0.6)
                                  ),
                                ),
                                style: TextStyle(
                                    color: AppColor.TYPE_PRIMARY,
                                    fontWeight: FontWeight.w600,
                                    fontSize: TextSize.headerText
                                ),
                                inputFormatters: [LengthLimitingTextInputFormatter(40)],
                                onChanged: (value){
                                  Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                  RegExp regex = new RegExp(pattern);
                                  setState(() {
                                    _allFieldValidate = regex.hasMatch(value);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.only(top: 50.0),
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        "Enter the email address you used to register with Dottie, and we'll send you instructions to reset your  password.",
                        style: TextStyle(
                            color: AppColor.TYPE_SECONDARY,
                            fontSize: TextSize.subjectTitle,
                            fontWeight: FontWeight.w500,
                            height: 1.4
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                )
                : Container(
                  margin: EdgeInsets.only(top: 80.0),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image(
                          image: AssetImage('assets/ic_reset_password.png'),
                          fit: BoxFit.cover,
                          height: 150.0,
                          width: 150.0,
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 16.0),
                          child: Text(
                            '$checkEmailTitle',
                            style: TextStyle(
                              color: AppColor.TYPE_PRIMARY,
                              fontSize: TextSize.planeHeaderText,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.normal,
                              fontFamily: "WorkSans"
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.symmetric(vertical: 16.0,horizontal: 60.0),
                          child: Text.rich(
                            TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: '$checkEmailSubTitle1',
                                  style: TextStyle(
                                      color: AppColor.TYPE_SECONDARY,
                                      fontSize: TextSize.subjectTitle,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.normal,
                                      fontFamily: "WorkSans"
                                  ),
                                ),
                                TextSpan(
                                  text: '${emailController.text.toString().trim()}',
                                  style: TextStyle(
                                      color: AppColor.THEME_PRIMARY,
                                      fontSize: TextSize.subjectTitle,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.normal,
                                      fontFamily: "WorkSans"
                                  ),
                                ),
                                TextSpan(
                                  text: '$checkEmailSubTitle2',
                                  style: TextStyle(
                                      color: AppColor.TYPE_SECONDARY,
                                      fontSize: TextSize.subjectTitle,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.normal,
                                      fontFamily: "WorkSans"
                                  ),
                                )
                              ]
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),

          Visibility(
            visible: !isEmailFocus,
            child: BottomGeneralButton(
              isActive: _allFieldValidate,
              buttonName:  _menuVisible ? 'OPEN MAIL APP' :'SEND INSTRUCTIONS ',
              onStartButton: (){
                if(_menuVisible){
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
            ),
          ),

          /*//Submit Button
          Positioned(
            bottom: 32.0,
            left: 20.0,
            right: 20.0,
            child: InkWell(
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
                      InkWell(
                        onTap: (){
                          Navigator.pop(context);
                          forgotPassword("resend");
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

  Future<void> forgotPassword(type) async {
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
        setState(() {
          if(type == "send"){
            checkEmailSubTitle1 = "We emailed ";
            checkEmailSubTitle2 = " with instructions on resetting the password.";
          } else{
            checkEmailTitle = "Let\'s check that email again";
            checkEmailSubTitle1 = "We sent you another email to ";
            checkEmailSubTitle2 = ". Also, check your Spam folder just in case the confirmation email got delivered there instead of your inbox. If so, select the confirmation message and click Not Spam, which will allow future Dottie messages to go through.";
          }
          _menuVisible = true;
        });
      }
    }
  }
}
