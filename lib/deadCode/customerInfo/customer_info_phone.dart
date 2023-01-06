import 'dart:convert';

import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:dottie_inspector/widget/bottom_general_button_widget.dart';
import 'package:dottie_inspector/widget/masked_phone_number.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_hud/progress_hud.dart';

import '../models/country_list_page.dart';

class AddCustomerInfoPhone extends StatefulWidget {
  final phoneData;
  final type;
  final clientId;

  const AddCustomerInfoPhone({Key key, this.phoneData, this.type, this.clientId}) : super(key: key);

  @override
  _AddCustomerInfoPhoneState createState() => _AddCustomerInfoPhoneState();
}

class _AddCustomerInfoPhoneState extends State<AddCustomerInfoPhone> {
  bool _allFieldValidate = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var _phoneController = MaskedTextController(mask: '(000) 000-0000');

//  final _phoneController = TextEditingController();
  FocusNode phoneFocus = FocusNode();
  int selectedIndex = -1;
  bool autoValidate = false;
  bool isFocusOn = true;
  bool isPhoneFocus = false;
  var countryData;
  var type = '';
  var clientId = '';

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

    String phoneNumber = widget.phoneData != null ? widget.phoneData['phoneno'] : "";
    String normalPhoneNumber = phoneNumber
        .replaceAll("(","")
        .replaceAll(")","")
        .replaceAll(" ","")
        .replaceAll("-","");
    String formattedPhoneNumber = normalPhoneNumber.length > 5
        ? "(" + normalPhoneNumber.substring(0,3) + ") " +
        normalPhoneNumber.substring(3,6) + "-" + normalPhoneNumber.substring(6, normalPhoneNumber.length)
        : normalPhoneNumber;

    print(formattedPhoneNumber);

    _phoneController.text = formattedPhoneNumber;
    selectedIndex = widget.phoneData != null ? widget.phoneData['selectedIndex'] : -1;
    _allFieldValidate = _phoneController.text.isNotEmpty && selectedIndex != -1;

    phoneFocus.addListener(() {
      setState(() {
        isFocusOn = !phoneFocus.hasFocus;
        isPhoneFocus = phoneFocus.hasFocus;
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
          icon: Icon(
            Icons.clear,
            color: AppColor.TYPE_PRIMARY,
            size: 28.0,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
//        actions: <Widget>[
//          GestureDetector(
//            onTap: (){
//              setState(() {
//                selectedIndex = -1;
//                _phoneController.text = "";
//                _allFieldValidate = false;
//                countryData = null;
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
          'Add Phone Number',
          style: TextStyle(
              color: AppColor.TYPE_PRIMARY,
              fontSize: TextSize.headerText,
              fontWeight: FontWeight.w600),
        ),
      ),
      body: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //Country Name
                  GestureDetector(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CountryListPage(
                            type: 2,
                          )
                        )
                      ).then((result) {
                        if(result != null){
                          if(result['countryData'] != null){
                            setState(() {
                              countryData = result['countryData'];
                            });
                          }
                        }
                        _allFieldValidate = _formKey.currentState.validate() && (selectedIndex != -1);
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 8.0),
                      padding: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 16.0),
                      decoration: BoxDecoration(
                        color: AppColor.WHITE_COLOR,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: AppColor.TRANSPARENT,
                          width: 3.0,
                        ),
                      ),
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        countryData == null ? 'United State' : countryData['mixedcase'] != null ? countryData['mixedcase'] : countryData['countryname'],
                        style: TextStyle(
                            color: AppColor.THEME_PRIMARY,
                            fontSize: TextSize.headerText,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'WorkSans',
                            fontStyle: FontStyle.normal
                        ),
                      ),
                    ),
                  ),

                  //Phone
                  Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        //Phone
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                          padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                          decoration: BoxDecoration(
                              color: isPhoneFocus
                                  ? AppColor.THEME_PRIMARY.withOpacity(0.08)
                                  : AppColor.WHITE_COLOR,
                              borderRadius: BorderRadius.circular(16.0)
                          ),
                          child:TextFormField(
                            controller: _phoneController,
                            focusNode: phoneFocus,
                            textAlign: TextAlign.start,
                            autofocus: false,
                            keyboardType: TextInputType.number,
                            validator: validatePhone,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              fillColor: AppColor.WHITE_COLOR,
                              hintText: "Phone Number",
                              contentPadding: EdgeInsets.symmetric(horizontal: 0.0,),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(width: 1, color: AppColor.TRANSPARENT),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(width: 1, color: AppColor.TRANSPARENT),
                              ),
                              labelText: 'Phone Number',
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
                        itemCount: 5,
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
                                  index == 0 ? 'Home' : index == 1 ? 'Mobile' : index == 2 ? 'Work' : index == 3 ? 'Primary' : 'Other',
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
                  var phoneString = _phoneController.text.toString().trim()
                      .replaceAll(" ", "")
                      .replaceAll("(", "")
                      .replaceAll(")", "")
                      .replaceAll("-", "");
                  print(phoneString);

                  Map phoneData = {
                    "phoneid": widget.phoneData == null ? "" : "${widget.phoneData['phoneid']}",
                    "phoneno": "$phoneString",
                    "phonetag": "${getLabelText(selectedIndex)}",
                    "clientphonepreferred": false,
                    "selectedIndex" : selectedIndex
                  };

                  if(widget.phoneData == null){
                    createClientPhone(phoneData);
                  } else {
                    updateClientPhone(phoneData);
                  }
                }else{
                  setState(() {
                    phoneFocus.requestFocus(FocusNode());
                    autoValidate = true;
                  });
                }
              },
              buttonName: "Save Mobile Number",
            ),
          ),

          _progressHUD
        ],
      ),
    );
  }

  String validatePhone(String value) {
    return value == '' ? 'Enter your phone number' : null;
  }

  String getLabelText(index){
    switch(index){
      case 0:
        return "Home";

      case 1:
        return "Mobile";

      case 2:
        return "Work";

      case 3:
        return "Primary";

      default:
        return "Other";
    }
  }

  ///////////////////////////API INTEGRATION////////////////////////
  Future<void> createClientPhone(phoneData) async {
    print("Create phone");
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var requestJson = {
      "phoneno":"${phoneData['phoneno']}",
      "phonetag":"${phoneData['phonetag']}"
    };
    var requestParam = json.encode(requestJson);
    var response = await request.postRequest("auth/myclient/$clientId/phone", requestParam);
    _progressHUD.state.dismiss();
    print("Phone post response get back: $response");

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        HelperClass.showSnackBar(context, '${response['reason']}');
      } else {
        Navigator.of(context).pop({"data": phoneData});
      }
    } else {
      HelperClass.showSnackBar(context, 'Something Went Wrong!');
    }
  }

  Future<void> updateClientPhone(phoneData) async {
    print("Update phone");
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var requestJson = {
      "phoneno":"${phoneData['phoneno']}",
      "phonetag":"${phoneData['phonetag']}"
    };
    var requestParam = json.encode(requestJson);
    var response = await request.patchRequest("auth/myclient/$clientId/phone/${phoneData['phoneid']}", requestParam);
    _progressHUD.state.dismiss();
    print("Phone post response get back: $response");

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        HelperClass.showSnackBar(context, '${response['reason']}');
      } else {
        Navigator.of(context).pop({"data": phoneData});
      }
    } else {
      HelperClass.showSnackBar(context, 'Something Went Wrong!');
    }
  }
}
