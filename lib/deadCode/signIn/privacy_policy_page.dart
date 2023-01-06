import 'package:dottie_inspector/pages/signInPages/privacy_policy_confirm_page.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/custom_toast.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatefulWidget {
  @override
  _PrivacyPolicyPageState createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.WHITE_COLOR,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: AppColor.WHITE_COLOR,
        title: Text(
          '',
          style: TextStyle(
              color: AppColor.TYPE_PRIMARY,
              fontSize: TextSize.headerText,
              fontWeight: FontWeight.w600),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 40.0,),
                    Image(
                      image: AssetImage('assets/splash_main.png'),
                      fit: BoxFit.cover,
                      height: 150.0,
                      width: 150.0,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 12.0),
                      child: Text(
                        'Your Privacy',
                        style: TextStyle(
                            color: AppColor.TYPE_PRIMARY,
                            fontSize: TextSize.greetingTitleText,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            fontFamily: "WorkSans"
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 16.0, left: 30.0, right: 30.0),
                      child: Text(
                        'How much would you like to know on how Dottie protects your data and respects your privacy?',
                        style: TextStyle(
                            color: AppColor.TYPE_SECONDARY,
                            fontSize: TextSize.subjectTitle,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            fontFamily: "WorkSans",
                            height: 1.3
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              // Submit Button
              Positioned(
                bottom: 16.0,
                left: 0.0,
                right: 0.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: (){
//                        CustomToast.showToastMessage("Nothing");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PrivacyPolicyConfirmPage()
                          )
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 20.0),
                        alignment: Alignment.bottomCenter,
                        height: 56.0,
                        decoration: BoxDecoration(
                            color: AppColor.THEME_PRIMARY,
                            borderRadius: BorderRadius.all(Radius.circular(4.0))
                        ),
                        child: Center(
                          child: Text(
                            'NOTHING',
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
                    InkWell(
                      onTap: (){
//                        CustomToast.showToastMessage("Only the highlights");
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PrivacyPolicyConfirmPage()
                            )
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 16.0),
                        alignment: Alignment.bottomCenter,
                        height: 56.0,
                        decoration: BoxDecoration(
                            color: AppColor.THEME_PRIMARY,
                            borderRadius: BorderRadius.all(Radius.circular(4.0))
                        ),
                        child: Center(
                          child: Text(
                            'ONLY THE HIGHLIGHTS',
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
                    InkWell(
                      onTap: (){
//                        CustomToast.showToastMessage("Everything");
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PrivacyPolicyConfirmPage()
                            )
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 16.0),
                        alignment: Alignment.bottomCenter,
                        height: 56.0,
                        decoration: BoxDecoration(
                            color: AppColor.THEME_PRIMARY,
                            borderRadius: BorderRadius.all(Radius.circular(4.0))
                        ),
                        child: Center(
                          child: Text(
                            'EVERYTHING',
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
                  ],
                ),
              ),
            ]
        ),
      ),
    );
  }
}
