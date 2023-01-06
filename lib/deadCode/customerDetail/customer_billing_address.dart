import 'dart:convert';

import 'package:dottie_inspector/deadCode/customerDetail/customer_zip_code.dart';
import 'package:dottie_inspector/deadCode/models/country_list_page.dart';
import 'package:dottie_inspector/deadCode/models/state_list_page.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:progress_hud/progress_hud.dart';

class AddCustomerBillingAddress extends StatefulWidget {
  final billData;
  final type;
  final clientId;

  const AddCustomerBillingAddress({Key key, this.billData, this.type, this.clientId}) : super(key: key);

  @override
  _AddCustomerBillingAddressState createState() => _AddCustomerBillingAddressState();
}

class _AddCustomerBillingAddressState extends State<AddCustomerBillingAddress> {

  bool _allFieldValidate = false;
  bool _autoValidate = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _streetController = TextEditingController();
  final _cityController = TextEditingController();

  final FocusNode _streetFocus = FocusNode();
  final FocusNode _cityFocus = FocusNode();

  Map countryData;
  Map stateData;
  Map zipData;
  String _country = '';
  String _state = '';
  String cityName = "City";

  String clientId = "";
  String type = "";

  bool isZipCodeAvailable = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // location
  Geolocator geoLocator = Geolocator();
  Position _currentPosition;

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

    if(widget.billData != null){
      countryData = widget.billData['country'];
      stateData = widget.billData['state'];
      zipData = widget.billData['zipCodeData'];
      _streetController.text = widget.billData['street1'];
      _cityController.text = widget.billData['city'];
      isZipCodeAvailable =true;
      _allFieldValidate =true;
    }

    type = widget.type ?? "";
    clientId = widget.clientId ?? "";
    getLocation();
  }

  void getLocation() async {
    _currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    _getAddressFromLatLng();
  }

  _getAddressFromLatLng() async {
    try {
      /*List<Place> p = await Geolocator.get(_currentPosition.latitude, _currentPosition.longitude);
      Placemark place = p[0];
      setState(() {
        _country = '${place.country}';
        _state = '${place.administrativeArea}';
        cityName = '${place.locality}';

//        cityName = '${place.locality}' + (place.administrativeArea.isEmpty) ? ', ${place.administrativeArea}' : '';
      });

      debugPrint('Address : Country : $_country State : $_state City : $cityName');
//      if(_country != null && _state != null && cityName != null)
//        updateCity();*/
    } catch (e) {
      print(e);
    }
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
          },
        ),
//        actions: <Widget>[
//          InkWell(
//            onTap: (){
//              setState(() {
//                _streetController.text = "";
//                _cityController.text = "";
//                isZipCodeAvailable = false;
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
          'Add Billing Address',
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
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.0),
                          child:  Image.asset(
                            'assets/ic_location.png',
                            width: 24.0,
                            height: 24.0,
                            color: AppColor.THEME_PRIMARY,
                          ),
                        ),
                        SizedBox(width: 16.0,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Use Current Location',
                              style: TextStyle(
                                  color: AppColor.TYPE_PRIMARY,
                                  fontSize: TextSize.subjectTitle,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'WorkSans'
                              ),
                            ),
                            SizedBox(height: 5.0,),
                            Text(
                              cityName =='City' ? 'City' : '$cityName, $_state, $_country',
                              style: TextStyle(
                                  color: AppColor.TYPE_SECONDARY,
                                  fontSize: TextSize.bodyText,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'WorkSans'
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                  Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
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
                            validator: (value){
                              return validateString(value, "city");
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
                                      builder: (context) => StateListPage(
                                          countryCode: countryData!=null ? countryData['countrycode'] : 'US'
                                      )
                                  )
                              ).then((result) {
                                if(result != null){
                                  if(result['stateData'] != null){
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
                        isZipCodeAvailable
                        ? InkWell(
                          onTap: (){
                            FocusScope.of(context).requestFocus(FocusNode());
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddCustomerZipCodePage(
                                        zipData: zipData
                                    )
                                )
                            ).then((result){
                              print("Result====$result");
                              if(result != null){
                                if(result['data'] != null){
                                  setState(() {
                                    zipData = result['data'];
                                    isZipCodeAvailable = true;
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
                                  'Zip Code',
                                  style: TextStyle(
                                      color: AppColor.TYPE_SECONDARY,
                                      fontSize: TextSize.headerText,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'WorkSans'
                                  ),
                                ),
                                SizedBox(height: 3.0,),
                                Text(
                                  '${zipData['zipCode']}',
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
                                    builder: (context) => AddCustomerZipCodePage(
                                        zipData: zipData
                                    )
                                )
                            ).then((result){
                              print("Result====$result");
                              if(result != null){
                                if(result['data'] != null){
                                  setState(() {
                                    zipData = result['data'];
                                    isZipCodeAvailable = true;
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
                              'Zip Code',
                              style: TextStyle(
                                  color: AppColor.TYPE_SECONDARY,
                                  fontSize: TextSize.headerText,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'WorkSans'
                              ),
                            ),
                          ),
                        ),
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
                  Map billData = {
                    "clientaddresstag": "Billing",
                    "clientaddresspreferred": true,
                    "country": country,
                    "street1": "${_streetController.text.toString().trim()}",
                    "city" : "${_cityController.text.toString().trim()}",
                    "state" : stateData,
                    "zipCodeData" : zipData
                  };
                  if(type == ''){
                    Navigator.of(context).pop({"data": billData});
                  } else {
                    createClientBillingAddress(billData);
                  }
                } else {
                  setState(() {
                    _autoValidate = true;
                    _streetFocus.requestFocus(FocusNode());
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
                    'ADD BILLING ADDRESS',
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

  void formValidation(){
    setState(() {
      _allFieldValidate = (_formKey.currentState.validate()) && (stateData != null) && (zipData != null);
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
  Future<void> createClientBillingAddress(billData) async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var requestJson = {
      "street1":"${billData['street1']}",
      "street2":"${billData['']}",
      "city":"${billData['city']}",
      "statecode":"${billData['state']['abbr']}",
      "countrycode":"${billData['country']['countrycode']}",
      "zip":"${billData['zipCodeData']['zipCode']}",
      "clientaddresstag":"${billData['clientaddresstag']}",
      "clientaddresspreferred":false
    };
    var requestParam = json.encode(requestJson);
    var response = await request.postRequest("auth/myclient/$clientId/address", requestParam);
    _progressHUD.state.dismiss();
    print("Phone post response get back: $response");

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
