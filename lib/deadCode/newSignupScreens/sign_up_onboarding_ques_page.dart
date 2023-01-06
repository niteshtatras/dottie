import 'dart:convert';

import 'package:dottie_inspector/deadCode/newSignupScreens/sign_up_experience_pool.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/SlideRightRoute.dart';
import 'package:dottie_inspector/utils/custom_toast.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:dottie_inspector/widget/bottom_general_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:progress_hud/progress_hud.dart';

class SignUpOnBoardingQuestionPage extends StatefulWidget {
  @override
  _SignUpOnBoardingQuestionPageState createState() => _SignUpOnBoardingQuestionPageState();
}

class _SignUpOnBoardingQuestionPageState extends State<SignUpOnBoardingQuestionPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedIndex = -1;

  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;

  @override
  void initState(){
    super.initState();
    _progressHUD = ProgressHUD(
      backgroundColor: Colors.transparent,
      color: Colors.white,
      containerColor: AppColor.LOADER_COLOR,
      borderRadius: 5.0,
      loading: _loading,
      text: 'Loading...',
    );
  }

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
            Navigator.pop(context);
          },
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Image.asset(
              'assets/ic_close.png',
              fit: BoxFit.cover,
              height: 28.0,
              width: 28.0,
            ),
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  'How can we make your life easier?',
                  style: TextStyle(
                    color: AppColor.TYPE_PRIMARY,
                    fontSize: 32.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(
                  height: 32.0,
                ),

                Container(
                  child: ListView.builder(
                    itemCount: 3,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index){
                      return InkWell(
                        onTap: (){
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 8),
                          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: AppColor.WHITE_COLOR,
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                              color: selectedIndex == index ? AppColor.THEME_PRIMARY : AppColor.TRANSPARENT,
                              width: 3.0,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                    color: AppColor.BACKGROUND_COLOR.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(24)
                                ),
                                child:  Image.asset(
                                  index == 0 ? 'assets/boarding/ic_stopwatch'
                                      : index == 1 ? 'assets/boarding/ic_superhero'
                                      : 'assets/boarding/ic_money',
                                  width: 24.0,
                                  height: 24.0,
                                  color:  AppColor.THEME_PRIMARY,
                                ),
                              ),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        index == 0 ? 'Complete an inspection in record time'
                                            : index == 1 ? 'Help me become a hero by identifying safety hazards '
                                            : 'Generate new leads and close deals',
                                        style: TextStyle(
                                            color: AppColor.TYPE_PRIMARY,
                                            fontSize: TextSize.headerText,
                                            fontStyle: FontStyle.normal,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'WorkSans'
                                        ),
                                      ),
                                    ),

                                    Container(
                                      margin: EdgeInsets.only(left: 8.0, top: 8.0),
                                      child: Text(
                                        index == 0 ? ''
                                            : index == 1 ? 'With more than 150 inspections points we’ll help you and your clients stay safe.'
                                            : '',
                                        style: TextStyle(
                                            color: AppColor.TYPE_PRIMARY.withOpacity(0.60),
                                            fontSize: TextSize.subjectTitle,
                                            fontStyle: FontStyle.normal,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'WorkSans'
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 120.0,)
              ],
            ),
          ),

          // Submit
          Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: BottomGeneralButton(
                onStartButton: (){
                  if(selectedIndex != -1){
                    updateQuestion();
                  }
                },
                buttonName: "CONTINUE",
                isActive: selectedIndex != -1,
              )
          ),

          _progressHUD
        ],
      ),
    );
  }

  void updateQuestion() async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var requestJson = {"selected": true};
    var questionId = "46";

    var simpleListId = "${selectedIndex+234}";

    var requestParam = json.encode(requestJson);
    var response = await request.postRequest(
        "auth/me/personalplan/$questionId/$simpleListId",
        requestParam
    );
    //auth/me/personalplan/{{questionid}}/{{simplelistid}}
    _progressHUD.state.dismiss();

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage('${response['reason']}');
      } else {
        Navigator.push(
            context,
            SlideRightRoute(
                page: SignUpExperiencePoolPage()
            )
        );
      }
    }
  }
}
