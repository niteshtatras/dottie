import 'dart:convert';

import 'package:contacts_service/contacts_service.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:dottie_inspector/widget/bottom_general_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_hud/progress_hud.dart';

import '../customerDetail/customer_email.dart';
import '../customerDetail/customer_phone.dart';

class NewCustomerInfoPage extends StatefulWidget {
  final contact;

  const NewCustomerInfoPage({Key key, this.contact}) : super(key: key);

  @override
  _NewCustomerInfoPageState createState() => _NewCustomerInfoPageState();
}

class _NewCustomerInfoPageState extends State<NewCustomerInfoPage> {
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
  Contact contact;
  Map nameData;
  var elevation = 0.0;
  final _scrollController = ScrollController();

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

    contact = widget.contact ?? null;
    if(contact != null){
      setContactData();
    }

    _scrollController.addListener(() {
      setState(() {
        if(_scrollController.position.pixels > _scrollController.position.minScrollExtent){
          elevation = HelperClass.ELEVATION_1;
        } else {
          elevation = HelperClass.ELEVATION;
        }
      });
    });


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

      if(contact.givenName.isNotEmpty){
         nameData = {"first_name": "${contact.givenName}", "last_name": "${contact.familyName}"};
         _firstNameController.text = contact.givenName;
         _lastNameController.text = contact.familyName;

         _allFieldValidate = true;
      }

      if(contact.emails.isNotEmpty){
        emailList.add({
          "email": "${contact.emails.first.value}",
          "emailtag": "${HelperClass.getEmailLabelText(HelperClass.getEmailLabelIndex(contact.emails.first.label))}",
          "clientemailpreferred": false,
          "selectedIndex" : HelperClass.getEmailLabelIndex("${contact.emails.first.label}")
        });
        print(emailList);
      }
      if(contact.phones.isNotEmpty){
        phoneList.add({
          "phoneno": "${contact.phones.first.value}",
          "phonetag": "${HelperClass.getLabelText(HelperClass.getLabelIndex(contact.phones.first.label))}",
          "clientphonepreferred": false,
          "selectedIndex" : HelperClass.getLabelIndex("${contact.phones.first.label}")
        });
        print(phoneList);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColor.PAGE_COLOR,
      appBar: AppBar(
        centerTitle: true,
        elevation: elevation,
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
        title: Text(
          'New Customer’s Info.',
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
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  key: _formKey,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
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
                                    color: AppColor.TYPE_PRIMARY,
                                    fontSize: TextSize.bodyText,
                                    fontWeight: FontWeight.w600,
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
                                      fontSize: TextSize.headerText,
                                      color: AppColor.TYPE_PRIMARY.withOpacity(0.6),
                                      fontWeight: FontWeight.w600
                                    ),
                                ),
                                style: TextStyle(
                                    color: AppColor.TYPE_PRIMARY,
                                    fontWeight: FontWeight.w600,
                                    fontSize: TextSize.headerText
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
                                    color: AppColor.TYPE_PRIMARY,
                                    fontSize: TextSize.subjectTitle,
                                    fontWeight: FontWeight.w600,
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
                                        fontSize: TextSize.headerText,
                                        color: AppColor.TYPE_PRIMARY.withOpacity(0.6),
                                        fontWeight: FontWeight.w600
                                    ),
                                ),
                                style: TextStyle(
                                    color: AppColor.TYPE_PRIMARY,
                                    fontWeight: FontWeight.w600,
                                    fontSize: TextSize.headerText
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
                          margin: EdgeInsets.only(top: 16.0),
                          child: ListView.builder(
                            itemCount: emailList != null ? emailList.length : 0,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index){
                              return Container(
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    InkWell(
                                      onTap: (){
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => AddCustomerEmail(
                                                  emailData: emailList[index],
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
                                                  padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 16.0),
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
                                                        ),
                                                      ),
                                                      SizedBox(height: 3.0,),
                                                      Text(
                                                        '${emailList[index]['email']}',
                                                        style: TextStyle(
                                                            color: AppColor.TYPE_PRIMARY,
                                                            fontSize: TextSize.headerText,
                                                            fontWeight: FontWeight.w600,
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
                                                        ),
                                                      ),
                                                      SizedBox(height: 3.0,),
                                                      Text(
                                                        '${emailList[index]['emailtag']}',
                                                        style: TextStyle(
                                                            color: AppColor.THEME_PRIMARY,
                                                            fontSize: TextSize.headerText,
                                                            fontWeight: FontWeight.w600,
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
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            emailList.removeAt(index);
                                          });
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
                            },
                          ),
                        ),

                        ///Add Email Address
                        emailList != null && emailList.length > 1
                        ? Container()
                        : InkWell(
                          onTap: (){
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddCustomerEmail()
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
                                    InkWell(
                                      onTap: (){
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => AddCustomerPhone(
                                                  phoneData: phoneList[index],
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
                                                        ),
                                                      ),
                                                      SizedBox(height: 3.0,),
                                                      Text(
                                                        '$formattedPhoneNumber',
                                                        style: TextStyle(
                                                            color: AppColor.TYPE_PRIMARY,
                                                            fontSize: TextSize.headerText,
                                                            fontWeight: FontWeight.w600,
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
                                                        ),
                                                      ),
                                                      SizedBox(height: 3.0,),
                                                      Text(
                                                        '${phoneList[index]['phonetag']}',
                                                        style: TextStyle(
                                                            color: AppColor.THEME_PRIMARY,
                                                            fontSize: TextSize.headerText,
                                                            fontWeight: FontWeight.w600,
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
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            phoneList.removeAt(index);
                                          });
//                                          showLoading(context, "You\'re about to remove a phone number.", "phone", index);
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
//                                  InkWell(
//                                    onTap: (){
//                                      Navigator.push(
//                                          context,
//                                          MaterialPageRoute(
//                                              builder: (context) => AddCustomerPhone(
//                                                phoneData: phoneList[index],
//                                              )
//                                          )
//                                      ).then((result){
//                                        if(result != null){
//                                          if(result['data'] != null){
//                                            setState(() {
//                                              phoneList.removeAt(index);
//                                              phoneList.insert(index, result['data']);
//                                            });
//                                          }
//                                        }
//                                      });
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
//                                            ),
//                                          ),
//                                          SizedBox(height: 3.0,),
//                                          Text(
//                                            '${phoneList[index]['phoneno']}',
//                                            style: TextStyle(
//                                                color: AppColor.TYPE_PRIMARY,
//                                                fontSize: TextSize.headerText,
//                                                fontWeight: FontWeight.w600,
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
                        : InkWell(
                            onTap: (){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AddCustomerPhone()
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
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
//                        : Column(
//                          crossAxisAlignment: CrossAxisAlignment.start,
//                          mainAxisAlignment: MainAxisAlignment.start,
//                          children: [
//                            InkWell(
//                              onTap: (){
//                                Navigator.push(
//                                    context,
//                                    MaterialPageRoute(
//                                        builder: (context) => AddCustomerPhone()
//                                    )
//                                ).then((result){
//                                  if(result != null){
//                                    if(result['data'] != null){
//                                      setState(() {
//                                        phoneList.add(result['data']);
//                                      });
//                                    }
//                                  }
//                                });
//                              },
//                              child: Container(
//                                padding: EdgeInsets.symmetric(horizontal:16.0, vertical: 12.0),
//                                width: MediaQuery.of(context).size.width,
//                                child: Text(
//                                  phoneList.length == 0 ? 'Add Phone Number' : phoneList.length == 1 ? 'Add Another Phone number' : '',
//                                  style: TextStyle(
//                                      color: AppColor.THEME_PRIMARY,
//                                      fontSize: TextSize.subjectTitle,
//                                      fontWeight: FontWeight.w600,
//                                  ),
//                                ),
//                              ),
//                            ),
//                            Divider(height: 1.0, color: AppColor.SEC_DIVIDER,),
//                          ],
//                        ),

                        SizedBox(height: 160.0,)
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),

          Visibility(
            visible: isFocusOn,
            child: BottomGeneralButton(
              isActive: _allFieldValidate,
              buttonName: "SAVE",
              onStartButton: (){
                if( _allFieldValidate){
                  setParameters();
                } else {
                  setState(() {
                    firstNameFocus.requestFocus(FocusNode());
                    _autoValidate = true;
                  });
                }
              },
            ),
          ),

          ///Submit Button
//          Positioned(
//            bottom: 0.0,
//            left: 0.0,
//            right: 0.0,
//            child: Container(
//              padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0, top: 12.0),
//              decoration: BoxDecoration(
//                color: elevation == 0.0 ? AppColor.TRANSPARENT : AppColor.WHITE_COLOR,
//                /*boxShadow: [
//                  BoxShadow(
//                      blurRadius: 24.0,
//                      offset: Offset(0.0,0),
//                      color: Colors.grey[400]
//                  )
//                ],*/
//              ),
//              child: InkWell(
//                onTap: (){
//                  if( _allFieldValidate){
//                   /* Navigator.push(
//                        context,
//                        SlideRightRoute(
//                            page: InspectionLocationPage()
//                        )
//                    );*/
//                    setParameters();
//                  } else {
//                    setState(() {
//                      firstNameFocus.requestFocus(FocusNode());
//                      _autoValidate = true;
//                    });
//                  }
//                },
//                child: Container(
//                  height: 56.0,
//                  decoration: BoxDecoration(
//                      color: _allFieldValidate ? AppColor.THEME_PRIMARY : AppColor.TYPE_PRIMARY.withOpacity(0.08),
//                      borderRadius: BorderRadius.all(Radius.circular(16.0))
//                  ),
//                  child: Center(
//                    child: Text(
//                      'SAVE',
//                      textAlign: TextAlign.center,
//                      style: TextStyle(
//                        color: _allFieldValidate ? AppColor.WHITE_COLOR : AppColor.TYPE_PRIMARY.withOpacity(0.6),
//                        fontSize: TextSize.bodyText,
//                        fontWeight: FontWeight.w600,
//                        fontStyle: FontStyle.normal,
//                      ),
//                    ),
//                  ),
//                ),
//              ),
//            ),
//          ),

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
}
