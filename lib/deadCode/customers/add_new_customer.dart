import 'dart:convert';
import 'dart:io';

import 'package:contacts_service/contacts_service.dart';
import 'package:dottie_inspector/deadCode/customerDetail/customer_billing_address.dart';
import 'package:dottie_inspector/deadCode/customerDetail/customer_email.dart';
import 'package:dottie_inspector/deadCode/customerDetail/customer_name.dart';
import 'package:dottie_inspector/deadCode/customerDetail/customer_note_page.dart';
import 'package:dottie_inspector/deadCode/customerDetail/customer_phone.dart';
import 'package:dottie_inspector/deadCode/customerDetail/customer_service_location.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/custom_toast.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/widget/custom_switch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_hud/progress_hud.dart';

import '../../webServices/AllRequest.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

const iOSLocalizedLabels = false;
class AddNewCustomerPage extends StatefulWidget {
  @override
  _AddNewCustomerPageState createState() => _AddNewCustomerPageState();
}

class _AddNewCustomerPageState extends State<AddNewCustomerPage> {
  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;
  var _allValidation = false;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _companySwitch = false;
  bool isNameAvailable = false;
  Map nameData;

  List phoneList = List();
  List emailList = List();
  List addressList = List();
  List serviceLocationList = List();

  var noteText = '';

  bool isNoteAvailable = false;
  var importContactOption = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _progressHUD = ProgressHUD(
      backgroundColor: Colors.transparent,
      color: Colors.white,
      containerColor: AppColor.LOADER_COLOR,
      borderRadius: 5.0,
      loading: _loading,
      text: 'Loading...',
    );

    importContactOption = !kIsWeb;
  }

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
        actions: [
          IconButton(
            padding: EdgeInsets.only(left: 16.0, right: 20.0),
            icon: Icon(
              Icons.done,
              color: AppColor.TYPE_PRIMARY,
              size: 28.0,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
        title: Text(
          'Create  Customer',
          style: TextStyle(
              color: AppColor.TYPE_PRIMARY,
              fontSize: TextSize.headerText,
              fontWeight: FontWeight.w600
          ),
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          print("printed");
          return true;
        },
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  //Import Contacts
                  Visibility(
                    visible: importContactOption,
                    child: InkWell(
                      onTap: (){
                        _askPermissions();
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                        alignment: Alignment.center,
                        height: 56.0,
                        decoration: BoxDecoration(
                          color: AppColor.BG_PRIMARY_ALT,
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                          border: Border.all(width: 1.0, color: AppColor.DIVIDER)
                        ),
                        child: Text(
                          'Import From Contacts',
                          style: TextStyle(
                            color: AppColor.TYPE_PRIMARY,
                            fontSize: TextSize.subjectTitle,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'WorkSans'
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),

                  //Personal Information title
                  Container(
                    padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 22.0),
                    child:  Text(
                      'PERSONAL',
                      style: TextStyle(
                          color: AppColor.TYPE_SECONDARY,
                          fontSize: TextSize.bodyText,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'WorkSans'
                      ),
                    ),
                  ),

                  //Toggle display as a company
                  Container(
                    padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 22.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            child: Text(
                              'Display as a company',
                              style: TextStyle(
                                  color: AppColor.TYPE_PRIMARY,
                                  fontSize: TextSize.headerText,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'WorkSans'
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 5.0),
                          child: CustomSwitch(
                            value: _companySwitch,
                            onChanged: (val){
                              setState(() {
                                _companySwitch = val;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  //Add customer name
                  isNameAvailable
                  ? InkWell(
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddCustomerName(
                                  nameData: nameData
                                )
                            )
                        ).then((result){
                          print("Result====$result");
                          if(result != null){
                            if(result['data'] != null){
                              setState(() {
                                nameData = result['data'];
                                isNameAvailable = true;
                              });
                            }
                          }
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Name',
                              style: TextStyle(
                                  color: AppColor.TYPE_SECONDARY,
                                  fontSize: TextSize.subjectTitle,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'WorkSans'
                              ),
                            ),
                            SizedBox(height: 3.0,),
                            Text(
                              '${nameData['first_name']} ${nameData['last_name']}',
                              style: TextStyle(
                                  color: AppColor.TYPE_PRIMARY,
                                  fontSize: TextSize.headerText,
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'WorkSans'
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : InkWell(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                             builder: (context) => AddCustomerName()
                          )
                        ).then((result){
                          if(result != null){
                            if(result['data'] != null){
                              setState(() {
                                nameData = result['data'];
                                isNameAvailable = true;
                                _allValidation = true;
                              });
                            }
                          }
                        });
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 28.0),
                        child: Text(
                          'Add Name',
                          style: TextStyle(
                              color: AppColor.THEME_PRIMARY,
                              fontSize: TextSize.headerText,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'WorkSans'
                          ),
                        ),
                      ),
                    ),
                  Divider(height: 1.0, color: AppColor.SEC_DIVIDER,),

                  ///Email
                  Container(
                    child: ListView.builder(
                      itemCount: emailList != null ? emailList.length : 0,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index){
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
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
                                padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      '${emailList[index]['emailtag']} Email',
                                      style: TextStyle(
                                          color: AppColor.TYPE_SECONDARY,
                                          fontSize: TextSize.subjectTitle,
                                          fontWeight: FontWeight.w400,
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
                            Divider(
                              height: 1.0,
                              color: AppColor.SEC_DIVIDER,
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  ///Add Email Address
                  emailList != null && emailList.length > 1
                  ? Container()
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
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
                          padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 28.0),
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            emailList.length == 0 ? 'Add Email Address' : emailList.length == 1 ? 'Add Another Email Address' : '',
                            style: TextStyle(
                                color: AppColor.THEME_PRIMARY,
                                fontSize: TextSize.headerText,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'WorkSans'
                            ),
                          ),
                        ),
                      ),
                      Divider(height: 1.0, color: AppColor.SEC_DIVIDER,),
                    ],
                  ),

                  ///Phone
                  Container(
                    child: ListView.builder(
                      itemCount: phoneList != null ? phoneList.length : 0,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index){
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
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
                                padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      '${phoneList[index]['phonetag']} Phone',
                                      style: TextStyle(
                                          color: AppColor.TYPE_SECONDARY,
                                          fontSize: TextSize.subjectTitle,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'WorkSans'
                                      ),
                                    ),
                                    SizedBox(height: 3.0,),
                                    Text(
                                      '${phoneList[index]['phoneno']}',
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
                            Divider(
                              height: 1.0,
                              color: AppColor.SEC_DIVIDER,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  ///Add Phone Number
                  phoneList != null && phoneList.length > 1
                  ? Container()
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
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
                          padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 28.0),
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            phoneList.length == 0 ? 'Add Phone Number' : phoneList.length == 1 ? 'Add Another Phone number' : '',
                            style: TextStyle(
                                color: AppColor.THEME_PRIMARY,
                                fontSize: TextSize.headerText,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'WorkSans'
                            ),
                          ),
                        ),
                      ),
                      Divider(height: 1.0, color: AppColor.SEC_DIVIDER,),
                    ],
                  ),

                  //Bill address title
                  Container(
                    padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 22.0),
                    child:  Text(
                      'BILLING ADDRESS',
                      style: TextStyle(
                          color: AppColor.TYPE_SECONDARY,
                          fontSize: TextSize.bodyText,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'WorkSans'
                      ),
                    ),
                  ),
                  ///Customer billing address
                  Container(
                    child: ListView.builder(
                      itemCount: addressList != null ? addressList.length : 0,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index){
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: (){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AddCustomerPhone(
                                          phoneData: addressList[index],
                                        )
                                    )
                                ).then((result){
                                  if(result != null){
                                    if(result['data'] != null){
                                      setState(() {
                                        addressList.removeAt(index);
                                        addressList.insert(index, result['data']);
                                      });
                                    }
                                  }
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Location ${index+1}',
                                      style: TextStyle(
                                          color: AppColor.TYPE_SECONDARY,
                                          fontSize: TextSize.subjectTitle,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'WorkSans'
                                      ),
                                    ),
                                    SizedBox(height: 3.0,),
                                    Text(
                                      '${addressList[index]['street1']} ${addressList[index]['city']} ${addressList[index]['zipCodeData']['zipCode']} ',
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
                            Divider(
                              height: 1.0,
                              color: AppColor.SEC_DIVIDER,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  ///Add Customer Billing Address
                  addressList != null && addressList.length > 1
                  ? Container()
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddCustomerBillingAddress()
                              )
                          ).then((result){
                            if(result != null){
                              if(result['data'] != null){
                                setState(() {
                                  addressList.add(result['data']);
                                });
                              }
                            }
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 28.0),
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            addressList.length == 0 ? 'Add Billing Address' : addressList.length == 1 ? 'Add Another Billing Address' : '',
                            style: TextStyle(
                                color: AppColor.THEME_PRIMARY,
                                fontSize: TextSize.headerText,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'WorkSans'
                            ),
                          ),
                        ),
                      ),
                      Divider(height: 1.0, color: AppColor.SEC_DIVIDER,),
                    ],
                  ),

                  ///Service location title
                  Container(
                    padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 22.0),
                    child:  Text(
                      'SERVICE LOCATIONS',
                      style: TextStyle(
                          color: AppColor.TYPE_SECONDARY,
                          fontSize: TextSize.bodyText,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'WorkSans'
                      ),
                    ),
                  ),
                  ///Service location
                  Container(
                    child: ListView.builder(
                      itemCount: serviceLocationList != null ? serviceLocationList.length : 0,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index){
                        var serviceLocationData = serviceLocationList[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: (){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AddCustomerServiceLocationPage(
                                          serviceLocationData: serviceLocationList[index],
                                        )
                                    )
                                ).then((result){
                                  if(result != null){
                                    if(result['data'] != null){
                                      setState(() {
                                        serviceLocationList.removeAt(index);
                                        serviceLocationList.insert(index, result['data']);
                                      });
                                    }
                                  }
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Location ${index+1}',
                                      style: TextStyle(
                                          color: AppColor.TYPE_SECONDARY,
                                          fontSize: TextSize.subjectTitle,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'WorkSans'
                                      ),
                                    ),
                                    SizedBox(height: 3.0,),
                                    Text(
                                      '${serviceLocationData['streetName']}, ${serviceLocationData['cityName']}, '
//                                          '${serviceLocationData['stateData']['label']}, '
                                      '${serviceLocationData['countryData']['mixedcase'] != null ? serviceLocationData['countryData']['mixedcase'] : serviceLocationData['countryData']['countryname']}, '
                                      '${serviceLocationData['zipCodeData']}',
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
                            Divider(
                              height: 1.0,
                              color: AppColor.SEC_DIVIDER,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  ///Add Service location
                  serviceLocationList != null /*&& serviceLocationList.length > 1*/
                  ? Container()
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddCustomerServiceLocationPage(
                                    billData: addressList.length > 0 ? addressList[0] : null
                                  )
                              )
                          ).then((result){
                            if(result != null){
                              if(result['data'] != null){
                                setState(() {
                                  serviceLocationList.add(result['data']);
                                });
                              }
                            }
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 28.0),
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            serviceLocationList.length == 0 ? 'Add Service Location' : serviceLocationList.length >= 1 ? 'Add Another Service Location' : '',
                            style: TextStyle(
                                color: AppColor.THEME_PRIMARY,
                                fontSize: TextSize.headerText,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'WorkSans'
                            ),
                          ),
                        ),
                      ),
                      Divider(height: 1.0, color: AppColor.SEC_DIVIDER,),
                    ],
                  ),

                  //Note title
                  Container(
                    padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 22.0),
                    child:  Text(
                      'NOTES',
                      style: TextStyle(
                          color: AppColor.TYPE_SECONDARY,
                          fontSize: TextSize.bodyText,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'WorkSans'
                      ),
                    ),
                  ),
                  //Add new note
                  isNoteAvailable
                      ? InkWell(
                    onTap: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddCustomerNotePage(
                                  noteData: noteText
                              )
                          )
                      ).then((result){
                        if(result != null){
                          setState(() {
                            noteText = result['data'];
                          });
                        }
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 28.0),
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        '$noteText',
                        style: TextStyle(
                            color: AppColor.TYPE_PRIMARY,
                            fontSize: TextSize.headerText,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'WorkSans'
                        ),
                      ),
                    ),
                  )
                      : InkWell(
                    onTap: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddCustomerNotePage(
                                noteData: noteText,
                              )
                          )
                      ).then((result){
                        if(result != null){
                          setState(() {
                            noteText = result['data'];
                            isNoteAvailable = true;
                          });
                        }
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 28.0),
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        'Add Notes',
                        style: TextStyle(
                            color: AppColor.THEME_PRIMARY,
                            fontSize: TextSize.headerText,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'WorkSans'
                        ),
                      ),
                    ),
                  ),
                  Divider(height: 1.0, color: AppColor.SEC_DIVIDER,),
                  SizedBox(height: 100.0,)
                ],
              ),
            ),

            //Submit Button
            Positioned(
              bottom: 32.0,
              left: 20.0,
              right: 20.0,
              child: InkWell(
                onTap: (){
                  print("emailData====$emailList");
                  print("phoneData====$phoneList");
                  print("AddressData====$addressList");
                  print("ServiceLocationData====$serviceLocationList");
                  if(_allValidation){
                    setParameters();
                  }
                },
                child: Container(
                  height: 56.0,
                  decoration: BoxDecoration(
                      color: _allValidation ? AppColor.THEME_PRIMARY : AppColor.DEACTIVATE,
                      borderRadius: BorderRadius.all(Radius.circular(4.0))
                  ),
                  child: Center(
                    child: Text(
                      'CREATE CUSTOMER',
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

            _progressHUD
          ],
        ),
      ),
    );
  }

  Future<void> _askPermissions() async {
    PermissionStatus permissionStatus = await Permission.contacts.request();
    if (permissionStatus == PermissionStatus.granted) {
      try {
        Contact contact = await ContactsService.openDeviceContactPicker(
            iOSLocalizedLabels: iOSLocalizedLabels);

        setState(() {
          emailList.clear();
          phoneList.clear();

          if(contact.givenName.isNotEmpty){
            nameData = {"first_name": "${contact.givenName}", "last_name": "${contact.familyName}"};
            isNameAvailable = true;
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
      } catch(error, stackTrace) {
        print(error);
        print(stackTrace);
      }
    } else {
      _handleInvalidPermissions(permissionStatus);
      openAppSettings();
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      throw PlatformException(
          code: "PERMISSION_DENIED",
          message: "Access to contact denied",
          details: null
      );
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      openAppSettings();
      CustomToast.showColoredToast('Contacts feature is not available on device');
      throw PlatformException(
          code: "PERMISSION_DISABLED",
          message: "Contacts feature is not available on device",
          details: null
      );
    }
  }

  void setParameters() {
    List billAddressList = List();
    List serviceAddressList = List();
    List emailDataList = List();
    List phoneDataList = List();

    addressList.forEach((billAddressData) {
      Map billData = {
        "clientaddresstag": "Billing",
        "clientaddresspreferred": true,
        "countrycode": "${billAddressData['country']['countrycode']}",
        "street1": "${billAddressData['street1']}",
        "city" : "${billAddressData['city']}",
        "statecode" : "${billAddressData['state']['abbr']}",
        "zip" : "${billAddressData['zipCodeData']['zipCode']}"
      };
      billAddressList.add(billData);
    });

    serviceLocationList.forEach((serviceLocationData) {
      Map serviceData = {
        "serviceaddressnick":"${serviceLocationData['nickName']}",
        "street1":"${serviceLocationData['streetName']}",
        "city":"${serviceLocationData['cityName']}",
//        "statecode":"CA",
        "statecode":"${serviceLocationData['stateData']['abbr']}",
        "countrycode":"${serviceLocationData['countryData']['countrycode']}",
        "zip":"${serviceLocationData['zipCodeData']}"
      };
      serviceAddressList.add(serviceData);
    });

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
      "notes": "$noteText",
      "phone": phoneList,
      "email": emailList,
      "address": billAddressList,
      "servicelocation": serviceAddressList
    };

    String requestParam = json.encode(requestJson);
    createClient(requestParam);
  }

  int getLabelIndex(tag){
    switch(tag){
      case "Home":
        return 0;

      case "Mobile":
        return 1;

      case "Work":
        return 2;

      case "Primary":
        return 3;

      case "Other":
        return 4;

      default:
        return 4;
    }
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
        Navigator.of(context).pop(true);
//        Navigator.pop(context);
      }
    } else {
      HelperClass.showSnackBar(context, 'Something Went Wrong!');
    }
  }

}
