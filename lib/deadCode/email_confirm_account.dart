import 'dart:convert';
import 'dart:io';

import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/custom_toast.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appavailability/flutter_appavailability.dart';
import 'package:progress_hud/progress_hud.dart';

class EmailConfirmAccountPage extends StatefulWidget {
  final email;

  const EmailConfirmAccountPage({Key key, this.email}) : super(key: key);

  @override
  _EmailConfirmAccountPageState createState() => _EmailConfirmAccountPageState();
}

class _EmailConfirmAccountPageState extends State<EmailConfirmAccountPage> {
  String checkEmailTitle = "Check your email";
  String checkEmailSubTitle1 = "We emailed ";
  String checkEmailSubTitle2 = " with instructions on resetting the password.";

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.WHITE_COLOR,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: AppColor.WHITE_COLOR,
        leading: IconButton(
          padding: EdgeInsets.only(left: 16.0, right: 16.0),
          icon: Icon(Icons.arrow_back_ios,color: AppColor.TYPE_PRIMARY,size: 32.0,),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Confirm Account',
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
        children: [
          SingleChildScrollView(
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
                                fontFamily: "WorkSans",
                                height: 1.5
                            ),
                          ),
                          TextSpan(
                            text: '${widget.email}',
                            style: TextStyle(
                                color: AppColor.THEME_PRIMARY,
                                fontSize: TextSize.subjectTitle,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.normal,
                                fontFamily: "WorkSans",
                                height: 1.5
                            ),
                          ),
                          TextSpan(
                            text: '. $checkEmailSubTitle1',
                            style: TextStyle(
                                color: AppColor.TYPE_SECONDARY,
                                fontSize: TextSize.subjectTitle,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.normal,
                                fontFamily: "WorkSans",
                              height: 1.5
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
          //Submit Button
          Positioned(
            bottom: 32.0,
            left: 20.0,
            right: 20.0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      /*Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResetPasswordPage(
                              type: "register"
                            ),
                          ),
                          ModalRoute.withName(LoginPage.tag));*/
                      resendVerificationCode();
                    },
                    child: Container(
                      height: 56.0,
                      decoration: BoxDecoration(
                          color: AppColor.THEME_PRIMARY,
                          borderRadius: BorderRadius.all(Radius.circular(4.0))
                      ),
                      child: Center(
                        child: Text(
                          'RESEND',
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
                SizedBox(width: 8.0,),
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      /*Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResetPasswordPage(
                          type: "register"
                        ),
                      ),
                      ModalRoute.withName(LoginPage.tag));*/
                      openEmailApp();
                    },
                    child: Container(
                      height: 56.0,
                      decoration: BoxDecoration(
                          color: AppColor.THEME_PRIMARY,
                          borderRadius: BorderRadius.all(Radius.circular(4.0))
                      ),
                      child: Center(
                        child: Text(
                          'OPEN MAIL APP',
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
              ],
            ),
          ),

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
        HelperClass.showSnackBar(context, "Email App not found!");
        print("err====$err");
      });
    } catch(e) {
      HelperClass.showSnackBar(context, "Email App not found!");
    }
  }

  Future<void> resendVerificationCode() async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());

    var requestJson = {
      "email": "${widget.email}"
    };
    var requestParam = json.encode(requestJson);
    var  response = await request.postUnAuthRequest("unauth/forgotInspectorPwd", requestParam);
    _progressHUD.state.dismiss();

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage("${response['reason']}");
      } else {
        setState(() {
          checkEmailTitle = "Let\'s check that email again";
          checkEmailSubTitle1 = "We sent you another email to ";
          checkEmailSubTitle2 = ". Also, check your Spam folder just in case the confirmation email got delivered there instead of your inbox. If so, select the confirmation message and click Not Spam, which will allow future Dottie messages to go through.";
        });
      }
    } else{
      CustomToast.showToastMessage("Something went wrong!");
    }
  }
}
