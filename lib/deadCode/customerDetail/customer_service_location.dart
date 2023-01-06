import 'dart:convert';

import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:dottie_inspector/widget/custom_switch.dart';
import 'package:flutter/material.dart';
import 'package:dottie_inspector/deadCode/models/state_list_page.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:progress_hud/progress_hud.dart';

import '../models/country_list_page.dart';
import 'customer_email.dart';
import 'customer_gate_code.dart';
import 'customer_note_page.dart';
import 'customer_phone.dart';

class AddCustomerServiceLocationPage extends StatefulWidget {
  final serviceLocationData;
  final billData;
  final type;
  final clientId;

  const AddCustomerServiceLocationPage({Key key, this.serviceLocationData, this.type, this.clientId, this.billData}) : super(key: key);

  @override
  _AddCustomerServiceLocationPageState createState() => _AddCustomerServiceLocationPageState();
}

class _AddCustomerServiceLocationPageState extends State<AddCustomerServiceLocationPage> {

  bool _allFieldValidate = false;
  bool _autoValidate = false;
  bool _sameBillAddressSwitch = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _streetController = TextEditingController();
  final _locationNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipCodeController = TextEditingController();

  final FocusNode _streetFocus = FocusNode();
  final FocusNode _locationNameFocus = FocusNode();
  final FocusNode _cityFocus = FocusNode();
  final FocusNode _zipCodeFocus = FocusNode();

  Map countryData;
  Map stateData;
  Map gateKeyData;
  Map emailData;
  Map phoneData;
  var noteText = '';

  bool isNoteAvailable = false;
  bool isGateCodeAvailable = false;
  bool isEmailAvailable = false;
  bool isPhoneAvailable = false;

  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;

  String clientId = "";
  String type = "";

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

    if(widget.serviceLocationData != null){
      countryData = widget.serviceLocationData['countryData'];
      stateData = widget.serviceLocationData['stateData'];
      _zipCodeController.text = widget.serviceLocationData['zipCodeData'];
      _streetController.text = widget.serviceLocationData['streetName'];
      _cityController.text = widget.serviceLocationData['cityName'];
    }
    if(widget.billData != null){
      print(widget.billData);
    }
    type = widget.type ?? "";
    clientId = widget.clientId ?? "";
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
          icon: Icon(
            Icons.keyboard_backspace,
            color: AppColor.TYPE_PRIMARY,
            size: 32.0,
          ),
          onPressed: () {
            Navigator.pop(context);
//          _progressHUD.state.dismiss();
          },
        ),
        title: Text(
          'Add Service Location',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        //Nick Name title
                        Container(
                          padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 22.0),
                          child:  Text(
                            'NICKNAME',
                            style: TextStyle(
                                color: AppColor.TYPE_SECONDARY,
                                fontSize: TextSize.bodyText,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'WorkSans'
                            ),
                          ),
                        ),

                        //Location Nick Name
                        Container(
                          margin: EdgeInsets.only(top: 0.0 ,left: 20.0, right: 20.0),
                          child:TextFormField(
                            controller: _locationNameController,
                            focusNode: _locationNameFocus,
                            keyboardType: TextInputType.text,
                            textAlign: TextAlign.start,
                            validator: (value){
                              return validateString(value, "location nick name");
                            },
                            onFieldSubmitted: (term) {
                              _locationNameFocus.unfocus();
                              FocusScope.of(context).requestFocus(_streetFocus);
                            },
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              fillColor: AppColor.WHITE_COLOR,
                              hintText: "Location Nickname",
                              contentPadding: EdgeInsets.symmetric(horizontal: 0.0,),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(width: 1, color: AppColor.TRANSPARENT),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(width: 1, color: AppColor.TRANSPARENT),
                              ),
                              labelText: 'Location Nickname',
                              hintStyle: TextStyle(
                                  fontSize: TextSize.bodyText,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.TYPE_SECONDARY
                              ),
                              labelStyle: TextStyle(
                                  fontSize: TextSize.headerText,
                                  fontWeight: FontWeight.w400,
                                  color: AppColor.TYPE_SECONDARY
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
                                formValidation();
                              });
                            },
                          ),
                        ),
                        Divider(
                          height: 1.0,
                          color: AppColor.SEC_DIVIDER,
                        ),

                        //Address title
                        Container(
                          padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 22.0),
                          child:  Text(
                            'ADDRESS',
                            style: TextStyle(
                                color: AppColor.TYPE_SECONDARY,
                                fontSize: TextSize.bodyText,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'WorkSans'
                            ),
                          ),
                        ),

                        //Toggle display as a same billing address
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
                                    'Same as billing address',
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
                              widget.billData == null
                              ? AbsorbPointer(
                                absorbing: false,
                                child: Container(
                                    margin: EdgeInsets.only(left: 5.0),
                                    child: CustomSwitch(
                                      value: _sameBillAddressSwitch,
                                      onChanged: (val){
                                        setState(() {
                                          _sameBillAddressSwitch = val;
                                        });
                                      },
                                    ),
                                  ),
                              )
                              : Container(
                                  margin: EdgeInsets.only(left: 5.0),
                                  child: CustomSwitch(
                                    value: _sameBillAddressSwitch,
                                    onChanged: (val){
                                      setState(() {
                                        _sameBillAddressSwitch = val;
                                        setDataInTextField();
                                      });
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),

                        //Country Name
                        InkWell(
                          onTap: (){
                            FocusScope.of(context).requestFocus(FocusNode());
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CountryListPage(
                                        type: 1
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
                              formValidation();
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 28.0),
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

                        //Street
                        Container(
                          margin: EdgeInsets.only(top: 0.0 ,left: 20.0, right: 20.0),
                          child:TextFormField(
                            controller: _streetController,
                            focusNode: _streetFocus,
                            textAlign: TextAlign.start,
                            keyboardType: TextInputType.text,
                            validator: (value){
                              return validateString(value, "street");
                            },
                            onFieldSubmitted: (term) {
                              _streetFocus.unfocus();
                              FocusScope.of(context).requestFocus(_cityFocus);
                            },
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              fillColor: AppColor.WHITE_COLOR,
                              hintText: "Street",
                              contentPadding: EdgeInsets.symmetric(horizontal: 0.0,),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(width: 1, color: AppColor.TRANSPARENT),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(width: 1, color: AppColor.TRANSPARENT),
                              ),
                              labelText: 'Street',
                              hintStyle: TextStyle(
                                  fontSize: TextSize.bodyText,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.TYPE_SECONDARY
                              ),
                              labelStyle: TextStyle(
                                  fontSize: TextSize.headerText,
                                  fontWeight: FontWeight.w400,
                                  color: AppColor.TYPE_SECONDARY
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
                                formValidation();
                              });
                            },
                          ),
                        ),
                        Divider(
                          height: 1.0,
                          color: AppColor.SEC_DIVIDER,
                        ),

                        //Suite Title
                        Container(
                          padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 22.0),
                          child:  Text(
                            'Apt/Suite',
                            style: TextStyle(
                                color: AppColor.TYPE_SECONDARY,
                                fontSize: TextSize.headerText,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'WorkSans'
                            ),
                          ),
                        ),

                        //City
                        Container(
                          margin: EdgeInsets.only(top: 6.0 ,left: 20.0, right: 20.0),
                          child:TextFormField(
                            controller: _cityController,
                            focusNode: _cityFocus,
                            textAlign: TextAlign.start,
                            keyboardType: TextInputType.text,
                            validator: (value){
                              return validateString(value, "city");
                            },
                            onFieldSubmitted: (term) {
                              _cityFocus.unfocus();
                              FocusScope.of(context).requestFocus(_zipCodeFocus);
                            },
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              fillColor: AppColor.WHITE_COLOR,
                              hintText: "City",
                              contentPadding: EdgeInsets.symmetric(horizontal: 0.0,),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(width: 1, color: AppColor.TRANSPARENT),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(width: 1, color: AppColor.TRANSPARENT),
                              ),
                              labelText: 'City',
                              hintStyle: TextStyle(
                                  fontSize: TextSize.bodyText,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.TYPE_SECONDARY
                              ),
                              labelStyle: TextStyle(
                                  fontSize: TextSize.headerText,
                                  fontWeight: FontWeight.w400,
                                  color: AppColor.TYPE_SECONDARY
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
                                formValidation();
                              });
                            },
                          ),
                        ),
                        Divider(
                          height: 1.0,
                          color: AppColor.SEC_DIVIDER,
                        ),

                        //State Name
                        InkWell(
                          onTap: (){
                              FocusScope.of(context).requestFocus(FocusNode());
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          StateListPage(
                                              countryCode: countryData!=null ? countryData['countrycode'] : 'US'
                                          )
                                  )
                              ).then((result) {
                                if (result != null) {
                                  if (result['stateData'] != null) {
                                    setState(() {
                                      stateData = result['stateData'];
                                    });
                                  }
                                }
                                formValidation();
                              });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 28.0),
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              stateData != null ? stateData['label'] : 'State',
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

                        // Zip code
                        Container(
                          margin: EdgeInsets.only(top: 6.0 ,left: 20.0, right: 20.0),
                          child:TextFormField(
                            controller: _zipCodeController,
                            focusNode: _zipCodeFocus,
                            textAlign: TextAlign.start,
                            keyboardType: TextInputType.number,
                            validator: (value){
                              return validateString(value, "zip code");
                            },
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              fillColor: AppColor.WHITE_COLOR,
                              hintText: "Zip Code",
                              contentPadding: EdgeInsets.symmetric(horizontal: 0.0,),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(width: 1, color: AppColor.TRANSPARENT),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(width: 1, color: AppColor.TRANSPARENT),
                              ),
                              labelText: 'Zip Code',
                              hintStyle: TextStyle(
                                  fontSize: TextSize.bodyText,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.TYPE_SECONDARY
                              ),
                              labelStyle: TextStyle(
                                  fontSize: TextSize.headerText,
                                  fontWeight: FontWeight.w400,
                                  color: AppColor.TYPE_SECONDARY
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
                                formValidation();
                              });
                            },
                          ),
                        ),

                        //Contact Info title
                        Container(
                          padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 22.0),
                          child:  Text(
                            'CONTACT INFO',
                            style: TextStyle(
                                color: AppColor.TYPE_SECONDARY,
                                fontSize: TextSize.bodyText,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'WorkSans'
                            ),
                          ),
                        ),

                        //Add customer email
                        isEmailAvailable
                            ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: (){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AddCustomerEmail(
                                            emailData: emailData
                                        )
                                    )
                                ).then((result){
                                  if(result != null){
                                    if(result['data'] != null){
                                      setState(() {
                                        isEmailAvailable = true;
                                        emailData = result['data'];
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
                                      '${emailData['emailtag']} Email',
                                      style: TextStyle(
                                          color: AppColor.TYPE_SECONDARY,
                                          fontSize: TextSize.subjectTitle,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'WorkSans'
                                      ),
                                    ),
                                    SizedBox(height: 3.0,),
                                    Text(
                                      '${emailData['email']}',
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
                            ),
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
                                        isEmailAvailable = true;
                                        emailData = result['data'];
                                      });
                                    }
                                  }
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 28.0),
                                width: MediaQuery.of(context).size.width,
                                child: Text(
                                  'Add Another Email Address',
                                  style: TextStyle(
                                      color: AppColor.THEME_PRIMARY,
                                      fontSize: TextSize.headerText,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'WorkSans'
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
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
                                    isEmailAvailable = true;
                                    emailData = result['data'];
                                    _allFieldValidate = true;
                                  });
                                }
                              }
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 28.0),
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              'Add Email Address',
                              style: TextStyle(
                                  color: AppColor.THEME_PRIMARY,
                                  fontSize: TextSize.headerText,
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

                        //Add customer phone
                        isPhoneAvailable
                            ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: (){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AddCustomerPhone(
                                            phoneData: phoneData
                                        )
                                    )
                                ).then((result){
                                  if(result != null){
                                    if(result['data'] != null){
                                      setState(() {
                                        isPhoneAvailable = true;
                                        phoneData = result['data'];
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
                                      '${phoneData['phonetag']} Phone Number',
                                      style: TextStyle(
                                          color: AppColor.TYPE_SECONDARY,
                                          fontSize: TextSize.subjectTitle,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'WorkSans'
                                      ),
                                    ),
                                    SizedBox(height: 3.0,),
                                    Text(
                                      '${phoneData['phoneno']}',
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
                            ),
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
                                        isPhoneAvailable = true;
                                        phoneData = result['data'];
                                      });
                                    }
                                  }
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 28.0),
                                width: MediaQuery.of(context).size.width,
                                child: Text(
                                  'Add Another Phone Number',
                                  style: TextStyle(
                                      color: AppColor.THEME_PRIMARY,
                                      fontSize: TextSize.headerText,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'WorkSans'
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
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
                                    isPhoneAvailable = true;
                                    phoneData = result['data'];
                                    _allFieldValidate = true;
                                  });
                                }
                              }
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 28.0),
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              'Add Phone Number',
                              style: TextStyle(
                                  color: AppColor.THEME_PRIMARY,
                                  fontSize: TextSize.headerText,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'WorkSans'
                              ),
                            ),
                          ),
                        ),

                        //Code or Key title
                        Container(
                          padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 22.0),
                          child:  Text(
                            'CODE OR KEY',
                            style: TextStyle(
                                color: AppColor.TYPE_SECONDARY,
                                fontSize: TextSize.bodyText,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'WorkSans'
                            ),
                          ),
                        ),
                        //Gate Code or Key Number
                        isGateCodeAvailable
                            ? InkWell(
                          onTap: (){
                            FocusScope.of(context).requestFocus(FocusNode());
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddCustomerGateKeyPage(
                                        gateKeyData: gateKeyData
                                    )
                                )
                            ).then((result){
                              print("Result====$result");
                              if(result != null){
                                if(result['data'] != null){
                                  setState(() {
                                    gateKeyData = result['data'];
                                    isGateCodeAvailable = true;
                                  });
                                }
                              }
                              formValidation();
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Gate Code or Key Number',
                                  style: TextStyle(
                                      color: AppColor.TYPE_SECONDARY,
                                      fontSize: TextSize.headerText,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'WorkSans'
                                  ),
                                ),
                                SizedBox(height: 3.0,),
                                Text(
                                  '${gateKeyData['code']}',
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
                                    builder: (context) => AddCustomerGateKeyPage(
                                        gateKeyData: gateKeyData
                                    )
                                )
                            ).then((result){
                              print("Result====$result");
                              if(result != null){
                                if(result['data'] != null){
                                  setState(() {
                                    gateKeyData = result['data'];
                                    isGateCodeAvailable = true;
                                    _allFieldValidate = true;
                                  });
                                }
                              }
                              formValidation();
                            });
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 28.0),
                            child: Text(
                              'Gate Code or Key Number',
                              style: TextStyle(
                                  color: AppColor.THEME_PRIMARY,
                                  fontSize: TextSize.headerText,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'WorkSans'
                              ),
                            ),
                          ),
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
                                  _allFieldValidate = true;
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
                                  _allFieldValidate = true;
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
                        Divider(
                          height: 1.0,
                          color: AppColor.SEC_DIVIDER,
                        ),
                        SizedBox(height: 100.0,)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          //Submit Button
          Positioned(
            bottom: 16.0,
            left: 20.0,
            right: 20.0,
            child: InkWell(
              onTap: (){
                if(_formKey.currentState.validate() && _allFieldValidate){
                  var country = countryData != null ? countryData : {"id":"60","mixedcase":"United State", "countryname":"United State", "countrycode":"US"};
                  Map serviceLocationData = {
                    "countryData": country,
                    "streetName": "${_streetController.text.toString().trim()}",
                    "nickName": "${_locationNameController.text.toString().trim()}",
                    "cityName" : "${_cityController.text.toString().trim()}",
                    "stateData" : stateData,
                    "zipCodeData" : "${_zipCodeController.text.toString().trim()}",
                  };
                  print(serviceLocationData);

                  if(type == ''){
                    Navigator.of(context).pop({"data": serviceLocationData});
                  } else {
                    createClientServiceLocation(serviceLocationData);
                  }
                } else {
                  setState(() {
                    _autoValidate = true;
                    _locationNameFocus.requestFocus(FocusNode());
                  });
                }
              },
              child: Container(
                margin: EdgeInsets.only(top: 24.0),
                height: 56.0,
                decoration: BoxDecoration(
                    color: _allFieldValidate ? AppColor.THEME_PRIMARY : AppColor.DEACTIVATE,
                    borderRadius: BorderRadius.all(Radius.circular(4.0))
                ),
                child: Center(
                  child: Text(
                    'ADD SERVICE LOCATION',
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
    );
  }

  void setDataInTextField() {
    setState((){
      if(_sameBillAddressSwitch) {
        countryData = widget.billData['country'];
        stateData = widget.billData['state'];
        _zipCodeController.text = widget.billData['zipCodeData']['zipCode'];
        _streetController.text = widget.billData['street1'];
        _cityController.text = widget.billData['city'];
      } else {
        stateData = null;
        _zipCodeController.text = "";
        _streetController.text = "";
        _cityController.text = "";
      }
    });
  }

  void formValidation(){
    setState(() {
      _allFieldValidate = (_formKey.currentState.validate()) && (stateData != null) && (gateKeyData != null);
    });
    print(_allFieldValidate);
  }

  String validateString(String value, String type) {
    if(value!='' && value!=null) {
      if(!value.startsWith(' '))
        return null;
      else
        return 'Enter your $type';
    }
    else {
      return 'Enter your $type';
    }
  }

  ///////////////////////////API INTEGRATION////////////////////////
  Future<void> createClientServiceLocation(serviceData) async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var requestJson = {
      "street1":"${serviceData['streetName']}",
      "street2":"${serviceData['streetName']}",
      "city":"${serviceData['cityName']}",
      "statecode":"${serviceData['stateData']['abbr']}",
      "countrycode":"${serviceData['countryData']['countrycode']}",
      "zip":"${serviceData['zipCodeData']}",
      "serviceaddressnick":"${serviceData['nickName']}"
    };

    var requestParam = json.encode(requestJson);
    var response = await request.postRequest("auth/myclient/$clientId/servicelocation", requestParam);
    _progressHUD.state.dismiss();
    print("Service Location post response get back: $response");

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        HelperClass.showSnackBar(context, '${response['reason']}');
      } else {
        Navigator.of(context).pop({"data": response});
      }
    } else {
      HelperClass.showSnackBar(context, 'Something Went Wrong!');
    }
  }
}