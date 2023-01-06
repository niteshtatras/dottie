import 'package:dottie_inspector/pages/signInPages/login_page_1.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/SlideRightRoute.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:dottie_inspector/widget/bottom_general_button_widget.dart';
import 'package:dottie_inspector/widget/custome_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DangerZoneDeleteConfirmScreen extends StatefulWidget {
  const DangerZoneDeleteConfirmScreen({Key key}) : super(key: key);

  @override
  _DangerZoneDeleteConfirmScreenState createState() => _DangerZoneDeleteConfirmScreenState();
}

class _DangerZoneDeleteConfirmScreenState extends State<DangerZoneDeleteConfirmScreen> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;

  bool isDarkMode = false;
  Color themeColor = AppColor.BLACK_COLOR;

  final _scrollController = ScrollController();
  var elevation = 0.0;

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

    _scrollController.addListener(() {
      setState(() {
        if(_scrollController.position.pixels > _scrollController.position.minScrollExtent){
          elevation = HelperClass.ELEVATION_1;
        } else {
          elevation = HelperClass.ELEVATION;
        }
      });
    });

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

  String getTitleData(int index) {
    switch(index) {
      case 0:
        return "Delete all your profile information";
      case 1:
        return "Subscription will be canceled";
      case 2:
        return "Delete inspections";
      case 3:
        return "Delete customers";
      default:
        return "Log you out on all devices";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
              Visibility(
                  visible: elevation != 0,
                  child: Divider(
                    height: 0.5,
                    thickness: 1,
                    color: isDarkMode ? AppColor.DIVIDER.withOpacity(0.4) : AppColor.DIVIDER,
                  )
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 10,),

                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'Deleting your account will do the following:',
                            style: TextStyle(
                                color: themeColor,
                                fontSize: TextSize.greetingTitleText,
                                fontWeight: FontWeight.w700,
                              height: 1.3
                            ),
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(top: 32),
                          child: ListView.builder(
                            itemCount: 5,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.only(bottom: 16),
                                padding: EdgeInsets.only(top: 24.0, bottom: 24, left: 16, right: 16),
                                decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? Color(0xff1F1F1F)
                                        : AppColor.WHITE_COLOR,
                                    borderRadius: BorderRadius.circular(32)
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                      },
                                      child: Container(
                                        height: 48.0,
                                        width: 48.0,
                                        child: Image.asset(
                                          'assets/boolean/ic_delete_close.png',
                                          height: 150,
                                          width: 150,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),

                                    SizedBox(width: 16,),
                                    Expanded(
                                      child: Text(
                                        '${getTitleData(index)}',
                                        style: TextStyle(
                                            color: themeColor,
                                            fontSize: TextSize.headerText,
                                            fontWeight: FontWeight.w700,
                                            height: 1.5
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        SizedBox(height: 120,)
                      ],
                    ),
                  ),
                ),
              )
            ]
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              child: InkWell(
                onTap: (){
                  showLoading(context);
                },
                child: Container(
                  height: 64.0,
                  margin: EdgeInsets.only(left: 48.0, right: 48.0, bottom: 34.0, top: 12.0),
                  decoration: BoxDecoration(
                      color: AppColor.RED_COLOR,
                      borderRadius: BorderRadius.all(Radius.circular(32.0))
                  ),
                  child: Center(
                    child: Text(
                      'Close Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColor.WHITE_COLOR,
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
          ),

          _progressHUD
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
                           deleteAccount();
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
        PreferenceHelper.clearPreferenceData(PreferenceHelper.WATER_VESSEL_BODIES);
        PreferenceHelper.clearPreferenceData(PreferenceHelper.WATER_VESSEL_BODIES_ITEM);
        PreferenceHelper.clearPreferenceData(PreferenceHelper.WATER_SELECTED_BODIES);
        PreferenceHelper.clearPreferenceData(PreferenceHelper.EQUIPMENT_ITEMS);
        PreferenceHelper.clearPreferenceData(PreferenceHelper.ANSWER_LIST);
        PreferenceHelper.clearPreferenceData(PreferenceHelper.TEMPLATE_LIST);
        PreferenceHelper.clearPreferenceData(PreferenceHelper.LANGUAGE);
        PreferenceHelper.clearPreferenceData(PreferenceHelper.DATE_FORMAT);
        PreferenceHelper.clearPreferenceData(PreferenceHelper.TIME_FORMAT);
        PreferenceHelper.clearPreferenceData(PreferenceHelper.BUSINESS_HOUR);
        PreferenceHelper.clearPreferenceData(PreferenceHelper.ROLES);
        PreferenceHelper.clearUserPreferenceData(context);

        Navigator.pop(context);
        Navigator.pushAndRemoveUntil(
            context,
            SlideRightRoute(
                page: LoginPage1()
            ),
            ModalRoute.withName(LoginPage1.tag)
        );
      }
    } else {
      HelperClass.showSnackBar(context, 'Something Went Wrong!');
    }
  }
}
