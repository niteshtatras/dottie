import 'dart:convert';

import 'package:dottie_inspector/deadCode/email_confirm_account.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/custom_toast.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:dottie_inspector/widget/bottom_general_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_hud/progress_hud.dart';

class EmailInfoEditPage extends StatefulWidget {
  final title;
  final value;

  const EmailInfoEditPage({Key key, this.title, this.value}) : super(key: key);

  @override
  _EmailInfoEditPageState createState() => _EmailInfoEditPageState();
}

class _EmailInfoEditPageState extends State<EmailInfoEditPage> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _emailController = TextEditingController();
  FocusNode emailFocus = FocusNode();

  bool _autoValidate = false;
  bool _allFieldValidate = false;
  bool isEmailFocus = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
      key: _scaffoldKey,
      backgroundColor: AppColor.PAGE_COLOR,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: AppColor.PAGE_COLOR,
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
          'Change Email',
          style: TextStyle(
              color: AppColor.TYPE_PRIMARY,
              fontSize: TextSize.headerText,
              fontWeight: FontWeight.w700
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 16.0,),

                Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [

                      //Email Address
                      Container(
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
                              controller: _emailController,
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
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal:24.0, vertical: 40.0),
                  child:  Text(
                    'Enter an updated email address for your account. We’ll send you an email with a confirmation link to confirm.',
                    style: TextStyle(
                        color: AppColor.TYPE_PRIMARY.withOpacity(0.8),
                        fontSize: TextSize.subjectTitle,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Work Sans'
                    ),
                  ),
                ),
                SizedBox(height: 160.0,)
              ],
            ),
          ),

          Visibility(
            visible: !isEmailFocus,
            child: BottomGeneralButton(
              isActive: _allFieldValidate,
              buttonName: "SEND INSTRUCTIONS",
              onStartButton: (){
                if(_formKey.currentState.validate() && _allFieldValidate){
                  changeEmail();
                } else {
                  setState(() {
                    emailFocus.requestFocus(FocusNode());
                    _autoValidate = true;
                  });
                }
              },
            ),
          ),
          //Submit Button
          /*Positioned(
            bottom: 16.0,
            left: 20.0,
            right: 20.0,
            child: InkWell(
              onTap: (){
                if(_formKey.currentState.validate() && _allFieldValidate){
                  changeEmail();
                } else {
                  setState(() {
                    emailFocus.requestFocus(FocusNode());
                    _autoValidate = true;
                  });
                }
              },
              child: Container(
                margin: EdgeInsets.only(top: 24.0),
                height: 56.0,
                decoration: BoxDecoration(
                    color: _allFieldValidate ? AppColor.THEME_PRIMARY : AppColor.TYPE_DISABLE,
                    borderRadius: BorderRadius.all(Radius.circular(4.0))
                ),
                child: Center(
                  child: Text(
                    'SEND INSTRUCTIONS',
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

  Future<void> changeEmail() async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());

    var requestJson = {
      "email": "${_emailController.text.toString().trim()}"
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
            MaterialPageRoute(
                builder: (context) => EmailConfirmAccountPage(
                    email: "${_emailController.text.toString().trim()}"
                )
            )
        );
      }
    }
  }
}
