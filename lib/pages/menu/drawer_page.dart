import 'dart:developer';

import 'package:dottie_inspector/deadCode/welcome_new_screen.dart';
import 'package:dottie_inspector/pages/settings/setting_page.dart';
import 'package:dottie_inspector/pages/signInPages/login_page_1.dart';
import 'package:dottie_inspector/pages/welcome/welcome_navigation_screen.dart';
import 'package:dottie_inspector/pages/welcome/welcome_template_screen.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/SlideRightRoute.dart';
import 'package:dottie_inspector/utils/empty_menu_app_bar.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DrawerPage extends StatefulWidget {
  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {

  var drawerValue = 'home';
  String lang = 'en';

  bool isDarkMode = false;
  Color themeColor = AppColor.BLACK_COLOR;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getThemeData();
    getPreferenceData();
  }

  void getPreferenceData() async {
    lang = await PreferenceHelper.getPreferenceData(PreferenceHelper.LANGUAGE) ?? "en";

    String value = await PreferenceHelper.getPreferenceData('drawerMenu');

    setState(() {
        drawerValue = value != null ? value : drawerMenu.home.toString();
    });

    print("DrawerValue====$drawerValue");
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
      appBar: EmptyMenuAppBar(),
      body: Container(
          color: AppColor.BLACK_COLOR,
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  children: <Widget>[
                    /*Container(
                  margin: EdgeInsets.only(top: 16.0, left: 16.0,right: 16.0),
                  alignment: Alignment.centerLeft,
                  child: CircleAvatar(
                    backgroundColor: AppColor.BG_SECONDARY_ALT,
                    child: Container(
                      height: 65.0,
                      width: 65.0,
                      child: ClipOval(
                        child: Image.asset(
                          'assets/drawer_profile.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    radius: 35.0,
                  ),
                ),
                SizedBox(height: 14.0,),
                Divider(
                  height: 1.0,
                  color: AppColor.SEC_DIVIDER,
                ),*/

                    //Title
                    /*Container(
                  margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
                  width: MediaQuery.of(context).size.width,
                  child:Text(
                      'Dottie',
                      style: TextStyle(
                          fontSize: TextSize.planeHeaderText,
                          color: AppColor.WHITE_COLOR,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'WorkSans'
                      )
                  ),
                ),*/

                    Container(
                      margin: EdgeInsets.only(left: 24.0, right: 24, top: 24.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(70.0),
                            child: CircleAvatar(
                              radius: 40.0,
                              child: Image(
                                image: AssetImage('assets/ic_inspector_logo.png'),
                                fit: BoxFit.cover,
                                height: 84.0,
                                width: 84.0,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                            alignment: Alignment.center,
                            child: Image(
                              image: AssetImage('assets/logo_dottie.png'),
                              fit: BoxFit.cover,
                              color: AppColor.WHITE_COLOR,
                              height: 35.0,
                              width: 85.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.0,),

                    //Home
                    /*InkWell(
                  onTap: (){
                    setPreferenceData(drawerMenu.home.toString());
                    Navigator.pop(context);
//                    InspectionMainPage
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WelcomeScreenPage()
                        )
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                        'Home',
                        style: TextStyle(
                            fontSize: TextSize.sideMenuText,
                            color: AppColor.WHITE_COLOR,
                            fontWeight: drawerValue == drawerMenu.home.toString() ? FontWeight.w900 : FontWeight.w100,
//                            color: drawerValue == drawerMenu.home.toString() ? AppColor.TYPE_PRIMARY : AppColor.TYPE_SECONDARY,
//                            fontWeight: drawerValue == drawerMenu.home.toString() ? FontWeight.w500 : FontWeight.normal,
                            fontFamily: 'WorkSans'
                        )
                    ),
                  ),
                ),*/

                    //Inspections
                    InkWell(
                      onTap: () {
                        setPreferenceData(drawerMenu.inspections.toString());
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                            context,
                            SlideRightRoute(
                              page: WelcomeNavigationScreen()
                            )
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                            lang == 'en' ? 'Inspections' : 'Inspecciones',
                            style: TextStyle(
                                fontSize: TextSize.sideMenuText,
                                color: AppColor.WHITE_COLOR,
                                fontWeight: drawerValue == drawerMenu.inspections.toString() ? FontWeight.w700 : FontWeight.w400,
                                fontFamily: 'WorkSans'
                            )
                        ),
                      ),
                    ),

                    //Customers
                    // InkWell(
                    //   onTap: (){
                    //     setPreferenceData(drawerMenu.customers.toString());
                    //     Navigator.pop(context);
                    //     Navigator.pushReplacement(
                    //         context,
                    //         MaterialPageRoute(
                    //             builder: (context) => InspectionCustomerListPage(
                    //               type: 1
                    //             )
                    //         )
                    //     );
                    //   },
                    //   child: Container(
                    //     margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    //     width: MediaQuery.of(context).size.width,
                    //     child: Text(
                    //         'Customers',
                    //         style: TextStyle(
                    //             fontSize: TextSize.sideMenuText,
                    //             color: AppColor.WHITE_COLOR,
                    //             fontWeight: drawerValue == drawerMenu.customers.toString() ? FontWeight.w900 : FontWeight.w100,
                    //             fontFamily: 'WorkSans'
                    //         )
                    //     ),
                    //   ),
                    // ),

                    //Settings
                    InkWell(
                      onTap: () {
                        setPreferenceData(drawerMenu.settings.toString());
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                            context,
                            SlideRightRoute(
                              page: SettingPage()
                            )
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                            lang == 'en' ? 'Settings' : 'Ajustes',
                            style: TextStyle(
                              fontSize: TextSize.sideMenuText,
                              color: AppColor.WHITE_COLOR,
                              fontWeight: drawerValue == drawerMenu.settings.toString() ? FontWeight.w900 : FontWeight.w100,
                              fontFamily: 'WorkSans',
                            )
                        ),
                      ),
                    ),

                    /*InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MaintenanceProviderPage()
                        )
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      'Maintenance',
                      style:  TextStyle(
                          fontSize: TextSize.sideMenuText,
                          color: AppColor.WHITE_COLOR,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'WorkSans'
                      ),
                    ),
                  ),
                ),

                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ReviewGeneralPage()
                        )
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      'Review',
                      style:  TextStyle(
                          fontSize: TextSize.sideMenuText,
                          color: AppColor.WHITE_COLOR,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'WorkSans'
                      ),
                    ),
                  ),
                ),

                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SafetyGeneralPage()
                        )
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      'Safety',
                      style:  TextStyle(
                          fontSize: TextSize.sideMenuText,
                          color: AppColor.WHITE_COLOR,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'WorkSans'
                      ),
                    ),
                  ),
                ),

                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BondingGeneralPage()
                        )
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      'Bonding',
                      style:  TextStyle(
                          fontSize: TextSize.sideMenuText,
                          color: AppColor.WHITE_COLOR,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'WorkSans'
                      ),
                    ),
                  ),
                ),

                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ValvesGeneralPage()
                        )
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      'Valves',
                      style:  TextStyle(
                          fontSize: TextSize.sideMenuText,
                          color: AppColor.WHITE_COLOR,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'WorkSans'
                      ),
                    ),
                  ),
                ),

                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GFCIGeneralPage()
                        )
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      'GFCI',
                      style:  TextStyle(
                          fontSize: TextSize.sideMenuText,
                          color: AppColor.WHITE_COLOR,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'WorkSans'
                      ),
                    ),
                  ),
                ),*/

                    /*InkWell(
                  onTap: () {
                    displayLogoutDialog(context, 'Do you want to logout?');
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      'Logout',
                      style:  TextStyle(
                          fontSize: TextSize.sideMenuText,
                          color: AppColor.WHITE_COLOR,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'WorkSans'
                      ),
                    ),
                  ),
                ),*/

                  ],
                ),
              ),

              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      SlideRightRoute(
                        page: WelcomeNavigationScreen()
                      )
                  );
                },
                child: Container(
                  height: 64.0,
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(left: 24.0, right: 24.0, bottom: 0.0, top: 12.0),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [
                            Color(0xff013399),
                            Color(0xffBC96E6)
                          ]
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      border: Border.all(
                          color: AppColor.TRANSPARENT,
                          width: 0.0
                      )
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    lang == 'en' ? 'New Inspection' : 'Nueva Inspección',
                    style:  TextStyle(
                        fontSize: TextSize.subjectTitle,
                        color: AppColor.WHITE_COLOR,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'WorkSans'
                    ),
                  ),
                ),
              ),

              InkWell(
                onTap: () {
                  displayLogoutDialog(context, lang == 'en' ? 'Do you want to logout?' : '¿Quieres cerrar sesión?');
                },
                child: Container(
                  height: 64.0,
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(left: 24.0, right: 24.0, bottom: 34.0, top: 8.0),
                  decoration: BoxDecoration(
                      color: AppColor.BLACK_COLOR,
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      border: Border.all(
                          color: AppColor.WHITE_COLOR,
                          width: 3.0
                      )
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    lang == 'en' ? 'Sign Out' : 'Desconectar',
                    style:  TextStyle(
                        fontSize: TextSize.subjectTitle,
                        color: AppColor.WHITE_COLOR,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'WorkSans'
                    ),
                  ),
                ),
              ),
            ],
          )
      ),
    );
  }

  void setPreferenceData(value) async {
    PreferenceHelper.setPreferenceData("drawerMenu", value);
    var menu = await PreferenceHelper.getPreferenceData("drawerMenu");
    setState(() {
      drawerValue = menu != null ? menu : 'home';
    });
    print("DrawerValue====$drawerValue");
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
//                      logoutUser(context);
                }),
          ],
        ),
        barrierDismissible: true);
  }

}
