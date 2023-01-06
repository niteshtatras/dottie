import 'package:dottie_inspector/deadCode/personalInfo/personal_info_email_edit.dart';
import 'package:dottie_inspector/deadCode/personalInfo/personal_info_name_edit.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PersonalInfoDisplayPage extends StatefulWidget {
  @override
  _PersonalInfoDisplayPageState createState() => _PersonalInfoDisplayPageState();
}

class _PersonalInfoDisplayPageState extends State<PersonalInfoDisplayPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EmptyAppBar(isDarkMode: false),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            //App Bar
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 16.0),
              height: 64.0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Image.asset(
                      'assets/ic_back.png',
                      height: 18.0,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Personal Info',
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: TextSize.subjectTitle,
                          color: AppColor.TYPE_PRIMARY
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            //Name
            GestureDetector(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PersonalInfoNameEditPage(
                      title: "Name",
                      value: "Bruce Wayne",
                    )
                  )
                );
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Name',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: TextSize.metaDataLimited,
                                color: AppColor.TYPE_SECONDARY
                            ),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(
                            'Bruce Wayne',
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: TextSize.subjectTitle,
                                color: AppColor.TYPE_PRIMARY
                            ),
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      'assets/right_arrow.png',
                      height: 18.0,
                      color: AppColor.TYPE_PRIMARY,
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              height: 1.0,
              color: AppColor.SEC_DIVIDER,
            ),

            //Email
            GestureDetector(
              onTap: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PersonalInfoEmailEdit(
                          title: "Email",
                          value: "bruce@wayen.com",
                        )
                    )
                );
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Email',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: TextSize.metaDataLimited,
                                color: AppColor.TYPE_SECONDARY
                            ),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(
                            'bruce@Wayne.com',
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: TextSize.subjectTitle,
                                color: AppColor.TYPE_PRIMARY
                            ),
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      'assets/right_arrow.png',
                      height: 18.0,
                      color: AppColor.TYPE_PRIMARY,
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              height: 1.0,
              color: AppColor.SEC_DIVIDER,
            ),
          ],
        ),
      ),
    );
  }
}
