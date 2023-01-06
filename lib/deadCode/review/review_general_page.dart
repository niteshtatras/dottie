import 'package:dottie_inspector/deadCode/review/review_add_upload_signature.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/SlideRightRoute.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/widget/bottom_general_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:dottie_inspector/pages/menu/drawer_page.dart';

class ReviewGeneralPage extends StatefulWidget {
  static String tag = "review-page";
  @override
  _ReviewGeneralPageState createState() => _ReviewGeneralPageState();
}

class _ReviewGeneralPageState extends State<ReviewGeneralPage> {
  double progress = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColor.PAGE_COLOR,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: AppColor.PAGE_COLOR,
        leading: InkWell(
          onTap: (){
            _scaffoldKey.currentState.openDrawer();
//            HelperClass.launchDetail(context, ReviewGeneralPage());
          },
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Image.asset(
              'assets/ic_menu.png',
//              'assets/ic_close.png',
              fit: BoxFit.cover,
              height: 28.0,
              width: 28.0,
            ),
          ),
        ),
        actions: [
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(horizontal: 3.0, vertical: 12.0),
            padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 20.0, right: 20.0),
            decoration: BoxDecoration(
                color: AppColor.THEME_PRIMARY.withOpacity(0.2),
                borderRadius: BorderRadius.all(Radius.circular(16.0))),
            child: Text(
              'Help',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: TextSize.bodyText,
                  color: AppColor.THEME_PRIMARY,
                  fontStyle: FontStyle.normal),
            ),
          ),
          InkWell(
            onTap: (){
              HelperClass.launchChapter(context);
            },
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 6.0, vertical: 12.0),
              padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 20.0, right: 20.0),
              decoration: BoxDecoration(
                  color: AppColor.THEME_PRIMARY.withOpacity(0.2),
                  borderRadius: BorderRadius.all(Radius.circular(16.0))),
              child: Text(
                'CHAPTERS',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: TextSize.bodyText,
                    color: AppColor.THEME_PRIMARY,
                    fontStyle: FontStyle.normal),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: DrawerPage(),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 20.0,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Review',
                        style: TextStyle(
                            color: AppColor.TYPE_PRIMARY,
                            fontSize: TextSize.greetingTitleText,
                            fontWeight: FontWeight.w600
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.0,),
                      Text(
                        '6 Steps',
                        style: TextStyle(
                            color: AppColor.TYPE_SECONDARY,
                            fontSize: TextSize.subjectTitle,
                            fontWeight: FontWeight.w600
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 32.0),
                        padding: EdgeInsets.all(1),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Image.asset(
                            'assets/main_images/ic_review_main.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 120.0,)
                ],
              ),
            ),
          ),

          BottomGeneralButton(
            buttonName: "Begin",
            onStartButton: (){
              Navigator.pushReplacement(
                  context,
                  SlideRightRoute(
                      page: AddUploadSignaturePage()
                  )
              );
            },
          ),
        ],
      ),
    );
  }
}
