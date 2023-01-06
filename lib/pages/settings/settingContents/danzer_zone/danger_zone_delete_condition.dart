import 'package:dottie_inspector/pages/settings/settingContents/danzer_zone/danger_zone_delete_confirm_screen.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/SlideRightRoute.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:dottie_inspector/widget/bottom_general_button_widget.dart';
import 'package:dottie_inspector/widget/bottom_general_dark_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DangerZoneDeleteSelection extends StatefulWidget {
  const DangerZoneDeleteSelection({Key key}) : super(key: key);

  @override
  _DangerZoneDeleteSelectionState createState() => _DangerZoneDeleteSelectionState();
}

class _DangerZoneDeleteSelectionState extends State<DangerZoneDeleteSelection> {
  List deleteOptionList = [];
  bool isDarkMode = false;
  Color themeColor = AppColor.BLACK_COLOR;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setData();
    getPreferenceData();
  }

  void getPreferenceData() async {
    await PreferenceHelper.getPreferenceData(PreferenceHelper.THEME_MODE).then((value){
      setState(() {
        var themeMode = value == null ? "" : value;
        if(themeMode == "auto") {
          var brightness = MediaQuery.of(context).platformBrightness;
          themeMode = Brightness.dark ==  brightness ? "dark" : "light";
        }
        isDarkMode = themeMode == "dark";
        themeColor = isDarkMode ? AppColor.WHITE_COLOR : AppColor.BLACK_COLOR;

        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: isDarkMode ? Colors.black : AppColor.THEME_PRIMARY.withOpacity(0.4),
          statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        ));
      });
    });
  }

  void setData() {
    for(int i=0; i<4; i++){
      deleteOptionList.add({
        "title": getTitleData(i),
        "isSelected" : false
      });
    }
  }

  String getTitleData(int index) {
    switch(index) {
      case 0:
        return "I’m no longer in need of my account";
      case 1:
        return "It’s too expensive";
      case 2:
        return "I’m switching to someone else";
      default:
        return "Other";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? AppColor.BLACK_COLOR : AppColor.PAGE_COLOR,
      appBar: EmptyAppBar(isDarkMode: isDarkMode),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        child: Image.asset(
                          isDarkMode
                              ? 'assets/ic_dark_back_button.png'
                              : 'assets/ic_close_button.png',
                          fit: BoxFit.cover,
                          width: 48,
                          height: 48,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 10,),

                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 0),
                          child: Text(
                            'We’re sad to see you go',
                            style: TextStyle(
                                color: themeColor,
                                fontSize: TextSize.greetingTitleText,
                                fontWeight: FontWeight.w700,
                              height: 1.3
                            ),
                          ),
                        ),

                        SizedBox(height: 16,),

                        Text(
                          'Before you go, let us know how we can improve. What is the primary reason you’re closing your account?',
                          style: TextStyle(
                              color: themeColor,
                              fontSize: TextSize.subjectTitle,
                              fontWeight: FontWeight.w600,
                              height: 1.5
                          ),
                          textAlign: TextAlign.start,
                        ),

                        Container(
                          margin: EdgeInsets.only(top: 32),
                          decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Color(0xff1F1F1F)
                                  : AppColor.WHITE_COLOR,
                            borderRadius: BorderRadius.circular(32)
                          ),
                          child: ListView.builder(
                            itemCount: deleteOptionList.length,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(top: 24.0, bottom: 24, left: 16, right: 16),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${deleteOptionList[index]['title']}',
                                            style: TextStyle(
                                                color: themeColor,
                                                fontSize: TextSize.headerText,
                                                fontWeight: FontWeight.w700,
                                                height: 1.5
                                            ),
                                            textAlign: TextAlign.start,
                                          ),
                                        ),

                                        SizedBox(width: 16,),

                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              deleteOptionList[index]['isSelected'] = !deleteOptionList[index]['isSelected'];
                                            });
                                          },
                                          child: Container(
                                            height: 24.0,
                                            width: 24.0,
                                            child: Image.asset(
                                              deleteOptionList[index]['isSelected']
                                                  ? 'assets/boolean/ic_check_yes.png'
                                                  : 'assets/boolean/ic_check_no.png',
                                              height: 24,
                                              width: 24,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),

                                      ],
                                    ),
                                  ),
                                  index == deleteOptionList.length - 1
                                  ? Container()
                                  : Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: isDarkMode ? AppColor.DIVIDER.withOpacity(0.4) : AppColor.DIVIDER,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ]
          ),

          BottomGeneralButton(
            buttonName: "Continue",
            isActive: true,
            onStartButton: (){
              Navigator.push(
                context,
                SlideRightRoute(
                  page: DangerZoneDeleteConfirmScreen()
                )
              );
            },
          )
        ],
      ),
    );
  }
}
