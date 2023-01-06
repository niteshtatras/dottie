//import 'package:dottie_inspector/pages/inspectionMain/welcome_screen.dart';
import 'package:dottie_inspector/pages/inspectionMain/inspection_adding_customer.dart';
import 'package:dottie_inspector/deadCode/safety_equipment_screen.dart';
import 'package:dottie_inspector/deadCode/welcome_new_screen.dart';
import 'package:dottie_inspector/pages/signInPages/login_page_1.dart';
import 'package:dottie_inspector/pages/welcome/welcome_navigation_screen.dart';
import 'package:dottie_inspector/pages/welcome/welcome_template_screen.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:flutter/material.dart';

class PasswordSuccessPage extends StatefulWidget {
  @override
  _PasswordSuccessPageState createState() => _PasswordSuccessPageState();
}

class _PasswordSuccessPageState extends State<PasswordSuccessPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.WHITE_COLOR,
      appBar: EmptyAppBar(isDarkMode: false),
      body: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          Image(
            image: AssetImage('assets/ic_reset_success.png'),
            fit: BoxFit.cover,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 160.0,),
              Image(
                image: AssetImage('assets/ic_inspector_logo.png'),
                fit: BoxFit.cover,
                height: 150.0,
                width: 150.0,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                alignment: Alignment.center,
                child: Image(
                  image: AssetImage('assets/logo_dottie.png'),
                  fit: BoxFit.cover,
                  height: 50.0,
                  width: 120.0,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 16.0),
                child: Text(
                  'Password successfully updated!',
                  style: TextStyle(
                      color: AppColor.TYPE_PRIMARY,
                      fontSize: TextSize.planeHeaderText,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal,
                      fontFamily: "WorkSans"
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          //Submit Button
          Positioned(
            bottom: 32.0,
            left: 20.0,
            right: 20.0,
            child: InkWell(
              onTap: (){
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WelcomeNavigationScreen(),
//                    builder: (context) => SafetyEquipmentInspectionPage(),
                  ),
                  ModalRoute.withName(WelcomeNavigationScreen.tag),
                );
              },
              child: Container(
                height: 56.0,
                decoration: BoxDecoration(
                    color: AppColor.THEME_PRIMARY,
                    borderRadius: BorderRadius.all(Radius.circular(4.0))
                ),
                child: Center(
                  child: Text(
                    'GOT TO DASHBOARD',
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
          ),
        ],
      ),
    );
  }
}
