
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dottie_inspector/connection_mixin.dart';
import 'package:dottie_inspector/database/database_helper.dart';
import 'package:dottie_inspector/main/welcome_intro_page.dart';
import 'package:dottie_inspector/pages/menu/drawer_page.dart';
import 'package:dottie_inspector/pages/settings/settingContents/business_hour.dart';
import 'package:dottie_inspector/pages/settings/settingContents/change_password.dart';
import 'package:dottie_inspector/pages/settings/settingContents/company_address_page.dart';
import 'package:dottie_inspector/pages/settings/settingContents/company_info_edit_page.dart';
import 'package:dottie_inspector/pages/settings/settingContents/danzer_zone/danger_zone_screen.dart';
import 'package:dottie_inspector/pages/settings/settingContents/profile_edit_page.dart';
import 'package:dottie_inspector/pages/settings/settingContents/setting_display_screen.dart';
import 'package:dottie_inspector/pages/settings/settingContents/your_data_page.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/SlideRightRoute.dart';
import 'package:dottie_inspector/utils/custom_toast.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/utils/language.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> with MyConnection{

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isToggleOn = false;
  int distanceType = 0;
  int volumeType = 0;
  var elevation = 0.0;
  final _scrollController = ScrollController();

  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;

  Map userData;
  Map companyData;
  var imagePath = '';
  var companyLogoPath = '';
  String lang = 'en';
  String productId = "";
  String versionCode = "";

  bool isRole = false;
  bool isDarkMode = false;
  Color themeColor = AppColor.BLACK_COLOR;

  // final MyConnectivity _connectivity = MyConnectivity.instance;
  bool _isInternetAvailable = true;
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  final dbHelper = DatabaseHelper.instance;

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  Future getImageFromCamera(type) async {
    var image1 = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image1 != null) {
      openCropImageOption(image1.path, type);
    }
  }

  void openCropImageOption(imagePath1, type) async {
    File croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath1,
        aspectRatioPresets: [
          CropAspectRatioPreset.square
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: lang == 'en' ? imageCropperEn : imageCropperEs,
            toolbarColor: isDarkMode ? Colors.black : AppColor.THEME_PRIMARY,
            toolbarWidgetColor: Colors.white,
            cropFrameColor: isDarkMode ? Colors.white : AppColor.BLACK_COLOR,
            cropFrameStrokeWidth: 2,
            hideBottomControls: true,
            statusBarColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.square,
            cropGridColor: isDarkMode ? Colors.black : AppColor.THEME_PRIMARY,
            backgroundColor: isDarkMode ? Colors.black : AppColor.PAGE_COLOR,
            showCropGrid: true,
            activeControlsWidgetColor: AppColor.THEME_PRIMARY,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        )
    );

    if(croppedFile != null) {
      File compressedFile = await HelperClass.getCompressedImageFile(croppedFile);
      setState(() {
        if(type == "profile")
          imagePath = compressedFile.path;
        else
          companyLogoPath = compressedFile.path;

        compressedFile = null;
      });

      uploadImageData(type);
    }

  }

  ImagePicker _imagePicker = ImagePicker();
  Future getImageFromGallery(type) async {
    var image1 = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image1 != null) {
      openCropImageOption(image1.path, type);
    }
  }

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

    getPackageInfo();
    getImageData();
    initConnectivity();
  }

  void getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      _packageInfo = packageInfo;
      versionCode = _packageInfo.version;
    });
    String appName = _packageInfo.appName;
    String packageName = _packageInfo.packageName;
    String version = _packageInfo.version;
    String buildNumber = _packageInfo.buildNumber;

    log("versionCode===$versionCode");
    log("appName===$appName\npackageName===$packageName\nversion====$version\nbuildNumber====$buildNumber");

  }

  @override
  void initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      log('Couldn\'t check connectivity status', error: e);
      return;
    }

    connectionSubscription();

    if (!mounted) {
      return Future.value(null);
    }

    return updateConnectionStatus(result);
  }

  @override
  void connectionSubscription() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      updateConnectionStatus(result);
    });
  }

  @override
  void updateConnectionStatus(result) {
    setState(() {
      _connectivityResult = result;
      if (_connectivityResult == ConnectivityResult.none) {
        _isInternetAvailable = false;
        log("InternetConnectionStatus====$_isInternetAvailable");

        companyDetailFromLocalDb();
      } else if ((_connectivityResult == ConnectivityResult.mobile) || (_connectivityResult == ConnectivityResult.wifi)) {
        _isInternetAvailable = true;
        log("InternetConnectionStatus====$_isInternetAvailable");
        getCompanyDetail();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void getImageData() async {
    productId = await PreferenceHelper.getPreferenceData(PreferenceHelper.PRODUCT_ID) ?? "";

    lang = await PreferenceHelper.getPreferenceData(PreferenceHelper.LANGUAGE) ?? "en";
    var imageData = await PreferenceHelper.getPreferenceData(PreferenceHelper.USER_AVATAR) ?? "";
    var firstName = await PreferenceHelper.getPreferenceData(PreferenceHelper.FIRST_NAME) ?? "";
    var lastName = await PreferenceHelper.getPreferenceData(PreferenceHelper.LAST_NAME) ?? "";
    var userName = await PreferenceHelper.getPreferenceData(PreferenceHelper.USER_NAME) ?? "";

    bool isRoleLoc = await PreferenceHelper.getRoleData() ?? false;

    var darkMode = await PreferenceHelper.getPreferenceData(PreferenceHelper.THEME_MODE) ?? "";
    print("Role===$isRoleLoc");
    setState(() {
      userData = {
        "username": "$userName",
        "firstname": "$firstName",
        "lastname": "$lastName",
        "avatar": "$imageData",
      };

      isRole = isRoleLoc;

      if(darkMode == "auto") {
        var brightness = MediaQuery.of(context).platformBrightness;
        darkMode = Brightness.dark ==  brightness ? "dark" : "light";
      }
      isDarkMode = darkMode == "dark";
      themeColor = isDarkMode ? AppColor.WHITE_COLOR : AppColor.BLACK_COLOR;

      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: isDarkMode ? Colors.black : AppColor.THEME_PRIMARY.withOpacity(0.4),
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
      ));

      Platform.isIOS
          ? isDarkMode
            ? SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark)
            : SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light)
          : SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? AppColor.BLACK_COLOR : AppColor.PAGE_COLOR,
      appBar: EmptyAppBar(isDarkMode: isDarkMode),
      key: _scaffoldKey,
      drawer: Drawer(
        child: DrawerPage(),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _scaffoldKey.currentState.openDrawer();
                      },
                      child: Container(
                        child: Image.asset(
                          'assets/ic_menu.png',
                          fit: BoxFit.cover,
                          color: themeColor,
                          width: 44,
                          height: 44,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: elevation != 0,
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        child: Text(
                          lang == 'en' ? 'Settings' : "Ajustes",
                          style: TextStyle(
                              color: themeColor,
                              fontSize: TextSize.headerText,
                              fontWeight: FontWeight.w600
                          ),
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
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[

                       /* Container(
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              CircleAvatar(
                                backgroundColor: AppColor.BG_SECONDARY_ALT,
                                child: Container(
                                  height: 100.0,
                                  width: 100.0,
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/profile_avatar.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                radius: 50.0,
                              ),

                              //Name of user
                              Container(
                                margin: EdgeInsets.only(top: 16.0,bottom: 40.0),
                                child: Text(
                                  'Bruce Wayne',
                                  style: TextStyle(
                                      color: AppColor.TYPE_PRIMARY,
                                      fontSize: TextSize.pageTitleText,
                                      fontWeight: FontWeight.w400
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
*/

                        SizedBox(height: 10,),

                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            lang == 'en' ? 'Settings' : "Ajustes",
                            style: TextStyle(
                                color: themeColor,
                                fontSize: TextSize.greetingTitleText,
                                fontWeight: FontWeight.w700
                            ),
                          ),
                        ),

                        /***
                         * Account info
                         */
                        getSettingTitleItem(lang == 'en' ? "Account" : "Cuenta"),

                        ///Profile Picture
                        getSettingItem(
                            lang == 'en' ? 'Profile Picture' : 'Foto de perfil',
                            "assets/settings/ic_setting_profile.png",
                            "assets/settings/ic_setting_forward.png", (){
                              bottomImagePicker(context);},
                          imageType: "profile"
                        ),

                        ///Profile Info
                        getSettingItem(
                            lang == 'en' ? "Profile Info" : "Información de perfil",
                            "assets/settings/ic_setting_profile_info.png",
                            "assets/settings/ic_setting_forward.png", (){

                              log("UserData===$userData");
                              Navigator.push(
                                context,
                                SlideRightRoute(
                                    page: ProfileInfoEditPage(
                                      userData: userData,
                                    )
                                )
                              ).then((result) {
                                log("Result===$result");
                                if(result != null) {
                                  setState(() {
                                    userData['firstname'] = '${result['userData']['firstname']}';
                                    userData['lastname'] = '${result['userData']['lastname']}';
                                  });
                                  PreferenceHelper.saveProfilePreferenceData(userData);
                                }
                              });
                        }),

                        ///Change Password
                        getSettingItem(
                            lang == 'en' ? "Change Password" : "Cambia la contraseña",
                            "assets/settings/ic_setting_change_password.png",
                            "assets/settings/ic_setting_forward.png", (){

                              Navigator.push(
                                context,
                                SlideRightRoute(
                                  page: ChangePasswordPage()
                                )
                              );
                        }),

                        ///Display
                        getSettingItem(
                            lang == 'en' ? "Display" : "Mostrar",
                            "assets/settings/ic_setting_display.png",
                            "assets/settings/ic_setting_forward.png", (){

                          Navigator.push(
                              context,
                              SlideRightRoute(
                                  page: SettingDisplayScreen()
                              )
                          ).then((value) async {
                            var language = await PreferenceHelper.getPreferenceData(PreferenceHelper.LANGUAGE) ?? "en";
                            var themeMode = await PreferenceHelper.getPreferenceData(PreferenceHelper.THEME_MODE) ?? "en";
                            setState(() {
                              lang = language;
                              if(themeMode == "auto") {
                                var brightness = MediaQuery.of(context).platformBrightness;
                                themeMode = Brightness.dark ==  brightness ? "dark" : "light";
                              }
                              isDarkMode = themeMode == "dark";
                              themeColor = isDarkMode ? AppColor.WHITE_COLOR : AppColor.BLACK_COLOR;
                            });
                          });
                        }),

                         ///My Data
                        getSettingItem(
                            lang == 'en' ? "My Data" : "Mis datos",
                            "assets/settings/ic_setting_my_data.png",
                            "assets/settings/ic_setting_forward.png", (){

                          Navigator.push(
                              context,
                              SlideRightRoute(
                                  page: YourDataPage()
                              )
                          );
                        }),

                         ///Danger Zone
                        isRole
                        ? getSettingItem(
                            lang == 'en' ? "Danger Zone" : "Zona peligrosa",
                            "assets/settings/ic_setting_danger_zone.png",
                            "assets/settings/ic_setting_forward.png", (){

                          Navigator.push(
                              context,
                              SlideRightRoute(
                                  page: DangerZonePage()
                              )
                          );
                        })
                        : Container(),

                        /****
                         * Subscription info
                         */


                        // getSettingTitleItem(lang == 'en' ? "Subscription" : "Suscripción",),
                        //
                        // getSubscriptionWidget(),


                        /***
                         * Company info
                         */
                        getSettingTitleItem(lang == 'en' ? "Company" : "Compañía"),

                        ///Company Logo
                        getSettingItem(
                            lang == 'en' ? "Company Logo" : "Logo de la compañía",
                            "assets/settings/ic_setting_company_logo.png",
                            "assets/settings/ic_setting_forward.png", (){
                            bottomCompanyImagePicker(context);},
                            imageType: "company"
                        ),

                         ///Company Info
                        getSettingItem(
                            lang == 'en' ? "Company Info" : "Información de la compañía",
                            "assets/settings/ic_setting_company_info.png",
                            "assets/settings/ic_setting_forward.png", (){

                              Navigator.push(
                                context,
                                SlideRightRoute(
                                  page: CompanyInfoEditPage(
                                    companyData: companyData
                                  )
                                )
                              ).then((result) {
                                if(result != null) {
                                  setState(() {
                                    companyData['companyname'] = "${result['companyname']}";
                                    companyData['legalname'] = "${result['legalname']}";
                                  });
                                }
                              });
                        }),

                        ///Address
                        getSettingItem(
                            lang == 'en' ? "Company Address" : 'Dirección de la empresa',
                            "assets/settings/ic_setting_address_info.png",
                            "assets/settings/ic_setting_forward.png", (){

                          Navigator.push(
                              context,
                              SlideRightRoute(
                                  page: CompanyAddressPage(
                                    companyData: companyData,
                                  )
                              )
                          ).then((result) {
                            log("ResultData====$result");
                            if(result != null) {
                              if(result['result']) {
                                getCompanyDetail();
                              }
                            }
                          });
                        }),

                        ///Business Hours
                        getSettingItem(
                            lang == 'en' ? "Business Hours" : "Horas de trabajo",
                            "assets/settings/ic_setting_working_hours.png",
                            "assets/settings/ic_setting_forward.png", (){

                              // var businessHour = companyData['preferences']['BusinessHours'] ?? [];
                              // log("BusinessHour====${businessHour.keys.toList()}");
                              // var keyList = businessHour.keys.toList();
                              // log("Key===${keyList[0]}");
                              // log("Value===${companyData['preferences']['BusinessHours'][keyList[0]][1]}");
                              //
                              // var date = companyData['preferences']['BusinessHours'][keyList[0]][1];
                              //
                              // var newdate = DateFormat.Hm("en_US");
                              // log("New Time===${newdate.parse(date).runtimeType}");
                              //
                              // var formatter = DateFormat('hh:mm a');
                              // String formatted = formatter.format(newdate.parse(date));
                              // log("New Time111===$formatted");


                          Navigator.push(
                              context,
                              SlideRightRoute(
                                  page: BusinessHour(
                                    preferences: companyData['preferences'] ?? null
                                  )
                              )
                          ).then((value){
                            if(value != null) {

                            }
                          });
                        }),

                        /***
                         * App info
                         */
                        getSettingTitleItem(lang == 'en' ? "App" : "aplicación"),

                        ///Help & Support
                        getSettingItem(
                            lang == "en" ? "Help & Support" : "Servicio de asistencia",
                            "assets/settings/ic_setting_help.png",
                            "assets/settings/ic_setting_forward.png", (){
                              _launchURL("https://inspectordottie.com/Help");
                        }),

                        ///Terms of service
                        getSettingItem(
                            lang == 'en' ? "Terms of use" : "Condiciones de uso",
                            "assets/settings/ic_setting_terms.png",
                            "assets/settings/ic_setting_forward.png", (){
                              _launchURL("https://dev.inspectordottie.com/Terms-of-Service");
                        }),

                        ///Privacy Policy
                        getSettingItem(
                            lang == 'en' ? "Privacy Policy" : "Política de privacidad",
                            "assets/settings/ic_setting_privacy.png",
                            "assets/settings/ic_setting_forward.png", (){
                              _launchURL("https://dev.inspectordottie.com/Privacy-Policy");
                        }),

                        SizedBox(height: 24.0,),
                        Center(
                          child: Text.rich(
                            TextSpan(
                              text: "Version - ",
                              style: TextStyle(
                                  color: themeColor.withOpacity(0.8),
                                  fontSize: TextSize.subjectTitle,
                                fontWeight: FontWeight.w500
                              ),
                              children: [
                                TextSpan(
                                  text: "v$versionCode",
                                  style: TextStyle(
                                      color: themeColor,
                                      fontSize: TextSize.subjectTitle,
                                      fontWeight: FontWeight.w700
                                  ),
                                )
                              ]
                            ),
                          ),
                        ),

                        SizedBox(height: 24.0,)
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

  void getProfileDetail() async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var response = await request.getAuthRequest("auth/me");
    _progressHUD.state.dismiss();

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage('${response['reason']}');
      } else {
        setState(() {
          userData = {
            "username": "${response['username']}",
            "firstname": "${response['firstname']}",
            "lastname": "${response['lastname']}",
            "nickname": response['nickname'],
            "avatar": response['avatar']
          };

          PreferenceHelper.saveProfilePreferenceData(userData);

          if(response['roles'] != null) {
            if(response['roles'].runtimeType == List) {
              PreferenceHelper.setRoleData(response['roles'].contains("Owner"));
            }
          }
        });
      }
    }
  }

  void displayLogoutDialog(BuildContext context, String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          content: Text(
            message,
            style: TextStyle(
              color: AppColor.TYPE_PRIMARY,
              fontSize: 16.0,
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
                child: const Text('Cancel'),
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context, 'Cancel');
                }),
            CupertinoDialogAction(
                child: const Text('Yes'),
                onPressed: () {
                  PreferenceHelper.clearUserPreferenceData(context);
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WelcomeIntroPage()
                      ),
                      ModalRoute.withName(WelcomeIntroPage.tag)
                  );
//                      logoutUser(context);
                }),
          ],
        ),
        barrierDismissible: true);
  }

  Widget getSettingItem(content, menuImage, forwardImage, onPressed, {imageType = ""}) {
    // log("ImageType====$imageType");
    // log("ImageType====${userData['avatar']}");
    // log("ImageType====${companyData['avatar']}");
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.0),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Color(0xff1F1F1F)
              : AppColor.TYPE_PRIMARY.withOpacity(0.04),
          borderRadius: BorderRadius.circular(32.0),
        ),
        child: Row(
          children: [
            imageType == "profile" && userData != null && userData['avatar'] != null && userData['avatar'] != "" && _isInternetAvailable
            ? Container(
              height: 48.0,
              width: 48.0,
              margin: EdgeInsets.only(right: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.network(
                  '${AllHttpRequest.apiUrl}${userData['avatar']}',
                  fit: BoxFit.contain,
                  height: 48.0,
                  width: 48.0,
                ),
              ),
            )
            : imageType == "company" && companyData != null && companyData['avatar'] != null && companyData['avatar'] != "" && _isInternetAvailable
            ? Container(
              height: 48.0,
              width: 48.0,
              margin: EdgeInsets.only(right: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.network(
                  '${AllHttpRequest.apiUrl}${companyData['avatar']}',
                  fit: BoxFit.fill,
                  height: 48.0,
                  width: 48.0,
                ),
              ),
            )
            : imageType == "company" || imageType == "profile"
            ? Container(
              height: 48.0,
              width: 48.0,
              margin: EdgeInsets.only(right: 8.0),
              decoration: BoxDecoration(
                  color: isDarkMode ? Color(0xff333333) : Color(0xffE5E5E5),
                  borderRadius: BorderRadius.circular(32)
              ),
              child: Image.asset(
                '$menuImage',
                fit: BoxFit.contain,
                height: 24.0,
                width: 24.0,
              ),
            )
            : Container(
              height: 48.0,
              width: 48.0,
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.only(right: 8.0),
              decoration: BoxDecoration(
                  color: isDarkMode ? Color(0xff333333) : Color(0xffE5E5E5),
                  borderRadius: BorderRadius.circular(32)
              ),
              child: Image.asset(
                '$menuImage',
                fit: BoxFit.contain,
                height: 24.0,
                width: 24.0,
              ),
            ),

            Expanded(
              child: Text(
                '$content',
                style: TextStyle(
                    color: themeColor,
                    fontSize: TextSize.headerText,
                    fontWeight: FontWeight.w700
                ),
              ),
            ),
            Container(
              height: 40.0,
              width: 40.0,
              margin: EdgeInsets.only(left: 8),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode ? Color(0xff333333) : Color(0xffE5E5E5),
                borderRadius: BorderRadius.circular(32)
              ),
              child: Image.asset(
                '$forwardImage',
                fit: BoxFit.contain,
                color: isDarkMode ? Colors.white : Colors.black,
                height: 16.0,
                width: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getSettingTitleItem(title) {
    return Container(
      margin: EdgeInsets.only(bottom: 8, top:24, left: 16, right: 16),
      child: Text(
        '$title',
        style: TextStyle(
            color: themeColor,
            fontSize: TextSize.subjectTitle,
            fontWeight: FontWeight.w700
        ),
      ),
    );
  }

  Widget getSubscriptionWidget() {
    return GestureDetector(
      onTap: (){
        // Navigator.push(
        //     context,
        //     SlideRightRoute(
        //         page: SubscriptionPlanScreen()
        //     )
        // );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8.0),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Color(0xff1F1F1F)
              : AppColor.TYPE_PRIMARY.withOpacity(0.04),
          borderRadius: BorderRadius.circular(32.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Image.asset(
                'assets/settings/ic_setting_logo.png',
                fit: BoxFit.contain,
                height: 48.0,
                width: 48.0,
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      child: Text(
                        'Inspector Dottie',
                        style: TextStyle(
                            color: themeColor,
                            fontSize: TextSize.headerText,
                            fontWeight: FontWeight.w700
                        ),
                      ),
                    ),
                    productId == ""
                    ? Container(
                      margin: EdgeInsets.only(top: 3),
                      child: Text(
                        lang == 'en' ? 'Upgrade Now' : 'Actualizar ahora',
                        style: TextStyle(
                            color: themeColor,
                            fontSize: TextSize.bodyText,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                    )
                    : Container(
                      margin: EdgeInsets.only(top: 3),
                      child: Text(
                        lang == 'en' ? 'Active' : 'Activa',
                        style: TextStyle(
                            color: themeColor,
                            fontSize: TextSize.bodyText,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              child: Image.asset(
                'assets/settings/ic_setting_forward.png',
                fit: BoxFit.contain,
                height: 40.0,
                width: 40.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchURL(_url) async {
    if (!await launch(_url)) throw 'Could not launch $_url';
  }

  void bottomImagePicker(context){
    showModalBottomSheet(
        context: context,
        barrierColor: isDarkMode ? Color(0xff000000).withOpacity(0.8) : Color(0xff000000).withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        backgroundColor: isDarkMode ? Color(0xff1f1f1f) : Colors.white,
        isDismissible: true,
        builder: (context){
          return StatefulBuilder(
            builder: (context1, myState){
              return SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.only(top: 24.0),
                        child: Text(
                          lang == 'en' ? 'Update Profile Photo' : "Actualizar foto de perfil",
                          style: TextStyle(
                              fontSize: TextSize.subjectTitle,
                              color: themeColor,
                              fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                          getImageFromCamera("profile");
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.only(top: 24.0),
                          child: Text(
                            lang == "en" ? takeAPictureEn : takeAPictureEs,
                            style: TextStyle(
                                fontSize: 20,
                                color: themeColor,
                                fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                          getImageFromGallery("profile");
                        },
                        child: Container(
                          padding: EdgeInsets.only(top: 24.0),
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            lang == 'en' ? 'Choose New Photo' : "Elegir nueva foto",
                            style: TextStyle(
                                fontSize: 20,
                                color: themeColor,
                                fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                          ///TODO: Remove image API integration

                        },
                        child: Container(
                          padding: EdgeInsets.only(top: 24.0),
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            lang == 'en' ? 'Remove Photo' : 'Quitar foto',
                            style: TextStyle(
                              fontSize: 20,
                              color: AppColor.RED_COLOR,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: 32, bottom: 16),
                          alignment: Alignment.center,
                          height: 64,
                          width: 110,
                          // padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                          decoration: BoxDecoration(
                            color: themeColor,
                            borderRadius: BorderRadius.circular(32)
                          ),
                          child: Text(
                            lang == 'en' ? 'Cancel' : 'Cancelar',
                            style: TextStyle(
                                fontSize: TextSize.subjectTitle,
                                color: isDarkMode ? Colors.black : Colors.white,
                                fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 12.0,
                      )
                    ],
                  ),
                ),
              );
            },
          );
        }
    );
  }

  void bottomCompanyImagePicker(context){
    showModalBottomSheet(
        context: context,
        barrierColor: isDarkMode ? Color(0xff000000).withOpacity(0.8) : Color(0xff000000).withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        backgroundColor: isDarkMode ? Color(0xff1f1f1f) : Colors.white,
        isDismissible: true,
        builder: (context){
          return StatefulBuilder(
            builder: (context1, myState){
              return SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.only(top: 24.0),
                        child: Text(
                          lang == 'en' ? 'Update Company Logo' : "Actualizar el logotipo de la empresa",
                          style: TextStyle(
                            fontSize: TextSize.subjectTitle,
                            color: themeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                          getImageFromGallery("company");
                        },
                        child: Container(
                          padding: EdgeInsets.only(top: 24.0),
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            lang == 'en' ? 'Choose New Logo' : 'Elija un nuevo logotipo',
                            style: TextStyle(
                              fontSize: 20,
                              color: themeColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                          ///TODO: Remove image API integration

                        },
                        child: Container(
                          padding: EdgeInsets.only(top: 24.0),
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            lang == 'en' ? 'Remove Logo' : 'Eliminar logotipo',
                            style: TextStyle(
                              fontSize: 20,
                              color: AppColor.RED_COLOR,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: 32, bottom: 16),
                          alignment: Alignment.center,
                          height: 64,
                          width: 110,
                          // padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                          decoration: BoxDecoration(
                              color: themeColor,
                              borderRadius: BorderRadius.circular(32)
                          ),
                          child: Text(
                            lang == 'en' ? 'Cancel' : 'Cancelar',
                            style: TextStyle(
                              fontSize: TextSize.subjectTitle,
                              color: isDarkMode ? Colors.black : Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 12.0,
                      )
                    ],
                  ),
                ),
              );
            },
          );
        }
    );
  }

  Future<void> uploadImageData(type) async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var inspectionId = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ID);
    var response;

    if(type == "profile") {
      response = await request.uploadProfileResource(
          "auth/me/setAvatar",
          imagePath,
          "avatar"
      );
    } else {
      response = await request.uploadProfileResource(
          "auth/admin/setLogo",
          companyLogoPath,
          "logo"
      );
    }
    print("Response====$response");
    print("Error====$response");
    _progressHUD.state.dismiss();
    if (response != null) {
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage('${response['reason']}');
      } else {
        setState(() {
          if(type == 'profile') {
            userData['avatar'] = response['avatar'];
          } else {
            companyData['avatar'] = response['logo'];
          }
        });
        PreferenceHelper.setPreferenceData(PreferenceHelper.USER_AVATAR, response['avatar']);
      }
    }
  }

  //Company detail
  void getCompanyDetail() async {
      _progressHUD.state.show();
      FocusScope.of(context).requestFocus(FocusNode());
      var response = await request.getAuthRequest("auth/me/myCompany");
      _progressHUD.state.dismiss();
      // const JsonEncoder encoder = JsonEncoder.withIndent('  ');
      // log("Response====${encoder.convert(response)}");

      if (response != null) {
        if (response['success']!=null && !response['success']) {
          CustomToast.showToastMessage('${response['reason']}');
        } else {
          setState(() {
            companyData = {
              "companyname": "${response['companyname']}",
              "legalname": "${response['legalname']}",
              "avatar": "${response['avatar']}",
              "preferences": response['preferences'],
              "phone": response['phone'],
              "address": response['address']
            };
          });
          print("CompanyData====>>>>$companyData");
          if(response['preferences'] != null) {
            var businessHour = response['preferences']['BusinessHours'] != null ? json.encode(response['preferences']['BusinessHours']) : null;
            PreferenceHelper.setPreferenceData(PreferenceHelper.BUSINESS_HOUR, businessHour);
          }

          var companyLocalData = {
            "payload": json.encode(response)
          };
          dbHelper.insertCompanyDetailData(companyLocalData);
        }
      }
  }

  void companyDetailFromLocalDb() async {
    try {
      var response = await dbHelper.getCompanyDetailData();
      var resultList = response.toList();

      log("responseType===${resultList.runtimeType}");
      log("responseType===${resultList.runtimeType}");

      if (resultList.length > 0) {
        var resultData = json.decode(resultList[0]['payload']);
        setState(() {
          companyData = {
            "companyname": "${resultData['companyname']}",
            "legalname": "${resultData['legalname']}",
            "avatar": "${resultData['avatar']}",
            "preferences": resultData['preferences'],
            "phone": resultData['phone'],
            "address": resultData['address']
          };
        });
        print("CompanyDataLocal====>>>>$companyData");
        if(resultData['preferences'] != null) {
          var businessHour = resultData['preferences']['BusinessHours'] != null ? json.encode(resultData['preferences']['BusinessHours']) : null;
          PreferenceHelper.setPreferenceData(PreferenceHelper.BUSINESS_HOUR, businessHour);
        }
      }
    } catch(e) {
      log("companyDetailFromLocalDbStackTrace=====$e");
    }
  }
}

