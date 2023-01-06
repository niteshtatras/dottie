import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PersonalInfoNameEditPage extends StatefulWidget {
  final title;
  final value;

  const PersonalInfoNameEditPage({Key key, this.title, this.value}) : super(key: key);

  @override
  _PersonalInfoNameEditPageState createState() => _PersonalInfoNameEditPageState();
}

class _PersonalInfoNameEditPageState extends State<PersonalInfoNameEditPage> {

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _firstNameController.text = 'Bruce';
    _lastNameController.text = 'Wayne';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EmptyAppBar(isDarkMode: false),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
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
                            '${widget.title}',
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

                  //First Name
                  Container(
                    margin: EdgeInsets.only(top: 28.0 ,left: 20.0, right: 20.0),
                    child:TextFormField(
                      controller: _firstNameController,
                      focusNode: null,
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                          fillColor: AppColor.BG_PRIMARY_ALT,
                          border: InputBorder.none,
                          hintText: "First Name",
                          hintStyle: TextStyle(
                              fontSize: TextSize.bodyText,
                              color: AppColor.TYPE_SECONDARY
                          )

                      ),
                      style: TextStyle(
                          color: AppColor.TYPE_PRIMARY,
                          fontWeight: FontWeight.w400,
                          fontSize: TextSize.subjectTitle
                      ),
                      inputFormatters: [LengthLimitingTextInputFormatter(40)],
                    ),
                  ),
                  Divider(
                    height: 1.0,
                    color: AppColor.SEC_DIVIDER,
                  ),

                  //Last Name
                  Container(
                    margin: EdgeInsets.only(top: 28.0 ,left: 20.0, right: 20.0),
                    child:TextFormField(
                      controller: _lastNameController,
                      focusNode: null,
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                          fillColor: AppColor.BG_PRIMARY_ALT,
                          border: InputBorder.none,
                          hintText: "Last Name",
                          hintStyle: TextStyle(
                              fontSize: TextSize.bodyText,
                              color: AppColor.TYPE_SECONDARY
                          )

                      ),
                      style: TextStyle(
                          color: AppColor.TYPE_PRIMARY,
                          fontWeight: FontWeight.w400,
                          fontSize: TextSize.subjectTitle
                      ),
                      inputFormatters: [LengthLimitingTextInputFormatter(40)],
                    ),
                  ),
                  Divider(
                    height: 1.0,
                    color: AppColor.SEC_DIVIDER,
                  ),
                ],
              ),
            ),

            //Submit Button
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: GestureDetector(
                onTap: (){

                },
                child: Container(
                  margin: EdgeInsets.only(top: 24.0),
                  height: 56.0,
                  decoration: BoxDecoration(
                      color: AppColor.THEME_PRIMARY,
                      borderRadius: BorderRadius.all(Radius.circular(4.0))
                  ),
                  child: Center(
                    child: Text(
                      'Save Changes',
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
    );
  }
}
