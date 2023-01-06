import 'dart:developer';

import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:flutter/material.dart';

class BottomGeneralDarkButton extends StatefulWidget {
  final VoidCallback onStartButton;
  final String buttonName;
  final bool isActive;
  final bool isDarkMode;

  const BottomGeneralDarkButton({Key key, this.onStartButton, this.buttonName, this.isActive, this.isDarkMode}) : super(key: key);

  @override
  _BottomGeneralDarkButtonState createState() => _BottomGeneralDarkButtonState();
}

class _BottomGeneralDarkButtonState extends State<BottomGeneralDarkButton> {
  bool isActive = true;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();

    print("Before isDarkMode===${widget.isDarkMode}");
    isActive = widget.isActive ?? true;
    isDarkMode = widget.isDarkMode ?? false;

    // getPreferenceData();
  }

  // void getPreferenceData() async {
  //   await PreferenceHelper.getPreferenceData(PreferenceHelper.THEME_MODE).then((value){
  //     setState(() {
  //       var themeMode = value == null ? "" : value;
  //       isDarkMode = themeMode != "dark";
  //     });
  //   });
  //
  //   log("isDarkMode===$isDarkMode");
  // }

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
          child: isDarkMode
          ? Container(
            height: 64.0,
            margin: EdgeInsets.only(left: 48.0, right: 48.0, bottom: 34.0, top: 12.0),
            decoration: BoxDecoration(
                color: isActive
                    ? AppColor.WHITE_COLOR
                    : Color(0xff333333),
              borderRadius: BorderRadius.all(Radius.circular(32.0))
            ),
            child: Center(
              child: Text(
                '${widget.buttonName}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isActive
                      ? AppColor.BLACK_COLOR
                      : Color(0xff545454),
                  fontSize: TextSize.subjectTitle,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.normal,
//                  height: 20.0
                ),
              ),
            ),
          )
          : Container(
            height: 64.0,
            margin: EdgeInsets.only(left: 48.0, right: 48.0, bottom: 34.0, top: 12.0),
            decoration: BoxDecoration(
                color: isActive
                    ? AppColor.BLACK_COLOR
                    : AppColor.DIVIDER,
                borderRadius: BorderRadius.all(Radius.circular(32.0))
            ),
            child: Center(
              child: Text(
                '${widget.buttonName}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isActive
                      ? AppColor.WHITE_COLOR
                      : Color(0xff808080),
                  fontSize: TextSize.subjectTitle,
                  fontWeight: FontWeight.w700,
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
