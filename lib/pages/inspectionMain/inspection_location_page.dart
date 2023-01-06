import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dottie_inspector/connection_mixin.dart';
import 'package:dottie_inspector/database/database_helper.dart';
import 'package:dottie_inspector/inspectionPreferences/inspection_preferences.dart';
import 'package:dottie_inspector/map_box_token.dart';
import 'package:dottie_inspector/model/inspection_data_model.dart';
import 'package:dottie_inspector/pages/menu/drawer_page.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/SlideRightRoute.dart';
import 'package:dottie_inspector/utils/custom_toast.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:dottie_inspector/utils/globalInstance.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/utils/inspection_utils.dart';
import 'package:dottie_inspector/utils/language.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:dottie_inspector/widget/GradientText.dart';
import 'package:dottie_inspector/widget/bottom_button_widget.dart';
import 'package:dottie_inspector/widget/dotted_border/dotted_border.dart';
import 'package:dottie_inspector/widget/gradient/grediant_box_border.dart';
import 'package:dottie_inspector/widget/image_view_screen_page.dart';
import 'package:dottie_inspector/widget/masked_phone_number.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_launcher_icons/android.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_hud/progress_hud.dart';

class InspectionLocationPage extends StatefulWidget {
  final clientId;
  final clientData;
  final detail;
  final inspectionDefId;
  final isClientServer;
  const InspectionLocationPage({Key key, this.clientId, this.detail, this.inspectionDefId, this.clientData, this.isClientServer}) : super(key: key);

  @override
  _InspectionLocationPageState createState() => _InspectionLocationPageState();
}

class _InspectionLocationPageState extends State<InspectionLocationPage> with MyConnection{
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  // location
  Geolocator geoLocator = Geolocator();
  Position _currentPosition;
  bool isLocationFound = false;
  bool isEditLocationFound = false;
  String locationName = '';
  String serviceAddressName = '';
  double latitude = 0.0;
  double longitude = 0.0;
  String countryCode = "";
  String stateCode = "";
  String zipCode = "";
  String cityName = "";
  String clientId = "";
  var inspectionDefIdLocal = '';
  var blockDetail;
  var customerData;
  List serviceList = [];

  // MapboxMapController mapController;
  //
  // void _onMapCreated(MapboxMapController controller) {
  //   mapController = controller;
  // }

  var isClientServer = false;
  var isLocalImage = false;
  var isPhotoTaken = false;
  var imagePath = '';
  var existingImage = '';
  var selectedIndex = -1;
  File noteImagePath;
  var photoDescription = "";
  var elevation = 0.0;
  final _scrollController = ScrollController();
  final dbHelper = DatabaseHelper.instance;

  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;

  List stateList = [];
  var stateData;
  var imagePathData;
  var countryName = "US";

  // Bottom sheet
  bool _allFieldValidate = false;
  bool _allEditFieldValidate = false;
  bool _allCustomerFieldValidate = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _locationNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _apartmentController = TextEditingController();

  final FocusNode _streetFocus = FocusNode();
  final FocusNode _locationNameFocus = FocusNode();
  final FocusNode _cityFocus = FocusNode();
  final FocusNode _zipCodeFocus = FocusNode();
  final FocusNode _apartmentFocus = FocusNode();

  bool isStreetFocus = false;
  bool isNickNameFocus = false;
  bool isCityFocus = false;
  bool isApartmentFocus = false;
  bool isZipCodeFocus = false;
  bool isLocationLoaded = false;

  ///Edit Location
  final GlobalKey<FormState> _editFormKey = GlobalKey<FormState>();
  final _editStreetController = TextEditingController();
  final _editLocationNameController = TextEditingController();
  final _editCityController = TextEditingController();
  final _editZipCodeController = TextEditingController();
  final _editApartmentController = TextEditingController();

  final FocusNode _editStreetFocus = FocusNode();
  final FocusNode _editLocationNameFocus = FocusNode();
  final FocusNode _editCityFocus = FocusNode();
  final FocusNode _editZipCodeFocus = FocusNode();
  final FocusNode _editApartmentFocus = FocusNode();

  bool isEditStreetFocus = false;
  bool isEditNickNameFocus = false;
  bool isEditCityFocus = false;
  bool isEditApartmentFocus = false;
  bool isEditZipCodeFocus = false;
  bool isEditLocationLoaded = false;

  var dialogState;

  ///Edit Customer
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController email1Controller = TextEditingController();
  var phone1Controller = MaskedTextController(mask: '(000) 000-0000');

  FocusNode firstNameFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();
  FocusNode email1Focus = FocusNode();
  FocusNode phone1Focus = FocusNode();

  bool isFirstNameFocus = false;
  bool isLastNameFocus = false;
  bool isEmail1Focus = false;
  bool isPhone1Focus = false;
  final GlobalKey<FormState> _customerFormKey = GlobalKey<FormState>();
  bool isLoaded = false;
  var customerState;
  var locationState;
  var locationEditState;
  String lang = "en";

  List emailList = [];
  List phoneList = [];

  bool isDarkMode = false;
  Color themeColor = AppColor.BLACK_COLOR;

  bool _isInternetAvailable = true;
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState(){
    super.initState();
    _progressHUD = ProgressHUD(
      backgroundColor: Colors.transparent,
      color: Colors.white,
      containerColor: AppColor.LOADER_COLOR,
      borderRadius: 5.0,
      loading: _loading,
      text: 'Loading...',
    );

    Timer(Duration(milliseconds: 100), getStateListFromLocalDB);

    clientId = widget.clientId ?? '';
    print("Client Id=====$clientId");
    _scrollController.addListener(() {
      setState(() {
        if(_scrollController.position.pixels > _scrollController.position.minScrollExtent){
          elevation = HelperClass.ELEVATION_1;
        } else {
          elevation = HelperClass.ELEVATION;
        }
      });
    });

    initConnectivity();
    getPreferenceData();

    setCustomerFormStates();
    setLocationFormStates();
    setLocationEditFormStates();
  }

  void getPreferenceData() async {
    lang = await PreferenceHelper.getPreferenceData(PreferenceHelper.LANGUAGE) ?? "en";

    setState(() {
      isClientServer = widget.isClientServer;

      var dynamicData = widget.detail;
      blockDetail = dynamicData['txt'][lang] ?? dynamicData['txt']['en'];
      inspectionDefIdLocal = widget.inspectionDefId;
      customerData = widget.clientData;
      var customerLocalData = json.decode(json.encode(customerData));
      // log("CustomerData====>>>>>${customerLocalData['phone']}");
      // log("CustomerData====>>>>>${customerLocalData['email']}");
      emailList = customerLocalData['email'] ?? [];
      phoneList = customerLocalData['phone'] ?? [];

      serviceList = customerData['servicelocation'];

      log("ServiceList===$serviceList");

      var customerName = '${customerData['firstname'] ?? ''} ${customerData['lastname'] ?? ''}';
      PreferenceHelper.setPreferenceData(PreferenceHelper.INSPECTION_CUSTOMER_NAME, customerName);
    });

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
  void initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      log('Couldn\'t check connectivity status', error: e);
      return;
    }

    connectionSubscription();

    if (!mounted) {
      return Future.value(null);
    }

    return updateConnectionStatus(result);
  }

  @override
  void connectionSubscription() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      updateConnectionStatus(result);
    });
  }

  @override
  void updateConnectionStatus(result) {
    setState(() {
      _connectivityResult = result;
      if (_connectivityResult == ConnectivityResult.none) {
        _isInternetAvailable = false;
        getStateListFromLocalDB();
      } else if ((_connectivityResult == ConnectivityResult.mobile) || (_connectivityResult == ConnectivityResult.wifi)) {
        _isInternetAvailable = true;
        getStateListFromLocalDB();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void setCustomerFormStates() {
    firstNameFocus.addListener((){
      if(customerState != null) {
        customerState(() {
          isFirstNameFocus = firstNameFocus.hasFocus;
        });
      }
    });
    lastNameFocus.addListener((){
      if(customerState != null) {
        customerState(() {
          isLastNameFocus = lastNameFocus.hasFocus;
        });
      }
    });
    email1Focus.addListener((){
      if(customerState != null) {
        customerState(() {
          isEmail1Focus = email1Focus.hasFocus;
        });
      }
    });
    phone1Focus.addListener((){
      if(customerState != null) {
        customerState(() {
          isPhone1Focus = phone1Focus.hasFocus;
        });
      }
    });
  }

  void setLocationFormStates() {
    _locationNameFocus.addListener(() {
      if(locationState != null){
        locationState((){
          setState(() {
            isNickNameFocus = _locationNameFocus.hasFocus;
          });
        });
      }
    });

    _streetFocus.addListener(() {
      if(locationState != null){
        locationState((){
          setState(() {
            isStreetFocus = _streetFocus.hasFocus;
          });
        });
      }
    });

    _cityFocus.addListener(() {
      if(locationState != null){
        locationState((){
          setState(() {
            isCityFocus = _cityFocus.hasFocus;
          });
        });
      }
    });

    _zipCodeFocus.addListener(() {
      if(locationState != null){
        locationState((){
          setState(() {
            isZipCodeFocus = _zipCodeFocus.hasFocus;
          });
        });
      }
    });

    _apartmentFocus.addListener(() {
      if(locationState != null){
        locationState((){
          setState(() {
            isApartmentFocus = _apartmentFocus.hasFocus;
          });
        });
      }
    });
  }

  void setLocationEditFormStates() {
    _editLocationNameFocus.addListener(() {
      if(locationEditState != null){
        locationEditState((){
          setState(() {
            isEditNickNameFocus = _editLocationNameFocus.hasFocus;
          });
        });
      }
    });

    _editStreetFocus.addListener(() {
      if(locationEditState != null){
        locationEditState((){
          setState(() {
            isEditStreetFocus = _editStreetFocus.hasFocus;
          });
        });
      }
    });

    _editCityFocus.addListener(() {
      if(locationEditState != null){
        locationEditState((){
          setState(() {
            isEditCityFocus = _editCityFocus.hasFocus;
          });
        });
      }
    });

    _editZipCodeFocus.addListener(() {
      if(locationEditState != null){
        locationEditState((){
          setState(() {
            isEditZipCodeFocus = _editZipCodeFocus.hasFocus;
          });
        });
      }
    });

    _editApartmentFocus.addListener(() {
      if(locationEditState != null){
        locationEditState((){
          setState(() {
            isEditApartmentFocus = _editApartmentFocus.hasFocus;
          });
        });
      }
    });
  }

  ImagePicker _imagePicker = ImagePicker();
  Future getImageFromCamera(type, [state]) async {
    var image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      openCropImageOption(image.path, type, state);
    }
  }

  Future getImageFromGallery(type, [state]) async {
    var image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      openCropImageOption(image.path, type, state);
    }
    // var image = await _imagePicker.pickImage(source: ImageSource.gallery);
    // if (image != null) {
    //   File compressedFile = await HelperClass.getCompressedImageFile(File(image.path));
    //
    //   setState(() {
    //     uploadLocationImage(compressedFile.path);
    //   });
    // }
  }

  void openCropImageOption(imagePath1, type, state) async {
    // ImageCropper imageCropper = ImageCropper();
    // File croppedFile = await imageCropper.cropImage(sourcePath: sourcePath)
    File croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath1,
        aspectRatioPresets: [
          CropAspectRatioPreset.square
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: lang == 'en' ? imageCropperEn : imageCropperEs,
            toolbarColor: isDarkMode ? Colors.black : AppColor.THEME_PRIMARY,
            toolbarWidgetColor: Colors.white,
            cropFrameColor: isDarkMode ? Colors.white : AppColor.BLACK_COLOR,
            cropFrameStrokeWidth: 2,
            hideBottomControls: true,
            statusBarColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.square,
            cropGridColor: isDarkMode ? Colors.black : AppColor.THEME_PRIMARY,
            backgroundColor: isDarkMode ? Colors.black : AppColor.PAGE_COLOR,
            showCropGrid: true,
            activeControlsWidgetColor: AppColor.THEME_PRIMARY,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        )
    );

    if(croppedFile != null) {
      File compressedFile = await HelperClass.getCompressedImageFile(croppedFile);

      if(type == "auto") {
        setState(() {
          if(_isInternetAvailable) {
            isLocalImage = false;
            uploadLocationImage(compressedFile.path, myState: state);
          } else {
            imagePath = compressedFile.path;

            uploadImageDataIntoLocalDb(compressedFile.path, myState: state);
          }
        });
      } else {
        setState(() {
          if(state != null) {
            state(() {
              imagePath = compressedFile.path;
            });
          } else {
            imagePath = compressedFile.path;
          }
        });
      }
    }
  }

  void getLocation(myState) async {
    print("Current Position====");
    // _progressHUD.state.show();
    _currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    print("Current Position====$_currentPosition");
    getAddress(myState);
  }

  void getAddress(myState) async {
    FocusScope.of(context).requestFocus(FocusNode());
    var response = await request.getLocationRequest(
        "https://api.mapbox.com/geocoding/v5/mapbox.places/${_currentPosition.longitude},${_currentPosition.latitude}.json?access_token=${Token.MAP_ID}"
    );

    isLocationLoaded = false;

    log("Response===$response");
    if(response != null){
      setState(() {
        var place = response['features'][0];
        print("PlaceDetail===$place");
        locationName = "${place['place_name']}";

        latitude = _currentPosition.latitude;
        longitude = _currentPosition.longitude;

        var streetArr = [];
        var street = "";
        var code = "";
        var zipCode = "";
        var apartment = "";

        if(place['properties'] != null) {
          if (place['properties'].containsKey('short_code')) {
            code = place['properties']['short_code'];
          }
        }

        for(int i=0; i<place['context'].length; i++) {
          if(place['context'][i]['id'].contains("postcode")){
            zipCode = place['context'][i]['text'];
          }
          if(place['context'][i]['id'].contains("place")) {
            cityName = place['context'][i]['text'];
          }
          if(place['context'][i]['id'].contains("region")) {
            code = place['context'][i]['short_code'];
          }
          if(place['context'][i]['id'].contains("district")) {
            apartment = place['context'][i]['text'];
          }
        }

        if(place.containsKey('address')) {
          streetArr.add(place['address']);
        }
        if(place.containsKey('text')) {
          streetArr.add(place['text']);
        }
        street = streetArr.join(' ');
        print("StreetAddress===$street");

        var codeSplit = code != null ? code.toString().split("-") : null;
        if (codeSplit != null && codeSplit.length > 1) {
          print("code====${codeSplit[0]}, ${codeSplit[1]}");
          countryCode = codeSplit[0] ?? "";
          stateCode = codeSplit[1] ?? "";
        }

        myState((){
          _allFieldValidate = true;
          _streetController.text = street;
          // _locationNameController.text = locationName;
          _cityController.text = cityName??"";
          _zipCodeController.text = zipCode;
          // _apartmentController.text = apartment;
        });
        serviceAddressName = street;

        // createClientServiceLocation();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode ? AppColor.BLACK_COLOR : AppColor.PAGE_COLOR,
     appBar: EmptyAppBar(isDarkMode: isDarkMode),
     /* appBar: AppBar(
        centerTitle: true,
        elevation: elevation,
        backgroundColor: AppColor.PAGE_COLOR,
        leading: GestureDetector(
          onTap: (){
            _scaffoldKey.currentState.openDrawer();
          },
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Image.asset(
              'assets/ic_menu.png',
              fit: BoxFit.cover,
              height: 28.0,
              width: 28.0,
            ),
          ),
        ),
      ),*/
      drawer: Drawer(
        child: DrawerPage(),
      ),
      body: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: GestureDetector(
                    onTap: () async {
                      _scaffoldKey.currentState.openDrawer();
                    },
                    child: Container(
                      child: Image.asset(
                        'assets/ic_menu.png',
                        fit: BoxFit.cover,
                        width: 44,
                        height: 44,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: 10.0,),
                          Text(
                            lang == 'en' ? serviceAddressSectionEn : serviceAddressSectionEs,
                            style: TextStyle(
                              color: themeColor,
                              fontSize: TextSize.subjectTitle,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 0.0,vertical: 8.0),
                            child: Text(
                              blockDetail != null && blockDetail['title'] != null
                                  ? '${blockDetail['title']}'
                                  : 'Location, location, location',
                              style: TextStyle(
                                  fontSize: TextSize.pageTitleText,
                                  color: themeColor,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.normal,),
                            ),
                          ),

                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 0.0,vertical: 8.0),
                            child: Text(
                              blockDetail != null && blockDetail['helpertext'] != null
                                  ? '${blockDetail['helpertext']}'
                                  : 'Select an existing customer service address or create a new one',
                              style: TextStyle(
                                  fontSize: TextSize.headerText,
                                  color: themeColor,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.normal,
                                  height: 1.3,),
                            ),
                          ),

                          SizedBox(height: 24.0,),

                        /*  customerData != null
                          ? GestureDetector(
                            onTap: (){
                              openEditCustomerBottomSheet(context);
                            },
                            child: Container(
                              padding: EdgeInsets.only(left: 16.0,right: 16, top: 16, bottom: 16),
                              margin: EdgeInsets.only(bottom: 8.0),
                              decoration: BoxDecoration(
                                color: AppColor.TYPE_PRIMARY.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(32.0),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          colors: [
                                            Color(0xff013399),
                                            Color(0xffBC96E6),
                                          ]
                                      ),
                                      borderRadius: BorderRadius.circular(32.0),
                                    ),
                                    height: 48.0,
                                    width: 48.0,
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${customerData['firstname'][0]}',
                                      style: TextStyle(
                                          color: AppColor.WHITE_COLOR,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 24.0
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin: EdgeInsets.only(left: 16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            '${customerData['firstname'] ?? ''} ${customerData['lastname'] ?? ''}',
                                            style: TextStyle(
                                                color: themeColor,
                                                fontWeight: FontWeight.w700,
                                                fontSize: TextSize.headerText
                                            ),
                                          ),
                                          SizedBox(height: 4.0,),
                                          Text(
                                            customerData['email'] == null
                                                ? '---'
                                                : customerData['email'].length > 0
                                                ? '${customerData['email'][0]['email']}'
                                                : '---',
                                            style: TextStyle(
                                                color: themeColor,
                                                fontWeight: FontWeight.w500,
                                                fontSize: TextSize.subjectTitle
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 8.0),
                                    height: 48.0,
                                    width: 48.0,
                                    decoration: BoxDecoration(
                                        color: Color(0xffDCFFF3),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColor.TRANSPARENT,
                                          width: 1.0,
                                        )
                                    ),
                                    child: Icon(
                                      Icons.done,
                                      size: 24.0,
                                      color: Color(0xff008B4A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          : Container(),*/

                          isLocationFound || isEditLocationFound
                          ? getLocationDataWidget(context)
                          : Container(
                            margin: EdgeInsets.only(top: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                //Add Location
                                /*GestureDetector(
                                  onTap: (){
                                    getLocation();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                                    margin: EdgeInsets.only(bottom: 0.0),
                                    decoration: BoxDecoration(
                                        color: AppColor.WHITE_COLOR,
                                        borderRadius: BorderRadius.circular(16)
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(12.0),
                                          decoration: BoxDecoration(
                                              color: AppColor.BACKGROUND_COLOR.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(24)
                                          ),
                                          child: Image.asset(
                                            'assets/ic_location.png',
                                            width: 24.0,
                                            height: 24.0,
                                            color: AppColor.THEME_PRIMARY,
                                          ),
                                        ),
                                        SizedBox(width: 16.0,),
                                        Text(
                                          'Use current location',
                                          style: TextStyle(
                                              color: AppColor.TYPE_PRIMARY,
                                              fontSize: TextSize.headerText,
                                              fontWeight: FontWeight.w600,

                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),*/

                                /*//Search Address
                                GestureDetector(
                                  onTap: (){
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => InspectionLocationSearchPage()
                                        )
                                    ).then((result){
                                      if(result != null){
                                        if(result['place'] != null) {
                                          setState(() {
                                            MapBoxPlace place = result['place'];
                                            locationName = "${place.placeName}";
                                            latitude = place.geometry.coordinates[1];
                                            longitude = place.geometry.coordinates[0];
                                            var code;
                                            if(place.context.length > 1){
                                              code = place.context[place.context.length-2].shortCode;
                                            } else if(place.properties != null){
                                              if(place.properties.shortCode != null){
                                                code = place.properties.shortCode;
                                              }
                                            }
                                            var codeSplit = code != null ? code.toString().split("-") : null;
                                            if(codeSplit != null && codeSplit.length > 1){
                                              print("code====${codeSplit[0]}, ${codeSplit[1]}");
                                              countryCode = codeSplit[0];
                                              stateCode = codeSplit[1];
                                            }

                                            cityName = place.text;
                                            print("CityName===$cityName");
                                            isLocationFound = true;

                                            createClientServiceLocation();
                                          });
                                        }
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                                    margin: EdgeInsets.only(top: 8.0, bottom: 16.0),
                                    decoration: BoxDecoration(
                                        color: AppColor.WHITE_COLOR,
                                        borderRadius: BorderRadius.circular(16)
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(12.0),
                                          decoration: BoxDecoration(
                                              color: AppColor.BACKGROUND_COLOR.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(24)
                                          ),
                                          child: Image.asset(
                                            'assets/ic_search.png',
                                            width: 24.0,
                                            height: 24.0,
                                            color: AppColor.THEME_PRIMARY,
                                          ),
                                        ),
                                        SizedBox(width: 16.0,),
                                        Expanded(
                                          child: Text(
                                            'Search address',
                                            style: TextStyle(
                                                color: AppColor.TYPE_PRIMARY,
                                                fontSize: TextSize.headerText,
                                                fontWeight: FontWeight.w600,

                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 16.0,),
                                        Icon(Icons.keyboard_arrow_right, size: 24.0, color: AppColor.TYPE_PRIMARY.withOpacity(0.6),)
                                      ],
                                    ),
                                  ),
                                ),*/
                                
                                Container(
                                  child: ListView.builder(
                                    itemCount: serviceList != null ? serviceList.length : 0,
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      // log("ServiceAddress====${serviceList[index]['image']}");
                                      // log("ServiceAddressType====${serviceList[index]['image'].runtimeType}");
                                      imagePathData = serviceList[index]['image'] ?? null;
                                      var imageData = imagePathData != null
                                          ? json.decode(json.encode(imagePathData))
                                          : "";
                                      var imagePath = imageData != ""
                                          ? "${GlobalInstance.apiBaseUrl}${imageData['path']}"
                                          : "";
                                      var imageId = imageData != ""
                                          ? "${imageData['imageid']}"
                                          : "";

                                      // log("ImagePath====$imagePath");
                                      return GestureDetector(
                                        onTap: () async {
                                          setState(() {
                                            log("SelectedService====${serviceList[index]}");
                                            isLocationFound = true;
                                            isPhotoTaken = imagePath != "";
                                            
                                            locationName = "${serviceList[index]['serviceaddressnick']}";//latitude //longitude
                                            serviceAddressName = "${serviceList[index]['street1']}";//latitude //longitude
                                            latitude = serviceList[index]['latitude'] ?? 0.0;
                                            longitude = serviceList[index]['longitude'] ?? 0.0;

                                            countryCode = "${serviceList[index]['countrycode']}";
                                            stateCode = "${serviceList[index]['statecode']}";
                                            zipCode = "${serviceList[index]['zip']}";

                                            cityName = "${serviceList[index]['city']}";
                                            print("CityName===$cityName");
                                            isLocationFound = true;
                                            existingImage = imagePath;
                                            selectedIndex = index;

                                            stateData = {
                                              "label": serviceList[index]['statename'],
                                              "abbr": serviceList[index]['statecode']
                                            };
                                            PreferenceHelper.setPreferenceData(PreferenceHelper.CLIENT_ID, clientId);
                                            PreferenceHelper.setPreferenceData(PreferenceHelper.LOCATION_ID, "${serviceList[index]['addressid']}");

                                            if(imageId != ""){
                                              PreferenceHelper.setPreferenceData(PreferenceHelper.LOCATION_IMAGE, existingImage);
                                              PreferenceHelper.setPreferenceData(PreferenceHelper.LOCATION_IMAGE_ID, imageId);
                                            }
                                          });

                                          var requestJson = {
                                            "street1":"$serviceAddressName",
                                            "city":"$cityName",
                                            "statecode": stateCode == null ? "" : stateCode == "" ? "" : stateCode,
                                            "countrycode": countryCode == "" ? "US" : countryCode,
                                            "zip":"$zipCode",
                                            "serviceaddressnick":"$serviceAddressName",
                                          };

                                          var requestParam = json.encode(requestJson);

                                          var endPoint = "auth/myclient/{{clientid}}/servicelocation";

                                          await dbHelper.insertServiceGeneralData({
                                            "url": endPoint,
                                            "verb": "POST",
                                            "payload": requestParam,
                                            "inspectiondefid": inspectionDefIdLocal,
                                            "isserviceserverid": "1",
                                            "servicelocalid": "${serviceList[index]['addressid']}",
                                            "serviceserverid": "${serviceList[index]['addressid']}",
                                            "customerlocalid": clientId,
                                            "customerserverid": clientId,
                                          });

                                          PreferenceHelper.setPreferenceData(PreferenceHelper.CLIENT_ID, clientId);
                                          PreferenceHelper.setPreferenceData(PreferenceHelper.LOCATION_ID, "${serviceList[index]['addressid']}");

                                          log("ClientId====$clientId&&AddressId===$serviceList[index]['addressid']");

                                          await dbHelper.getCustomerGeneralData();
                                          await dbHelper.getServiceGeneralData();
                                        },
                                        child: Container(
                                            margin: EdgeInsets.only(bottom: 8.0),
                                            padding: EdgeInsets.all(16.0,),
                                            decoration: BoxDecoration(
                                              color: isDarkMode
                                                  ? Color(0xff1f1f1f)
                                                  : AppColor.TYPE_PRIMARY.withOpacity(0.04),
                                              borderRadius: BorderRadius.circular(32.0),
                                            ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              imagePath != ""
                                                  ? Stack(
                                                    children: [
                                                      ConstrainedBox(
                                                constraints: BoxConstraints(
                                                        maxHeight: 175.0
                                                ),
                                                child: Container(
                                                        width: MediaQuery.of(context).size.width,
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(16.0),
                                                        ),
                                                        child: Stack(
                                                          children: [
                                                            _isInternetAvailable
                                                            ? Container(
                                                              width: MediaQuery.of(context).size.width,
                                                              child: ClipRRect(
                                                                borderRadius: BorderRadius.circular(16.0),
                                                                child: Container(
                                                                  height: 300,
                                                                  color: AppColor.WHITE_COLOR,
                                                                  child: Image.network(
                                                                    "$imagePath",
                                                                    height: 300,
                                                                    fit: BoxFit.cover,
                                                                    loadingBuilder: (context, child, loadingProgress){
                                                                      if(loadingProgress == null) {
                                                                        return child;
                                                                      } else {
                                                                        return Container(
                                                                          height: 300,
                                                                          color: AppColor.WHITE_COLOR,
                                                                          child: Center(
                                                                            child: CircularProgressIndicator(
                                                                              value: loadingProgress.expectedTotalBytes != null ?
                                                                              loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                                                                  : null,
                                                                            ),
                                                                          ),
                                                                        );
                                                                      }
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                            : Container(
                                                              width: MediaQuery.of(context).size.width,
                                                              child: ClipRRect(
                                                                borderRadius: BorderRadius.circular(16.0),
                                                                child: Container(
                                                                  height: 300,
                                                                  color: AppColor.WHITE_COLOR,
                                                                  child: Image.asset(
                                                                    'assets/section_fallback_image.png',
                                                                    height: 300,
                                                                    fit: BoxFit.cover,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                ),
                                              ),
                                                    ],
                                                  )
                                                  : Container(),

                                              Container(
                                                margin: EdgeInsets.only(top: 16),
                                                child: Text(
                                                  '${serviceList[index]['serviceaddressnick']}',
                                                  style: TextStyle(
                                                      fontSize: TextSize.planeHeaderText,
                                                      color: themeColor,
                                                      fontWeight: FontWeight.w700,),
                                                  textAlign: TextAlign.left,
                                                ),
                                              ),

                                              Container(
                                                margin: EdgeInsets.only(top: 8),
                                                child: Text(
                                                  '${serviceList[index]['street1']}',
                                                  style: TextStyle(
                                                      fontSize: TextSize.bodyText,
                                                      color: themeColor,
                                                      fontWeight: FontWeight.w600,
                                                    height: 1.5
                                                  ),
                                                  textAlign: TextAlign.left,
                                                ),
                                              ),

                                            ],
                                          ),
                                        ),
                                        // child: Container(
                                        //   margin: EdgeInsets.only(bottom: 8.0),
                                        //   padding: EdgeInsets.only(bottom: 16.0),
                                        //   decoration: BoxDecoration(
                                        //     color: AppColor.INSPECTION_ICON,
                                        //     borderRadius: BorderRadius.circular(32.0),
                                        //   ),
                                        //   child: Column(
                                        //     crossAxisAlignment: CrossAxisAlignment.start,
                                        //     mainAxisAlignment: MainAxisAlignment.start,
                                        //     children: [
                                        //       Container(
                                        //         padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                                        //         child: Row(
                                        //           crossAxisAlignment: CrossAxisAlignment.center,
                                        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        //           children: [
                                        //             Expanded(
                                        //               child: GestureDetector(
                                        //                 onTap: () {
                                        //                   setState(() {
                                        //                     log("SelectedService====${serviceList[index]}");
                                        //                     isLocationFound = true;
                                        //                     isPhotoTaken = imagePath != "";
                                        //                     locationName = "${serviceList[index]['street1']}";//latitude //longitude
                                        //                     latitude = serviceList[index]['latitude'] ?? 0.0;
                                        //                     longitude = serviceList[index]['longitude'] ?? 0.0;
                                        //
                                        //                     countryCode = "${serviceList[index]['countrycode']}";
                                        //                     stateCode = "${serviceList[index]['statecode']}";
                                        //                     zipCode = "${serviceList[index]['zip']}";
                                        //
                                        //                     cityName = "${serviceList[index]['city']}";
                                        //                     print("CityName===$cityName");
                                        //                     isLocationFound = true;
                                        //                     existingImage = imagePath;
                                        //                     selectedIndex = index;
                                        //
                                        //                     stateData = {
                                        //                       "label": serviceList[index]['statename'],
                                        //                       "abbr": serviceList[index]['statecode']
                                        //                     };
                                        //                     PreferenceHelper.setPreferenceData(PreferenceHelper.CLIENT_ID, clientId);
                                        //                     PreferenceHelper.setPreferenceData(PreferenceHelper.LOCATION_ID, "${serviceList[index]['addressid']}");
                                        //
                                        //                     if(imageId != ""){
                                        //                       PreferenceHelper.setPreferenceData(PreferenceHelper.LOCATION_IMAGE, existingImage);
                                        //                       PreferenceHelper.setPreferenceData(PreferenceHelper.LOCATION_IMAGE_ID, imageId);
                                        //                     }
                                        //                   });
                                        //                 },
                                        //                 child: Container(
                                        //                   child: Text(
                                        //                     '${serviceList[index]['street1']}, '
                                        //                         '${serviceList[index]['city']}',
                                        //                     style: TextStyle(
                                        //                         fontSize: TextSize.headerText,
                                        //                         color: AppColor.WHITE_COLOR,
                                        //                         fontWeight: FontWeight.w700,
                                        //                         fontStyle: FontStyle.normal,
                                        //                         fontFamily: "WorkSans"),
                                        //                     textAlign: TextAlign.left,
                                        //                   ),
                                        //                 ),
                                        //               ),
                                        //             ),
                                        //
                                        //             GestureDetector(
                                        //               onTap: (){
                                        //                 setState(() {
                                        //
                                        //                 });
                                        //               },
                                        //               child: Container(
                                        //                 margin: EdgeInsets.only(left: 8.0),
                                        //                 decoration: BoxDecoration(
                                        //                     color: AppColor.WHITE_COLOR,
                                        //                     borderRadius: BorderRadius.all(Radius.circular(32.0))
                                        //                 ),
                                        //                 padding: EdgeInsets.all(12.0),
                                        //                 child: Image.asset(
                                        //                   'assets/ic_add.png',
                                        //                   fit: BoxFit.cover,
                                        //                   height: 24.0,
                                        //                   width: 24.0,
                                        //                 ),
                                        //               ),
                                        //             ),
                                        //           ],
                                        //         ),
                                        //       ),
                                        //
                                        //       Container(
                                        //         width: MediaQuery.of(context).size.width,
                                        //         margin: EdgeInsets.symmetric(horizontal: 8.0),
                                        //         padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
                                        //         decoration: BoxDecoration(
                                        //           color: AppColor.WHITE_COLOR,
                                        //           borderRadius: BorderRadius.circular(16.0),
                                        //         ),
                                        //         child: Column(
                                        //           crossAxisAlignment: CrossAxisAlignment.start,
                                        //           mainAxisAlignment: MainAxisAlignment.start,
                                        //           children: [
                                        //             imagePath != ""
                                        //               ? ConstrainedBox(
                                        //               constraints: BoxConstraints(
                                        //                   maxHeight: 280.0
                                        //               ),
                                        //               child: Container(
                                        //                   width: MediaQuery.of(context).size.width,
                                        //                   decoration: BoxDecoration(
                                        //                     borderRadius: BorderRadius.circular(16.0),
                                        //                   ),
                                        //                   child: Stack(
                                        //                     children: [
                                        //                       Container(
                                        //                         width: MediaQuery.of(context).size.width,
                                        //                         child: ClipRRect(
                                        //                           borderRadius: BorderRadius.circular(16.0),
                                        //                           child: /*CachedNetworkImage(
                                        //                             // "${GlobalInstance.apiBaseUrl}$bgImage",
                                        //                             imageUrl: "$imagePath",
                                        //                             imageBuilder: (context, imageProvider) => Container(
                                        //                               decoration: BoxDecoration(
                                        //                                 image: DecorationImage(
                                        //                                     image: imageProvider,
                                        //                                     fit: BoxFit.cover,
                                        //                                 ),
                                        //                               ),
                                        //                             ),
                                        //                             progressIndicatorBuilder: (context, url, downloadProgress) =>
                                        //                                 CircularProgressIndicator(value: downloadProgress.progress),
                                        //                             errorWidget: (context, url, error) => Icon(Icons.error),
                                        //                           ),*/
                                        //
                                        //                           Container(
                                        //                             height: 300,
                                        //                             color: AppColor.WHITE_COLOR,
                                        //                             child: Image.network(
                                        //                               "$imagePath",
                                        //                               height: 300,
                                        //                               fit: BoxFit.cover,
                                        //                               loadingBuilder: (context, child, loadingProgress){
                                        //                                 if(loadingProgress == null) {
                                        //                                   return child;
                                        //                                 } else {
                                        //                                   return Container(
                                        //                                     height: 300,
                                        //                                     color: AppColor.WHITE_COLOR,
                                        //                                     child: Center(
                                        //                                       child: CircularProgressIndicator(
                                        //                                         value: loadingProgress.expectedTotalBytes != null ?
                                        //                                         loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                        //                                             : null,
                                        //                                       ),
                                        //                                     ),
                                        //                                   );
                                        //                                 }
                                        //                               },
                                        //                             ),
                                        //                           ),
                                        //                         ),
                                        //                       ),
                                        //                     ],
                                        //                   )
                                        //               ),
                                        //             )
                                        //             : Container(),
                                        //           ],
                                        //         ),
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),
                                      );
                                    },
                                  ),
                                ),

                                GestureDetector(
                                  onTap: () async {
                                    openAddNewAddressBottomSheet(context);
                                    // if(await HelperClass.internetConnectivity()) {
                                    //   openAddNewAddressBottomSheet(context);
                                    // } else {
                                    //   HelperClass.openSnackBar(context);
                                    // }
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(top: 0.0, bottom: 16.0),
                                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                                    decoration: BoxDecoration(
                                      // color: AppColor.THEME_PRIMARY.withOpacity(0.08),
                                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                                        gradient: LinearGradient(
                                            colors: AppColor.gradientColor(0.16)
                                        )
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[

                                        Expanded(
                                          child: GradientText(
                                            lang == 'en' ? newServiceAddressEn : newServiceAddressEs,
                                            style: TextStyle(
                                              color: AppColor.TYPE_PRIMARY,
                                              fontSize: TextSize.headerText,
                                              fontStyle: FontStyle.normal,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            gradient: LinearGradient(
                                                colors: AppColor.gradientColor(1.0)
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 16.0,),
                                        Container(
                                          child: Image.asset(
                                            'assets/new_ui/ic_add_address.png',
                                            fit: BoxFit.contain,
                                            height: 48.0,
                                            width: 48.0,
                                          ),
                                        ),

                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 160.0,),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Positioned(
              bottom: 0.0,
              right: 0.0,
              left: 0.0,
              child: BottomButtonWidget(
                onNextButton: () async {
                  if(isLocationFound  && (imagePath != "" || existingImage != "")) {
                    PreferenceHelper.setPreferenceData(PreferenceHelper.INSPECTION_SERVICE_LOCATION, "$locationName");
                    beginInspection();
                  }
                },
                onBackButton: () async {
                  int inspectionIndex = await InspectionPreferences.getInspectionId(InspectionPreferences.INSPECTION_INDEX);
                  InspectionUtils.decrementIndex(inspectionIndex);
                  Navigator.pop(context);
                },
                isActive: isLocationFound && (imagePath != "" || existingImage != ""),
              ),
            ),

            _progressHUD
          ],
        ),
      ),
    );
  }

  Widget getLocationDataWidget(context) {
    return GestureDetector(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 8.0),
            padding: EdgeInsets.all(16.0,),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Color(0xff333333)
                  : AppColor.TYPE_PRIMARY.withOpacity(0.04),
              borderRadius: BorderRadius.circular(32.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                isPhotoTaken
                    ? Container(
                      child: _isInternetAvailable && !isLocalImage
                      ? Stack(
                  children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight: 175.0
                        ),
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16.0),
                                    child: Container(
                                      height: 175,
                                      color: AppColor.WHITE_COLOR,
                                      child: Image.network(
                                        "$existingImage",
                                        height: 175,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress){
                                          if(loadingProgress == null) {
                                            return child;
                                          } else {
                                            return Container(
                                              height: 175,
                                              color: AppColor.WHITE_COLOR,
                                              child: Center(
                                                child: CircularProgressIndicator(
                                                  value: loadingProgress.expectedTotalBytes != null ?
                                                  loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                                      : null,
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          margin: EdgeInsets.only(left: 8.0),
                          height: 48.0,
                          width: 48.0,
                          decoration: BoxDecoration(
                              color: Color(0xffDCFFF3),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColor.TRANSPARENT,
                                width: 1.0,
                              )
                          ),
                          child: Icon(
                            Icons.done,
                            size: 24.0,
                            color: Color(0xff008B4A),
                          ),
                        ),
                      ),
                  ],
                )
                      : isLocalImage
                      ? Container(
                        width: MediaQuery.of(context).size.width,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Container(
                            height: 175,
                            color: AppColor.WHITE_COLOR,
                            child: Image.file(
                              File(imagePath),
                              height: 175,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      )
                      : Container(
                        width: MediaQuery.of(context).size.width,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Container(
                            height: 175,
                            color: AppColor.WHITE_COLOR,
                            child: Image.asset(
                              'assets/section_fallback_image.png',
                              height: 175,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(
                  margin: EdgeInsets.symmetric(vertical: 24.0),
                  padding: EdgeInsets.symmetric(horizontal: 3.0),
                  child: DottedBorder(
                      color: Color(0xFF000000),
                      radius: Radius.circular(24.0),
                      borderType: BorderType.RRect,
                      strokeWidth: 3.0,
                      strokeCap: StrokeCap.square,
                      dashPattern: [5,8],
                      child: Container(
                        height: 180.0,
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.all(0.0),
                        decoration: BoxDecoration(
                            color: isDarkMode
                                ? Color(0xff1f1f1f)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(24.0)
                        ),
                        child: GestureDetector(
                          onTap: () {
                            bottomNavigation(context, "auto",  null);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                child: Image.asset(
                                  'assets/welcome/ic_camera_profile.png',
                                  width: 56.0,
                                  height: 56.0,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              SizedBox(height: 8.0,),
                              Text(
                                lang == 'en' ? takeAPictureEn : takeAPictureEs,
                                style:  TextStyle(
                                    color: themeColor,
                                    fontSize: TextSize.subjectTitle,
                                    fontWeight: FontWeight.w700,
                                    height: 1.3
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                  ),
                ),

                locationName == null
                ? Container(
                  margin: EdgeInsets.only(top: 16),
                  child: Text(
                    '$locationName',
                    style: TextStyle(
                      fontSize: TextSize.planeHeaderText,
                      color: themeColor,
                      fontWeight: FontWeight.w700,),
                    textAlign: TextAlign.left,
                  ),
                )
                : Container(),

                Container(
                  margin: EdgeInsets.only(top: 8),
                  child: Text(
                    '$serviceAddressName',
                    style: TextStyle(
                        fontSize: TextSize.bodyText,
                        color: themeColor,
                        fontWeight: FontWeight.w600,
                        height: 1.5
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),

              ],
            ),
          ),

          Container(
            margin: EdgeInsets.only(top: 0, bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center ,
              children: [
                GestureDetector(
                  onTap: (){
                    openEditAddressBottomSheet(context);
                  },
                  child: Container(
                    width: 132,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Color(0xff333333)
                          : AppColor.TYPE_PRIMARY.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      lang == "en" ? 'Edit' : "Editar",
                      style: TextStyle(
                          color: themeColor,
                          fontWeight: FontWeight.w700,
                          fontSize: TextSize.subjectTitle
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 8,),
                GestureDetector(
                  onTap: (){
                    setState(() {
                      isLocationFound = false;
                      isEditLocationFound = false;
                      serviceAddressName = "";
                      locationName = "";
                      existingImage = "";
                      imagePath = "";
                      isPhotoTaken = false;
                    });
                  },
                  child: Container(
                    width: 132,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Color(0xff333333)
                          : AppColor.TYPE_PRIMARY.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                    child: Text(
                      lang == "en" ? 'Change' : "Cambio",
                      style: TextStyle(
                          color: themeColor,
                          fontWeight: FontWeight.w700,
                          fontSize: TextSize.subjectTitle
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget getLocationWidget(){
    return GestureDetector(
      onTap: () async {
        openEditAddressBottomSheet(context);
      },
      child: Container(
        padding: EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: AppColor.INSPECTION_ICON,
          borderRadius: BorderRadius.circular(32.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '$locationName',
                        style: TextStyle(
                            fontSize: TextSize.headerText,
                            color: AppColor.WHITE_COLOR,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal),
                        textAlign: TextAlign.left,
                      ),
                    ),

                    GestureDetector(
                      onTap: (){
                        setState(() {
                          displayDeleteLocationDialog(context, "Are you sure? You're delete to service location");
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: AppColor.WHITE_COLOR,
                            borderRadius: BorderRadius.all(Radius.circular(32.0))
                        ),
                        padding: EdgeInsets.all(12.0),
                        child: Image.asset(
                          'assets/ic_close.png',
                          fit: BoxFit.cover,
                          height: 24.0,
                          width: 24.0,
                        ),
                      ),
                    ),
                  ],
                )
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
              decoration: BoxDecoration(
                color: AppColor.WHITE_COLOR,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  isPhotoTaken
                  ? ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.width - 64,
                        maxWidth: MediaQuery.of(context).size.width
                    ),
                    child: GestureDetector(
                      onTap: (){
                        Navigator.push(
                            context,
                            SlideRightRoute(
                                page: ImageViewScreenPage(
                                  imageFile: imagePath,
                                  noteImagePath: noteImagePath,
                                )
                            )
                        ).then((result) async {
                          if(result != null){
//                          File compressedFile = await HelperClass.getCompressedImageFile(result);
                            setState(() {
//                            imagePath = compressedFile.path;
//                            image = compressedFile;
                              noteImagePath = result;
                            });
                          }
                        });
                      },
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Stack(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.width - 64,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16.0),
                                  child: imagePath != ""
                                  ? Image.file(
                                    File(imagePath),
                                    fit: BoxFit.cover,
                                  )
                                  : /*CachedNetworkImage(
                                      imageUrl: "$existingImage",
                                    imageBuilder: (context, imageProvider) => Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    progressIndicatorBuilder: (context, url, downloadProgress) =>
                                        CircularProgressIndicator(value: downloadProgress.progress),
                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                  )*/
                                  Image.network(
                                    "$existingImage",
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress){
                                      if(loadingProgress == null) {
                                        return child;
                                      } else {
                                        return Container(
                                          height: 300,
                                          color: AppColor.WHITE_COLOR,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null ?
                                              loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                                  : null,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 16.0,
                                right: 16.0,
                                child: GestureDetector(
                                  onTap: () async {
                                    displayDeleteLocationImageDialog(context, "Do you want to delete the location image?", null);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(40.0),
                                      color: AppColor.RED_COLOR,
                                    ),
                                    child: Image.asset(
                                      'assets/ic_delete.png',
                                      fit: BoxFit.contain,
                                      color: AppColor.WHITE_COLOR,
                                      height: 24.0,
                                      width: 24.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                      ),
                    ),
                  )
                  : Container(
                    child: DottedBorder(
                        radius: Radius.circular(16.0),
                        borderType: BorderType.RRect,
                        strokeWidth: 3.0,
                        color: AppColor.DIVIDER,
                        strokeCap: StrokeCap.square,
                        dashPattern: [7,6],
                        child: Container(
                          color: AppColor.WHITE_COLOR,
                          height: 70.0,
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 16.0),
                          child: GestureDetector(
                            onTap: (){
                              bottomNavigation(context, "auto", null);
                              // getImageFromCamera("auto");
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                      color: AppColor.BACKGROUND_COLOR.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(24)
                                  ),
                                  child: Image.asset(
                                    'assets/pool/ic_camera.png',
                                    width: 24.0,
                                    height: 24.0,
                                    fit: BoxFit.contain,
                                    color: AppColor.THEME_PRIMARY,
                                  ),
                                ),
                                SizedBox(width: 8.0,),
                                Text(
                                  lang == 'en' ? takeAPictureEn : takeAPictureEs,
                                  style:  TextStyle(
                                      color: AppColor.TYPE_PRIMARY,
                                      fontSize: TextSize.headerText,
                                      fontWeight: FontWeight.w600,
                                      height: 1.3
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void bottomNavigation(context, type, state){
    showModalBottomSheet(
        context: context,
        barrierColor: isDarkMode ? Color(0xff000000).withOpacity(0.8) : Color(0xff000000).withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        isDismissible: false,
        builder: (context){
          return StatefulBuilder(
            builder: (context1, myState){
              return SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                          getImageFromCamera(type, state);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(top: 24.0, bottom: 16.0),
                          child: Text(
                            lang == 'en' ? takeAPictureEn : takeAPictureEs,
                            style: TextStyle(
                                fontSize: TextSize.headerText,
                                color: themeColor,
                                fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Divider(height: 1, thickness: 1, color: isDarkMode ? AppColor.DIVIDER.withOpacity(0.4) : AppColor.DIVIDER,),
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                          getImageFromGallery(type, state);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                          child: Text(
                            'Choose from library',
                            style: TextStyle(
                                fontSize: TextSize.headerText,
                                color: themeColor,
                                fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Divider(height: 1, thickness: 1, color: isDarkMode ? AppColor.DIVIDER.withOpacity(0.4) : AppColor.DIVIDER,),
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                                fontSize: TextSize.headerText,
                                color: themeColor.withOpacity(0.8),
                                fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 12.0,
                      )
                    ],
                  ),
                ),
              );
            },
          );
        }
    );
  }

  ///////////////////////////API INTEGRATION////////////////////////
  Future<void> createClientServiceLocation([myState]) async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    if(locationName.length > 10){
      if(cityName == '')
        cityName = locationName.substring(10);
    }

    var newLocationName = '';
    if(locationName.length > 16){
      newLocationName = locationName.substring(0, 16);
    } else {
      newLocationName = locationName;
    }

    var requestJson = {
      "street1":"$newLocationName",
      "city":"$cityName",
      "statecode":"$stateCode",
      "countrycode":"$countryCode",
      "zip":"",
      "serviceaddressnick":"$cityName"
    };

    var requestParam = json.encode(requestJson);
    var response = await request.postRequest("auth/myclient/$clientId/servicelocation", requestParam);
    _progressHUD.state.dismiss();
    print("Service Location post response get back: $response");

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        HelperClass.showSnackBar(context, '${response['reason']}');
      } else {
        print("AddressId===${response['addressid']}");
        PreferenceHelper.setPreferenceData(PreferenceHelper.CLIENT_ID, clientId);
        PreferenceHelper.setPreferenceData(PreferenceHelper.LOCATION_ID, "${response['addressid']}");

        var addressId = await PreferenceHelper.getPreferenceData(PreferenceHelper.LOCATION_ID);
        print("AddressId===${response['addressid']}");
        print("AddressId===$addressId");
      }
    } else {
      HelperClass.showSnackBar(context, 'Something Went Wrong!');
    }
  }

  Future<void> createManualServiceLocation(serviceLocation, {myState}) async {
    if(myState != null)
      setCircularProgress(true, myState);
    else
      _progressHUD.state.show();

    FocusScope.of(context).requestFocus(FocusNode());

    var requestJson = {
      "street1":"${serviceLocation['streetName']}",
      "city":"${serviceLocation['cityName']}",
      "statecode": stateCode == null ? "" : stateCode == "" ? "" : stateCode,
      "countrycode": countryCode == "" ? "US" : countryCode,
      "zip":"${serviceLocation['zipCode']}",
      "serviceaddressnick":"${serviceLocation['streetName']}",
    };

    var requestParam = json.encode(requestJson);
    var response = await request.postRequest("auth/myclient/$clientId/servicelocation", requestParam);

    if(myState != null)
      setCircularProgress(false, myState);
    else
      _progressHUD.state.dismiss();

    print("Service Location post response get back: $response");

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage("${response['reason']}");
      } else {
        print("AddressId===${response['addressid']}");
        PreferenceHelper.setPreferenceData(PreferenceHelper.CLIENT_ID, clientId);
        PreferenceHelper.setPreferenceData(PreferenceHelper.LOCATION_ID, "${response['addressid']}");

        var addressId = await PreferenceHelper.getPreferenceData(PreferenceHelper.LOCATION_ID);
        print("AddressId===${response['addressid']}");
        print("AddressId===$addressId");
        var imageResponse;
        // if(imagePath != "") {
        //   imageResponse = await uploadLocationImage(imagePath, myState: myState);
        // }
        setState(() {
          isLocationFound = true;
          locationName = "${serviceLocation['streetName']}";
          serviceAddressName = "${serviceLocation['streetName']}";

          countryCode = "US";

          cityName = serviceLocation['cityName'];
          print("CityName===$cityName");

          // if(imageResponse != null) {
          //   response['image'] = imageResponse;
          // }
          serviceList.insert(serviceList.length, response);

          log("ServiceList====>>>$serviceList");

          myState((){
            _streetController.text = "";
            _locationNameController.text = "";
            _apartmentController.text = "";
            _cityController.text = "";
            _zipCodeController.text = "";
          });
        });

        await dbHelper.insertServiceGeneralData({
          "url": "",
          "verb": "POST",
          "payload": requestParam,
          "inspectiondefid": inspectionDefIdLocal,
          "isserviceserverid": 1,
          "servicelocalid": "${response['addressid']}",
          "serviceserverid": "${response['addressid']}",
          "customerlocalid": clientId,
          "customerserverid": clientId,
        });

        Navigator.pop(context);
      }
    } else {
      CustomToast.showToastMessage("Something Went Wrong!");
    }
  }

  Future<void> insertServiceLocationDataIntoLocalDB(serviceLocation, {myState}) async {
    FocusScope.of(context).requestFocus(FocusNode());

    var requestJson = {
      "street1":"${serviceLocation['streetName']}",
      "city":"${serviceLocation['cityName']}",
      "statecode": stateCode == null ? "" : stateCode == "" ? "" : stateCode,
      "countrycode": countryCode == "" ? "US" : countryCode,
      "zip":"${serviceLocation['zipCode']}",
      "serviceaddressnick":"${serviceLocation['streetName']}",
    };

    var requestParam = json.encode(requestJson);

    var endPoint = "auth/myclient/{{clientid}}/servicelocation";

    var response = await dbHelper.insertServiceGeneralData({
      "url": endPoint,
      "verb": "POST",
      "payload": requestParam,
      "inspectiondefid": inspectionDefIdLocal,
      "isserviceserverid": 0,
      "servicelocalid": 0,
      "serviceserverid": 0,
      "customerlocalid": clientId,
      "customerserverid": clientId,
    });
    print("Service Location post response get back: $response");

    if (response != null) {
      PreferenceHelper.setPreferenceData(PreferenceHelper.CLIENT_ID, clientId);
      PreferenceHelper.setPreferenceData(PreferenceHelper.LOCATION_ID, "$response");

      var addressId = response;
      print("AddressId===$addressId");
      var imageResponse;
      if(imagePath != "") {
        uploadImageDataIntoLocalDb(imagePath, myState: myState);
        // if(_isInternetAvailable) {
        //   imageResponse = await uploadLocationImage(imagePath, myState: myState);
        // } else {
        //
        // }
      }
      setState(() {
        isLocationFound = true;
        locationName = "${serviceLocation['streetName']}";
        serviceAddressName = "${serviceLocation['streetName']}";

        countryCode = "US";

        cityName = serviceLocation['cityName'];
        print("CityName===$cityName");

        // if(imageResponse != null) {
        //   response['image'] = imageResponse;
        // }
        // serviceList.insert(serviceList.length, response);

        log("ServiceList====>>>$serviceList");

        myState((){
          _streetController.text = "";
          _locationNameController.text = "";
          _apartmentController.text = "";
          _cityController.text = "";
          _zipCodeController.text = "";
        });
      });
      Navigator.pop(context);
    } else {
      CustomToast.showToastMessage("Something Went Wrong!");
    }
  }

  Future<void> updateManualServiceLocation(serviceLocation, {myState}) async {
    if(myState != null)
      setEditCircularProgress(true, myState);
    else
      _progressHUD.state.show();

    FocusScope.of(context).requestFocus(FocusNode());
    var addressId = await PreferenceHelper.getPreferenceData(PreferenceHelper.LOCATION_ID) ?? "";

    var requestJson = {
      "street1":"${serviceLocation['streetName']}",
      "city":"${serviceLocation['cityName']}",
      "statecode": stateCode == null ? "" : stateCode == "" ? "" : stateCode,
      "countrycode": countryCode == "" ? "US" : countryCode,
      "zip":"${serviceLocation['zipCode']}",
      "serviceaddressnick":"${serviceLocation['streetName']}",
    };

    log("RequestParameter====$requestJson");

    var requestParam = json.encode(requestJson);
    var response = await request.patchRequest("auth/myclient/$clientId/servicelocation/$addressId", requestParam);

    if(myState != null)
      setEditCircularProgress(false, myState);
    else
      _progressHUD.state.dismiss();

    print("Service Location post response get back: $response");

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage("${response['reason']}");
      } else {
        print("AddressId===${response['addressid']}");
        PreferenceHelper.setPreferenceData(PreferenceHelper.CLIENT_ID, clientId);
        PreferenceHelper.setPreferenceData(PreferenceHelper.LOCATION_ID, "${response['addressid']}");

        serviceList.removeWhere((element) => "${element['addressid']}" == "$addressId");

        // var addressId1 = await PreferenceHelper.getPreferenceData(PreferenceHelper.LOCATION_ID);
        // print("AddressId===${response['addressid']}");
        // print("AddressId===$addressId1");
        var imageResponse;
        if(imagePath != "") {
          imageResponse = await uploadLocationImage(imagePath, myState: myState);
        }
        setState(() {
          isEditLocationFound = true;
          isLocationFound = true;
          locationName = "${serviceLocation['streetName']}";
          serviceAddressName = "${serviceLocation['streetName']}";

          countryCode = "US";

          cityName = serviceLocation['cityName'];
          print("CityName===$cityName");

          if(imageResponse != null) {
            response['image'] = imageResponse;
          }

          serviceList.insert(serviceList.length, response);

          log("ServiceListUpdated====>>>$serviceList");

          myState((){
            _editStreetController.text = "";
            _editLocationNameController.text = "";
            _editApartmentController.text = "";
            _editCityController.text = "";
            _editZipCodeController.text = "";
          });
        });

        setState(() {
          isEditLocationFound = true;
          isPhotoTaken = existingImage != "" ? true : imagePath != "";
          locationName = "${serviceLocation['streetName']}";//latitude //longitude
          serviceAddressName = "${serviceLocation['streetName']}";//latitude //longitude

          stateCode = "${stateData['abbr']}";
          zipCode = "${serviceLocation['zipCode']}";

          cityName = "${serviceLocation['cityName']}";
          print("CityName===$cityName");
          isLocationFound = true;
          if(response['image'] != null) {
            existingImage = "${GlobalInstance.apiBaseUrl}" + response['image']['path'];
          }

          stateData = {
            "label": response['statename'],
            "abbr": response['statecode'],
          };

          if(response['image'] != null) {
            imagePathData = {
              "imageid": response['image']['imageid'],
              "path": response['image']['path']
            };
          }
        });
        Navigator.pop(context);
      }
    } else {
      CustomToast.showToastMessage("Something Went Wrong!");
    }
  }

  Future updateLocalManualServiceLocation(serviceLocation, {myState}) async {
    FocusScope.of(context).requestFocus(FocusNode());
    var addressId = await PreferenceHelper.getPreferenceData(PreferenceHelper.LOCATION_ID) ?? "";

    var requestJson = {
      "street1":"${serviceLocation['streetName']}",
      "city":"${serviceLocation['cityName']}",
      "statecode": stateCode == null ? "" : stateCode == "" ? "" : stateCode,
      "countrycode": countryCode == "" ? "US" : countryCode,
      "zip":"${serviceLocation['zipCode']}",
      "serviceaddressnick":"${serviceLocation['streetName']}",
    };

    log("RequestParameter====$requestJson");
    var requestParam = json.encode(requestJson);

    var response = await dbHelper.updateServiceGeneralDetail(
      serviceLocalId: customerData['clientid'],
      payload: requestParam,
    );

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage("${response['reason']}");
      } else {
        // if(imagePath != "") {
        //   await uploadImageDataIntoLocalDb(imagePath, myState: myState);
        // }

        setState(() {
          isEditLocationFound = true;
          isLocationFound = true;
          locationName = "${serviceLocation['streetName']}";
          serviceAddressName = "${serviceLocation['streetName']}";

          countryCode = "US";

          cityName = serviceLocation['cityName'];
          print("CityName===$cityName");

          log("ServiceListUpdated====>>>$serviceList");

          myState((){
            _editStreetController.text = "";
            _editLocationNameController.text = "";
            _editApartmentController.text = "";
            _editCityController.text = "";
            _editZipCodeController.text = "";
          });
        });

        Navigator.pop(context);
      }
    } else {
      CustomToast.showToastMessage("Something Went Wrong!");
    }
  }

  Future uploadLocationImage(image, {myState}) async {

    if(myState != null)
      setCircularProgress(true, myState);
    else
      _progressHUD.state.show();

    FocusScope.of(context).requestFocus(FocusNode());
    var addressId = await PreferenceHelper.getPreferenceData(PreferenceHelper.LOCATION_ID);
    var clientId = await PreferenceHelper.getPreferenceData(PreferenceHelper.CLIENT_ID);

    var response = await request.uploadOnlyResource(
        "auth/myclient/$clientId/servicelocation/$addressId/photo",
        image
    );
    print("Response====$response");

    if(myState != null)
      setCircularProgress(false, myState);
    else
      _progressHUD.state.dismiss();

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage("${response['reason']}");
      } else {
        setState((){
          imagePath = image;
          isPhotoTaken = true;
          isLocalImage = false;

          var path = "${AllHttpRequest.apiUrl}${response['path']}";
          existingImage = path;

          if(myState != null) {
            myState((){
              isPhotoTaken = true;
              imagePath = image;
              existingImage = path;
            });
          }
          var imageId = "${response['imageid']}";
          PreferenceHelper.setPreferenceData(PreferenceHelper.LOCATION_IMAGE, path);
          PreferenceHelper.setPreferenceData(PreferenceHelper.LOCATION_IMAGE_ID, imageId);

          return response;
        });
      }
    }
  }

  Future uploadImageDataIntoLocalDb(image, {myState}) async {
    try{
      FocusScope.of(context).requestFocus(FocusNode());
      var addressId = await PreferenceHelper.getPreferenceData(PreferenceHelper.LOCATION_ID);
      var clientId = await PreferenceHelper.getPreferenceData(PreferenceHelper.CLIENT_ID);

      var endPoint =  "auth/myclient/{{clientid}}/servicelocation/{{serviceid}}/photo";

      var response = await dbHelper.insertLocationImageData({
        "servicelocalid": "$addressId",
        "serviceserverid": "$addressId",
        "customerlocalid": "$clientId",
        "customerserverid": "$clientId",
        "url": '$endPoint',
        "verb":'MULTIPART',
        "payload": "",
        "imagepath": image,
      });
      print("Response====$response");

      if (response != null) {
        setState((){
          imagePath = image;
          isPhotoTaken = true;
          isLocalImage = true;

          if(myState != null) {
            myState(() {
              isPhotoTaken = true;
              imagePath = image;
            });
          }

          PreferenceHelper.setPreferenceData(PreferenceHelper.LOCATION_IMAGE_ID, "$response");
          return response;
        });
      }
    }catch(e){
      log("uploadImageDataIntoLocalDbStackTrace===$e");
    }
  }

  Future<void> deleteLocationImage([myState]) async{
    _progressHUD.state.show();
    if(myState != null) {
      setEditCircularProgress(true, myState);
    }

    FocusScope.of(context).requestFocus(FocusNode());
    var addressId = await PreferenceHelper.getPreferenceData(PreferenceHelper.LOCATION_ID);
    var clientId = await PreferenceHelper.getPreferenceData(PreferenceHelper.CLIENT_ID);
    var imageId = await PreferenceHelper.getPreferenceData(PreferenceHelper.LOCATION_IMAGE_ID);

    var response = await request.deleteAuthImageRequest(
      "auth/myclient/$clientId/servicelocation/$addressId/photo/$imageId",
    );
    print("Response====$response");
    _progressHUD.state.dismiss();

    if(myState != null) {
      setEditCircularProgress(false, myState);
    }

    if (response == null) {
      setState((){
        PreferenceHelper.clearPreferenceData(PreferenceHelper.LOCATION_IMAGE);
        PreferenceHelper.clearPreferenceData(PreferenceHelper.LOCATION_IMAGE_ID);

        if(myState != null) {
          myState((){
            imagePath = "";
            existingImage = "";
            isPhotoTaken = false;
          });
        } else {
          imagePath = "";
          existingImage = "";
          isPhotoTaken = false;
        }
      });
    } else {
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage("${response['reason']}");
      }
    }
  }

  Future deleteLocationImageFromLocalDB({myState}) async {
    FocusScope.of(context).requestFocus(FocusNode());
    var imageId = await PreferenceHelper.getPreferenceData(PreferenceHelper.LOCATION_IMAGE_ID);

    _progressHUD.state.dismiss();

    var response = await dbHelper.deleteLocationImageData(imageId);
    if (response == null) {
      setState((){
        PreferenceHelper.clearPreferenceData(PreferenceHelper.LOCATION_IMAGE);
        PreferenceHelper.clearPreferenceData(PreferenceHelper.LOCATION_IMAGE_ID);

        if(myState != null) {
          myState((){
            imagePath = "";
            existingImage = "";
            isPhotoTaken = false;
          });
        } else {
          imagePath = "";
          existingImage = "";
          isPhotoTaken = false;
        }
      });
    }
  }

  Future<void> deleteLocation() async{
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var addressId = await PreferenceHelper.getPreferenceData(PreferenceHelper.LOCATION_ID);
    var clientId = await PreferenceHelper.getPreferenceData(PreferenceHelper.CLIENT_ID);

    var response = await request.deleteAuthRequest(
      "auth/myclient/$clientId/servicelocation/$addressId",
    );
    print("Response====$response");
    _progressHUD.state.dismiss();
    if (response != null) {
      if (response['success'] != null && !response['success']) {
        CustomToast.showToastMessage('${response['reason']}');
      } else {
        setState(() {
          print("in if Response=");
          isLocationFound = false;
          locationName = '';
          serviceAddressName = '';
          if (serviceList != null) serviceList.removeAt(selectedIndex);
          PreferenceHelper.clearPreferenceData(PreferenceHelper.LOCATION_IMAGE);
          PreferenceHelper.clearPreferenceData(PreferenceHelper.LOCATION_IMAGE_ID);
        });
      }
    } else {
      print("in else Response=");
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage("${response['reason']}");
      }
    }
  }

  void displayDeleteLocationDialog(BuildContext context, String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          content: Text(
            message,
            style: TextStyle(
              color: AppColor.TYPE_PRIMARY,
              fontSize: 16.0,
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
                child: const Text('Cancel'),
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context, 'Cancel');
                }),
            CupertinoDialogAction(
                child: const Text('Yes'),
                onPressed: () {

                  Navigator.pop(context);
                  deleteLocation();

                }),
          ],
        ),
        barrierDismissible: true);
  }

  void displayDeleteLocationImageDialog(BuildContext context, String message, myState) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          content: Text(
            message,
            style: TextStyle(
              color: AppColor.TYPE_PRIMARY,
              fontSize: 16.0,
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
                child: const Text('Cancel'),
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context, 'Cancel');
                }),
            CupertinoDialogAction(
                child: const Text('Yes'),
                onPressed: () {

                  Navigator.pop(context);
                  if(_isInternetAvailable) {
                    deleteLocationImage(myState);
                  } else {
                    deleteLocationImageFromLocalDB(myState: myState);
                  }
                }),
          ],
        ),
        barrierDismissible: true);
  }

  Future beginInspection() async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var addressId = await PreferenceHelper.getPreferenceData(PreferenceHelper.LOCATION_ID);

    var requestJson = {
      "addressid": "{{serviceid}}",
      "inspectiondefid": inspectionDefIdLocal ?? "1"
    };

    var endPoint = "auth/inspection";

    // var requestParam = json.encode(requestJson);
    // var response = await request.postRequest(
    //     "auth/inspection",
    //     requestParam
    // );

    _progressHUD.state.dismiss();

   var response =  await dbHelper.insertInspectionId({
      "url": '$endPoint',
      "verb":'POST',
      "inspectionlocalid": "1",
      "inspectionserverid": "0",
      "isinspectionserverid": 0,
      "serviceaddressid": "$addressId",
      "servicelocalid": "$addressId",
      "inspectiondefid": inspectionDefIdLocal ?? "1",
      "payload": json.encode(requestJson),
    });

    if (response != null) {
      PreferenceHelper.clearPreferenceData(PreferenceHelper.INSPECTION_ID);
      PreferenceHelper.setPreferenceData(PreferenceHelper.INSPECTION_ID, "$response");

      PreferenceHelper.clearPreferenceData(PreferenceHelper.PDF_TOKEN);
      PreferenceHelper.setPreferenceData(PreferenceHelper.PDF_TOKEN, "");
      ///Children Inspection Data
      var localChildData = await InspectionPreferences.getPreferenceData(InspectionPreferences.INSPECTION_CHILD_DATA);
      var childrenTemplateData = json.decode(localChildData);

      print("API====11111==$childrenTemplateData");
      inspectionData(response, childrenTemplateData);
    }
  }

  void inspectionData(inspectionId, inspectiondef) async {
    // try{
      var transformedData = HelperClass.unroll(inspectionId, inspectiondef, [], [], []);
      const JsonEncoder encoder = JsonEncoder.withIndent('  ');

      log("TransformedData====>>>>${encoder.convert(transformedData)}");

      int inspectionIndex = await InspectionPreferences.getInspectionId(InspectionPreferences.INSPECTION_INDEX) ?? 0;

      print("Index===$inspectionIndex");
      InspectionPreferences.clearPreferenceData(InspectionPreferences.INSPECTION_DATA);
      InspectionPreferences.setPreferenceData(
          InspectionPreferences.INSPECTION_DATA,
          json.encode(transformedData['flow'])
      );

      var pageName;
      var inspectionData;
      int index;

      print("Index====$inspectionIndex");
      print("Length====${transformedData.length}");
      for(int i=inspectionIndex ?? 0; i<transformedData['flow'].length; i++) {
        var data = await InspectionUtils.getInspectionBlockTypeData(transformedData['flow'][i], transformedData['flow'].length);
        if(data != null){
          pageName = data;
          inspectionData = transformedData[i];
          index = i;
          break;
        }
      }
      if(pageName != null){
        InspectionPreferences.clearPreferenceData(InspectionPreferences.INSPECTION_INDEX);
        InspectionPreferences.setInspectionId(
            InspectionPreferences.INSPECTION_INDEX,
            ++index
        );
        Navigator.push(
            context,
            SlideRightRoute(
                page: pageName
            )
        );
      }
    // }catch (e) {
    //   print("inspectionData====Error=====$e");
    // }
  }

  void gotoNextPage() async {
    var listItem = await InspectionPreferences.getPreferenceData(InspectionPreferences.INSPECTION_DETAIL_LIST);
    List inspectionListItem = json.decode(listItem);


    print("iNSPECTION Location Data === $inspectionListItem");

    for(int i=0; i<inspectionListItem.length; i++) {
      if(inspectionListItem[i]['status'] == 0) {
        if (inspectionListItem[i]['blocktype'] == 'section') {
          inspectionListItem[i]['status'] = 1;
          InspectionPreferences.clearPreferenceData(InspectionPreferences.INSPECTION_DETAIL_LIST);
          InspectionPreferences.setPreferenceData(
              InspectionPreferences.INSPECTION_DETAIL_LIST,
              json.encode(inspectionListItem)
          );

          getInspectionSection(inspectionListItem[i]['inspectiondefid']);
          break;
        }
      }
    }
  }

  void getInspectionSection(id) async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());

    var response = await request.getAuthRequest("auth/buildinspection/$id");
    _progressHUD.state.dismiss();

    if (response != null) {
      var inspectionData;
      if(response.length > 0) {
        inspectionData = response[0];
      }

      if(inspectionData != null){
        response.removeAt(0);
        // Section inspection list
        InspectionPreferences.clearPreferenceData(InspectionPreferences.INSPECTION_CHAPTER_DETAIL_LIST);
        InspectionPreferences.setPreferenceData(
            InspectionPreferences.INSPECTION_CHAPTER_DETAIL_LIST,
            json.encode(response)
        );

        var pageName = await InspectionUtils.getInspectionBlockType(
            inspectionData['questiontype'],
            inspectionData
        );

        if(pageName != null) {
          Navigator.pushReplacement(
              context,
              SlideRightRoute(
                  page: pageName
              )
          );
        }
      }
    }
  }

  void gotoNextScreen() async {
    var listItemData = await InspectionPreferences.getPreferenceData(InspectionPreferences.INSPECTION_DATA);
    var transformedData = json.decode(listItemData);
    int inspectionIndex = await InspectionPreferences.getInspectionId(InspectionPreferences.INSPECTION_INDEX);

    print(transformedData);
    print(inspectionIndex);

    var pageName;
    var inspectionData;
    int index;

    print("Index====$inspectionIndex");
    print("Length====${transformedData.length}");
    for(int i=inspectionIndex ?? 0; i<transformedData.length; i++) {
      var data = await InspectionUtils.getInspectionBlockTypeData(transformedData[i], transformedData.length);
      if(data != null){
        pageName = data;
        inspectionData = transformedData[i];
        index = i;
        break;
      }
    }

    if(pageName != null){
      InspectionPreferences.clearPreferenceData(InspectionPreferences.INSPECTION_INDEX);
      InspectionPreferences.setInspectionId(
          InspectionPreferences.INSPECTION_INDEX,
          ++index
      );
      Navigator.push(
          context,
          SlideRightRoute(
              page: pageName
          )
      );
    }
  }

  void openAddNewAddressBottomSheet(context){
    isLocationLoaded = false;
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        useRootNavigator: true,
        clipBehavior: Clip.none,
        barrierColor: isDarkMode ? Color(0xff000000).withOpacity(0.8) : Color(0xff000000).withOpacity(0.5),
        isDismissible: false,
        enableDrag: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        backgroundColor: isDarkMode ? Color(0xff333333) : AppColor.PAGE_COLOR,
        builder: (context){
          return StatefulBuilder(
            builder: (context1, myState){
              locationState = myState;
              return GestureDetector(
                onTap: (){
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height - 50,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: (){
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                                    child: Image.asset(
                                      isDarkMode
                                      ? 'assets/ic_dark_close.png'
                                      : 'assets/ic_back_close.png',
                                      height: 44.0,
                                      width: 44.0,
                                    ),
                                  ),
                                ),

                                Text(
                                  lang == 'en' ? newServiceAddressEn : newServiceAddressEs,
                                  style: TextStyle(
                                    color: themeColor,
                                    fontSize: TextSize.headerText,
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      myState((){
                                        if(_formKey.currentState.validate() && _allFieldValidate){
                                          Map serviceLocationData = {
                                            "streetName": "${_streetController.text.toString().trim()}",
                                            "nickName": "${_locationNameController.text.toString().trim()}",
                                            "apaName": "${_apartmentController.text.toString().trim()}",
                                            "cityName" : "${_cityController.text.toString().trim()}",
                                            "zipCode" : "${_zipCodeController.text.toString().trim()}",
                                          };
                                          print("Service Location Data====>>>$serviceLocationData");

                                          if(_isInternetAvailable) {
                                            createManualServiceLocation(
                                                serviceLocationData,
                                                myState: myState);
                                          } else {
                                            insertServiceLocationDataIntoLocalDB(serviceLocationData, myState: myState);
                                          }
                                        } else {
                                          setState(() {
                                            _locationNameFocus.requestFocus(FocusNode());
                                          });
                                          print("Service Location Data====>>>Else");
                                        }
                                      });
                                    });

                                    // Navigator.pop(context);
                                  },
                                  child: Theme(
                                    data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                                    child: Container(
                                      alignment: Alignment.bottomCenter,
                                      decoration: BoxDecoration(
                                          // gradient: LinearGradient(colors: [
                                          //   Color(0xff013399),
                                          //   Color(0xffBC96E6),
                                          // ]),
                                          gradient: LinearGradient(colors: [
                                            (_allFieldValidate) ? Color(0xff013399) : themeColor.withOpacity(0.6),
                                            (_allFieldValidate) ? Color(0xffBC96E6) : themeColor.withOpacity(0.6),
                                          ]),
                                          borderRadius: BorderRadius.all(Radius.circular(32.0))
                                      ),
                                      margin: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                                      padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 8.0),
                                      child: Center(
                                        child: Text(
                                          lang == 'en' ? saveEn : saveEs,
                                          style: TextStyle(
                                              fontSize: TextSize.headerText,
                                              color: AppColor.WHITE_COLOR,
                                              fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Form(
                                  key: _formKey,
                                  autovalidateMode: AutovalidateMode.disabled,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [

                                        imagePath != ''
                                            ? ConstrainedBox(
                                          constraints: BoxConstraints(
                                              maxHeight: MediaQuery.of(context).size.width-32,
                                              maxWidth: MediaQuery.of(context).size.width
                                          ),
                                          child: Container(
                                            margin: EdgeInsets.only(top: 16.0, left: 0.0, right: 0.0, bottom: 0.0),
                                            width: MediaQuery.of(context).size.width,
                                            height: MediaQuery.of(context).size.width-32,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(32.0),
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: AppColor.TYPE_PRIMARY.withOpacity(0.16),
                                                      blurRadius: 1.0
                                                  )
                                                ]
                                            ),
                                            child: Stack(
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context).size.width,
                                                  height: MediaQuery.of(context).size.width-32,
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(32.0),
                                                    child: Image.file(
                                                      File(imagePath),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),

                                                Positioned(
                                                  top: 16.0,
                                                  right: 16.0,
                                                  child: GestureDetector(
                                                    onTap: (){
                                                      setState(() {
                                                        myState((){
                                                          imagePath = "";
                                                        });
                                                      });
                                                    },
                                                    child: Container(
                                                      padding: EdgeInsets.all(12.0),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(40.0),
                                                        color: AppColor.RED_COLOR,
                                                      ),
                                                      child: Image.asset(
                                                        'assets/ic_delete.png',
                                                        fit: BoxFit.contain,
                                                        color: AppColor.WHITE_COLOR,
                                                        height: 24.0,
                                                        width: 24.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                            : Container(
                                          height: 180.0,
                                          width: MediaQuery.of(context).size.width,
                                          margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                  colors: AppColor.gradientColor(0.32)
                                              ),
                                              borderRadius: BorderRadius.circular(32.0)
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              GestureDetector(
                                                onTap: (){
                                                  // getImageFromCamera("", myState);
                                                  bottomNavigation(context, "",  locationState);
                                                },
                                                child:  Container(
                                                  child: Image.asset(
                                                    'assets/welcome/ic_camera_profile.png',
                                                    width: 56.0,
                                                    height: 56.0,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 8.0,),
                                              Text(
                                                lang == 'en' ? takeAPictureEn : takeAPictureEs,
                                                style:  TextStyle(
                                                    color: themeColor,
                                                    fontSize: TextSize.subjectTitle,
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.3
                                                ),
                                              )
                                            ],
                                          ),
                                        ),

                                        //Nick Name
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          margin: EdgeInsets.only(top: 16.0, bottom: 16.0),
                                          padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: isNickNameFocus && isDarkMode
                                                    ? AppColor.gradientColor(0.32)
                                                    : isNickNameFocus
                                                    ? AppColor.gradientColor(0.16)
                                                    : isDarkMode
                                                    ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                                                    : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
                                              ),
                                              borderRadius: BorderRadius.circular(32.0),
                                              border: GradientBoxBorder(
                                                  gradient: LinearGradient(
                                                    colors: isNickNameFocus
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
                                                lang == 'en' ? nickNameOptionalEn : nickNameOptionalEs,
                                                style: TextStyle(
                                                  fontSize: TextSize.subjectTitle,
                                                  color: themeColor.withOpacity(1.0),
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle: FontStyle.normal,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              TextFormField(
                                                controller: _locationNameController,
                                                focusNode: _locationNameFocus,
                                                onFieldSubmitted: (term) {
                                                  _locationNameFocus.unfocus();
                                                  FocusScope.of(context).requestFocus(_streetFocus);
                                                },
                                                // validator: (value){
                                                //   return validateString(value, "Nick Name");
                                                // },
                                                textInputAction: TextInputAction.next,
                                                keyboardType: TextInputType.text,
                                                textCapitalization: TextCapitalization.sentences,
                                                textAlign: TextAlign.start,
                                                decoration: InputDecoration(
                                                  fillColor: AppColor.WHITE_COLOR,
                                                  hintText: lang == 'en' ? nickNameEn : nickNameEs,
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

                                                },
                                              ),
                                            ],
                                          ),
                                        ),

                                        //Use Current Location
                                        Visibility(
                                          visible: _isInternetAvailable,
                                          child: GestureDetector(
                                            onTap: () async {

                                              await Permission.location.request().then((status){
                                                if(status.isGranted){
                                                  print("Granted");
                                                  setState(() {
                                                    myState((){
                                                      isLocationLoaded = true;
                                                    });
                                                  });
                                                  getLocation(myState);
                                                } else if(status.isDenied) {
                                                  print("Denied");
                                                } else if(status.isPermanentlyDenied) {
                                                  print("Permanently Denied");
                                                  openAppSettings();
                                                }
                                              });
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                                              margin: EdgeInsets.only(bottom: 0.0),
                                              decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                      colors: AppColor.gradientColor(0.32)
                                                  ),
                                                  borderRadius: BorderRadius.circular(32)
                                              ),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    child: Image.asset(
                                                      'assets/new_ui/ic_current_location.png',
                                                      fit: BoxFit.contain,
                                                      height: 48.0,
                                                      width: 48.0,
                                                    ),
                                                  ),
                                                  SizedBox(width: 16.0,),
                                                  Text(
                                                    lang == 'en' ? useCurrentLocationEn : useCurrentLocationEs,
                                                    style: TextStyle(
                                                        color: themeColor,
                                                        fontSize: TextSize.headerText,
                                                        fontWeight: FontWeight.w600,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),

                                        //Street Name
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
                                                lang == 'en' ? streetEn : streetEs,
                                                style: TextStyle(
                                                  fontSize: TextSize.subjectTitle,
                                                  color: themeColor,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle: FontStyle.normal,
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
                                                validator: (value){
                                                  return validateString(value, lang == "en" ? "Us street address" : "Dirección de la calle US");
                                                },
                                                textCapitalization: TextCapitalization.sentences,
                                                textInputAction: TextInputAction.next,
                                                keyboardType: TextInputType.text,
                                                textAlign: TextAlign.start,
                                                decoration: InputDecoration(
                                                  fillColor: AppColor.WHITE_COLOR,
                                                  hintText: lang == "en" ? "Your US street address" : "Tu dirección de la calle US",
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
                                                  myState(() {
                                                    formValidation();
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),

                                        //App/Suit (Optional)
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          margin: EdgeInsets.only(top: 8.0, bottom: 0.0),
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
                                                lang == 'en' ? aptSuiteEn : aptSuiteEs,
                                                style: TextStyle(
                                                  fontSize: TextSize.subjectTitle,
                                                  color: themeColor.withOpacity(1.0),
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle: FontStyle.normal,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              TextFormField(
                                                controller: _apartmentController,
                                                focusNode: _apartmentFocus,
                                                onFieldSubmitted: (term) {
                                                  _apartmentFocus.unfocus();
                                                  FocusScope.of(context).requestFocus(_cityFocus);
                                                },
                                                // validator: (value){
                                                //   return validateString(value, "Nick Name");
                                                // },
                                                textCapitalization: TextCapitalization.sentences,
                                                textInputAction: TextInputAction.next,
                                                keyboardType: TextInputType.text,
                                                textAlign: TextAlign.start,
                                                decoration: InputDecoration(
                                                  fillColor: AppColor.WHITE_COLOR,
                                                  hintText: lang == 'en' ? apartmentEn : apartmentEs,
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
                                                  // setState(() {
                                                  //   formValidation();
                                                  // });
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
                                            // log("StateList====$stateList");
                                            if(stateList.length > 0) {
                                              bottomStatePicker(context, myState);
                                            } else {
                                              CustomToast.showToastMessage("No state available, please check your internet connectivity.");
                                              // HelperClass.showSnackBar(context, "No state available, please check your internet connectivity.");
                                            }
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context).size.width,
                                            margin: EdgeInsets.only(top: 8.0, bottom: 0.0),
                                            padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                            decoration: BoxDecoration(
                                                color: isDarkMode
                                                ? Color(0xff1f1f1f)
                                                : AppColor.WHITE_COLOR,
                                                borderRadius: BorderRadius.circular(32.0)
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  lang == "en" ? stateEn : stateEs,
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
                                                        : lang == "en" ? stateEn : stateEs,
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
                                              ],
                                            ),
                                          ),
                                        ),

                                        //City
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          margin: EdgeInsets.only(top: 8.0, bottom: 0.0),
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
                                                lang == 'en' ? cityEn : cityEs,
                                                style: TextStyle(
                                                  fontSize: TextSize.subjectTitle,
                                                  color: themeColor.withOpacity(1.0),
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle: FontStyle.normal,),
                                                textAlign: TextAlign.center,
                                              ),
                                              TextFormField(
                                                controller: _cityController,
                                                focusNode: _cityFocus,
                                                onFieldSubmitted: (term) {
                                                  _cityFocus.unfocus();
                                                  FocusScope.of(context).requestFocus(_zipCodeFocus);
                                                },
                                                validator: (value){
                                                  return validateString(value, lang == 'en' ? yourCityEn : yourCityEs);
                                                },
                                                textCapitalization: TextCapitalization.sentences,
                                                textInputAction: TextInputAction.next,
                                                keyboardType: TextInputType.text,
                                                textAlign: TextAlign.start,
                                                decoration: InputDecoration(
                                                  fillColor: AppColor.WHITE_COLOR,
                                                  hintText: lang == 'en' ? yourCityEn : yourCityEs,
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
                                                  myState(() {
                                                    formValidation();
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),

                                        //Zip Code
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          margin: EdgeInsets.only(top: 8.0, bottom: 0.0),
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
                                                lang == 'en' ? zipCodeEn : zipCodeEs,
                                                style: TextStyle(
                                                    fontSize: TextSize.subjectTitle,
                                                    color: themeColor,
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle: FontStyle.normal),
                                                textAlign: TextAlign.center,
                                              ),
                                              TextFormField(
                                                controller: _zipCodeController,
                                                focusNode: _zipCodeFocus,
                                                onFieldSubmitted: (term) {
                                                  _zipCodeFocus.unfocus();
                                                },
                                                validator: (value){
                                                  return validateString(value, lang == 'en' ? zipCodeEn : zipCodeEs);
                                                },
                                                textInputAction: TextInputAction.done,
                                                keyboardType: TextInputType.number,
                                                textAlign: TextAlign.start,
                                                decoration: InputDecoration(
                                                  fillColor: AppColor.WHITE_COLOR,
                                                  hintText: lang == 'en' ? zipCodeEn : zipCodeEs,
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
                                                  myState(() {
                                                    formValidation();
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 250.0,)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: SingleChildScrollView(
                          child: Visibility(
                            visible: isLocationLoaded,
                            child: Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height - 50,
                              margin: EdgeInsets.only(top: 10.0),
                              color: isLocationLoaded ? AppColor.GREY_COLOR.withOpacity(0.4) : AppColor.TRANSPARENT,
                              child: Container(
                                child: Center(
                                  child: Container(
                                    child: CircularProgressIndicator(
                                      backgroundColor: AppColor.TRANSPARENT,
                                      color: AppColor.THEME_PRIMARY,
                                      strokeWidth: 5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        }
    );
  }

  void openEditAddressBottomSheet(context) {
    isEditLocationLoaded = false;

    _allEditFieldValidate = true;
    _editLocationNameController.text = locationName ?? "";
    _editStreetController.text = locationName ?? "";
    _editCityController.text = cityName??"";
    // _editApartmentController.text = "";
    _editZipCodeController.text = zipCode??"";

    _editLocationNameController.selection = TextSelection.collapsed(offset: _editLocationNameController.text.length);
    _editStreetController.selection = TextSelection.collapsed(offset: _editStreetController.text.length);
    _editApartmentController.selection = TextSelection.collapsed(offset: _editApartmentController.text.length ?? 0);
    _editCityController.selection = TextSelection.collapsed(offset: _editCityController.text.length);
    _editZipCodeController.selection = TextSelection.collapsed(offset: _editZipCodeController.text.length);

    isEditLocationFound = true;
    imagePath = "";
    existingImage = existingImage;
    isPhotoTaken = existingImage != "";
    // stateData = stateData;
    log("ImagePath===$imagePath");
    log("ExistingImagePath===$existingImage");
    var result = imagePath != "" ? "ImageFile" : existingImage == '' ? "No Image" : "Existing";
    log("Result===$result");

    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        useRootNavigator: true,
        clipBehavior: Clip.none,
        barrierColor: isDarkMode ? Color(0xff000000).withOpacity(0.8) : Color(0xff000000).withOpacity(0.5),
        isDismissible: false,
        enableDrag: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        builder: (context){
          return StatefulBuilder(
            builder: (context1, myState){
              locationEditState = myState;

              return GestureDetector(
                onTap: (){
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height - 50,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: (){
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                                    child: Image.asset(
                                      isDarkMode
                                        ? 'assets/ic_dark_close.png'
                                        : 'assets/ic_back_close.png',
                                      height: 44.0,
                                      width: 44.0,
                                    ),
                                  ),
                                ),

                                Text(
                                  lang == 'en' ? "Edit Service Address" : "Editar dirección de servicio",
                                  style: TextStyle(
                                    color: themeColor,
                                    fontSize: TextSize.headerText,
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      myState((){
                                        if(_editFormKey.currentState.validate() && _allEditFieldValidate){
                                          Map serviceLocationData = {
                                            "streetName": "${_editStreetController.text.toString().trim()}",
                                            "nickName": "${_editLocationNameController.text.toString().trim()}",
                                            "apaName": "${_editApartmentController.text.toString().trim()}",
                                            "cityName" : "${_editCityController.text.toString().trim()}",
                                            "zipCode" : "${_editZipCodeController.text.toString().trim()}",
                                          };
                                          print("Service Location Data====>>>$serviceLocationData");

                                          if(_isInternetAvailable) {
                                            updateManualServiceLocation(serviceLocationData, myState: locationEditState);
                                          } else {
                                            updateLocalManualServiceLocation(serviceLocationData, myState: locationEditState);
                                          }

                                        } else {
                                          setState(() {
                                            _editLocationNameFocus.requestFocus(FocusNode());
                                          });
                                          print("Service Location Data====>>>Else");
                                        }
                                      });
                                    });

                                    // Navigator.pop(context);
                                  },
                                  child: Theme(
                                    data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                                    child: Container(
                                      alignment: Alignment.bottomCenter,
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(colors: [
                                            (_allEditFieldValidate) ? Color(0xff013399) : themeColor.withOpacity(0.6),
                                            (_allEditFieldValidate) ? Color(0xffBC96E6) : themeColor.withOpacity(0.6),
                                          ]),
                                          borderRadius: BorderRadius.all(Radius.circular(32.0))
                                      ),
                                      margin: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                                      padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 8.0),
                                      child: Center(
                                        child: Text(
                                          lang == 'en' ? saveEn : saveEs,
                                          style: TextStyle(
                                              fontSize: TextSize.headerText,
                                              color: AppColor.WHITE_COLOR,
                                              fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Form(
                                  key: _editFormKey,
                                  autovalidateMode: AutovalidateMode.disabled,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        //Nick Name
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          margin: EdgeInsets.only(top: 16.0, bottom: 16.0),
                                          padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: isEditNickNameFocus && isDarkMode
                                                    ? AppColor.gradientColor(0.32)
                                                    : isEditNickNameFocus
                                                    ? AppColor.gradientColor(0.16)
                                                    : isDarkMode
                                                    ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                                                    : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
                                              ),
                                              borderRadius: BorderRadius.circular(32.0),
                                              border: GradientBoxBorder(
                                                  gradient: LinearGradient(
                                                    colors: isEditNickNameFocus
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
                                                lang == 'en' ? nickNameOptionalEn : nickNameOptionalEs,
                                                style: TextStyle(
                                                  fontSize: TextSize.subjectTitle,
                                                  color: themeColor.withOpacity(1.0),
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle: FontStyle.normal,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              TextFormField(
                                                controller: _editLocationNameController,
                                                focusNode: _editLocationNameFocus,
                                                onFieldSubmitted: (term) {
                                                  _editLocationNameFocus.unfocus();
                                                  FocusScope.of(context).requestFocus(_editStreetFocus);
                                                },
                                                // validator: (value){
                                                //   return validateString(value, "Nick Name");
                                                // },
                                                textInputAction: TextInputAction.next,
                                                keyboardType: TextInputType.text,
                                                textCapitalization: TextCapitalization.sentences,
                                                textAlign: TextAlign.start,
                                                decoration: InputDecoration(
                                                  fillColor: AppColor.WHITE_COLOR,
                                                  hintText: lang == 'en' ? nickNameEn : nickNameEs,
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

                                                },
                                              ),
                                            ],
                                          ),
                                        ),

                                        imagePath != ''
                                          ? ConstrainedBox(
                                            constraints: BoxConstraints(
                                                maxHeight: MediaQuery.of(context).size.width-32,
                                                maxWidth: MediaQuery.of(context).size.width
                                            ),
                                            child: Container(
                                              margin: EdgeInsets.only(top: 16.0, left: 0.0, right: 0.0, bottom: 10.0),
                                              width: MediaQuery.of(context).size.width,
                                              height: MediaQuery.of(context).size.width-32,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(32.0),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: AppColor.TYPE_PRIMARY.withOpacity(0.16),
                                                        blurRadius: 1.0
                                                    )
                                                  ]
                                              ),
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    width: MediaQuery.of(context).size.width,
                                                    height: MediaQuery.of(context).size.width-32,
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(32.0),
                                                      child: Image.file(
                                                        File(imagePath),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),

                                                  Positioned(
                                                    top: 16.0,
                                                    right: 16.0,
                                                    child: GestureDetector(
                                                      onTap: (){
                                                        setState(() {
                                                          myState((){
                                                            imagePath = "";
                                                          });
                                                        });
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.all(12.0),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(40.0),
                                                          color: AppColor.RED_COLOR,
                                                        ),
                                                        child: Image.asset(
                                                          'assets/ic_delete.png',
                                                          fit: BoxFit.contain,
                                                          color: AppColor.WHITE_COLOR,
                                                          height: 24.0,
                                                          width: 24.0,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                          : existingImage == ''
                                          ? Container(
                                          height: 180.0,
                                          width: MediaQuery.of(context).size.width,
                                          margin: EdgeInsets.only(top: 0.0, bottom: 0.0),
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                  colors: AppColor.gradientColor(0.32)
                                              ),
                                              borderRadius: BorderRadius.circular(32.0)
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              GestureDetector(
                                                onTap: (){
                                                  bottomNavigation(context, "",  myState);
                                                },
                                                child:  Container(
                                                  child: Image.asset(
                                                    'assets/welcome/ic_camera_profile.png',
                                                    width: 56.0,
                                                    height: 56.0,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 8.0,),
                                              Text(
                                                lang == 'en' ? takeAPictureEn : takeAPictureEs,
                                                style:  TextStyle(
                                                    color: themeColor,
                                                    fontSize: TextSize.subjectTitle,
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.3
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                          : ConstrainedBox(
                                          constraints: BoxConstraints(
                                              maxHeight: MediaQuery.of(context).size.width-32,
                                              maxWidth: MediaQuery.of(context).size.width
                                          ),
                                          child: Container(
                                              width: MediaQuery.of(context).size.width,
                                              height: MediaQuery.of(context).size.width-32,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(16.0),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: AppColor.TYPE_PRIMARY.withOpacity(0.16),
                                                        blurRadius: 1.0
                                                    )
                                                  ]
                                              ),
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    width: MediaQuery.of(context).size.width,
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(32.0),
                                                      child: Container(
                                                        width: MediaQuery.of(context).size.width,
                                                        height: MediaQuery.of(context).size.width-32,
                                                        color: AppColor.WHITE_COLOR,
                                                        child: Image.network(
                                                          "$existingImage",
                                                          fit: BoxFit.cover,
                                                          loadingBuilder: (context, child, loadingProgress){
                                                            if(loadingProgress == null) {
                                                              return child;
                                                            } else {
                                                              return Container(
                                                                height: 300,
                                                                color: AppColor.WHITE_COLOR,
                                                                child: Center(
                                                                  child: CircularProgressIndicator(
                                                                    value: loadingProgress.expectedTotalBytes != null ?
                                                                    loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                                                        : null,
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  Positioned(
                                                    top: 16.0,
                                                    right: 16.0,
                                                    child: GestureDetector(
                                                      onTap: (){
                                                        displayDeleteLocationImageDialog(context, "Do you want to delete the location image?", myState);
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.all(12.0),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(40.0),
                                                          color: AppColor.RED_COLOR,
                                                        ),
                                                        child: Image.asset(
                                                          'assets/ic_delete.png',
                                                          fit: BoxFit.contain,
                                                          color: AppColor.WHITE_COLOR,
                                                          height: 24.0,
                                                          width: 24.0,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                          ),
                                        ),

                                        //Street Name
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                          padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: isEditStreetFocus && isDarkMode
                                                    ? AppColor.gradientColor(0.32)
                                                    : isEditStreetFocus
                                                    ? AppColor.gradientColor(0.16)
                                                    : isDarkMode
                                                    ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                                                    : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
                                              ),
                                              borderRadius: BorderRadius.circular(32.0),
                                              border: GradientBoxBorder(
                                                  gradient: LinearGradient(
                                                    colors: isEditStreetFocus
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
                                                lang == 'en' ? streetEn : streetEs,
                                                style: TextStyle(
                                                  fontSize: TextSize.subjectTitle,
                                                  color: AppColor.TYPE_PRIMARY.withOpacity(1.0),
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle: FontStyle.normal,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              TextFormField(
                                                controller: _editStreetController,
                                                focusNode: _editStreetFocus,
                                                onFieldSubmitted: (term) {
                                                  _editStreetFocus.unfocus();
                                                  FocusScope.of(context).requestFocus(_editApartmentFocus);
                                                },
                                                validator: (value){
                                                  return validateString(value, lang == "en" ? "Us street address" : "Dirección de la calle US");
                                                },
                                                textCapitalization: TextCapitalization.sentences,
                                                textInputAction: TextInputAction.next,
                                                keyboardType: TextInputType.text,
                                                textAlign: TextAlign.start,
                                                decoration: InputDecoration(
                                                  fillColor: AppColor.WHITE_COLOR,
                                                  hintText: lang == "en" ? "Your US street address" : "Tu dirección de la calle US",
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
                                                  // myState(() {
                                                  //   editFormValidation();
                                                  // });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),

                                        //App/Suit (Optional)
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                          padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: isEditApartmentFocus && isDarkMode
                                                    ? AppColor.gradientColor(0.32)
                                                    : isEditApartmentFocus
                                                    ? AppColor.gradientColor(0.16)
                                                    : isDarkMode
                                                    ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                                                    : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
                                              ),
                                              borderRadius: BorderRadius.circular(32.0),
                                              border: GradientBoxBorder(
                                                  gradient: LinearGradient(
                                                    colors: isEditApartmentFocus
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
                                                lang == "en" ? aptSuiteEn : aptSuiteEs,
                                                style: TextStyle(
                                                  fontSize: TextSize.subjectTitle,
                                                  color: themeColor.withOpacity(1.0),
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle: FontStyle.normal,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              TextFormField(
                                                controller: _editApartmentController,
                                                focusNode: _editApartmentFocus,
                                                onFieldSubmitted: (term) {
                                                  _editApartmentFocus.unfocus();
                                                  FocusScope.of(context).requestFocus(_editCityFocus);
                                                },
                                                // validator: (value){
                                                //   return validateString(value, "Nick Name");
                                                // },
                                                textCapitalization: TextCapitalization.sentences,
                                                textInputAction: TextInputAction.next,
                                                keyboardType: TextInputType.text,
                                                textAlign: TextAlign.start,
                                                decoration: InputDecoration(
                                                  fillColor: AppColor.WHITE_COLOR,
                                                  hintText: lang == "en" ? apartmentEn : apartmentEs,
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
                                                  // setState(() {
                                                  //   formValidation();
                                                  // });
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
                                            // log("StateList====$stateList");
                                            if(stateList.length > 0) {
                                              bottomStatePicker(context, myState);
                                            } else {
                                              CustomToast.showToastMessage("No state available, please check your internet connectivity.");
                                              // HelperClass.showSnackBar(context, "No state available, please check your internet connectivity.");
                                            }
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context).size.width,
                                            margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                            padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                            decoration: BoxDecoration(
                                                color: isDarkMode
                                                    ? Color(0xff1f1f1f)
                                                    : AppColor.WHITE_COLOR,
                                                borderRadius: BorderRadius.circular(32.0)
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  lang == "en" ? stateEn : stateEs,
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
                                                        : lang == "en" ? stateEn : stateEs,
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
                                              ],
                                            ),
                                          ),
                                        ),

                                        //City
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                          padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: isEditCityFocus && isDarkMode
                                                    ? AppColor.gradientColor(0.32)
                                                    : isEditCityFocus
                                                    ? AppColor.gradientColor(0.16)
                                                    : isDarkMode
                                                    ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                                                    : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
                                              ),
                                              borderRadius: BorderRadius.circular(32.0),
                                              border: GradientBoxBorder(
                                                  gradient: LinearGradient(
                                                    colors: isEditCityFocus
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
                                                lang == "en" ? cityEn : cityEs,
                                                style: TextStyle(
                                                  fontSize: TextSize.subjectTitle,
                                                  color: themeColor.withOpacity(1.0),
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle: FontStyle.normal,),
                                                textAlign: TextAlign.center,
                                              ),
                                              TextFormField(
                                                controller: _editCityController,
                                                focusNode: _editCityFocus,
                                                onFieldSubmitted: (term) {
                                                  _editCityFocus.unfocus();
                                                  FocusScope.of(context).requestFocus(_editZipCodeFocus);
                                                },
                                                validator: (value){
                                                  return validateString(value, lang == "en" ? yourCityEn : yourCityEs);
                                                },
                                                textCapitalization: TextCapitalization.sentences,
                                                textInputAction: TextInputAction.next,
                                                keyboardType: TextInputType.text,
                                                textAlign: TextAlign.start,
                                                decoration: InputDecoration(
                                                  fillColor: AppColor.WHITE_COLOR,
                                                  hintText: lang == "en" ? yourCityEn : yourCityEs,
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
                                                  // myState(() {
                                                  //   editFormValidation();
                                                  // });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),

                                        //Zip Code
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                          padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: isEditZipCodeFocus && isDarkMode
                                                    ? AppColor.gradientColor(0.32)
                                                    : isEditZipCodeFocus
                                                    ? AppColor.gradientColor(0.16)
                                                    : isDarkMode
                                                    ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                                                    : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
                                              ),
                                              borderRadius: BorderRadius.circular(32.0),
                                              border: GradientBoxBorder(
                                                  gradient: LinearGradient(
                                                    colors: isEditZipCodeFocus
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
                                                lang == "en" ? zipCodeEn : zipCodeEs,
                                                style: TextStyle(
                                                    fontSize: TextSize.subjectTitle,
                                                    color: themeColor,
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle: FontStyle.normal),
                                                textAlign: TextAlign.center,
                                              ),
                                              TextFormField(
                                                controller: _editZipCodeController,
                                                focusNode: _editZipCodeFocus,
                                                onFieldSubmitted: (term) {
                                                  _editZipCodeFocus.unfocus();
                                                },
                                                validator: (value){
                                                  return validateString(value, lang == "en" ? zipCodeEn : zipCodeEs);
                                                },
                                                textInputAction: TextInputAction.done,
                                                keyboardType: TextInputType.number,
                                                textAlign: TextAlign.start,
                                                decoration: InputDecoration(
                                                  fillColor: AppColor.WHITE_COLOR,
                                                  hintText: lang == "en" ? zipCodeEn : zipCodeEs,
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
                                                  // myState(() {
                                                  //   editFormValidation();
                                                  // });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 250.0,)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: SingleChildScrollView(
                          child: Visibility(
                            visible: isEditLocationLoaded,
                            child: Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height - 50,
                              margin: EdgeInsets.only(top: 10.0),
                              color: isEditLocationLoaded ? AppColor.GREY_COLOR.withOpacity(0.4) : AppColor.TRANSPARENT,
                              child: Container(
                                child: Center(
                                  child: Container(
                                    child: CircularProgressIndicator(
                                      backgroundColor: AppColor.TRANSPARENT,
                                      color: AppColor.THEME_PRIMARY,
                                      strokeWidth: 5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        }
    );
  }

  void openEditCustomerBottomSheet(context){
    var emailData = emailList.length > 0 ? emailList[0] : "";
    var phoneData = phoneList.length > 0 ? phoneList[0] : "";
    firstNameController.text = customerData['firstname'];
    lastNameController.text = customerData['lastname'];
    email1Controller.text = emailData != "" ? emailData['email'] : "";
    phone1Controller.text = phoneData != "" ? phoneData['phoneno'] : "";
    isLoaded = false;

    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        clipBehavior: Clip.none,
        barrierColor: isDarkMode ? Color(0xff000000).withOpacity(0.8) : Color(0xff000000).withOpacity(0.5),
        isDismissible: false,
        enableDrag: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        backgroundColor: AppColor.PAGE_COLOR,
        builder: (context){
          return StatefulBuilder(
            builder: (context1, myState){
              customerState = myState;
              return Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height - 50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: (){
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                                  child: Image.asset(
                                    'assets/ic_back_close.png',
                                    height: 44.0,
                                    width: 44.0,
                                  ),
                                ),
                              ),

                              Text(
                                lang == 'en' ? "Edit Customer" : "Editar cliente",
                                style: TextStyle(
                                  color: themeColor,
                                  fontSize: TextSize.headerText,
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              GestureDetector(
                                onTap: (){
                                  if(firstNameController.text.toString() != ""
                                      || lastNameController.text.toString() != ""){
                                    setState(() {
                                      myState((){
                                        isLoaded = true;
                                      });
                                    });
                                    updateProfileDetail(myState);
                                  }
                                },
                                child: Theme(
                                  data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                                  child: Container(
                                    alignment: Alignment.bottomCenter,
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            colors: AppColor.gradientColor(1.0)
                                        ),
                                        borderRadius: BorderRadius.all(Radius.circular(32.0))
                                    ),
                                    margin: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                                    padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 8.0),
                                    child: Center(
                                      child: Text(
                                        lang == 'en' ? saveEn : saveEs,
                                        style: TextStyle(
                                            fontSize: TextSize.headerText,
                                            color: AppColor.WHITE_COLOR,
                                            fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Form Data
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Form(
                                key: _customerFormKey,
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      /***
                                       * First Name
                                       */
                                      Container(
                                        width: MediaQuery.of(context).size.width,
                                        margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                        padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                        decoration: BoxDecoration(
                                            color: isFirstNameFocus
                                                ? AppColor.THEME_PRIMARY.withOpacity(0.08)
                                                : AppColor.WHITE_COLOR,
                                            borderRadius: BorderRadius.circular(32.0)
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              lang == "en" ? firstNameTitleEn : firstNameTitleEs,
                                              style: TextStyle(
                                                  fontSize: TextSize.subjectTitle,
                                                  color: themeColor.withOpacity(1.0),
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle: FontStyle.normal
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            TextFormField(
                                              controller: firstNameController,
                                              focusNode: firstNameFocus,
                                              onFieldSubmitted: (term) {
                                                firstNameFocus.unfocus();
                                                FocusScope.of(context).requestFocus(lastNameFocus);
                                              },
                                              textCapitalization: TextCapitalization.sentences,
                                              textInputAction: TextInputAction.next,
                                              keyboardType: TextInputType.name,
                                              textAlign: TextAlign.start,
                                              validator: (value){
                                                return validateString(value, lang == "en" ? givenNameEn : givenNameEs);
                                              },
                                              decoration: InputDecoration(
                                                fillColor: AppColor.WHITE_COLOR,
                                                hintText: lang == "en" ? givenNameEn : givenNameEs,
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
                                                myState((){
                                                  setState(() {
                                                    _allCustomerFieldValidate = _customerFormKey.currentState.validate();
                                                  });
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      /***
                                       * Last Name
                                       */
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
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              lang == "en" ? lastNameEn : lastNameEs,
                                              style: TextStyle(
                                                  fontSize: TextSize.subjectTitle,
                                                  color: themeColor.withOpacity(1.0),
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle: FontStyle.normal
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            TextFormField(
                                              controller: lastNameController,
                                              focusNode: lastNameFocus,
                                              onFieldSubmitted: (term) {
                                                lastNameFocus.unfocus();
                                                FocusScope.of(context).requestFocus(email1Focus);
                                              },
                                              validator: (value) {
                                                return validateString(value, lang == "en" ? lastNameEn : lastNameEs);
                                              },
                                              textCapitalization: TextCapitalization.sentences,
                                              textInputAction: TextInputAction.next,
                                              keyboardType: TextInputType.text,
                                              textAlign: TextAlign.start,
                                              decoration: InputDecoration(
                                                fillColor: AppColor.WHITE_COLOR,
                                                hintText: lang == "en" ? familyNameEn : familyNameEs,
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
                                                myState((){
                                                  setState(() {
                                                    _allCustomerFieldValidate = _customerFormKey.currentState.validate();
                                                  });
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      /***
                                       * Email
                                       */
                                      Container(
                                        width: MediaQuery.of(context).size.width,
                                        margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                        padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                        decoration: BoxDecoration(
                                            color: isEmail1Focus
                                                ? AppColor.THEME_PRIMARY.withOpacity(0.08)
                                                : AppColor.WHITE_COLOR,
                                            borderRadius: BorderRadius.circular(16.0)
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              lang == "en" ? emailOptionalEn : emailOptionalEs,
                                              style: TextStyle(
                                                  fontSize: TextSize.subjectTitle,
                                                  color: themeColor.withOpacity(1.0),
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle: FontStyle.normal
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            TextFormField(
                                              controller: email1Controller,
                                              focusNode: email1Focus,
                                              onFieldSubmitted: (term) {
                                                email1Focus.unfocus();
                                                FocusScope.of(context).requestFocus(phone1Focus);
                                              },
                                              textInputAction: TextInputAction.next,
                                              keyboardType: TextInputType.text,
                                              textAlign: TextAlign.start,
                                              decoration: InputDecoration(
                                                fillColor: AppColor.WHITE_COLOR,
                                                hintText: lang == "en" ? emailHintEn : emailHintEs,
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

                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      /***
                                       * Phone
                                       */
                                      Container(
                                        width: MediaQuery.of(context).size.width,
                                        margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                        padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                        decoration: BoxDecoration(
                                            color: isPhone1Focus
                                                ? AppColor.THEME_PRIMARY.withOpacity(0.08)
                                                : AppColor.WHITE_COLOR,
                                            borderRadius: BorderRadius.circular(16.0)
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              lang == "en" ? phoneOptionalEn : phoneOptionalEs,
                                              style: TextStyle(
                                                fontSize: TextSize.subjectTitle,
                                                color: themeColor.withOpacity(1.0),
                                                fontWeight: FontWeight.w600,
                                                fontStyle: FontStyle.normal,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            TextFormField(
                                              controller: phone1Controller,
                                              focusNode: phone1Focus,
                                              onFieldSubmitted: (term) {
                                                phone1Focus.unfocus();
                                              },
                                              textInputAction: TextInputAction.done,
                                              keyboardType: TextInputType.number,
                                              textAlign: TextAlign.start,
                                              decoration: InputDecoration(
                                                fillColor: AppColor.WHITE_COLOR,
                                                hintText: "(000) 000-0000",
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

                                              },
                                            ),
                                          ],
                                        ),
                                      ),

                                      /***
                                       * Remove Customer from inspection
                                       */
                                      GestureDetector(
                                        onTap: () async {
                                          setState(() {
                                            myState((){
                                              isLoaded = true;
                                            });
                                          });
                                          removeCustomerDetail(myState);
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context).size.width,
                                          margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                          padding: EdgeInsets.all(16.0),
                                          decoration: BoxDecoration(
                                              color: AppColor.WHITE_COLOR,
                                              borderRadius: BorderRadius.circular(16.0)
                                          ),
                                          child: Text(
                                            lang == "en" ? removeCustomerEn : removeCustomerEs,
                                            style: TextStyle(
                                              fontSize: TextSize.headerText,
                                              color: AppColor.RED_COLOR.withOpacity(1.0),
                                              fontWeight: FontWeight.w700,
                                              fontStyle: FontStyle.normal,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),

                                      SizedBox(
                                        height: 200,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SingleChildScrollView(
                    child: Container(
                      margin: EdgeInsets.only(top: 400.0),
                      color: isLoaded ? AppColor.GREY_COLOR.withOpacity(0.4) : AppColor.TRANSPARENT,
                      child: Visibility(
                        visible: isLoaded,
                        child: Container(
                          child: Center(
                            child: Container(
                              child: CircularProgressIndicator(
                                backgroundColor: AppColor.TRANSPARENT,
                                color: AppColor.THEME_PRIMARY,
                                strokeWidth: 5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              );
            },
          );
        }
    );
  }

  void formValidation(){
    setState(() {
      _allFieldValidate = (_formKey.currentState.validate());
    });
    print(_allFieldValidate);
  }

  void editFormValidation(){
    setState(() {
      _allEditFieldValidate = (_editFormKey.currentState.validate());
    });
    print("Hello====$_allEditFieldValidate");
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

  void updateProfileDetail(myState) async {
    // _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());

    var phoneList = [];
    var emailList = [];

    if(customerData != null) {
      if(customerData['email'] != null && customerData["email"].length > 0){
        if(email1Controller.text.toString().trim() != "") {
          emailList.add({
            "emailid": "${customerData['email'][0]['emailid']}",
            "email": "${email1Controller.text}",
            "emailtag": "Work",
            "clientemailpreferred": false
          });
        }
      } else {
        if(email1Controller.text.toString().trim() != "") {
          emailList.add({
            "email": "${email1Controller.text}",
            "emailtag": "Work",
            "clientemailpreferred": false
          });
        }
      }

      if(customerData['phone'] != null && customerData["phone"].length > 0){
        if(phone1Controller.text.toString().trim() != "") {
          emailList.add({
          "phoneid": "${customerData['phone'][0]['phoneid']}",
          "phoneno": "${phone1Controller.text}",
          "phonetag": "Work",
          "clientphonepreferred": false
          });
        }
      } else {
        if(phone1Controller.text.toString().trim() != "") {
          emailList.add({
            "phoneno": "${phone1Controller.text}",
            "phonetag": "Work",
            "clientphonepreferred": false
          });
        }
      }
    }

    var requestJson;
    if(firstNameController.text == ''){
      requestJson = {"lastname": "${lastNameController.text.toString().trim()}"};
    } else if(lastNameController.text == ''){
      requestJson = {"firstname": "${firstNameController.text.toString().trim()}"};
    } else {
      requestJson = {
        "firstname": "${firstNameController.text.toString().trim()}",
        "lastname": "${lastNameController.text.toString().trim()}",
        "email": emailList,
        "phone": phoneList
      };
    }
    var requestParam = json.encode(requestJson);
    var response = await request.patchRequest("auth/myclient/${customerData['clientid']}", requestParam);
    // _progressHUD.state.dismiss();

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage('${response['reason']}');
      } else {
        setState(() {
          myState((){
            customerData['firstname'] = firstNameController.text.toString().trim();
            customerData['lastname'] = lastNameController.text.toString().trim();
            isLoaded = false;
          });
        });
        Navigator.pop(context);
      }
    }
  }

  Future<void> removeCustomerDetail(myState) async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var response = await request.deleteAuthRequest("auth/myclient/${customerData['clientid']}");
    _progressHUD.state.dismiss();

    if (response != null) {
      if(response['success'] != null && response['success']){
        setState(() {
          myState((){
            isLoaded = true;
          });
        });
        int inspectionIndex = await InspectionPreferences.getInspectionId(InspectionPreferences.INSPECTION_INDEX);
        InspectionUtils.decrementIndex(inspectionIndex);
        Navigator.of(context).pop(true);
        Navigator.of(context).pop(true);
      } else {
        CustomToast.showToastMessage("Something Went Wrong!");
      }
    } else {
      CustomToast.showToastMessage("Something Went Wrong!");
    }
  }

  void setCircularProgress(bool result, myState) {
    setState(() {
      myState((){
        isLocationLoaded = result;
      });
    });
  }

  void setEditCircularProgress(bool result, myState) {
    setState(() {
      myState((){
        isEditLocationLoaded = result;
      });
    });
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
      });

      try {
        var stateData = {
          "payload": json.encode(response)
        };
        dbHelper.insertStateListData(stateData);
      } catch(e) {
        log("InsertStateDataError===$e");
      }
    }
  }

  Future stateListFromLocalDb() async {
    try{
      var response = await dbHelper.getStateListData();
      var resultList = response.toList();

      log("responseType===${resultList.runtimeType}");
      stateList.clear();

      if(resultList.length > 0) {
        setState(() {
          stateList.addAll(json.decode(resultList[0]['payload']));
        });
      }
    }catch(e) {
      log("templateListFromLocalDbStackTrace====$e");
    }
  }

  Future getStateListFromLocalDB() async {
    // try{
      var response = await dbHelper.fetchStateRecord();
      var resultList = response.toList();

      log("responseType===${resultList.runtimeType}");
      // log("response===$resultList");
      stateList.clear();

      if(resultList.length > 0) {
        setState(() {
          stateList = resultList;
        });
      }
    // }catch(e) {
    //   log("getStateListFromLocalDBStackTrace====$e");
    // }
  }

  List<InspectionModelData> _inspectionModelDataList = [];
  void bottomStatePicker(context, stateState){
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
                                          setState(() {
                                            myState((){
                                              stateState((){
                                                // stateData = stateList[index];
                                                // stateCode = stateData['abbr'];
                                                var stateLocalData = {
                                                  "label": stateList[index]['statename'],
                                                  "abbr": stateList[index]['statecode'],
                                                  "id": stateList[index]['stateid']
                                                };
                                                stateData = stateLocalData;
                                                stateCode = stateLocalData['abbr'];
                                              });
                                            });
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(vertical: 6),
                                          child: Text(
                                            // stateList[index]['label'],
                                            stateList[index]['statename'],
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

                            // FutureBuilder<List<InspectionModelData>>(
                            //   future: AllHttpRequest().getInspectionDataListFromAPI(),
                            //   builder: (context, snapshot) {
                            //     if(snapshot.hasError) {
                            //       return Text("Something went wrong!!!");
                            //     } else if(snapshot.hasData) {
                            //       return ListView.builder(
                            //         itemCount: snapshot.data.length,
                            //         itemBuilder: (context, index) {
                            //           return Text("${snapshot.data[index].inspectionid}");
                            //         }
                            //       );
                            //     }
                            //     return null;
                            //   },
                            // ),

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
