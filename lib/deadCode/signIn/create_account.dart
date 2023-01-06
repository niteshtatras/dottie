import 'package:dottie_inspector/pages/settings/setting_page.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateAccountPage extends StatefulWidget {
  static String tag = 'create-account-page';

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EmptyAppBar(isDarkMode: false),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              //App Bar
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 16.0),
                height: 64.0,
                child: InkWell(
                  onTap: () {
                  Navigator.pop(context);
                },
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Icon(
                    Icons.keyboard_backspace,
                    color: AppColor.BLACK_COLOR,
                    size: 32.0,
                  ),
                ),
              ),

              //MainBody
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Create\nyour account',
                      style: TextStyle(
                        color: AppColor.TYPE_PRIMARY,
                        fontSize: TextSize.greetingTitleText,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                    //First Name
                    Container(
                      margin: EdgeInsets.only(top: 32.0),
                      child:TextFormField(
                        controller: null,
                        focusNode: null,
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                          fillColor: AppColor.BG_PRIMARY_ALT,
                          hintText: "First Name",
                          contentPadding: EdgeInsets.symmetric(horizontal: 0.0,),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            borderSide: BorderSide(width: 1,color: AppColor.THEME_PRIMARY),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            borderSide: BorderSide(width: 1,color: AppColor.DIVIDER),
                          ),
                          labelText: 'First Name',
                          hintStyle: TextStyle(
                            fontSize: TextSize.bodyText,
                            color: AppColor.TYPE_SECONDARY
                          )
                        ),
                        style: TextStyle(
                          color: AppColor.TYPE_PRIMARY,
                          fontWeight: FontWeight.w400,
                          fontSize: TextSize.subjectTitle
                        ),
                        inputFormatters: [LengthLimitingTextInputFormatter(40)],
                      ),
                    ),
                    //Last Name
                    Container(
                      margin: EdgeInsets.only(top: 24.0),
                      child:TextFormField(
                        controller: null,
                        focusNode: null,
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                            fillColor: AppColor.BG_PRIMARY_ALT,
                            hintText: "Last Name",
                            contentPadding: EdgeInsets.symmetric(horizontal: 0.0,),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(4)),
                              borderSide: BorderSide(width: 1,color: AppColor.THEME_PRIMARY),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(4)),
                              borderSide: BorderSide(width: 1,color: AppColor.DIVIDER),
                            ),
                            labelText: 'Last Name',
                            hintStyle: TextStyle(
                                fontSize: TextSize.bodyText,
                                color: AppColor.TYPE_SECONDARY
                            )
                        ),
                        style: TextStyle(
                            color: AppColor.TYPE_PRIMARY,
                            fontWeight: FontWeight.w400,
                            fontSize: TextSize.subjectTitle
                        ),
                        inputFormatters: [LengthLimitingTextInputFormatter(40)],
                      ),
                    ),
                    //Email Address
                    Container(
                      margin: EdgeInsets.only(top: 32.0),
                      child:TextFormField(
                        controller: null,
                        focusNode: null,
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                            fillColor: AppColor.BG_PRIMARY_ALT,
                            hintText: "Email address",
                            contentPadding: EdgeInsets.symmetric(horizontal: 0.0,),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(4)),
                              borderSide: BorderSide(width: 1,color: AppColor.THEME_PRIMARY),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(4)),
                              borderSide: BorderSide(width: 1,color: AppColor.DIVIDER),
                            ),
                            labelText: 'Email address',
                            hintStyle: TextStyle(
                                fontSize: TextSize.bodyText,
                                color: AppColor.TYPE_SECONDARY
                            )
                        ),
                        style: TextStyle(
                            color: AppColor.TYPE_PRIMARY,
                            fontWeight: FontWeight.w400,
                            fontSize: TextSize.subjectTitle
                        ),
                        inputFormatters: [LengthLimitingTextInputFormatter(40)],
                      ),
                    ),
                    //Password
                    Container(
                      margin: EdgeInsets.only(top: 32.0),
                      child:TextFormField(
                        controller: null,
                        focusNode: null,
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                            fillColor: AppColor.BG_PRIMARY_ALT,
                            hintText: "Password",
                            contentPadding: EdgeInsets.symmetric(horizontal: 0.0,),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(4)),
                              borderSide: BorderSide(width: 1,color: AppColor.THEME_PRIMARY),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(4)),
                              borderSide: BorderSide(width: 1,color: AppColor.DIVIDER),
                            ),
                            labelText: 'Password',
                            hintStyle: TextStyle(
                                fontSize: TextSize.bodyText,
                                color: AppColor.TYPE_SECONDARY
                            )
                        ),
                        style: TextStyle(
                            color: AppColor.TYPE_PRIMARY,
                            fontWeight: FontWeight.w400,
                            fontSize: TextSize.subjectTitle
                        ),
                        inputFormatters: [LengthLimitingTextInputFormatter(40)],
                      ),
                    ),
                    //Confirm Password
                    Container(
                      margin: EdgeInsets.only(top: 32.0),
                      child:TextFormField(
                        controller: null,
                        focusNode: null,
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                            fillColor: AppColor.BG_PRIMARY_ALT,
                            hintText: "Confirm Password",
                            contentPadding: EdgeInsets.symmetric(horizontal: 0.0,),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(4)),
                              borderSide: BorderSide(width: 1,color: AppColor.THEME_PRIMARY),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(4)),
                              borderSide: BorderSide(width: 1,color: AppColor.DIVIDER),
                            ),
                            labelText: 'Confirm Password',
                            hintStyle: TextStyle(
                                fontSize: TextSize.bodyText,
                                color: AppColor.TYPE_SECONDARY
                            )
                        ),
                        style: TextStyle(
                            color: AppColor.TYPE_PRIMARY,
                            fontWeight: FontWeight.w400,
                            fontSize: TextSize.subjectTitle
                        ),
                        inputFormatters: [LengthLimitingTextInputFormatter(40)],
                      ),
                    ),

                    //Submit Button
                    InkWell(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingPage()
                          )
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 24.0),
                        height: 56.0,
                        decoration: BoxDecoration(
                            color: AppColor.THEME_PRIMARY,
                            borderRadius: BorderRadius.all(Radius.circular(4.0))
                        ),
                        child: Center(
                          child: Text(
                            'Sign Up',
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

                    //Agree content
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(top: 30.0),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: "I agree to",
                              style: TextStyle(
                                fontSize: TextSize.bodyText,
                                color: AppColor.TYPE_PRIMARY,
                                fontWeight: FontWeight.w400,
                                height: 1.3
                              ),
                            ),
                            TextSpan(
                              text: " terms & conditions ",
                              style: TextStyle(
                                  fontSize: TextSize.bodyText,
                                  color: AppColor.THEME_PRIMARY,
                                  fontWeight: FontWeight.w400,
                                  height: 1.3
                              ),
                            ),
                            TextSpan(
                              text: "&\n",
                              style: TextStyle(
                                  fontSize: TextSize.bodyText,
                                  color: AppColor.TYPE_PRIMARY,
                                  fontWeight: FontWeight.w400,
                                  height: 1.3
                              ),
                            ),
                            TextSpan(
                              text: "privacy policy",
                              style: TextStyle(
                                  fontSize: TextSize.bodyText,
                                  color: AppColor.THEME_PRIMARY,
                                  fontWeight: FontWeight.w400,
                                  height: 1.3
                              ),
                            ),
                          ]
                        ),
                      )
                    ),
                    SizedBox(
                      height: 60.0,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
