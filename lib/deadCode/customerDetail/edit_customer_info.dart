import 'dart:convert';

import 'package:dottie_inspector/deadCode/customerInfo/customer_info_email.dart';
import 'package:dottie_inspector/deadCode/customerInfo/customer_info_phone.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/custom_toast.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:dottie_inspector/widget/bottom_general_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_hud/progress_hud.dart';

class EditCustomerInfoPage extends StatefulWidget {
  final contact;

  const EditCustomerInfoPage({Key key, this.contact}) : super(key: key);

  @override
  _EditCustomerInfoPageState createState() => _EditCustomerInfoPageState();
}

class _EditCustomerInfoPageState extends State<EditCustomerInfoPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _allFieldValidate = false;
  bool isFocusOn = true;
  bool isFirstNameFocus = false;
  bool isLastNameFocus = false;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  FocusNode firstNameFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();

  List phoneList = [];
  List emailList = [];
//  Contact contact;
  Map nameData;
  Map customerData;

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

    customerData = widget.contact ?? null;

    if(customerData != null){
      setContactData();
    }

    firstNameFocus.addListener(() {
      setState(() {
        isFirstNameFocus = firstNameFocus.hasFocus;
        isFocusOn = !firstNameFocus.hasFocus;
      });
    });
    lastNameFocus.addListener(() {
      setState(() {
        isLastNameFocus = lastNameFocus.hasFocus;
        isFocusOn = !lastNameFocus.hasFocus;
      });
    });
  }

  void setContactData(){
    setState(() {
      emailList.clear();
      phoneList.clear();

      print("EmailList====>>>>${customerData['email']}");
      print("PhoneList====>>>>${customerData['phone']}");

      if(customerData['email'] != null) {
        for (int i = 0; i < customerData['email'].length; i++) {
          emailList.add({
            "emailid": "${customerData['email'][i]['emailid']}",
            "email": "${customerData['email'][i]['email']}",
            "emailtag": "${HelperClass.getEmailLabelText(HelperClass.getEmailLabelIndex(customerData['email'][i]['emailtag']))}",
            "clientemailpreferred": false,
            "selectedIndex": HelperClass.getEmailLabelIndex("${customerData['email'][i]['emailtag']}")
          });
        }
      }

      if(customerData['phone'] != null){
        for(int i=0; i<customerData['phone'].length; i++){
          phoneList.add({
            "phoneid": "${customerData['phone'][i]['phoneid']}",
            "phoneno": "${customerData['phone'][i]['phoneno']}",
            "phonetag": "${HelperClass.getLabelText(HelperClass.getLabelIndex(customerData['phone'][i]['phonetag']))}",
            "clientemailpreferred": false,
            "selectedIndex" : HelperClass.getLabelIndex("${customerData['phone'][i]['phonetag']}")
          });
        }
      }

      print("EmailList====>>>>$emailList");
      print("PhoneList====>>>>$phoneList");

      nameData = {
        "first_name": "${customerData['firstname']}",
        "last_name": "${customerData['lastname']}"
      };
      _firstNameController.text = customerData['firstname'];
      _lastNameController.text = customerData['lastname'];

      _allFieldValidate = true;
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
          icon: Icon(Icons.clear,color: AppColor.TYPE_PRIMARY,size: 28.0,),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Edit Customer’s Info.',
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: TextSize.headerText,
              color: AppColor.TYPE_PRIMARY
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  key: _formKey,
                  child: Container(
                    margin: EdgeInsets.only(left: 16.0, right: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        //first name
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                          padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                          decoration: BoxDecoration(
                              color: isFirstNameFocus
                                  ? AppColor.THEME_PRIMARY.withOpacity(0.08)
                                  : AppColor.WHITE_COLOR,
                              borderRadius: BorderRadius.circular(16.0)
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'First Name',
                                style: TextStyle(
                                    color: AppColor.TYPE_PRIMARY.withOpacity(0.8),
                                    fontSize: TextSize.subjectTitle,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Work Sans'
                                ),
                              ),
                              TextFormField(
                                controller: _firstNameController,
                                focusNode: firstNameFocus,
                                textAlign: TextAlign.start,
                                keyboardType: TextInputType.name,
                                textInputAction: TextInputAction.next,
                                validator: (value){
                                  return validateString(value, "first name");
                                },
                                onFieldSubmitted: (term) {
                                  firstNameFocus.unfocus();
                                  FocusScope.of(context).requestFocus(lastNameFocus);
                                },
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 0.0,vertical: 0.0),
                                    hintText: "Given Name",
                                    hintStyle: TextStyle(
                                        fontSize: TextSize.subjectTitle,
                                        color: AppColor.TYPE_PRIMARY.withOpacity(0.6),
                                        fontWeight: FontWeight.w600
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
                            ],
                          ),
                        ),

                        //last name
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                          padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                          decoration: BoxDecoration(
                              color: isLastNameFocus
                                  ? AppColor.THEME_PRIMARY.withOpacity(0.08)
                                  : AppColor.WHITE_COLOR,
                              borderRadius: BorderRadius.circular(16.0)
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Last Name',
                                style: TextStyle(
                                    color: AppColor.TYPE_PRIMARY.withOpacity(0.8),
                                    fontSize: TextSize.subjectTitle,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Work Sans'
                                ),
                              ),
                              TextFormField(
                                controller: _lastNameController,
                                focusNode: lastNameFocus,
                                textAlign: TextAlign.start,
                                keyboardType: TextInputType.name,
                                textInputAction: TextInputAction.done,
                                validator: (value){
                                  return validateString(value, "last name");
                                },
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 0.0,vertical: 0.0),
                                    hintText: "Family Name",
                                    hintStyle: TextStyle(
                                        fontSize: TextSize.subjectTitle,
                                        color: AppColor.TYPE_PRIMARY.withOpacity(0.6),
                                        fontWeight: FontWeight.w600
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
                            ],
                          ),
                        ),

                        ///Email
                        Container(
                          margin: EdgeInsets.only(top: 8.0),
                          child: ListView.builder(
                            itemCount: emailList != null ? emailList.length : 0,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index){
                              return Container(
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    GestureDetector(
                                      onTap: (){
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => AddCustomerInfoEmail(
                                                  emailData: emailList[index],
                                                  clientId: "${customerData['clientid']}",
                                                )
                                            )
                                        ).then((result){
                                          if(result != null){
                                            if(result['data'] != null){
                                              setState(() {
                                                emailList.removeAt(index);
                                                emailList.insert(index, result['data']);
                                              });
                                            }
                                          }
                                        });
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        margin: EdgeInsets.only(bottom: 16.0),
                                        decoration: BoxDecoration(
                                          color: AppColor.WHITE_COLOR,
                                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                                          border: Border.all(
                                              color: AppColor.WHITE_COLOR,
                                              width: 3.0
                                          ),
                                        ),
                                        child: IntrinsicHeight(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start ,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Expanded(
                                                flex: 60,
                                                child: Container(
                                                  padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'Email',
                                                        style: TextStyle(
                                                            color: AppColor.TYPE_PRIMARY,
                                                            fontSize: TextSize.bodyText,
                                                            fontWeight: FontWeight.w600,
                                                            fontFamily: 'WorkSans'
                                                        ),
                                                      ),
                                                      SizedBox(height: 3.0,),
                                                      Text(
                                                        '${emailList[index]['email']}',
                                                        style: TextStyle(
                                                            color: AppColor.TYPE_PRIMARY,
                                                            fontSize: TextSize.headerText,
                                                            fontWeight: FontWeight.w600,
                                                            fontFamily: 'WorkSans'
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: Container(
                                                  child:  VerticalDivider(
                                                    width: 1,
                                                    color: AppColor.DIVIDER,
                                                    thickness: 0.5,
                                                  ),
                                                ),
                                              ),

                                              Expanded(
                                                flex: 35,
                                                child: Container(
                                                  padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 16.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'Label',
                                                        style: TextStyle(
                                                            color: AppColor.TYPE_PRIMARY,
                                                            fontSize: TextSize.bodyText,
                                                            fontWeight: FontWeight.w600,
                                                            fontFamily: 'WorkSans'
                                                        ),
                                                      ),
                                                      SizedBox(height: 3.0,),
                                                      Text(
                                                        '${emailList[index]['emailtag']}',
                                                        style: TextStyle(
                                                            color: AppColor.THEME_PRIMARY,
                                                            fontSize: TextSize.headerText,
                                                            fontWeight: FontWeight.w600,
                                                            fontFamily: 'WorkSans'
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: -8.0,
                                      top: -8.0,
                                      child: GestureDetector(
                                        onTap: () {
                                          showLoading(context, "You\'re about to remove an email address.", "email", index);
                                        },
                                        child: Container(
                                          width: 40.0,
                                          height: 40.0,
                                          decoration: BoxDecoration(
                                              color: AppColor.RED_COLOR.withOpacity(0.08),
                                              borderRadius: BorderRadius.circular(24)
                                          ),
                                          child: Icon(
                                            Icons.remove,
                                            size: 24.0,
                                            color: AppColor.RED_COLOR,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
//                              return Column(
//                                crossAxisAlignment: CrossAxisAlignment.start,
//                                mainAxisAlignment: MainAxisAlignment.start,
//                                children: [
//                                  GestureDetector(
//                                    onTap: (){
//                                      bottomNavigation(context, "Edit Email Address", "Remove Email Address", 'email', index);
//                                    },
//                                    child: Container(
//                                      width: MediaQuery.of(context).size.width,
//                                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
//                                      decoration: BoxDecoration(
//                                          color: AppColor.WHITE_COLOR,
//                                          borderRadius: BorderRadius.circular(16)
//                                      ),
//                                      child: Column(
//                                        crossAxisAlignment: CrossAxisAlignment.start,
//                                        mainAxisAlignment: MainAxisAlignment.start,
//                                        children: <Widget>[
//                                          Text(
//                                            '${emailList[index]['emailtag']} Email',
//                                            style: TextStyle(
//                                                color: AppColor.TYPE_SECONDARY,
//                                                fontSize: TextSize.subjectTitle,
//                                                fontWeight: FontWeight.w400,
//                                                fontFamily: 'WorkSans'
//                                            ),
//                                          ),
//                                          SizedBox(height: 3.0,),
//                                          Text(
//                                            '${emailList[index]['email']}',
//                                            style: TextStyle(
//                                                color: AppColor.TYPE_PRIMARY,
//                                                fontSize: TextSize.headerText,
//                                                fontWeight: FontWeight.w600,
//                                                fontFamily: 'WorkSans'
//                                            ),
//                                          ),
//                                        ],
//                                      ),
//                                    ),
//                                  ),
//                                  Divider(
//                                    height: 1.0,
//                                    color: AppColor.SEC_DIVIDER,
//                                  ),
//                                ],
//                              );
                            },
                          ),
                        ),

                        ///Add Email Address
                        emailList != null && emailList.length > 1
                            ? Container()
                            : GestureDetector(
                          onTap: (){
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddCustomerInfoEmail(
                                      clientId: "${customerData['clientid']}",
                                    )
                                )
                            ).then((result){
                              if(result != null){
                                if(result['data'] != null){
                                  setState(() {
                                    emailList.add(result['data']);
                                  });
                                }
                              }
                            });
                          },
                          child: Container(
                          margin: EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0),
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                          decoration: BoxDecoration(
                              color: AppColor.THEME_PRIMARY.withOpacity(0.08),
                              borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                                Icon(
                                  Icons.add,
                                  size: 18,
                                  color: AppColor.THEME_PRIMARY,
                                ),
                                SizedBox(width: 8.0,),
                                Flexible(
                                  child: Text(
                                    emailList.length == 0 ? 'Email' : emailList.length == 1 ? 'Email' : '',
                                    style: TextStyle(
                                        color: AppColor.THEME_PRIMARY,
                                        fontSize: TextSize.subjectTitle,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'WorkSans'
                                    ),
                                  ),
                                ),
                          ],
                        ),
                              ),
                          ),

                        ///Phone
                        Container(
                          margin: EdgeInsets.only(top: 16.0),
                          child: ListView.builder(
                            itemCount: phoneList != null ? phoneList.length : 0,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index){
                              String normalPhoneNumber = phoneList[index]['phoneno']
                                                      .replaceAll("(","")
                                                      .replaceAll(")","")
                                                      .replaceAll(" ","")
                                                      .replaceAll("-","");
                              String formattedPhoneNumber = normalPhoneNumber.length > 5
                                  ? "(" + normalPhoneNumber.substring(0,3) + ") " +
                                    normalPhoneNumber.substring(3,6) + "-" + normalPhoneNumber.substring(6, normalPhoneNumber.length)
                                  : normalPhoneNumber;

                              print(formattedPhoneNumber);
                              return Container(
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    GestureDetector(
                                      onTap: (){
                                        Navigator.push(
                                            _scaffoldKey.currentContext,
                                            MaterialPageRoute(
                                                builder: (context) => AddCustomerInfoPhone(
                                                  phoneData: phoneList[index],
                                                  clientId: "${customerData['clientid']}",
                                                )
                                            )
                                        ).then((result){
                                          if(result != null){
                                            if(result['data'] != null){
                                              setState(() {
                                                phoneList.removeAt(index);
                                                phoneList.insert(index, result['data']);
                                              });
                                            }
                                          }
                                        });
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        margin: EdgeInsets.only(bottom: 16.0),
                                        decoration: BoxDecoration(
                                          color: AppColor.WHITE_COLOR,
                                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                                          border: Border.all(
                                              color: AppColor.WHITE_COLOR,
                                              width: 3.0
                                          ),
                                        ),
                                        child: IntrinsicHeight(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start ,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Expanded(
                                                flex: 60,
                                                child: Container(
                                                  padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 16.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                    Text(
                                                       'Phone',
                                                        style: TextStyle(
                                                            color: AppColor.TYPE_PRIMARY,
                                                            fontSize: TextSize.bodyText,
                                                            fontWeight: FontWeight.w600,
                                                            fontFamily: 'WorkSans'
                                                        ),
                                                      ),
                                                      SizedBox(height: 3.0,),
                                                      Text(
                                                        '$formattedPhoneNumber',
                                                        style: TextStyle(
                                                            color: AppColor.TYPE_PRIMARY,
                                                            fontSize: TextSize.headerText,
                                                            fontWeight: FontWeight.w600,
                                                            fontFamily: 'WorkSans'
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: Container(
                                                  child:  VerticalDivider(
                                                    width: 1,
                                                    color: AppColor.DIVIDER,
                                                    thickness: 0.5,
                                                  ),
                                                ),
                                              ),

                                              Expanded(
                                                flex: 35,
                                                child: Container(
                                                  padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 16.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'Label',
                                                        style: TextStyle(
                                                            color: AppColor.TYPE_PRIMARY,
                                                            fontSize: TextSize.bodyText,
                                                            fontWeight: FontWeight.w600,
                                                            fontFamily: 'WorkSans'
                                                        ),
                                                      ),
                                                      SizedBox(height: 3.0,),
                                                      Text(
                                                        '${phoneList[index]['phonetag']}',
                                                        style: TextStyle(
                                                            color: AppColor.THEME_PRIMARY,
                                                            fontSize: TextSize.headerText,
                                                            fontWeight: FontWeight.w600,
                                                            fontFamily: 'WorkSans'
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: -8.0,
                                      top: -8.0,
                                      child: GestureDetector(
                                        onTap: () {
                                          showLoading(context, "You\'re about to remove a phone number.", "phone", index);
                                        },
                                        child: Container(
                                          width: 40.0,
                                          height: 40.0,
                                          decoration: BoxDecoration(
                                              color: AppColor.RED_COLOR.withOpacity(0.08),
                                              borderRadius: BorderRadius.circular(24)
                                          ),
                                          child: Icon(
                                            Icons.remove,
                                            size: 24.0,
                                            color: AppColor.RED_COLOR,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );

//                              return Column(
//                                crossAxisAlignment: CrossAxisAlignment.start,
//                                mainAxisAlignment: MainAxisAlignment.start,
//                                children: [
//                                  GestureDetector(
//                                    onTap: (){
//                                      bottomNavigation(context, "Edit Phone Number", "Remove Phone Number", 'phone', index);
//                                    },
//                                    child: Container(
//                                      width: MediaQuery.of(context).size.width,
//                                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
//                                      decoration: BoxDecoration(
//                                          color: AppColor.WHITE_COLOR,
//                                          borderRadius: BorderRadius.circular(16)
//                                      ),
//                                      child: Column(
//                                        crossAxisAlignment: CrossAxisAlignment.start,
//                                        mainAxisAlignment: MainAxisAlignment.start,
//                                        children: <Widget>[
//                                          Text(
//                                            '${phoneList[index]['phonetag']} Phone',
//                                            style: TextStyle(
//                                                color: AppColor.TYPE_SECONDARY,
//                                                fontSize: TextSize.subjectTitle,
//                                                fontWeight: FontWeight.w400,
//                                                fontFamily: 'WorkSans'
//                                            ),
//                                          ),
//                                          SizedBox(height: 3.0,),
//                                          Text(
//                                            '$formattedPhoneNumber',
//                                            style: TextStyle(
//                                                color: AppColor.TYPE_PRIMARY,
//                                                fontSize: TextSize.headerText,
//                                                fontWeight: FontWeight.w600,
//                                                fontFamily: 'WorkSans'
//                                            ),
//                                          ),
//                                        ],
//                                      ),
//                                    ),
//                                  ),
//                                  Divider(
//                                    height: 1.0,
//                                    color: AppColor.SEC_DIVIDER,
//                                  ),
//                                ],
//                              );
                            },
                          ),
                        ),
                        ///Add Phone Number
                        phoneList != null && phoneList.length > 1
                            ? Container()
                            : GestureDetector(
                          onTap: (){
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddCustomerInfoPhone(
                                      clientId: "${customerData['clientid']}",
                                    )
                                )
                            ).then((result){
                              if(result != null){
                                if(result['data'] != null){
                                  setState(() {
                                    phoneList.add(result['data']);
                                  });
                                }
                              }
                            });
                          },
                          child: Container(
                          margin: EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0),
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                          decoration: BoxDecoration(
                              color: AppColor.THEME_PRIMARY.withOpacity(0.08),
                              borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.add,
                                  size: 18,
                                  color: AppColor.THEME_PRIMARY,
                                ),
                                SizedBox(width: 8.0,),
                                Flexible(
                                  child: Text(
                                    phoneList.length == 0 ? 'Phone' : phoneList.length == 1 ? 'Phone' : '',
                                    style: TextStyle(
                                        color: AppColor.THEME_PRIMARY,
                                        fontSize: TextSize.subjectTitle,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'WorkSans'
                                    ),
                                  ),
                                ),
                              ],
                          ),
                        ),
                            ),

                        SizedBox(height: 160.0,)
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),

          //Submit Button
          Visibility(
            visible: isFocusOn,
            child: BottomGeneralButton(
              isActive: _allFieldValidate,
              buttonName: "SAVE",
              onStartButton: (){
                if( _allFieldValidate){
                  updateProfileDetail();
                } else {
                  setState(() {
                    firstNameFocus.requestFocus(FocusNode());
                    _autoValidate = true;
                  });
                }
              },
            ),
          ),

          _progressHUD
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

  void setParameters() {
    List emailDataList = List();
    List phoneDataList = List();
    nameData = {"first_name": "${_firstNameController.text.trim()}", "last_name": "${_lastNameController.text.trim()}"};

    emailList.forEach((emailData) {
      emailDataList.add({
        "\"email\"":"\"${emailData['email']}\"",
        "\"emailtag\"":"\"${emailData['emailtag']}\"",
        "\"clientemailpreferred\"": false
      });
    });
    phoneList.forEach((phoneData) {
      phoneDataList.add({
        "\"phoneno\"":"\"${phoneData['phoneno']}\"",
        "\"phonetag\"":"\"${phoneData['phonetag']}\"",
        "\"clientphonepreferred\"": false
      });
    });

    var requestJson = {
      "firstname": "${nameData['first_name']}",
      "lastname": "${nameData['last_name']}",
      "nickname":" ",
      "notes": "",
      "phone": phoneList,
      "email": emailList,
      "address": [],
      "servicelocation": []
    };

    String requestParam = json.encode(requestJson);
    createClient(requestParam);
  }

  void bottomNavigation(context, firstContent, secondContent, type, index){
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        backgroundColor: Colors.white,
        builder: (context){
          return StatefulBuilder(
            builder: (context1, myState){
              return SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 12.0,),
                      GestureDetector(
                        onTap: (){
                          print('TYPE====>>>>$type');
                          Navigator.pop(context);
                          if(type == 'email'){
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddCustomerInfoEmail(
                                      emailData: emailList[index],
                                      clientId: "${customerData['clientid']}",
                                    )
                                )
                            ).then((result){
                              if(result != null){
                                if(result['data'] != null){
                                  setState(() {
                                    emailList.removeAt(index);
                                    emailList.insert(index, result['data']);
                                  });
                                }
                              }
                            });
                          } else if(type == 'phone'){
                            Navigator.push(
                                _scaffoldKey.currentContext,
                                MaterialPageRoute(
                                    builder: (context) => AddCustomerInfoPhone(
                                      phoneData: phoneList[index],
                                      clientId: "${customerData['clientid']}",
                                    )
                                )
                            ).then((result){
                              if(result != null){
                                if(result['data'] != null){
                                  setState(() {
                                    phoneList.removeAt(index);
                                    phoneList.insert(index, result['data']);
                                  });
                                }
                              }
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                          child: Text(
                            '$firstContent',
                            style: TextStyle(
                                fontSize: TextSize.headerText,
                                color: AppColor.TYPE_PRIMARY,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'WorkSans'
                            ),
                          ),
                        ),
                      ),
                      Divider(
                        height: 1.0,
                        color: AppColor.SEC_DIVIDER,
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                          if(type == 'email'){
                            showLoading(context, 'You\'re about to remove an email address.', type, index);
                          } else if(type == 'phone'){
                            showLoading(context, 'You\'re about to remove a phone number.', type, index);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                          child: Text(
                            '$secondContent',
                            style: TextStyle(
                                fontSize: TextSize.headerText,
                                color: AppColor.RED_COLOR,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'WorkSans'
                            ),
                          ),
                        ),
                      ),
                      Divider(
                        height: 1.0,
                        color: AppColor.SEC_DIVIDER,
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                                fontSize: TextSize.headerText,
                                color: AppColor.TYPE_SECONDARY,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'WorkSans'
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0,),
                    ],
                  ),
                ),
              );
            },
          );
        }
    );
  }

  void showLoading(context, content, type, index) {
    var sLoadingContext;
    print("show loading call");
    showDialog(
      context: _scaffoldKey.currentContext,
      barrierDismissible: false,
      builder: (BuildContext loadingContext) {
        sLoadingContext = loadingContext;
        return Container(
          height: 500,
          margin: EdgeInsets.only(top: 50, bottom: 30),
          child: Dialog(
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Text(
                    'Are you sure?',
                    style: TextStyle(
                        fontSize: TextSize.headerText,
                        color: AppColor.TYPE_PRIMARY,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'WorkSans'
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 28.0, vertical: 10.0),
                  child: Text(
                    '$content',
                    style: TextStyle(
                        fontSize: TextSize.subjectTitle,
                        color: AppColor.TYPE_SECONDARY,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'WorkSans',
                        height: 1.3
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: (){
                            Navigator.pop(_scaffoldKey.currentContext);
                          },
                          child: Container(
                            height: 56.0,
                            alignment: Alignment.center,
                            child: Text(
                              'CANCEL',
                              style: TextStyle(
                                fontSize: TextSize.subjectTitle,
                                color: AppColor.TYPE_SECONDARY,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'WorkSans',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: (){
                            removeCustomerDetail(type, index);
                            Navigator.pop(_scaffoldKey.currentContext);
                          },
                          child: Container(
                            height: 56.0,
                            alignment: Alignment.center,
                            child: Text(
                              'REMOVE',
                              style: TextStyle(
                                fontSize: TextSize.subjectTitle,
                                color: type == 'normal' ? AppColor.TYPE_PRIMARY : AppColor.RED_COLOR,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'WorkSans',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  ///////////////////////////API Integration/////////////////////////////
  Future<void> createClient(requestParam) async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());

    var response = await request.postRequest("auth/myclient", requestParam);
    _progressHUD.state.dismiss();

    if (response != null) {
      if(response['success'] != null){
        HelperClass.showSnackBar(context, '${response['reason']}');
      } else {
//        Navigator.of(context).pop(true);
        Navigator.of(context).pop({
          "data": response
        });
      }
    } else {
      HelperClass.showSnackBar(context, 'Something Went Wrong!');
    }
  }

  void updateProfileDetail() async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var requestJson;
    if(_firstNameController.text == ''){
      requestJson = {"lastname": "${_lastNameController.text.toString().trim()}"};
    } else if(_lastNameController.text == ''){
      requestJson = {"firstname": "${_firstNameController.text.toString().trim()}"};
    } else{
      requestJson = {
        "firstname": "${_firstNameController.text.toString().trim()}",
        "lastname": "${_lastNameController.text.toString().trim()}"
      };
    }
    var requestParam = json.encode(requestJson);
    var response = await request.patchRequest("auth/myclient/${customerData['clientid']}", requestParam);
    _progressHUD.state.dismiss();

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage('${response['reason']}');
      } else {
       /* Navigator.of(context).pop({"userData": {
          "firstname": "${_firstNameController.text.toString().trim()}",
          "lastname": "${_lastNameController.text.toString().trim()}"
        }});*/
       customerData['firstname'] = _firstNameController.text.toString().trim();
       customerData['lastname'] = _lastNameController.text.toString().trim();

       Navigator.of(context).pop({
         "data": customerData
       });
      }
    }
  }

  Future<void> removeCustomerDetail(type, index) async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var response;
    if(type == 'email') {
      response = await request.deleteAuthRequest("auth/myclient/${customerData['clientid']}/email/${emailList[index]['emailid']}");
    } else if(type == 'phone') {
      response = await request.deleteAuthRequest("auth/myclient/${customerData['clientid']}/phone/${phoneList[index]['phoneid']}");
    }
    _progressHUD.state.dismiss();

    if (response != null) {
      if(response['success'] != null && response['success']){
        setState(() {
          if(type == 'email') {
            emailList.removeAt(index);
          } else if(type == 'phone') {
            phoneList.removeAt(index);
          }
        });
      } else {
        HelperClass.showSnackBar(context, 'Something Went Wrong!');
      }
    } else {
      HelperClass.showSnackBar(context, 'Something Went Wrong!');
    }
  }

}
