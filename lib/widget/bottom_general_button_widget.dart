import 'dart:developer';

import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:flutter/material.dart';

class BottomGeneralButton extends StatefulWidget {
  final VoidCallback onStartButton;
  final String buttonName;
  final bool isActive;

  const BottomGeneralButton({Key key, this.onStartButton, this.buttonName, this.isActive}) : super(key: key);

  @override
  _BottomGeneralButtonState createState() => _BottomGeneralButtonState();
}

class _BottomGeneralButtonState extends State<BottomGeneralButton> {
  bool isActive = true;
  bool isDarkMode = false;
  Color themeColor = AppColor.BLACK_COLOR;

  @override
  void initState() {
    super.initState();

    isActive = widget.isActive ?? true;
    print("IsActive===$isActive");
    print("IsActive1===${widget.isActive}");
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
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        child: GestureDetector(
          onTap: (){
            widget.onStartButton();
          },
          child: Container(
            height: 64.0,
            margin: EdgeInsets.only(left: 48.0, right: 48.0, bottom: 34.0, top: 12.0),
            decoration: BoxDecoration(
                color: isDarkMode
                  ? widget.isActive
                    ? Colors.white
                    : Color(0xff333333)
                :  widget.isActive
                  ? AppColor.BLACK_COLOR
                  : AppColor.DIVIDER,
                borderRadius: BorderRadius.all(Radius.circular(32.0))
            ),
            child: Center(
              child: Text(
                '${widget.buttonName}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode
                    ? widget.isActive
                      ? AppColor.BLACK_COLOR
                      : Color(0xff545454)
                    : widget.isActive
                      ? AppColor.WHITE_COLOR
                      : Color(0xff808080),
//                  color: AppColor.WHITE_COLOR,
                  fontSize: TextSize.subjectTitle,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
//                  height: 20.0
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
