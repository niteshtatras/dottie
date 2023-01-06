
import 'package:dottie_inspector/deadCode/review/review_add_upload_signature.dart';
import 'package:dottie_inspector/deadCode/review/review_general_page.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/SlideLeftRoute.dart';
import 'package:dottie_inspector/utils/SlideRightRoute.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:flutter/material.dart';

class ReviewSwipePage extends StatefulWidget {
  @override
  _ReviewSwipePageState createState() => _ReviewSwipePageState();
}

class _ReviewSwipePageState extends State<ReviewSwipePage> {
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
        leading: IconButton(
          padding: EdgeInsets.only(left: 16.0, right: 0.0),
          icon: Icon(
            Icons.clear,
            color: AppColor.TYPE_PRIMARY,
            size: 32.0,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
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
              padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 8.0, right: 16.0),
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
                  SizedBox(height: 10.0,),
                  //Title
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 36.0),
                    alignment: Alignment.center,
                    child: Text(
                      'Let’s review',
                      style: TextStyle(
                          fontSize: TextSize.pageTitleText,
                          color: AppColor.TYPE_PRIMARY,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                          fontFamily: "WorkSans"),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 56.0,vertical: 16.0),
                    alignment: Alignment.center,
                    child: Text(
                      'Swipe cards to view unaswered questions',
                      style: TextStyle(
                          fontSize: TextSize.headerText,
                          color: AppColor.TYPE_PRIMARY,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                          fontFamily: "WorkSans"),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),

          //Start Button
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Visibility(
              visible: true,
              child: Container(
                padding: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0, top: 10.0),
                decoration: BoxDecoration(
                    color: AppColor.WHITE_COLOR,
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 24.0,
                          offset: Offset(0.0,0),
                          color: Colors.grey[400]
                      )
                    ]
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: (){
                          Navigator.pushReplacement(
                            context,
                            SlideLeftRoute(
                              page: ReviewGeneralPage()
                            )
                          );
                        },
                        child: Container(
                          height: 56.0,
                          decoration: BoxDecoration(
                              color: AppColor.THEME_PRIMARY,
                              borderRadius: BorderRadius.all(Radius.circular(16.0))
                          ),
                          child: Center(
                            child: Text(
                              'BACK',
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
                    SizedBox(width: 8.0,),
                    Expanded(
                      child: InkWell(
                        onTap: (){
                          Navigator.pushReplacement(
                              context,
                              SlideRightRoute(
                                  page: AddUploadSignaturePage()
                              )
                          );
                        },
                        child: Container(
                          height: 56.0,
                          decoration: BoxDecoration(
                              color: AppColor.THEME_PRIMARY,
                              borderRadius: BorderRadius.all(Radius.circular(16.0))
                          ),
                          child: Center(
                            child: Text(
                              'NEXT',
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
