import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/custom_toast.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:dottie_inspector/widget/bottom_general_button_widget.dart';
import 'package:dottie_inspector/widget/gradient/grediant_box_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_hud/progress_hud.dart';

class CompanyAddressPage extends StatefulWidget {
  final title;
  final value;
  final companyData;

  const CompanyAddressPage({Key key, this.title, this.value, this.companyData}) : super(key: key);

  @override
  _CompanyAddressPageState createState() => _CompanyAddressPageState();
}

class _CompanyAddressPageState extends State<CompanyAddressPage> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _streetController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _apartmentController = TextEditingController();

  final FocusNode _streetFocus = FocusNode();
  final FocusNode _stateFocus = FocusNode();
  final FocusNode _cityFocus = FocusNode();
  final FocusNode _zipCodeFocus = FocusNode();
  final FocusNode _apartmentFocus = FocusNode();

  bool isStreetFocus = false;
  bool isStateFocus = false;
  bool isCityFocus = false;
  bool isApartmentFocus = false;
  bool isZipCodeFocus = false;
  bool isFocusOn = true;

  var imagePath = '';
  bool isPhotoTaken = false;
  bool _autoValidate = false;
  bool _allFieldValidate = false;
  Map companyData;
  var elevation = 0.0;
  ScrollController _scrollController = ScrollController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;
  List stateList = [];
  var stateData;
  var countryName = "US";
  var stateCode = "";
  List addressList = [];


  // final MyConnectivity _connectivity = MyConnectivity.instance;
  bool _isInternetAvailable = true;
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  ///validation
  bool isUpdated = false;
  String streetName = "";
  String apartmentName = "";
  String cityName = "";
  String stateName = "";
  String stateLocalName = "";
  String zipCode = "";

  bool isDarkMode = false;
  Color themeColor = AppColor.BLACK_COLOR;

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

    _scrollController.addListener(() {
      setState(() {
        if(_scrollController.position.pixels > _scrollController.position.minScrollExtent){
          elevation = HelperClass.ELEVATION_1;
        } else {
          elevation = HelperClass.ELEVATION;
        }
      });
    });

    companyData = widget.companyData;

    log("CompanyData===$companyData");

    if(companyData != null) {
      if(companyData['address'] != null) {
        for (int i = 0; i < companyData['address'].length; i++) {
          if (companyData['address'][i]['accountaddresstag'] == "Physical Address") {
            Map companyPhysicalAddress = companyData['address'][i];
            setState(() {
              _streetController.text = companyPhysicalAddress['street1'];
              _cityController.text = companyPhysicalAddress['city'];
              _zipCodeController.text = companyPhysicalAddress['zip'];
              _apartmentController.text = companyPhysicalAddress['street2'];
              countryName = companyPhysicalAddress['country'];
              stateCode = companyPhysicalAddress['state'] ?? "";

              streetName = companyPhysicalAddress['street1'];
              cityName = companyPhysicalAddress['city'];
              apartmentName = companyPhysicalAddress['street2'];
              zipCode = companyPhysicalAddress['zip'];
            });
          } else {
            addressList.add(companyData['address'][i]);
          }
        }
      }
    }

    initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    // Timer(Duration(milliseconds: 100), getStateList);
    getPreferenceData();
    setAddressFormStates();
  }

  void getPreferenceData() async {
    await PreferenceHelper.getPreferenceData(PreferenceHelper.THEME_MODE).then((value){
      setState(() {
        var themeMode = value == null ? "" : value;
        if(themeMode == "auto") {
          var brightness = MediaQuery.of(context).platformBrightness;
          themeMode = Brightness.dark ==  brightness ? "dark" : "light";
        }
        isDarkMode = themeMode == "dark";
        themeColor = isDarkMode ? AppColor.WHITE_COLOR : AppColor.BLACK_COLOR;

        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: isDarkMode ? Colors.black : AppColor.THEME_PRIMARY.withOpacity(0.4),
          statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        ));
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      log('Couldn\'t check connectivity status', error: e);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectivityResult = result;
      log("Connection====$_connectivityResult");
      setState(() {
        if(_connectivityResult == ConnectivityResult.none) {
          print("No Internet found");
          _isInternetAvailable = false;
        } else if(_connectivityResult == ConnectivityResult.mobile) {
          print("Mobile");
          _isInternetAvailable = true;
          getStateList();
        } else if(_connectivityResult == ConnectivityResult.wifi) {
          print("WIFI");
          _isInternetAvailable = true;
          getStateList();
        }
      });
    });
  }

  void setAddressFormStates() {
    _stateFocus.addListener(() {
      setState(() {
        isStateFocus = _stateFocus.hasFocus;
        isFocusOn = !_stateFocus.hasFocus;
      });
    });

    _streetFocus.addListener(() {
      setState(() {
        isStreetFocus = _streetFocus.hasFocus;
        isFocusOn = !_streetFocus.hasFocus;
      });
    });

    _cityFocus.addListener(() {
      setState(() {
        isCityFocus = _cityFocus.hasFocus;
        isFocusOn = !_cityFocus.hasFocus;
      });
    });

    _zipCodeFocus.addListener(() {
      setState(() {
        isZipCodeFocus = _zipCodeFocus.hasFocus;
        isFocusOn = !_zipCodeFocus.hasFocus;
      });
    });

    _apartmentFocus.addListener(() {
      setState(() {
        isApartmentFocus = _apartmentFocus.hasFocus;
        isFocusOn = !_apartmentFocus.hasFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode ? AppColor.BLACK_COLOR : AppColor.PAGE_COLOR,
      appBar: EmptyAppBar(isDarkMode: isDarkMode),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop({"result": isUpdated});
          return true;
        },
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop({"result": isUpdated});
                        },
                        child: Container(
                          child: Image.asset(
                            isDarkMode
                                ? 'assets/ic_dark_back_button.png'
                                : 'assets/ic_close_button.png',
                            fit: BoxFit.cover,
                            width: 48,
                            height: 48,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 8,
                        child: Visibility(
                          visible: elevation != 0,
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              'Company Address',
                              style: TextStyle(
                                  color: themeColor,
                                  fontSize: TextSize.headerText,
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(),
                      ),
                    ],
                  ),
                ),

                Visibility(
                    visible: elevation != 0,
                    child: Divider(
                      height: 0.5,
                      thickness: 1,
                      color: isDarkMode ? AppColor.DIVIDER.withOpacity(0.4) : AppColor.DIVIDER,
                    )
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          child: Text(
                            'Company Address',
                            style: TextStyle(
                                color: themeColor,
                                fontSize: TextSize.greetingTitleText,
                                fontWeight: FontWeight.w700
                            ),
                          ),
                        ),

                        /***
                         * Country
                         */
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(top: 16.0, bottom: 0.0, left: 16, right: 16),
                          padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                          decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Color(0xff1F1F1F)
                                  : AppColor.WHITE_COLOR,
                              borderRadius: BorderRadius.circular(32.0)
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Country',
                                style: TextStyle(
                                    fontSize: TextSize.subjectTitle,
                                    color: themeColor.withOpacity(1.0),
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.normal
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  '$countryName',
                                  style: TextStyle(
                                      fontSize: TextSize.headerText,
                                      color: themeColor.withOpacity(1.0),
                                      fontWeight: FontWeight.w700,
                                      fontStyle: FontStyle.normal
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(left: 16.0, right: 16.0),
                          child: Form(
                            key: _formKey,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  /***
                                   * Street
                                   */
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                    padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isStreetFocus && isDarkMode
                                              ? AppColor.gradientColor(0.32)
                                              : isStreetFocus
                                              ? AppColor.gradientColor(0.16)
                                              : isDarkMode
                                              ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                                              : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
                                        ),
                                        borderRadius: BorderRadius.circular(32.0),
                                        border: GradientBoxBorder(
                                            gradient: LinearGradient(
                                              colors: isStreetFocus
                                                  ? AppColor.gradientColor(1.0)
                                                  : [AppColor.TRANSPARENT, AppColor.TRANSPARENT],
                                            ),
                                            width: 3
                                        )
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Street',
                                          style: TextStyle(
                                              fontSize: TextSize.subjectTitle,
                                              color: themeColor.withOpacity(1.0),
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FontStyle.normal
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        TextFormField(
                                          controller: _streetController,
                                          focusNode: _streetFocus,
                                          onFieldSubmitted: (term) {
                                            _streetFocus.unfocus();
                                            FocusScope.of(context).requestFocus(_apartmentFocus);
                                          },
                                          textCapitalization: TextCapitalization.sentences,
                                          textInputAction: TextInputAction.next,
                                          keyboardType: TextInputType.name,
                                          textAlign: TextAlign.start,
                                          validator: (value){
                                            return validateString(value, "street");
                                          },
                                          decoration: InputDecoration(
                                            fillColor: AppColor.WHITE_COLOR,
                                            hintText: "Street",
                                            filled: false,
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.only(top: 0,),
                                            hintStyle: TextStyle(
                                                fontSize: TextSize.headerText,
                                                fontWeight: FontWeight.w700,
                                                color: isDarkMode
                                                    ? Color(0xff545454)
                                                    : Color(0xff808080)
                                            ),
                                          ),
                                          style: TextStyle(
                                              color: themeColor,
                                              fontWeight: FontWeight.w700,
                                              fontSize: TextSize.headerText
                                          ),
                                          inputFormatters: [LengthLimitingTextInputFormatter(40)],
                                          onChanged: (value){
                                            setState(() {
                                              _allFieldValidate = _formKey.currentState.validate();
                                              isUpdated = streetName != _streetController.text;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  /***
                                   * Apartment
                                   */
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                    padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isApartmentFocus && isDarkMode
                                              ? AppColor.gradientColor(0.32)
                                              : isApartmentFocus
                                              ? AppColor.gradientColor(0.16)
                                              : isDarkMode
                                              ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                                              : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
                                        ),
                                        borderRadius: BorderRadius.circular(32.0),
                                        border: GradientBoxBorder(
                                            gradient: LinearGradient(
                                              colors: isApartmentFocus
                                                  ? AppColor.gradientColor(1.0)
                                                  : [AppColor.TRANSPARENT, AppColor.TRANSPARENT],
                                            ),
                                            width: 3
                                        )
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Apt/Suite (Optional)',
                                          style: TextStyle(
                                              fontSize: TextSize.subjectTitle,
                                              color: themeColor.withOpacity(1.0),
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FontStyle.normal
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        TextFormField(
                                          controller: _apartmentController,
                                          focusNode: _apartmentFocus,
                                          validator: (value) {
                                            return validateString(value, "apartment");
                                          },
                                          onFieldSubmitted: (term) {
                                            _apartmentFocus.unfocus();
                                            FocusScope.of(context).requestFocus(_cityFocus);
                                          },
                                          textCapitalization: TextCapitalization.sentences,
                                          textInputAction: TextInputAction.next,
                                          keyboardType: TextInputType.text,
                                          textAlign: TextAlign.start,
                                          decoration: InputDecoration(
                                            fillColor: AppColor.WHITE_COLOR,
                                            hintText: "Apartment",
                                            filled: false,
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.only(top: 0,),
                                            hintStyle: TextStyle(
                                                fontSize: TextSize.headerText,
                                                fontWeight: FontWeight.w700,
                                                color: isDarkMode
                                                    ? Color(0xff545454)
                                                    : Color(0xff808080)
                                            ),
                                          ),
                                          style: TextStyle(
                                              color: themeColor,
                                              fontWeight: FontWeight.w700,
                                              fontSize: TextSize.headerText
                                          ),
                                          inputFormatters: [LengthLimitingTextInputFormatter(40)],
                                          onChanged: (value){
                                            setState(() {
                                              _allFieldValidate = _formKey.currentState.validate();
                                              isUpdated = apartmentName != _apartmentController.text;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),

                                  /***
                                   * City
                                   */
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                    padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isCityFocus && isDarkMode
                                              ? AppColor.gradientColor(0.32)
                                              : isCityFocus
                                              ? AppColor.gradientColor(0.16)
                                              : isDarkMode
                                              ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                                              : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
                                        ),
                                        borderRadius: BorderRadius.circular(32.0),
                                        border: GradientBoxBorder(
                                            gradient: LinearGradient(
                                              colors: isCityFocus
                                                  ? AppColor.gradientColor(1.0)
                                                  : [AppColor.TRANSPARENT, AppColor.TRANSPARENT],
                                            ),
                                            width: 3
                                        )
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'City',
                                          style: TextStyle(
                                              fontSize: TextSize.subjectTitle,
                                              color: themeColor.withOpacity(1.0),
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FontStyle.normal
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        TextFormField(
                                          controller: _cityController,
                                          focusNode: _cityFocus,
                                          validator: (value) {
                                            return validateString(value, "city");
                                          },
                                          onFieldSubmitted: (term) {
                                            _cityFocus.unfocus();
                                            FocusScope.of(context).requestFocus(_zipCodeFocus);
                                          },
                                          textCapitalization: TextCapitalization.sentences,
                                          textInputAction: TextInputAction.next,
                                          keyboardType: TextInputType.text,
                                          textAlign: TextAlign.start,
                                          decoration: InputDecoration(
                                            fillColor: AppColor.WHITE_COLOR,
                                            hintText: "City",
                                            filled: false,
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.only(top: 0,),
                                            hintStyle: TextStyle(
                                                fontSize: TextSize.headerText,
                                                fontWeight: FontWeight.w700,
                                                color: isDarkMode
                                                    ? Color(0xff545454)
                                                    : Color(0xff808080)
                                            ),
                                          ),
                                          style: TextStyle(
                                              color: themeColor,
                                              fontWeight: FontWeight.w700,
                                              fontSize: TextSize.headerText
                                          ),
                                          inputFormatters: [LengthLimitingTextInputFormatter(40)],
                                          onChanged: (value){
                                            setState(() {
                                              _allFieldValidate = _formKey.currentState.validate();
                                              isUpdated = cityName != _cityController.text;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),

                                  /***
                                   * State
                                   */
                                  GestureDetector(
                                    onTap: (){
                                      bottomStatePicker(context);
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                      padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: isStateFocus && isDarkMode
                                                ? AppColor.gradientColor(0.32)
                                                : isStateFocus
                                                ? AppColor.gradientColor(0.16)
                                                : isDarkMode
                                                ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                                                : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
                                          ),
                                          borderRadius: BorderRadius.circular(32.0),
                                          border: GradientBoxBorder(
                                              gradient: LinearGradient(
                                                colors: isStateFocus
                                                    ? AppColor.gradientColor(1.0)
                                                    : [AppColor.TRANSPARENT, AppColor.TRANSPARENT],
                                              ),
                                              width: 3
                                          )
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'State',
                                            style: TextStyle(
                                                fontSize: TextSize.subjectTitle,
                                                color: themeColor.withOpacity(1.0),
                                                fontWeight: FontWeight.w600,
                                                fontStyle: FontStyle.normal
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          Container(
                                            margin: EdgeInsets.symmetric(vertical: 16),
                                            child: Text(
                                              stateData != null
                                                  ? '${stateData['label']}'
                                                  : "State",
                                              style: stateData != null
                                              ? TextStyle(
                                                  fontSize: TextSize.headerText,
                                                  color: themeColor.withOpacity(1.0),
                                                  fontWeight: FontWeight.w700,
                                                  fontStyle: FontStyle.normal
                                              )
                                              : TextStyle(
                                                  fontSize: TextSize.headerText,
                                                  color: AppColor.TYPE_PRIMARY.withOpacity(0.6),
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle: FontStyle.normal
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          // TextFormField(
                                          //   controller: _stateController,
                                          //   focusNode: _stateFocus,
                                          //   validator: (value) {
                                          //     return validateString(value, "state");
                                          //   },
                                          //   onFieldSubmitted: (term) {
                                          //     _stateFocus.unfocus();
                                          //     FocusScope.of(context).requestFocus(_zipCodeFocus);
                                          //   },
                                          //   textCapitalization: TextCapitalization.sentences,
                                          //   textInputAction: TextInputAction.next,
                                          //   keyboardType: TextInputType.text,
                                          //   textAlign: TextAlign.start,
                                          //   decoration: InputDecoration(
                                          //     fillColor: AppColor.WHITE_COLOR,
                                          //     hintText: "State",
                                          //     filled: false,
                                          //     border: InputBorder.none,
                                          //     contentPadding: EdgeInsets.only(top: 0,),
                                          //     hintStyle: TextStyle(
                                          //         fontSize: TextSize.headerText,
                                          //         fontWeight: FontWeight.w700,
                                          //         color: AppColor.TYPE_PRIMARY.withOpacity(0.6)
                                          //     ),
                                          //   ),
                                          //   style: TextStyle(
                                          //       color: themeColor,
                                          //       fontWeight: FontWeight.w700,
                                          //       fontSize: TextSize.headerText
                                          //   ),
                                          //   inputFormatters: [LengthLimitingTextInputFormatter(40)],
                                          //   onChanged: (value){
                                          //     setState(() {
                                          //       _allFieldValidate = _formKey.currentState.validate();
                                          //     });
                                          //   },
                                          // ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  /***
                                   * ZipCode
                                   */
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                    padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isZipCodeFocus && isDarkMode
                                              ? AppColor.gradientColor(0.32)
                                              : isZipCodeFocus
                                              ? AppColor.gradientColor(0.16)
                                              : isDarkMode
                                              ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                                              : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
                                        ),
                                        borderRadius: BorderRadius.circular(32.0),
                                        border: GradientBoxBorder(
                                            gradient: LinearGradient(
                                              colors: isZipCodeFocus
                                                  ? AppColor.gradientColor(1.0)
                                                  : [AppColor.TRANSPARENT, AppColor.TRANSPARENT],
                                            ),
                                            width: 3
                                        )
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Zip Code',
                                          style: TextStyle(
                                              fontSize: TextSize.subjectTitle,
                                              color: themeColor.withOpacity(1.0),
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FontStyle.normal
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        TextFormField(
                                          controller: _zipCodeController,
                                          focusNode: _zipCodeFocus,
                                          validator: (value) {
                                            return validateString(value, "zip code");
                                          },
                                          textInputAction: TextInputAction.done,
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.start,
                                          decoration: InputDecoration(
                                            fillColor: AppColor.WHITE_COLOR,
                                            hintText: "00000",
                                            filled: false,
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.only(top: 0,),
                                            hintStyle: TextStyle(
                                                fontSize: TextSize.headerText,
                                                fontWeight: FontWeight.w700,
                                                color: isDarkMode
                                                    ? Color(0xff545454)
                                                    : Color(0xff808080)
                                            ),
                                          ),
                                          style: TextStyle(
                                              color: themeColor,
                                              fontWeight: FontWeight.w700,
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
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 160.0,)
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Visibility(
              visible: isFocusOn,
              child: BottomGeneralButton(
                isActive: isUpdated,
                buttonName: "UPDATE",
                onStartButton: () async {
                  // if(_formKey.currentState.validate() && _allFieldValidate){
                  //   updateCompanyDetail();
                  // } else {
                  //   setState(() {
                  //     _streetFocus.requestFocus(FocusNode());
                  //     _autoValidate = true;
                  //   });
                  // }

                  if(isUpdated) {
                    updateCompanyDetail();
                  }
                  // if(await HelperClass.internetConnectivity()) {
                  //   updateCompanyDetail();
                  // } else {
                  //   HelperClass.openSnackBar(context);
                  // }
                },
              )
            ),

            _progressHUD
          ],
        ),
      ),
    );
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

  void updateCompanyDetail() async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var physicalAddress = {
      "accountaddresstag":"Physical Address",
      "street1": "${_streetController.text}",
      "street2": "${_apartmentController.text}",
      "city": "${_cityController.text}",
      "state": "${stateData['abbr']}",
      "zip": "${_zipCodeController.text}",
      "country": "$countryName"
    };
    addressList.add(physicalAddress);
    var requestJson = {
      "address": addressList
    };
    print("Request===$requestJson");
    var requestParam = json.encode(requestJson);
    var response = await request.postRequest("auth/admin/setAllAddresses", requestParam);
    _progressHUD.state.dismiss();

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage('${response['reason']}');
      } else {
        // companyData.remove('address');
        companyData['address'] = addressList;
        CustomToast.showTopShortToast("Success");
      }
    }
  }

  ///////////API Integration/////////////////
  Future<void> getStateList() async {
      _progressHUD.state.show();
      FocusScope.of(context).requestFocus(FocusNode());
      var response = await request.getUnAuthRequest("unauth/states/US");
      print("Country list response get back: $response");
      _progressHUD.state.dismiss();

      if (response != null) {
        setState(() {
          stateList = response;

          for(var state in stateList) {
            if(state['abbr'] == stateCode) {
              stateData = state;
              stateLocalName = stateData['label'];
              break;
            }
          }
        });
      }
  }

  void bottomStatePicker(context){
    showModalBottomSheet(
        context: context,
        barrierColor: isDarkMode ? Color(0xff000000).withOpacity(0.8) : Color(0xff000000).withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        isDismissible: true,
        builder: (context){
          return StatefulBuilder(
            builder: (context1, myState){
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(top: 16.0,left: 16, right: 16, bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select State',
                          style: TextStyle(
                            fontSize: TextSize.headerText,
                            color: themeColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        GestureDetector(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          child: Container(
                            child: Image.asset(
                              isDarkMode
                              ? 'assets/ic_dark_close.png'
                              : 'assets/ic_back_close.png',
                              height: 32.0,
                              width: 32.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, thickness: 1, color: isDarkMode ? AppColor.DIVIDER.withOpacity(0.4) : AppColor.DIVIDER,),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 24),
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: stateList != null ? stateList.length : 0,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: (){
                                          Navigator.pop(context);
                                          setState(() {
                                            stateData = stateList[index];
                                            isUpdated = stateLocalName != stateData['label'];
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(vertical: 6),
                                          child: Text(
                                            stateList[index]['label'],
                                            style: TextStyle(
                                                fontSize: TextSize.subjectTitle,
                                                color: themeColor,
                                                fontWeight: FontWeight.w600
                                            ),
                                          ),
                                        ),
                                      ),
                                      Divider(height: 1, thickness: 1, color: isDarkMode ? AppColor.DIVIDER.withOpacity(0.4) : AppColor.DIVIDER,),
                                    ],
                                  ),
                                );
                              },
                            ),

                            SizedBox(
                              height: 12.0,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 0,)
                ],
              );
            },
          );
        }
    );
  }
}
