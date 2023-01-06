import 'dart:convert';

import 'package:dottie_inspector/deadCode/signIn/reset_password_success.dart';
import 'package:dottie_inspector/pages/signInPages/login_page_1.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_hud/progress_hud.dart';

class ResetPasswordPage extends StatefulWidget {
  final type;

  const ResetPasswordPage({Key key, this.type}) : super(key: key);

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _allFieldValidate = false;
  TextEditingController newPasswordController = new TextEditingController();
  TextEditingController confirmPasswordController = new TextEditingController();
  FocusNode newPasswordFocus = FocusNode();
  FocusNode confirmPasswordFocus = FocusNode();

  bool _obscureConfirmVisible = false;
  bool _obscureConfirmText = true;
  bool _obscureNewTextVisible = false;
  bool _obscureNewText = true;

  bool isContainCapital = false;
  bool isContainLower = false;
  bool isContainNumber = false;
  bool isContainSymbol = false;
  bool isContainEight = false;

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
      backgroundColor: AppColor.BG_PRIMARY,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: AppColor.BG_PRIMARY,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon:  Image.asset(
            'assets/ic_back_button.png',
            height: 24.0,
            width: 24.0,
          ),
        ),
        title: Text(
          'New Password',
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
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  //New Password
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Form(
                      autovalidateMode: AutovalidateMode.always,
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          //New Password
                          Container(
                            margin: EdgeInsets.only(top: 32.0 ,left: 20.0, right: 20.0),
                            child: TextFormField(
                              controller: newPasswordController,
                              focusNode: newPasswordFocus,
                              validator: validatePassword,
                              autofocus: false,
                              onFieldSubmitted: (value){
                                newPasswordFocus.unfocus();
                                FocusScope.of(context).requestFocus(confirmPasswordFocus);
                              },
                              textInputAction: TextInputAction.done,
                              textAlign: TextAlign.start,
                              decoration: InputDecoration(
                                fillColor: AppColor.WHITE_COLOR,
                                hintText: "New Password",
                                contentPadding: EdgeInsets.symmetric(horizontal: 0.0,),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                  borderSide: BorderSide(
                                      width: 1, color: AppColor.TRANSPARENT),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                  borderSide:
                                  BorderSide(width: 1, color: AppColor.TRANSPARENT),
                                ),
                                labelText: 'New Password',
                                hintStyle: TextStyle(
                                  fontSize: TextSize.subjectTitle,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.TYPE_SECONDARY,
                                ),
                                labelStyle: TextStyle(
                                    fontSize: TextSize.subjectTitle,
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.TYPE_SECONDARY
                                ),
                                suffixIcon: Visibility(
                                  visible: _obscureNewTextVisible,
                                  child: IconButton(
                                    icon: Icon(
                                      _obscureNewText
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: AppColor.TYPE_SECONDARY,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureNewText = !_obscureNewText;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              obscureText: _obscureNewText,
                              style: TextStyle(
                                  color: AppColor.TYPE_PRIMARY,
                                  fontWeight: FontWeight.w600,
                                  fontSize: TextSize.headerText),
                              inputFormatters: [LengthLimitingTextInputFormatter(40)],
                              onChanged: (value){
                                setState(() {
                                  _allFieldValidate = _formKey.currentState.validate();
                                  _obscureNewTextVisible = value.isNotEmpty;

                                  isContainCapital = checkValidation('(?=.*[A-Z])', value);
                                  isContainLower = checkValidation('(?=.*[a-z])', value);
                                  isContainNumber = checkValidation('(?=.*[0-9])', value);
                                  isContainSymbol = checkValidation('(?=.*[!@#\$%^&*+-])', value);
                                  isContainEight = value.length > 8;

                                  print("After===$isContainCapital $isContainLower $isContainNumber $isContainSymbol $isContainEight");
                                });
                              },
                            ),
                          ),

                          //Confirm Password
                          Container(
                            margin: EdgeInsets.only(top: 32.0 ,left: 20, right: 20),
                            child: TextFormField(
                              controller: confirmPasswordController,
                              focusNode: confirmPasswordFocus,
                              validator: validatePassword,
                              autofocus: false,
                              textInputAction: TextInputAction.done,
                              textAlign: TextAlign.start,
                              decoration: InputDecoration(
                                fillColor: AppColor.WHITE_COLOR,
                                hintText: "Confirm Password",
                                contentPadding: EdgeInsets.symmetric(horizontal: 0.0,),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                  borderSide: BorderSide(
                                      width: 1, color: AppColor.TRANSPARENT),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                  borderSide:
                                  BorderSide(width: 1, color: AppColor.TRANSPARENT),
                                ),
                                labelText: 'Confirm Password',
                                hintStyle: TextStyle(
                                  fontSize: TextSize.subjectTitle,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.TYPE_SECONDARY,
                                ),
                                labelStyle: TextStyle(
                                    fontSize: TextSize.subjectTitle,
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.TYPE_SECONDARY
                                ),
                                suffixIcon: Visibility(
                                  visible: _obscureConfirmVisible,
                                  child: IconButton(
                                    icon: Icon(
                                      _obscureConfirmText
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: AppColor.TYPE_SECONDARY,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmText = !_obscureConfirmText;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              obscureText: _obscureConfirmText,
                              style: TextStyle(
                                  color: AppColor.TYPE_PRIMARY,
                                  fontWeight: FontWeight.w600,
                                  fontSize: TextSize.headerText),
                              inputFormatters: [LengthLimitingTextInputFormatter(40)],
                              onChanged: (value){
                                setState(() {
                                  _allFieldValidate = newPasswordController.text.toString().trim() == confirmPasswordController.text.toString().trim();
                                  _obscureConfirmVisible = value.isNotEmpty;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16.0,),
                  //all check list
                  //Capital letter
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 28.0, vertical: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        isContainCapital
                        ? Container(
                            height: 32.0,
                            width: 32.0,
                            decoration: BoxDecoration(
                              color: AppColor.SUCCESS_COLOR,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.done,
                              size: 24.0,
                              color: AppColor.WHITE_COLOR,
                            ),
                          )
                       : Container(
                           height: 32.0,
                           width: 32.0,
                           decoration: BoxDecoration(
                               color: AppColor.GREY_COLOR,
                               shape: BoxShape.circle,
//                               border: Border.all(color: AppColor.TYPE_SECONDARY, width: 1.0)
                           ),
                           child: Icon(
                             Icons.done,
                             size: 24.0,
                             color: AppColor.WHITE_COLOR,
                           ),
                         ),

                        SizedBox(width: 16.0,),
                        // Text
                        Text(
                          'Contains a capital',
                          style: TextStyle(
                            fontSize: TextSize.subjectTitle,
                            fontFamily: "WorkSans",
                            color: isContainCapital ? AppColor.SUCCESS_COLOR : AppColor.TYPE_DISABLE,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal
                          ),
                        )
                      ],
                    ),
                  ),
                  //Lower letter
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 28.0, vertical: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        isContainLower
                            ? Container(
                          height: 32.0,
                          width: 32.0,
                          decoration: BoxDecoration(
                            color: AppColor.SUCCESS_COLOR,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.done,
                            size: 24.0,
                            color: AppColor.WHITE_COLOR,
                          ),
                        )
                            : Container(
                          height: 32.0,
                          width: 32.0,
                          decoration: BoxDecoration(
                            color: AppColor.GREY_COLOR,
                            shape: BoxShape.circle,
//                               border: Border.all(color: AppColor.TYPE_SECONDARY, width: 1.0)
                          ),
                          child: Icon(
                            Icons.done,
                            size: 24.0,
                            color: AppColor.WHITE_COLOR,
                          ),
                        ),

                        SizedBox(width: 16.0,),
                        // Text
                        Text(
                          'Contains a lower',
                          style: TextStyle(
                              fontSize: TextSize.subjectTitle,
                              fontFamily: "WorkSans",
                              color: isContainLower ? AppColor.SUCCESS_COLOR : AppColor.TYPE_DISABLE,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.normal
                          ),
                        )
                      ],
                    ),
                  ),
                  //Contains Number
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 28.0, vertical: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        isContainNumber
                            ? Container(
                          height: 32.0,
                          width: 32.0,
                          decoration: BoxDecoration(
                            color: AppColor.SUCCESS_COLOR,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.done,
                            size: 24.0,
                            color: AppColor.WHITE_COLOR,
                          ),
                        )
                            : Container(
                          height: 32.0,
                          width: 32.0,
                          decoration: BoxDecoration(
                            color: AppColor.GREY_COLOR,
                            shape: BoxShape.circle,
//                               border: Border.all(color: AppColor.TYPE_SECONDARY, width: 1.0)
                          ),
                          child: Icon(
                            Icons.done,
                            size: 24.0,
                            color: AppColor.WHITE_COLOR,
                          ),
                        ),

                        SizedBox(width: 16.0,),
                        // Text
                        Text(
                          'Contains a number',
                          style: TextStyle(
                              fontSize: TextSize.subjectTitle,
                              fontFamily: "WorkSans",
                              color: isContainNumber ? AppColor.SUCCESS_COLOR : AppColor.TYPE_DISABLE,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.normal
                          ),
                        )
                      ],
                    ),
                  ),
                  //Contains Symbol
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 28.0, vertical: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        isContainSymbol
                            ? Container(
                          height: 32.0,
                          width: 32.0,
                          decoration: BoxDecoration(
                            color: AppColor.SUCCESS_COLOR,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.done,
                            size: 24.0,
                            color: AppColor.WHITE_COLOR,
                          ),
                        )
                            : Container(
                          height: 32.0,
                          width: 32.0,
                          decoration: BoxDecoration(
                            color: AppColor.GREY_COLOR,
                            shape: BoxShape.circle,
//                               border: Border.all(color: AppColor.TYPE_SECONDARY, width: 1.0)
                          ),
                          child: Icon(
                            Icons.done,
                            size: 24.0,
                            color: AppColor.WHITE_COLOR,
                          ),
                        ),

                        SizedBox(width: 16.0,),
                        // Text
                        Text(
                          'Contains a symbol',
                          style: TextStyle(
                              fontSize: TextSize.subjectTitle,
                              fontFamily: "WorkSans",
                              color: isContainSymbol ? AppColor.SUCCESS_COLOR : AppColor.TYPE_DISABLE,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.normal
                          ),
                        )
                      ],
                    ),
                  ),
                  //Contains 8 characters
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 28.0, vertical: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        isContainEight
                        ? Container(
                          height: 32.0,
                          width: 32.0,
                          decoration: BoxDecoration(
                            color: AppColor.SUCCESS_COLOR,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.done,
                            size: 24.0,
                            color: AppColor.WHITE_COLOR,
                          ),
                        )
                            : Container(
                          height: 32.0,
                          width: 32.0,
                          decoration: BoxDecoration(
                            color: AppColor.GREY_COLOR,
                            shape: BoxShape.circle,
//                               border: Border.all(color: AppColor.TYPE_SECONDARY, width: 1.0)
                          ),
                          child: Icon(
                            Icons.done,
                            size: 24.0,
                            color: AppColor.WHITE_COLOR,
                          ),
                        ),

                        SizedBox(width: 16.0,),
                        // Text
                        Text(
                          'At least 8 characters',
                          style: TextStyle(
                              fontSize: TextSize.subjectTitle,
                              fontFamily: "WorkSans",
                              color: isContainEight ? AppColor.SUCCESS_COLOR : AppColor.TYPE_DISABLE,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.normal
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
          ),

          //Submit Button
          Positioned(
            bottom: 32.0,
            left: 20.0,
            right: 20.0,
            child: InkWell(
              onTap: (){
                  if (_formKey.currentState.validate() && _allFieldValidate) {
                    //    If all data are correct then save data to out variables
                    _formKey.currentState.save();
                    if(widget.type == 'register'){
                      resetPassword();
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ResetPasswordSuccessPage()
                          )
                      );
                    }
                  }
                  else {
                    //    If all data are not valid then start auto validation.
                    setState(() {
                      newPasswordFocus.requestFocus(FocusNode());
                    });
                  }
              },
              child: Container(
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

          _progressHUD
        ],
      ),
    );
  }

  String validatePassword(String value) {
    if(value!='' && value!=null) {
      if(!value.startsWith(' '))
        return null;
      else
        return 'Enter your valid password';
    }
    else {
      return 'Enter your password';
    }
  }

  bool checkValidation(String patternType, String value) {
    Pattern pattern = '$patternType';
    RegExp regex = new RegExp(pattern);
    if(value != '') {
      return regex.hasMatch(value);
    } else{
      return false;
    }
  }

  Future<void> resetPassword() async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());

    var requestJson = {
      "password": "${newPasswordController.text.toString().trim()}"
    };
    var requestParam = json.encode(requestJson);
    var  response = await request.postRequest("auth/me/setPassword", requestParam);
    _progressHUD.state.dismiss();

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        HelperClass.showSnackBar(context, '${response['reason']}');
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage1(),
          ),
          ModalRoute.withName(LoginPage1.tag),
        );
      }
    }
  }
}
