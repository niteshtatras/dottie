import 'dart:convert';

import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_hud/progress_hud.dart';

import '../../pages/signInPages/confirm_account.dart';

class RegisterEmailPage extends StatefulWidget {
  final nameData;

  const RegisterEmailPage({Key key, this.nameData}) : super(key: key);

  @override
  _RegisterEmailPageState createState() => _RegisterEmailPageState();
}

class _RegisterEmailPageState extends State<RegisterEmailPage> {
  final _emailController = TextEditingController();
  final FocusNode emailFocus = FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _allFieldValidate = false;
  Map nameData;

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

    nameData = widget.nameData ?? {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
        backgroundColor: AppColor.WHITE_COLOR,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0.0,
          backgroundColor: AppColor.WHITE_COLOR,
          leading: IconButton(
            padding: EdgeInsets.only(left: 16.0, right: 16.0),
            icon: Icon(
              Icons.keyboard_backspace,
              color: AppColor.TYPE_PRIMARY,
              size: 32.0,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            '',
            style: TextStyle(
                color: AppColor.TYPE_PRIMARY,
                fontSize: TextSize.headerText,
                fontWeight: FontWeight.w600),
          ),
        ),
        body: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 10.0,),
                        Image(
                          image: AssetImage('assets/splash_main.png'),
                          fit: BoxFit.cover,
                          height: 150.0,
                          width: 150.0,
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 12.0),
                          child: Text(
                            'What’s your email?',
                            style: TextStyle(
                                color: AppColor.TYPE_PRIMARY,
                                fontSize: TextSize.greetingTitleText,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.normal,
                                fontFamily: "WorkSans"
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 16.0, left: 30.0, right: 30.0),
                          child: Text(
                            'We’ll send you one of those fancy emails that contains a confirmation link.',
                            style: TextStyle(
                                color: AppColor.TYPE_SECONDARY,
                                fontSize: TextSize.subjectTitle,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.normal,
                                fontFamily: "WorkSans",
                              height: 1.3
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Form(
                          key: _formKey,
//                    autovalidate: _autoValidate,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[

                              //First Name
                              Container(
                                margin: EdgeInsets.only(top: 40.0 ,left: 20.0, right: 20.0),
                                child:TextFormField(
                                  controller: _emailController,
                                  focusNode: emailFocus,
                                  textAlign: TextAlign.start,
                                  autofocus: false,
                                  validator: validateEmail,
                                  textInputAction: TextInputAction.done,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    fillColor: AppColor.WHITE_COLOR,
                                    hintText: "Email",
                                    contentPadding: EdgeInsets.symmetric(horizontal: 0,),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(4)),
                                      borderSide: BorderSide(width: 1,color: AppColor.TRANSPARENT),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(4)),
                                      borderSide: BorderSide(width: 1,color: AppColor.TRANSPARENT),
                                    ),
                                    labelText: 'Email',
                                    hintStyle: TextStyle(
                                        fontSize: TextSize.bodyText,
                                        fontWeight: FontWeight.w500,
                                        color: AppColor.TYPE_SECONDARY
                                    ),
                                    labelStyle: TextStyle(
                                        fontSize: TextSize.bodyText,
                                        fontWeight: FontWeight.w500,
                                        color: AppColor.TYPE_SECONDARY
                                    ),
                                  ),
                                  style: TextStyle(
                                      color: AppColor.TYPE_PRIMARY,
                                      fontWeight: FontWeight.w600,
                                      fontSize: TextSize.subjectTitle
                                  ),
                                  inputFormatters: [LengthLimitingTextInputFormatter(40)],
                                  onChanged: (value){
                                    setState(() {
                                      _allFieldValidate = _formKey.currentState.validate();
                                    });
                                  },
                                ),
                              ),
                              Divider(
                                height: 1.0,
                                color: AppColor.SEC_DIVIDER,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 200.0,)
                      ],
                    ),
                  ),
                  // Submit Button
                  Positioned(
                    bottom: 16.0,
                    left: 20.0,
                    right: 20.0,
                    child: InkWell(
                      onTap: (){
                        if(_formKey.currentState.validate() && _allFieldValidate){
                          Map formData = {
                            "email": "${_emailController.text.toString().trim()}",
                            "first_name": nameData['first_name'],
                            "last_name": nameData['last_name']
                          };
                          registerEmailAddress(formData);
//                          Navigator.push(
//                              context,
//                              MaterialPageRoute(
//                                  builder: (context) => ConfirmAccountPage(
//                                    formData: formData,
//                                  )
//                              )
//                          );
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
                            color: _allFieldValidate ? AppColor.THEME_PRIMARY : AppColor.DEACTIVATE,
                            borderRadius: BorderRadius.all(Radius.circular(4.0))
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                '         CONTINUE',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColor.WHITE_COLOR,
                                  fontSize: TextSize.subjectTitle,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                            ),
                            Container(
                                margin: EdgeInsets.only(right: 16.0),
                                padding: EdgeInsets.all(5.0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                    color: _allFieldValidate ? AppColor.DARK_BLUE_COLOR : AppColor.TYPE_SECONDARY_ALT
                                ),
                                child: Icon(Icons.arrow_forward, color: AppColor.WHITE_COLOR,)
                            )
                          ],
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
        Navigator.push(
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
