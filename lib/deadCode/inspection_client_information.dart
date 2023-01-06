import 'package:dottie_inspector/pages/inspectionMain/inspection_location_page.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/SlideRightRoute.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class LocationClientInformation extends StatefulWidget {
  @override
  _LocationClientInformationState createState() => _LocationClientInformationState();
}

class _LocationClientInformationState extends State<LocationClientInformation> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();

  FocusNode firstNameFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();

  var imagePath = '';
  bool _autoValidate = false;
  bool _allFieldValidate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColor.WHITE_COLOR,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: AppColor.WHITE_COLOR,
        leading: IconButton(
          padding: EdgeInsets.only(left: 16.0, right: 16.0),
          icon: Icon(Icons.clear,color: AppColor.TYPE_PRIMARY,size: 28.0,),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 10.0,),
                  Text(
                    'Start: 1 of 4',
                    style: TextStyle(
                        color: AppColor.TYPE_SECONDARY,
                        fontSize: TextSize.subjectTitle,
                        fontWeight: FontWeight.w600
                    ),
                    textAlign: TextAlign.center,
                  ),

                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: 60.0,vertical: 8.0),
                    child: LinearPercentIndicator(
                      animationDuration: 200,
                      backgroundColor: Color(0xffE5E5E5),
                      percent: 0.25,
                      lineHeight: 8.0,
                      progressColor: AppColor.HEADER_COLOR,
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 36.0,vertical: 8.0),
                    alignment: Alignment.center,
                    child: Text(
                      'Let’s begin by adding  client information',
                      style: TextStyle(
                          fontSize: TextSize.pageTitleText,
                          color: AppColor.TYPE_PRIMARY,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  SizedBox(height: 24.0,),
                  Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [

                        //First Name
                        Container(
                          padding: EdgeInsets.symmetric(horizontal:24.0,),
                          child:  Text(
                            'Client’s first name*',
                            style: TextStyle(
                                color: AppColor.TYPE_PRIMARY.withOpacity(0.6),
                                fontSize: TextSize.subjectTitle,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Work Sans'
                            ),
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(top: 8.0 ,left: 24.0, right: 24.0),
                          child:TextFormField(
                            controller: _firstNameController,
                            focusNode: firstNameFocus,
                            textAlign: TextAlign.start,
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            autofocus: false,
                            validator: (value){
                              return validateString(value, "client's first name");
                            },
                            onFieldSubmitted: (term) {
                              firstNameFocus.unfocus();
                              FocusScope.of(context).requestFocus(lastNameFocus);
                            },
                            decoration: InputDecoration(
                                fillColor: AppColor.WHITE_COLOR,
                                filled: true,
                                border: InputBorder.none,
                                hintText: "",
                                hintStyle: TextStyle(
                                    fontSize: TextSize.subjectTitle,
                                    color: AppColor.TYPE_PRIMARY.withOpacity(0.6)
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                    borderSide: BorderSide(
                                      color: AppColor.THEME_PRIMARY,
                                      width: 3,
                                    )
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                                  borderSide: BorderSide(width: 1,color: AppColor.WHITE_COLOR),
                                ),
                                errorBorder: UnderlineInputBorder(
                                    borderSide: new BorderSide(
                                        color: Colors.red
                                    )
                                )
                            ),
                            style: TextStyle(
                                color: AppColor.TYPE_PRIMARY,
                                fontWeight: FontWeight.w600,
                                fontSize: TextSize.subjectTitle
                            ),
                            inputFormatters: [LengthLimitingTextInputFormatter(40)],
                            onChanged: (value){
                              setState(() {
                                _allFieldValidate = _formKey.currentState.validate();
                              });
                            },
                          ),
                        ),

                        //Last Name
                        Container(
                          margin: EdgeInsets.only(top: 32.0),
                          padding: EdgeInsets.symmetric(horizontal:24.0,),
                          child:  Text(
                            'Client’s last name*',
                            style: TextStyle(
                                color: AppColor.TYPE_PRIMARY.withOpacity(0.6),
                                fontSize: TextSize.subjectTitle,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Work Sans'
                            ),
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(top: 8.0 ,left: 24.0, right: 24.0),
                          child:TextFormField(
                            controller: _lastNameController,
                            focusNode: lastNameFocus,
                            textAlign: TextAlign.start,
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            autofocus: false,
                            validator: (value){
                              return validateString(value, "client's last name");
                            },
                            onFieldSubmitted: (term) {
                              lastNameFocus.unfocus();
                              FocusScope.of(context).requestFocus(emailFocus);
                            },
                            decoration: InputDecoration(
                                fillColor: AppColor.WHITE_COLOR,
                                filled: true,
                                border: InputBorder.none,
                                hintText: "",
                                hintStyle: TextStyle(
                                    fontSize: TextSize.subjectTitle,
                                    color: AppColor.TYPE_PRIMARY.withOpacity(0.6)
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                    borderSide: BorderSide(
                                      color: AppColor.THEME_PRIMARY,
                                      width: 3,
                                    ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                                  borderSide: BorderSide(width: 1,color: AppColor.WHITE_COLOR),
                                ),
                                errorBorder: UnderlineInputBorder(
                                    borderSide: new BorderSide(
                                        color: Colors.red
                                    )
                                )
                            ),
                            style: TextStyle(
                                color: AppColor.TYPE_PRIMARY,
                                fontWeight: FontWeight.w600,
                                fontSize: TextSize.subjectTitle
                            ),
                            onSaved: (value){
                              print("search");
                            },
                            inputFormatters: [LengthLimitingTextInputFormatter(40)],
                            onChanged: (value){
                              setState(() {
                                _allFieldValidate = _formKey.currentState.validate();
                              });
                            },
                          ),
                        ),

                        //Email Address
                        Container(
                          margin: EdgeInsets.only(top: 32.0),
                          padding: EdgeInsets.symmetric(horizontal:24.0,),
                          child:  Text(
                            'Client’s email*',
                            style: TextStyle(
                                color: AppColor.TYPE_PRIMARY.withOpacity(0.6),
                                fontSize: TextSize.subjectTitle,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Work Sans'
                            ),
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(top: 8.0 ,left: 24.0, right: 24.0),
                          child:TextFormField(
                            controller: _emailController,
                            focusNode: emailFocus,
                            textAlign: TextAlign.start,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            autofocus: false,
                            validator: validateEmail,
                            decoration: InputDecoration(
                                fillColor: AppColor.WHITE_COLOR,
                                filled: true,
                                border: InputBorder.none,
                                hintText: "",
                                hintStyle: TextStyle(
                                    fontSize: TextSize.subjectTitle,
                                    color: AppColor.TYPE_PRIMARY.withOpacity(0.6)
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                    borderSide: BorderSide(
                                      color: AppColor.THEME_PRIMARY,
                                      width: 3,
                                    )
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                                  borderSide: BorderSide(width: 1,color: AppColor.WHITE_COLOR),
                                ),
                                errorBorder: UnderlineInputBorder(
                                    borderSide: new BorderSide(
                                        color: Colors.red
                                    )
                                ),
                            ),
                            style: TextStyle(
                                color: AppColor.TYPE_PRIMARY,
                                fontWeight: FontWeight.w600,
                                fontSize: TextSize.subjectTitle
                            ),
                            inputFormatters: [LengthLimitingTextInputFormatter(40)],
                            onChanged: (value){
                              setState(() {
                                _allFieldValidate = _formKey.currentState.validate();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 160.0,)

                ],
              ),
            ),
          ),

          //Submit Button
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0, top: 12.0),
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
              child: GestureDetector(
                onTap: (){
                  /*if(_formKey.currentState.validate() && _allFieldValidate){
                    Map nameData = {
                      "first_name": "${_firstNameController.text.toString().trim()}",
                      "last_name": "${_lastNameController.text.toString().trim()}",
                      "email": "${_emailController.text.toString().trim()}"
                    };
                    Navigator.push(
                      context,
                      SlideRightRoute(
                        page: InspectionLocationPage()
                      )
                    );
                  } else {
                    setState(() {
                      firstNameFocus.requestFocus(FocusNode());
                      _autoValidate = true;
                    });
                  }*/
                  Navigator.push(
                      context,
                      SlideRightRoute(
                          page: InspectionLocationPage()
                      )
                  );
                },
                child: Container(
                  height: 56.0,
                  decoration: BoxDecoration(
                      color: _allFieldValidate ? AppColor.THEME_PRIMARY : AppColor.TYPE_DISABLE,
                      borderRadius: BorderRadius.all(Radius.circular(4.0))
                  ),
                  child: Center(
                    child: Text(
                      'CONTINUE',
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
          ),
        ],
      ),
    );
  }

  String validateString(String value, String type) {
    if(value!='' && value!=null) {
      if(!value.startsWith(' '))
        return null;
      else
        return 'Enter $type';
    }
    else {
      return 'Enter $type';
    }
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if(value != '') {
      if (!regex.hasMatch(value))
        return 'Enter client\'s valid email address';
      else
        return null;
    } else {
      return 'Enter client\'s email address';
    }
  }
}
