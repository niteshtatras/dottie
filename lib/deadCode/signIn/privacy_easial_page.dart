import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PrivacyEasyLifePage extends StatefulWidget {
  @override
  _PrivacyEasyLifePageState createState() => _PrivacyEasyLifePageState();
}

class _PrivacyEasyLifePageState extends State<PrivacyEasyLifePage> {
  int selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.WHITE_COLOR,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: AppColor.WHITE_COLOR,
        leading: IconButton(
          padding: EdgeInsets.only(left: 16.0, right: 16.0),
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColor.TYPE_PRIMARY,
            size: 32.0,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 10.0,),
                  Container(
                    margin: EdgeInsets.only(left: 32.0, right:32.0),
                    child: Text(
                      'How can we make your life easier?',
                      style: TextStyle(
                          color: AppColor.TYPE_PRIMARY,
                          fontSize: TextSize.greetingTitleText,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.normal,
                          fontFamily: "WorkSans"
                      ),
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: ListView.builder(
                      itemCount: 3,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index){
                        return InkWell(
                          onTap: (){
                            setState(() {

                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 8.0),
                            padding: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 16.0),
                            decoration: BoxDecoration(
                              color: AppColor.WHITE_COLOR,
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(
                                color: selectedIndex == index ? AppColor.THEME_PRIMARY : AppColor.TRANSPARENT,
                                width: 3.0,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                            minHeight: 40
                                        ),
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          padding: EdgeInsets.only(right: 8.0),
                                          child: Text(
                                            index == 0
                                                ? 'Placeholder'
                                                : index == 1
                                                ? 'Placeholder'
                                                : 'None',
                                            style: TextStyle(
                                                color: AppColor.TYPE_PRIMARY,
                                                fontSize: TextSize.subjectTitle,
                                                fontStyle: FontStyle.normal,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'WorkSans'
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: index != 2,
                                      child: Container(
                                        margin: EdgeInsets.only(left: 8.0),
                                        height: 40.0,
                                        width: 40.0,
                                        decoration: BoxDecoration(
                                            color: selectedIndex == index ? AppColor.THEME_PRIMARY : AppColor.PAGE_COLOR,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color:  selectedIndex == index ? AppColor.TRANSPARENT : AppColor.TYPE_SECONDARY,
                                              width: 1.0,
                                            )
                                        ),
                                        child: Icon(
                                          Icons.done,
                                          size: 24.0,
                                          color: AppColor.PAGE_COLOR,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                ],
              ),
            ),
            // Submit Button
            Positioned(
              bottom: 16.0,
              left: 20.0,
              right: 20.0,
              child: InkWell(
                onTap: (){
                  if(selectedIndex != -1){

                  }
                },
                child: Container(
                  margin: EdgeInsets.only(top: 24.0),
                  height: 56.0,
                  decoration: BoxDecoration(
                      color: selectedIndex != -1 ? AppColor.THEME_PRIMARY : AppColor.TYPE_PRIMARY.withOpacity(0.08),
                      borderRadius: BorderRadius.all(Radius.circular(16.0))
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'NEXT',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: selectedIndex != -1 ? AppColor.WHITE_COLOR : AppColor.TYPE_PRIMARY.withOpacity(0.6),
                            fontSize: TextSize.subjectTitle,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
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
      ),
    );
  }
}
