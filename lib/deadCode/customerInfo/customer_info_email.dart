import 'dart:convert';

import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:dottie_inspector/widget/bottom_general_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_hud/progress_hud.dart';

class AddCustomerInfoEmail extends StatefulWidget {
  final emailData;
  final clientId;
  final type;

  const AddCustomerInfoEmail({Key key, this.emailData, this.type, this.clientId}) : super(key: key);

  @override
  _AddCustomerInfoEmailState createState() => _AddCustomerInfoEmailState();
}

class _AddCustomerInfoEmailState extends State<AddCustomerInfoEmail> {
  final _emailController = TextEditingController();
  FocusNode emailFocus = FocusNode();
  bool isEmailFocus = false;
  bool isFocusOn = true;

  int selectedIndex = -1;
  bool autoValidate = false;
  bool _allFieldValidate = false;
  var type = '';
  var clientId = '';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;

  @override
  void initState() {
    super.initState();
    _progressHUD = ProgressHUD(
      backgroundColor: Colors.transparent,
      color: Colors.white,
      containerColor: AppColor.LOADER_COLOR,
      borderRadius: 5.0,
      loading: _loading,
      text: 'Loading...',
    );

    clientId = widget.clientId ?? "";
    type = widget.type ?? "";
    _emailController.text = widget.emailData != null ? widget.emailData['email'] : "";
    selectedIndex = widget.emailData != null ? widget.emailData['selectedIndex'] : -1;
    _allFieldValidate = _emailController.text.isNotEmpty && selectedIndex != -1;

    emailFocus.addListener(() {
      setState(() {
        isFocusOn = !emailFocus.hasFocus;
        isEmailFocus = emailFocus.hasFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColor.PAGE_COLOR,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: AppColor.PAGE_COLOR,
        leading: IconButton(
          padding: EdgeInsets.only(left: 16.0, right: 16.0),
          icon: Icon(Icons.keyboard_backspace,color: AppColor.TYPE_PRIMARY,size: 32.0,),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
//        actions: <Widget>[
//          GestureDetector(
//            onTap: (){
//              setState(() {
//                selectedIndex = -1;
//                _emailController.text = "";
//                _allFieldValidate = false;
//                FocusScope.of(context).requestFocus(FocusNode());
//              });
//            },
//            child: Container(
//              padding: EdgeInsets.all(16.0),
//              child: Image.asset(
//                'assets/ic_delete.png',
//                fit: BoxFit.contain,
//                height: 28.0,
//                width: 28.0,
//                color: AppColor.RED_COLOR,
//              ),
//            ),
//          )
//        ],
        title: Text(
          'Add Email Address',
          style: TextStyle(
              color: AppColor.TYPE_PRIMARY,
              fontSize: TextSize.headerText,
              fontWeight: FontWeight.w600
          ),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[

                    Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          //Email
                          Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                            padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                            decoration: BoxDecoration(
                                color: isEmailFocus
                                    ? AppColor.THEME_PRIMARY.withOpacity(0.08)
                                    : AppColor.WHITE_COLOR,
                                borderRadius: BorderRadius.circular(16.0)
                            ),
                            child:TextFormField(
                              controller: _emailController,
                              focusNode: emailFocus,
                              textAlign: TextAlign.start,
                              autofocus: false,
                              validator: validateEmail,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                fillColor: AppColor.WHITE_COLOR,
                                hintText: "Email Address",
                                contentPadding: EdgeInsets.symmetric(horizontal: 0.0,),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                  borderSide: BorderSide(width: 1, color: AppColor.TRANSPARENT),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                  borderSide: BorderSide(width: 1, color: AppColor.TRANSPARENT),
                                ),
                                labelText: 'Email Address',
                                hintStyle: TextStyle(
                                    fontSize: TextSize.bodyText,
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.TYPE_SECONDARY
                                ),
                                labelStyle: TextStyle(
                                    fontSize: TextSize.bodyText,
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.TYPE_SECONDARY
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
                                  _allFieldValidate = _formKey.currentState.validate() && (selectedIndex != -1);
                                });
                              },
                            ),
                          ),
                          Divider(
                            height: 1.0,
                            color: AppColor.SEC_DIVIDER,
                          ),
                        ],
                      ),
                    ),


                    //Label
                    Container(
                      padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 22.0),
                      child:  Text(
                        'LABEL',
                        style: TextStyle(
                            color: AppColor.TYPE_SECONDARY,
                            fontSize: TextSize.bodyText,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'WorkSans'
                        ),
                      ),
                    ),
                    Container(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: 3,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index){
                            return Container(
                              margin: EdgeInsets.only(bottom: 8.0),
                              padding: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 16.0),
                              decoration: BoxDecoration(
                                color: AppColor.WHITE_COLOR,
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(
                                  color: AppColor.TRANSPARENT,
                                  width: 3.0,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    index == 0 ? 'Personal' : index == 1 ? 'Work' : 'Other',
                                    style: TextStyle(
                                        color: AppColor.TYPE_PRIMARY,
                                        fontSize: TextSize.headerText,
                                        fontStyle: FontStyle.normal,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'WorkSans'
                                    ),
                                  ),

                                  //
                                  GestureDetector(
                                    onTap: (){
                                      setState(() {
                                        selectedIndex = index;
                                        _allFieldValidate = selectedIndex != -1 && _formKey.currentState.validate();
                                        FocusScope.of(context).requestFocus(FocusNode());
                                      });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(left: 8.0),
                                      height: 48.0,
                                      width: 48.0,
                                      decoration: BoxDecoration(
                                          color: selectedIndex == index ? AppColor.THEME_PRIMARY.withOpacity(0.12) : AppColor.TYPE_PRIMARY.withOpacity(0.08),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: selectedIndex == index
                                                ? AppColor.TRANSPARENT
                                                : AppColor.TYPE_PRIMARY.withOpacity(0.6),
                                            width: 1.0,
                                          )
                                      ),
                                      child: Icon(
                                        Icons.done,
                                        size: 24.0,
                                        color: selectedIndex == index ? AppColor.THEME_PRIMARY : AppColor.TRANSPARENT,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                      ),
                    ),
                    SizedBox(height: 100.0,),
                  ],
                ),
              ),
            ),

            //Submit Button
            Visibility(
              visible: isFocusOn,
              child: BottomGeneralButton(
                isActive: _allFieldValidate,
                onStartButton: (){
                  if(_formKey.currentState.validate() && _allFieldValidate){
                    Map emailData = {
                      "emailid": widget.emailData == null ? "" : "${widget.emailData['emailid']}",
                      "email": "${_emailController.text.toString().trim()}",
                      "emailtag": "${getLabelText(selectedIndex)}",
                      "clientemailpreferred": false,
                      "selectedIndex" : selectedIndex
                    };

                    if(widget.emailData == null){
                      createClientEmail(emailData);
                    } else {
                      updateClientEmail(emailData);
                    }
                  } else{
                    setState(() {
                      autoValidate = true;
                      emailFocus.requestFocus(FocusNode());
                    });
                  }
                },
                buttonName: "Save Email Address",
              ),
            ),

            _progressHUD
          ],
        ),
      ),
    );
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if(value != '') {
      if (!regex.hasMatch(value))
        return 'Enter your valid email address';
      else
        return null;
    } else {
      return 'Enter your email address';
    }
  }

  String getLabelText(index){
    switch(index){
      case 0:
        return "Personal";

      case 1:
        return "Work";

      default:
        return "Other";
    }
  }

  ///////////////////////////API INTEGRATION////////////////////////
  Future<void> createClientEmail(emailData) async {
    print("Create Email");
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var requestJson = {
      "email":"${emailData['email']}",
      "clientemailtag":"${emailData['emailtag']}",
      "clientemailpreferred": false
    };

    var requestParam = json.encode(requestJson);
    var response = await request.postRequest("auth/myclient/$clientId/email", requestParam);
    _progressHUD.state.dismiss();
    print("Phone post response get back: $response");

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        HelperClass.showSnackBar(context, '${response['reason']}');
      } else {
        Navigator.of(context).pop({"data": emailData});
      }
    } else {
      HelperClass.showSnackBar(context, 'Something Went Wrong!');
    }
  }

  Future<void> updateClientEmail(emailData) async {
    print("Update Email");
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var requestJson = {
      "email":"${emailData['email']}",
      "clientemailtag":"${emailData['emailtag']}",
      "clientemailpreferred": false
    };

    var requestParam = json.encode(requestJson);
    var response = await request.patchRequest("auth/myclient/$clientId/email/${emailData['emailid']}", requestParam);
    _progressHUD.state.dismiss();
    print("Phone post response get back: $response");

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        HelperClass.showSnackBar(context, '${response['reason']}');
      } else {
        Navigator.of(context).pop({"data": emailData});
      }
    } else {
      HelperClass.showSnackBar(context, 'Something Went Wrong!');
    }
  }
}
