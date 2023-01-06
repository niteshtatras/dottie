import 'package:dottie_inspector/pages/signInPages/login_page_1.dart';
import 'package:dottie_inspector/deadCode/signIn/create_account.dart';
import 'package:dottie_inspector/deadCode/signIn/login_page.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

//var _orientation;
double _width, _height;
List<Slide> _slides;

class SingleButtonIntro extends StatefulWidget {

  SingleButtonIntro(List<Slide> slidesList){
    _slides = slidesList;
  }

  @override
  State<StatefulWidget> createState() {
    return SingleButtonIntroState();
  }
}

class SingleButtonIntroState extends State<SingleButtonIntro> {

  static final PageController pageController = new PageController();
  static int pos = 0;

  static const _kDuration = const Duration(milliseconds: 300);
  var _dotIndicatorPlus =  Dots(
    controller: pageController,
    itemCount: _slides.length,
    onPageSelected: (int page) {
      pageController.animateToPage(page,
          duration: _kDuration, curve: Curves.decelerate);
    },
    color: Colors.white,
  );

  @override
  Widget build(BuildContext context) {

    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
//    _orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          AnimatedContainer(
            curve: Curves.bounceInOut,
            duration: Duration(milliseconds: 400),
            child: PageView.builder(
              physics: new ClampingScrollPhysics(),
              controller: pageController,
              itemBuilder: (BuildContext context, int index) {
                return _slides[index % _slides.length];
              },
              itemCount: _slides.length,
              onPageChanged: (int value) {
                setState(() {
                  pos = value;
                });
              },
            ),
          ),
//          Positioned(
////            bottom: MediaQuery.of(context).orientation == Orientation.portrait ? _height * 2/ 10 : _height*2.30/10,
//            right: 0.0,
//            left: 0.0,
//            bottom: _height * 2/10,
//            child: Container(
//              color: Colors.blue,
//              child: Center(
//                child: _dotIndicatorPlus,
//              ),
//            ),
//          ),
          Positioned(
            right: 0.0,
            left: 0.0,
            bottom: 0.0,
            child: Column(
              children: <Widget>[
                Container(
                  color: AppColor.THEME_PRIMARY,
                  child: Center(
                    child: _dotIndicatorPlus,
                  ),
                ),
                _bottomMenu()
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _bottomMenu() {
    return Container(
      color: AppColor.THEME_PRIMARY,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 10.0,
          ),
//          platformButton(
////            child: SizedBox(
////              width: _width*9/10,
////              height: Platform.isAndroid ? _height*.7/10 : _height*.4/10,
////              child: Center(
////                child: Text(
////                  '$_buttonText',
////                  textAlign: TextAlign.center,
////                  style: TextStyle(color: Colors.white,fontSize: MediaQuery.of(context).orientation == Orientation.portrait? _height*0.225/10 : _height*0.32/10 ,fontStyle: FontStyle.normal,decorationColor: Colors.white),
////                ),
////              ),
////            ),
//            onPressed: _onButtonPress,
//            child: Container(
//              margin: EdgeInsets.symmetric(horizontal: 24.0),
//              color: Colors.white,
//            )
//          ),
          InkWell(
            onTap: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateAccountPage()
                  )
              );
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24.0),
              height: 56.0,
              decoration: BoxDecoration(
                color: AppColor.WHITE_COLOR,
                borderRadius: BorderRadius.all(Radius.circular(4.0))
              ),
              child: Center(
                child: Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColor.THEME_PRIMARY,
                    fontSize: TextSize.subjectTitle,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          InkWell(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage1()
                )
              );
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24.0),
              height: 56.0,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.all(Radius.circular(0.0))
              ),
              child: Center(
                child: Text(
                  'Sign In',
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
          SizedBox(
            height: 16.0,
          )
        ],
      ),
    );
  }

  // Widget platformButton({Widget child, Color color, VoidCallback onPressed}) {
  //   if(Platform.isIOS){
  //     return CupertinoButton(child: child, onPressed: onPressed,color: color,borderRadius: BorderRadius.all(Radius.circular(6.0)),);
  //   }else{
  //     return TextButton(child: child,onPressed: onPressed,color: color,shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6.0))),);
  //   }
  // }
}

class Dots extends AnimatedWidget {
  // @Collin Jackson
  Dots({
    this.controller,
    this.itemCount,
    this.onPageSelected,
    this.color: Colors.white,
  }) : super(listenable: controller);

  final PageController controller;
  final int itemCount;
  final ValueChanged<int> onPageSelected;
  final Color color;
  static const double _kDotSize = 6.0;
  static const double _kMaxZoom = 3.5;
  static const double _kDotSpacing = 35.0;
  IconData iconData = FontAwesomeIcons.solidCircle;

  Widget _buildDot(int index) {
    double selectedNess = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((controller.page ?? controller.initialPage) - index).abs(),
      ),
    );

    double zoom = 1.0 + (_kMaxZoom - 1.0) * selectedNess;
    return Container(
      color: AppColor.WHITE_COLOR,
      width: _kDotSpacing,
      child: Center(
        child: Material(
          color: AppColor.THEME_PRIMARY,
          child: IconButton(
            onPressed: (){
              onPageSelected(index);
            },
            icon: Icon(
              iconData,
              color: AppColor.WHITE_COLOR,
              size: _kDotSize * zoom,
//             height: _kDotSize * zoom,
            ),
          ),
        ),
      ),
    );
//    return new Container(
//      width: _kDotSpacing,
//      child: new Center(
//        child: new Material(
//          color: color,
//          type: MaterialType.circle,
//          child: new Container(
//            width: _kDotSize * zoom,
//            height: _kDotSize * zoom,
//            child: new InkWell(
//              onTap: () => onPageSelected(index),
//            ),
//          ),
//        ),
//      ),
//    );
  }

  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: new List<Widget>.generate(itemCount, _buildDot),
    );
  }
}

class Slide extends StatelessWidget {
  double _height;
  String description, screenName;

  Slide(this.description, this.screenName);

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: AppColor.THEME_PRIMARY,
        body: SizedBox(
//          height: _height * 8.5 / 10,
          width: double.infinity,
          child: Padding(
//              padding: EdgeInsets.only(
//                  top: MediaQuery.of(context).orientation == Orientation.portrait ? _height * 1 / 10 : _height * 0.5 / 10,
//                  bottom: MediaQuery.of(context).orientation == Orientation.portrait ? _height * 0.75 / 10 : _height * 0.25 / 10,
//                  left: 20.0,
//                  right: 20.0),
          padding: EdgeInsets.all(0.0),
              child: Column(
                children: <Widget>[
                  Container(
                    color: AppColor.WHITE_COLOR,
                    width: double.infinity,
                    padding: EdgeInsets.only(top: 20.0),
//                    child: Text(
//                      title,
//                      maxLines: 1,
//                      textAlign: TextAlign.center,
//                      style: titleStyle,
//                      textDirection: TextDirection.ltr,
//                    ),
                    child: Container(
                      child: Image.asset(
                        'assets/welcome/welcome_title.png',
                        height: 60.0,
                        width: 100.0,
                      ),
                    ),
                  ),
                  Container(
                    color: AppColor.WHITE_COLOR,
                    width: double.infinity,
                    child: Container(
                      height: _height*4.3/10,
                      child: Stack(
                        children: <Widget>[

                          Positioned(
                            left: 0.0,
                            right: 0.0,
                            bottom: 40.0,
                            child: Container(
                              height: 24.0,
                              color: AppColor.SEC_DIVIDER,
                            ),
                          ),

                          Positioned(
                            left: 0.0,
                            right: 0.0,
                            bottom: 0.0,
                            child: Container(
                              height: 40.0,
                              color: AppColor.THEME_PRIMARY.withOpacity(0.2),
                            ),
                          ),

                          //Images
                          Stack(
                            clipBehavior: Clip.none,
                            children: <Widget>[
                              screenName == "screen3"
                                  ? Stack(
                                clipBehavior: Clip.none,
                                children: <Widget>[
                                  Positioned(
                                    left: 23.0,
                                    bottom: 80.0,
                                    child: Image.asset(
                                      "assets/welcome/screen3/screen3_left.png",
                                      width: 68.0,
                                      height: 53.0,
                                    ),
                                  ),
                                  Positioned(
                                    right: 13.0,
                                    bottom: -25.0,
                                    child: Image.asset(
                                      "assets/welcome/screen3/screen3_ladder.png",
                                      width: 100.0,
                                      height: 115.0,
                                    ),
                                  ),
                                  Positioned(
                                    right: 32.0,
                                    bottom: 80.0,
                                    child: Image.asset(
                                      "assets/welcome/screen3/screen3_icon.png",
                                      width: 230.0,
                                      height: 235.0,
                                    ),
                                  ),
                                ],
                              )
                                  : screenName == 'screen1'
                                  ? Stack(
                                clipBehavior: Clip.none,
                                children: <Widget>[
                                  Positioned(
                                    left: 23.0,
                                    bottom: 18.0,
                                    child: Image.asset(
                                      "assets/welcome/screen1/screen1_left.png",
                                      width: 150.0,
                                      height: 290.0,
                                    ),
                                  ),
                                  Positioned(
                                    right: 45.0,
                                    bottom: 80.0,
                                    child: Image.asset(
                                      "assets/welcome/screen1/screen1_right.png",
                                      width: 120.0,
                                      height: 70.0,
                                    ),
                                  ),
                                ],
                              )
                                  : screenName == 'screen4'
                                  ? Stack(
                                clipBehavior: Clip.none,
                                children: <Widget>[
                                  Positioned(
                                    right: 14.0,
                                    left: 14.0,
                                    bottom: 10.0,
                                    child: Image.asset(
                                      "assets/welcome/screen4/screen4_icon.png",
                                    ),
                                  ),
                                ],
                              )
                                  : screenName == 'screen2'
                                  ? Stack(
                                clipBehavior: Clip.none,
                                children: <Widget>[
                                  Positioned(
                                    left: 23.0,
                                    bottom: 80.0,
                                    child: Image.asset(
                                      "assets/welcome/screen2/screen2_left.png",
                                      width: 165.0,
                                      height: 50.0,
                                    ),
                                  ),
                                  Positioned(
                                    left: 105.0,
                                    bottom: 120.0,
                                    child: Image.asset(
                                      "assets/welcome/screen2/screen2_build.png",
                                      width: 85.0,
                                      height: 60.0,
                                    ),
                                  ),
                                  Positioned(
                                    right: 40.0,
                                    bottom: 100.0,
                                    child: Image.asset(
                                      "assets/welcome/screen2/screen2_icon.png",
                                      width: 120.0,
                                      height: 160.0,
                                    ),
                                  ),
                                ],
                              )
                                  : Container(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 32.0,
                  ),
                  SafeArea(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColor.WHITE_COLOR,
                            fontSize: TextSize.headerText,
                            height: 1.2
                          ),
                          maxLines: 3,
                          textDirection: TextDirection.ltr,
                        ),
                      ),
                  ),
                ],
              )),
        ));
  }
}