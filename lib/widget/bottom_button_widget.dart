import 'dart:convert';
import 'dart:developer';

import 'package:dottie_inspector/database/database_helper.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:flutter/material.dart';

class BottomButtonWidget extends StatefulWidget {
  final VoidCallback onBackButton;
  final VoidCallback onNextButton;
  final bool isActive;
  final String buttonName;

  const BottomButtonWidget({Key key, this.onBackButton, this.onNextButton, this.isActive, this.buttonName}) : super(key: key);

  @override
  _BottomButtonWidgetState createState() => _BottomButtonWidgetState();
}

class _BottomButtonWidgetState extends State<BottomButtonWidget> {

  bool isDarkMode = false;
  Color themeColor = AppColor.BLACK_COLOR;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getThemeData();
  }

  void getThemeData() async {
    await PreferenceHelper.getPreferenceData(PreferenceHelper.THEME_MODE).then((value){
      setState(() {
        var themeMode = value == null ? "" : value;
        log("ThemeData===$themeMode");
        if(themeMode == "auto") {
          var brightness = MediaQuery.of(context).platformBrightness;
          themeMode = Brightness.dark ==  brightness ? "dark" : "light";
        }
        isDarkMode = themeMode == "dark";
        themeColor = isDarkMode ? AppColor.WHITE_COLOR : AppColor.BLACK_COLOR;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
//      color: Color(0xffF8F6F4).withOpacity(0.60),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
          ? [Colors.transparent, Colors.transparent]
          : [Color(0xffF8F6F4).withOpacity(0.0), Color(0xffF8F6F4).withOpacity(0.20),]
        )
      ),
      child: Container(
        height: 64.0,
        margin: EdgeInsets.only(left: 48.0, right: 48.0, bottom: 34.0, top: 12.0),
        decoration: BoxDecoration(
            color: isDarkMode
                ? Color(0xff333333)
                : AppColor.BLACK_COLOR,
            borderRadius: BorderRadius.all(Radius.circular(32.0))
            /*boxShadow: [
              BoxShadow(
                  blurRadius: 24.0,
                  offset: Offset(0.0,0),
                  color: Colors.grey[400]
              )
            ]*/
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: (){
                  /*Navigator.pushReplacement(
                                context,
                                SlideLeftRoute(
                                    page: ValvesGeneralPage()
                                )
                            );*/
//                Navigator.pop(context);
                  widget.onBackButton();
                },
                child: Container(
                  margin: EdgeInsets.only(left: 24.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Back',
                    style: TextStyle(
                      color: AppColor.WHITE_COLOR,
                      fontSize: TextSize.subjectTitle,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.normal,
//                      height: 20.0
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  widget.onNextButton();
                },
                child: Container(
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 24.0),
                  child: Text(
                    widget.buttonName != null ? widget.buttonName : 'Next',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: widget.isActive
                          ? AppColor.WHITE_COLOR
                          : AppColor.WHITE_COLOR.withOpacity(0.24),
                      fontSize: TextSize.subjectTitle,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.normal,
//                      height: 20.0
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
//    return Container(
//      padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0, top: 12.0),
//      decoration: BoxDecoration(
//          color: widget.isActive ? AppColor.WHITE_COLOR : AppColor.TRANSPARENT,
//          /*boxShadow: [
//            BoxShadow(
//                blurRadius: 24.0,
//                offset: Offset(0.0,0),
//                color: Colors.grey[400]
//            )
//          ]*/
//      ),
//      child: Row(
//        crossAxisAlignment: CrossAxisAlignment.center,
//        mainAxisAlignment: MainAxisAlignment.spaceBetween,
//        children: [
//          Expanded(
//            child: GestureDetector(
//              onTap: (){
//                /*Navigator.pushReplacement(
//                              context,
//                              SlideLeftRoute(
//                                  page: ValvesGeneralPage()
//                              )
//                          );*/
////                Navigator.pop(context);
//                widget.onBackButton();
//              },
//              child: Container(
//                height: 56.0,
//                decoration: BoxDecoration(
//                    color: AppColor.THEME_PRIMARY,
//                    borderRadius: BorderRadius.all(Radius.circular(16.0))
//                ),
//                child: Center(
//                  child: Text(
//                    'BACK',
//                    textAlign: TextAlign.center,
//                    style: TextStyle(
//                      color: AppColor.WHITE_COLOR,
//                      fontSize: TextSize.subjectTitle,
//                      fontWeight: FontWeight.w500,
//                      fontStyle: FontStyle.normal,
//                    ),
//                  ),
//                ),
//              ),
//            ),
//          ),
//          SizedBox(width: 8.0,),
//          Expanded(
//            child: GestureDetector(
//              onTap: (){
//                widget.onNextButton();
//              },
//              child: Container(
//                height: 56.0,
//                decoration: BoxDecoration(
//                    color: widget.isActive ? AppColor.THEME_PRIMARY : AppColor.TYPE_PRIMARY.withOpacity(0.08),
//                    borderRadius: BorderRadius.all(Radius.circular(16.0))
//                ),
//                child: Center(
//                  child: Text(
//                    'NEXT',
//                    textAlign: TextAlign.center,
//                    style: TextStyle(
//                      color: widget.isActive ? AppColor.WHITE_COLOR : AppColor.TYPE_PRIMARY.withOpacity(0.6),
//                      fontSize: TextSize.subjectTitle,
//                      fontWeight: FontWeight.w500,
//                      fontStyle: FontStyle.normal,
//                    ),
//                  ),
//                ),
//              ),
//            ),
//          ),
//        ],
//      ),
//    );
  }
}
