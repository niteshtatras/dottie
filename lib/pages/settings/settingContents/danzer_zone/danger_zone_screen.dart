import 'package:dottie_inspector/pages/settings/settingContents/danzer_zone/danger_zone_delete_condition.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/SlideRightRoute.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:dottie_inspector/widget/custome_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DangerZonePage extends StatefulWidget {
  const DangerZonePage({Key key}) : super(key: key);

  @override
  _DangerZonePageState createState() => _DangerZonePageState();
}

class _DangerZonePageState extends State<DangerZonePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;
  bool isDarkMode = false;
  Color themeColor = AppColor.BLACK_COLOR;

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
                            'Danger Zone',
                            style: TextStyle(
                                color: themeColor,
                                fontSize: TextSize.greetingTitleText,
                                fontWeight: FontWeight.w700
                            ),
                          ),
                        ),

                        SizedBox(height: 16,),

                        Text(
                          'Deleting your account will delete all of your inspections, photos, and customers. This action can’t be reversed. Requires password.',
                          style: TextStyle(
                              color: themeColor,
                              fontSize: TextSize.subjectTitle,
                              fontWeight: FontWeight.w600,
                              height: 1.5
                          ),
                          textAlign: TextAlign.start,
                        ),

                        SizedBox(
                          height: 8.0,
                        ),

                        InkWell(
                          onTap: (){
                            showLoading(context);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: 180,
                            height: 56,
                            margin: EdgeInsets.symmetric(vertical: 32.0),
                            padding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 30),
                            decoration: BoxDecoration(
                              color: Color(0xffF6E6E4),
                              borderRadius: BorderRadius.circular(32.0),
                            ),
                            child: Text(
                              'Delete Account',
                              style: TextStyle(
                                color: AppColor.RED_COLOR,
                                fontSize: TextSize.subjectTitle,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  void showLoading(context) {
    print("show loading call");
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: isDarkMode ? Color(0xff000000).withOpacity(0.8) : Color(0xff000000).withOpacity(0.5),
      builder: (BuildContext loadingContext) {
        return Container(
          height: 500,
          margin: EdgeInsets.only(top: 50, bottom: 30),
          child: Dialog(
            backgroundColor: isDarkMode ? Color(0xffF2F2F2).withOpacity(0.8) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32)),
            ),
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Text(
                    'Are you sure?',
                    style: TextStyle(
                        fontSize: TextSize.headerText,
                        color: AppColor.BLACK_COLOR,
                        fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                  child: Text(
                    'You are about to delete you account. This action will delete all of your inspections, photos, and customers. This action can\'t be reversed.',
                    style: TextStyle(
                        fontSize: 15,
                        color: AppColor.BLACK_COLOR,
                        fontWeight: FontWeight.w400,
                        height: 1.5
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 16,),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xC7252525),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 44.0,
                            alignment: Alignment.center,
                            child: Text(
                              'CANCEL',
                              style: TextStyle(
                                fontSize: 17,
                                color: AppColor.RED_COLOR,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 44,
                        child: VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: Color(0xC7252525),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: (){
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                SlideRightRoute(
                                    page: DangerZoneDeleteSelection()
                                )
                            );
                          },
                          child: Container(
                            height: 44.0,
                            alignment: Alignment.center,
                            child: Text(
                              'DELETE',
                              style: TextStyle(
                                fontSize: 17,
                                color: AppColor.RED_COLOR,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> deleteAccount() async {
    var  response = await request.deleteAuthRequest("auth/myteam");

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        HelperClass.showSnackBar(context, '${response['reason']}');
      } else {
        Navigator.pop(context);
      }
    } else {
      HelperClass.showSnackBar(context, 'Something Went Wrong!');
    }
  }
}
