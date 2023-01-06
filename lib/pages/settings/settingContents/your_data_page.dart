import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/custom_toast.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:dottie_inspector/widget/custom_switch.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_hud/progress_hud.dart';

class YourDataPage extends StatefulWidget {
  @override
  _YourDataPageState createState() => _YourDataPageState();
}

class _YourDataPageState extends State<YourDataPage> {

  bool isSellInformation = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;

  // final MyConnectivity _connectivity = MyConnectivity.instance;
  bool _isInternetAvailable = true;
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  bool isDarkMode = false;
  Color themeColor = AppColor.BLACK_COLOR;

  @override
  void initState() {
    // WidgetsBinding.instance.addPostFrameCallback((_)=> getSellInformationData);
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
    initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    // Timer(Duration(milliseconds: 100), getSellInformationData);
    // getSellInformationData();
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
  void dispose() {
    // TODO: implement dispose
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      log('Couldn\'t check connectivity status', error: e);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectivityResult = result;
      log("Connection====$_connectivityResult");
      setState(() {
        if(_connectivityResult == ConnectivityResult.none) {
          print("No Internet found");
          _isInternetAvailable = false;
        } else if(_connectivityResult == ConnectivityResult.mobile) {
          print("Mobile");
          _isInternetAvailable = true;
          getSellInformationData();
        } else if(_connectivityResult == ConnectivityResult.wifi) {
          print("WIFI");
          _isInternetAvailable = true;
          getSellInformationData();
        }
      });
    });
  }

  void getSellInformationData() async {
    var subscriptionData = await PreferenceHelper.getSellInformationData(PreferenceHelper.SELL_INFORMATION);
    log("$subscriptionData");
    setState(() {
      isSellInformation = subscriptionData ?? false;
      log("$isSellInformation");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? AppColor.BLACK_COLOR : AppColor.PAGE_COLOR,
      appBar: EmptyAppBar(isDarkMode: isDarkMode),
      // appBar: AppBar(
      //   centerTitle: true,
      //   elevation: 0.0,
      //   backgroundColor: AppColor.PAGE_COLOR,
      //   leading: GestureDetector(
      //     onTap: () {
      //       Navigator.pop(context);
      //     },
      //     splashColor: Colors.transparent,
      //     highlightColor: Colors.transparent,
      //     child: Icon(
      //       Icons.keyboard_backspace,
      //       color: AppColor.TYPE_PRIMARY,
      //       size: 32.0,
      //     ),
      //   ),
      //   title: Text(
      //     'My Data',
      //     style: TextStyle(
      //         color: AppColor.TYPE_PRIMARY,
      //         fontSize: TextSize.headerText,
      //         fontWeight: FontWeight.w600
      //     ),
      //   ),
      // ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GestureDetector(
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
                            'My Data',
                            style: TextStyle(
                                color: themeColor,
                                fontSize: TextSize.greetingTitleText,
                                fontWeight: FontWeight.w700
                            ),
                          ),
                        ),

                        SizedBox(height: 16,),

                        Text.rich(
                          TextSpan(
                            text: "For California Residents only.",
                            style: TextStyle(
                                color: themeColor,
                                fontSize: TextSize.subjectTitle,
                                fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                            children: [
                              TextSpan(
                                text: " Pursuant to the California Consumer Privacy Act (CCPA).",
                                style: TextStyle(
                                    color: themeColor,
                                    fontSize: TextSize.subjectTitle,
                                    fontWeight: FontWeight.w500,
                                  height: 1.3,
                                ),
                              )
                            ]
                          ),
                            textAlign: TextAlign.justify,
                        ),


                        SizedBox(
                          height: 16.0,
                        ),

                        Text.rich(
                          TextSpan(
                            text: 'This option stops the sharing of personal information with third parties for only this app on this device. To learn more about how your data is hared and for more options, please visit the ',
                            style: TextStyle(
                              color: themeColor,
                              fontSize: TextSize.subjectTitle,
                              fontWeight: FontWeight.w700,
                              height: 1.5
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Privacy Policy.',
                                style: TextStyle(
                                  // color: AppColor.THEME_PRIMARY,
                                  fontSize: TextSize.subjectTitle,
                                  fontWeight: FontWeight.w700,
                                  height: 1.5,
                                  foreground: Paint()..shader = linearGradient
                                ),
                                recognizer: TapGestureRecognizer()..onTap = (){
                                  HelperClass.launchURL("https://dev.inspectordottie.com/Privacy-Policy");
                                }
                              )
                            ]
                          ),
                          textAlign: TextAlign.justify,
                        ),

                        //Toggle
                        Container(
                          margin: EdgeInsets.only(top: 32.0,),
                          padding: EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Color(0xff1F1F1F)
                                : AppColor.WHITE_COLOR,
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(right: 16.0),
                                  child: Text(
                                    'Do not sell my personal information',
                                    style: TextStyle(
                                        color: themeColor,
                                        fontSize: TextSize.headerText,
                                        fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              CustomSwitch(
                                value: isSellInformation,
                                onChanged: (newValue) async {
                                  updateInformationNotSell(newValue);
                                },
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          _progressHUD
        ],
      ),
    );
  }

  final Shader linearGradient = LinearGradient(
    colors: AppColor.gradientColor(1.0),
  ).createShader(Rect.fromLTWH(0.0, 0.0, 111.0, 30.0));

  void updateInformationNotSell(newValue) async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    // var requestJson = {"password": "${_confirmPasswordController.text.toString().trim()}"};

    var requestJson = {
      "preferences": {
        "DoNotSell": newValue
      }
    };
    log("RequestJson===$requestJson");

    var requestParam = json.encode(requestJson);
    var response = await request.patchRequest("auth/admin/setCompanyPrefs", requestParam);
    _progressHUD.state.dismiss();

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage('${response['reason']}');
      } else {
        CustomToast.showToastMessage('Do Not Sell preferences saved');
        setState(() {
          isSellInformation = newValue;
          PreferenceHelper.setSellInformationData(PreferenceHelper.SELL_INFORMATION, isSellInformation);
        });
        // Navigator.pop(context);
      }
    }
  }

}
