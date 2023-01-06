import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dottie_inspector/connection_mixin.dart';
import 'package:dottie_inspector/database/country_state_database_entry.dart';
import 'package:dottie_inspector/database/database_helper.dart';
import 'package:dottie_inspector/inspectionPreferences/inspection_preferences.dart';
import 'package:dottie_inspector/pages/backgroundServices/background_services.dart';
import 'package:dottie_inspector/pages/inspectionMain/inspection_adding_customer.dart';
import 'package:dottie_inspector/pages/menu/drawer_page.dart';
import 'package:dottie_inspector/pages/menu/index_menu.dart';
import 'package:dottie_inspector/pages/settings/settingContents/profile_edit_page.dart';
import 'package:dottie_inspector/pages/settings/setting_page.dart';
import 'package:dottie_inspector/pages/signInPages/login_page_1.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/SlideRightRoute.dart';
import 'package:dottie_inspector/utils/connectivity/my_connectivity.dart';
import 'package:dottie_inspector/utils/custom_toast.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:dottie_inspector/utils/globalInstance.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/utils/inspection_utils.dart';
import 'package:dottie_inspector/utils/language.dart';
import 'package:dottie_inspector/utils/lock_file.dart';
import 'package:dottie_inspector/utils/navigator/enum.dart';
import 'package:dottie_inspector/utils/navigator/slide_bottom_top.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:mapbox_search/mapbox_search.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:progress_hud/progress_hud.dart';

// Toggle this to cause an async error to be thrown during initialization
// and to test that runZonedGuarded() catches the error
const _kShouldTestAsyncErrorOnInit = false;

// Toggle this for testing Crashlytics in your app locally.
const _kTestingCrashlytics = true;

class WelcomeTemplateScreenPage extends StatefulWidget{
  static String tag = 'welcome-template-screen';
  @override
  _WelcomeTemplateScreenPageState createState() => _WelcomeTemplateScreenPageState();
}

class _WelcomeTemplateScreenPageState extends State<WelcomeTemplateScreenPage>  with MyConnection {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final dbHelper = DatabaseHelper.instance;

  // final MyConnectivity _connectivity = MyConnectivity.instance;

  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;
  String name = "";
  List inspectionList = [];
  var imagePath;
  var userImage;

  bool _isInternetAvailable = true;
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  String lang = "en";
  Future<void> _initializeFlutterFireFuture;

  bool isDarkMode = false;
  Color themeColor = AppColor.BLACK_COLOR;
  bool isIos = Platform.isIOS;

  int totalPendingIndex = 0;
  int totalPendingData = 0;
  static double percentValue = 0.0;
  var state;

  int customerCount = 0;
  int inspectionCount = 0;
  bool alreadyOpened = false;
  // final _lock = LockSynchronized.getLockInstance();

  @override
  void initState() {
    super.initState();

    // initPlatformState();
    _progressHUD = ProgressHUD(
      backgroundColor: Colors.transparent,
      color: Colors.white,
      containerColor: AppColor.LOADER_COLOR,
      borderRadius: 5.0,
      loading: _loading,
      text: 'Loading...',
    );

    ///Online Mode
    // Timer(Duration(milliseconds: 100), getProfileDetail);
    //     Timer(Duration(milliseconds: 100), fetchCountSimpleList);
    //     Timer(Duration(milliseconds: 200), sendPendingRequest);
    ///End

    ///Offline Mode
    // connectivity.initialise();
    // connectivity.myStream.listen((source) {
    //   setState(() {
    //     _isInternetAvailable = connectivity.getConnectivityResult(source);
    //   });
    //   if(connectivity.getConnectivityResult(source)) {
    //     getProfileDetail();
    //
    //     Timer(Duration(milliseconds: 100), fetchCountSimpleList);
    //     Timer(Duration(milliseconds: 200), sendPendingRequest);
    //   } else {
    //     loadProfileDetailFromLocalDb();
    //   }
    // });

    initConnectivity();

    ///End

    getPreferenceData();
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
        log("InternetConnectionStatus====$_isInternetAvailable");

        loadProfileDetailFromLocalDb();
      } else if ((_connectivityResult == ConnectivityResult.mobile) || (_connectivityResult == ConnectivityResult.wifi)) {
        _isInternetAvailable = true;
        log("InternetConnectionStatus====$_isInternetAvailable");
        getProfileDetail();

        Timer(Duration(milliseconds: 100), fetchCountSimpleList);
        Timer(Duration(milliseconds: 200), sendPendingRequest);
        Timer(Duration(milliseconds: 200), getInspectionCount);
        Timer(Duration(milliseconds: 200), getCustomerCount);
      }
    });
  }

  void getPreferenceData() async {

    var language = await PreferenceHelper.getPreferenceData(PreferenceHelper.LANGUAGE) ?? "en";
    var firstName = await PreferenceHelper.getPreferenceData(PreferenceHelper.FIRST_NAME) ?? "";
    var userAvatar = await PreferenceHelper.getPreferenceData(PreferenceHelper.USER_AVATAR) ?? "";

    var templateListData = await PreferenceHelper.getPreferenceData(PreferenceHelper.TEMPLATE_LIST);
    var transformedData = templateListData == null ? [] : json.decode(templateListData);

    setState(() {
      lang = language;
      name = firstName;
      userImage = userAvatar;
      inspectionList = transformedData;
    });

    log("userImage====$userImage");
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

    CountryStateListEntry.insertCountryDataIntoLocalDB();
    CountryStateListEntry.insertStateDataIntoLocalDB();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _connectivitySubscription?.cancel();
    // connectivity.disposeStream();
    super.dispose();
  }

  void sendPendingRequest() async {
    try{
      // _progressHUD.state.show();
      // openProgressDialog();
      var customerList = await dbHelper.getCustomerGeneralData();
      var serviceAddressList = await dbHelper.getServiceGeneralData();
      var locationImageList = await dbHelper.getLocationImageData();
      var inspectionIdList = await dbHelper.getInspectionIdData();
      var pendingList = await dbHelper.getAllPendingEndPoints();
      var bodyOfWaterList = await dbHelper.getPendingBodyOfWaterData();
      var vesselList = await dbHelper.getAllPendingVesselData();
      var equipmentList = await dbHelper.getAllPendingEquipmentData();
      var deleteAnswerList = await dbHelper.getAllDeleteAnswerData();

      final _lock = LockSynchronized.getLockInstance();
      // print("PENDING LIST====${pendingList.toList()}");
      // int totalPendingData = (pendingList != null ? pendingList.toList().length : 0)
      //     + (bodyOfWaterList != null ? bodyOfWaterList.toList().length : 0)
      //     + (vesselList != null ? vesselList.toList().length : 0)
      //     + (equipmentList != null ? equipmentList.toList().length : 0) ;

      for(int i=0; i<customerList.length; i++) {
        if("${customerList[i]['iscustomerserverid']}" == "0"){
          var response = await _lock.synchronized(() => BackgroundServices.sendInspectionIdData(customerList[i]['payload'], customerList[i]['url']));

          if(response != null) {
            if (response['success']!=null && !response['success']) {
              print('${response['reason']}');
            } else {
              await dbHelper.updateCustomerGeneralDataRecord(
                  customerList[i]['customerlocalid'],
                  "${response['clientid']}");

              PreferenceHelper.setPreferenceData(PreferenceHelper.CLIENT_ID, "${response['clientid']}");
            }
          }
        }
      }

      for(int i=0; i<serviceAddressList.length; i++) {
        if("${serviceAddressList[i]['isserviceserverid']}" == "0") {
          var clientId = serviceAddressList[i]['customerlocalid'];
          var endPoint = serviceAddressList[i]['url'];

          clientId = clientId == "" || clientId == "null" ? 0 : clientId;

          var fetchClientId = await dbHelper.getSingleCustomerGeneralRecord(clientId);
          if(fetchClientId != null && fetchClientId.toList().length > 0) {
            endPoint = endPoint.toString().replaceAll("{{clientid}}", "${fetchClientId[0]['customerserverid']}");
          }

          var response = await _lock.synchronized(() => BackgroundServices.sendInspectionIdData(serviceAddressList[i]['payload'], endPoint));

          if(response != null) {
            if (response['success']!=null && !response['success']) {
              print('${response['reason']}');
            } else {
              await dbHelper.updateServiceGeneralDataRecord(
                  serviceAddressList[i]['servicelocalid'],
                  "${response['addressid']}");

              PreferenceHelper.setPreferenceData(PreferenceHelper.LOCATION_ID, "${response['addressid']}");
            }
          }
        }
      }

      for(int i=0; i<locationImageList.length; i++) {
        var addressId = locationImageList[i]['servicelocalid'];
        var clientId = locationImageList[i]['customerlocalid'];
        var endPoint = locationImageList[i]['url'];
        var imagePath = locationImageList[i]['imagepath'];

        addressId = addressId == "" || addressId == "null" ? 0 : addressId;
        clientId = clientId == "" || clientId == "null" ? 0 : clientId;

        var fetchClientId = await dbHelper.getSingleCustomerGeneralRecord(clientId);
        if(fetchClientId != null && fetchClientId.toList().length > 0) {
          endPoint = endPoint.toString().replaceAll("{{clientid}}", "${fetchClientId[0]['customerserverid']}");
        }

        var fetchServiceAddressId = await dbHelper.getSingleServiceGeneralRecord(addressId);
        if(fetchServiceAddressId != null && fetchServiceAddressId.toList().length > 0) {
          endPoint = endPoint.toString().replaceAll("{{serviceid}}", "${fetchServiceAddressId[0]['serviceserverid']}");
        }

        var response = await _lock.synchronized(() => BackgroundServices.uploadOnlyResourceRecord(endPoint, imagePath));

        if(response != null) {
          if (response['success']!=null && !response['success']) {
            print('${response['reason']}');
          } /*else {
            await dbHelper.updateServiceGeneralDataRecord(
                serviceAddressList[i]['servicelocalid'],
                "${response['addressid']}");

            PreferenceHelper.setPreferenceData(PreferenceHelper.LOCATION_ID, "${response['addressid']}");
          }*/
        }
      }

      for(int i=0; i<inspectionIdList.length; i++) {
        if("${inspectionIdList[i]['isinspectionserverid']}" == "0") {
          var addressId = inspectionIdList[i]['servicelocalid'];
          var payload = inspectionIdList[i]['payload'];

          addressId = addressId == "" || addressId == "null" ? 0 : addressId;
          print("AddressId===$addressId");

          var fetchServiceAddressId = await dbHelper.getSingleServiceGeneralRecord(addressId);
          log("ServiceAddressRecord===$fetchServiceAddressId");
          if(fetchServiceAddressId != null && fetchServiceAddressId.toList().length > 0) {
            payload = payload.toString().replaceAll("{{serviceid}}", "${fetchServiceAddressId[0]['serviceserverid']}");
            log("payload===$payload");
          }

          var response = await _lock.synchronized(() => BackgroundServices.sendInspectionIdData(payload, inspectionIdList[i]['url']));

          if(response != null) {
            if (response['success']!=null && !response['success']) {
              print('${response['reason']}');
            } else {
              await dbHelper.updateInspectionIdDataRecord(
                  inspectionIdList[i]['inspectionlocalid'],
                  "${response['inspectionid']}");
            }
          }
        }
      }

      for(int j=0; j<bodyOfWaterList.toList().length; j++) {
        log("BodyOfWaterEndPoint====${bodyOfWaterList[j]['url']}");
        var addressId = bodyOfWaterList[j]['servicelocalid'];
        var clientId = bodyOfWaterList[j]['customerlocalid'];
        var endPoint = bodyOfWaterList[j]['url'];

        addressId = addressId == "" || addressId == "null" ? 0 : addressId;
        clientId = clientId == "" || clientId == "null" ? 0 : clientId;

        var fetchClientId = await dbHelper.getSingleCustomerGeneralRecord(clientId);
        if(fetchClientId != null && fetchClientId.toList().length > 0) {
          endPoint = endPoint.toString().replaceAll("{{clientid}}", "${fetchClientId[0]['customerserverid']}");
        }

        var fetchServiceAddressId = await dbHelper.getSingleServiceGeneralRecord(addressId);
        if(fetchServiceAddressId != null && fetchServiceAddressId.toList().length > 0) {
          endPoint = endPoint.toString().replaceAll("{{serviceid}}", "${fetchServiceAddressId[0]['serviceserverid']}");
        }

        var response = await _lock.synchronized(() => BackgroundServices.sendPendingVesselBodyEquipmentData(bodyOfWaterList[j]['payload'], endPoint));

        // var response = 123;
        if(response != null){
          if (response['success']!=null && !response['success']) {
            print('${response['reason']}');
          } else {
            await dbHelper.updateBodyOfWaterRecord(
                bodyOfWaterList[j]['bodyofwateridlocal'],
                "${response['bodyofwaterid']}");
          }

          // await dbHelper.updateBodyOfWaterRecord(
          //     bodyOfWaterList[j]['bodyofwateridlocal'],
          //     "$response");
        }
      }

      for(int k=0; k<vesselList.toList().length; k++) {
        try {
          var bodyofwaterid = vesselList[k]['bodyofwaterid'] ?? 0;
          var payload = vesselList[k]['payload'];
          var endPoint = vesselList[k]['url'];

          var addressId = vesselList[k]['servicelocalid'];
          var clientId = vesselList[k]['customerlocalid'];

          bodyofwaterid = bodyofwaterid == "" || bodyofwaterid == "null" ? 0 : bodyofwaterid;
          addressId = addressId == "" || addressId == "null" ? 0 : addressId;
          clientId = clientId == "" || clientId == "null" ? 0 : clientId;

          var fetchBodyOfWaterRecord = await dbHelper.getSingleBodyOfWaterRecord(bodyofwaterid);
          if (fetchBodyOfWaterRecord != null && fetchBodyOfWaterRecord.toList().length > 0) {
            endPoint = endPoint.toString().replaceAll("{{bodyofwaterid}}", "${fetchBodyOfWaterRecord[0]['bodyofwaterid']}");
          }

          var fetchClientId = await dbHelper.getSingleCustomerGeneralRecord(clientId);
          if(fetchClientId != null && fetchClientId.toList().length > 0) {
            endPoint = endPoint.toString().replaceAll("{{clientid}}", "${fetchClientId[0]['customerserverid']}");
          }

          var fetchServiceAddressId = await dbHelper.getSingleServiceGeneralRecord(addressId);
          if(fetchServiceAddressId != null && fetchServiceAddressId.toList().length > 0) {
            endPoint = endPoint.toString().replaceAll("{{serviceid}}", "${fetchServiceAddressId[0]['serviceserverid']}");
          }

          var vesselResponse = await _lock.synchronized(() => BackgroundServices.sendPendingVesselBodyEquipmentData(payload, endPoint));

          if(vesselResponse != null){
            if (vesselResponse['success']!=null && !vesselResponse['success']) {
              print('${vesselResponse['reason']}');
            } else {
              await dbHelper.updateVesselRecord(
                  vesselList[k]['vesselidlocal'],
                  "${vesselResponse['vesselid']}");
            }
          }
        } catch(e) {
          log("VesselRecordIssue===$e");
        }
      }

      for(int x=0; x<equipmentList.toList().length; x++) {
        var vesselid = equipmentList[x]['vesselid'] ?? 0;
        var payload = equipmentList[x]['payload'];
        var endPoint = equipmentList[x]['url'];
        var addressId = equipmentList[x]['servicelocalid'];
        var clientId = equipmentList[x]['customerlocalid'];

        vesselid = vesselid == "" || vesselid == "null" ? 0 : vesselid;
        addressId = addressId == "" || addressId == "null" ? 0 : addressId;
        clientId = clientId == "" || clientId == "null" ? 0 : clientId;

        log("ClientId====$clientId&&AddressId===$addressId");
        var fetchVesselRecord = await dbHelper.getSingleVesselRecord(vesselid);
        if(fetchVesselRecord != null && fetchVesselRecord.toList().length > 0) {
          try {
            var payloadData = Map<String,dynamic>.of(json.decode(payload));
            var vesselData = [];
            for(int m=0; m<payloadData['vessel'].toList().length; m++) {
              vesselData.add(payloadData['vessel'][m].toString().replaceAll("{{vesselid}}", "${fetchVesselRecord[0]['vesselid']}"));
            }
            payloadData['vessel'] = vesselData;

            payload = json.encode(payloadData);
          } catch(e) {
            log("PayloadIssue====$e");
          }
        }

        var fetchClientId = await dbHelper.getSingleCustomerGeneralRecord(clientId);
        if(fetchClientId != null && fetchClientId.toList().length > 0) {
          endPoint = endPoint.toString().replaceAll("{{clientid}}", "${fetchClientId[0]['customerserverid']}");
        }

        var fetchServiceAddressId = await dbHelper.getSingleServiceGeneralRecord(addressId);
        if(fetchServiceAddressId != null && fetchServiceAddressId.toList().length > 0) {
          endPoint = endPoint.toString().replaceAll("{{serviceid}}", "${fetchServiceAddressId[0]['serviceserverid']}");
        }

        log("EndPoint===$endPoint");
        var equipmentResponse = await _lock.synchronized(() => BackgroundServices.sendPendingVesselBodyEquipmentData(payload, endPoint));

        if(equipmentResponse != null){
          if (equipmentResponse['success']!=null && !equipmentResponse['success']) {
            print('${equipmentResponse['reason']}');
          } else {
            await dbHelper.updateEquipmentRecord(
                equipmentList[x]['equipmentidlocal'],
                "${equipmentResponse['equipmentid']}");
          }
        }
      }
      var response;

      for(int y=0; y<pendingList.toList().length; y++) {
        try{
          var vesselid = pendingList[y]['vesselid'] ?? 0;
          var equipmentid = pendingList[y]['equipmentid'] ?? 0;
          var bodyofwaterid = pendingList[y]['bodyofwaterid'] ?? 0;
          var endPoint = pendingList[y]['url'];
          var inspectionId = pendingList[y]['inspectionid'];

          vesselid = vesselid == "" || vesselid == "null" ? 0 : vesselid;
          equipmentid = equipmentid == "" || equipmentid == "null" ? 0 : equipmentid;
          bodyofwaterid = bodyofwaterid == "" || bodyofwaterid == "null" ? 0 : bodyofwaterid;
          inspectionId = inspectionId == "" || inspectionId == "null" ? 0 : inspectionId;
          var inspectionServerId = 0;

          var fetchInspectionId = await dbHelper.getSingleInspectionIdRecord(inspectionId);
          if(fetchInspectionId != null && fetchInspectionId.toList().length > 0) {
            inspectionServerId = fetchInspectionId[0]['inspectionserverid'] ?? 0;
            endPoint = endPoint.toString().replaceAll("{{inspectionid}}", "${fetchInspectionId[0]['inspectionserverid']}");
          } else {
            endPoint = endPoint.toString().replaceAll("{{inspectionid}}", "$inspectionId");
          }

          var fetchBodyOfWaterRecord = await dbHelper.getSingleBodyOfWaterRecord(bodyofwaterid);
          if(fetchBodyOfWaterRecord != null && fetchBodyOfWaterRecord.toList().length > 0) {
            endPoint = endPoint.toString().replaceAll("{{bodyofwaterid}}", "${fetchBodyOfWaterRecord[0]['bodyofwaterid']}");
          }

          var fetchVesselRecord = await dbHelper.getSingleVesselRecord(vesselid);
          if(fetchVesselRecord != null && fetchVesselRecord.toList().length > 0) {
            endPoint = endPoint.toString().replaceAll("{{vesselid}}", "${fetchVesselRecord[0]['vesselid']}");
          }

          var fetchEquipmentRecord = await dbHelper.getSingleEquipmentRecord(equipmentid);
          if(fetchEquipmentRecord != null && fetchEquipmentRecord.toList().length > 0) {
            endPoint = endPoint.toString().replaceAll("{{equipmentid}}", "${fetchEquipmentRecord[0]['equipmentid']}");
          }

          endPoint = endPoint.toString().replaceAll("{{inspectionid}}", "$inspectionServerId");

          response = await _lock.synchronized(() => BackgroundServices.sendPendingRequestToServer(pendingList[y], endPoint));

        } catch(e) {
          log("PendingRecord====$e");
        }
      }

      for(int j=0; j<deleteAnswerList.toList().length; j++) {
        var inspectionId = deleteAnswerList[j]['inspectionid'];

        var inspectionServerId = 0;

        var fetchInspectionId = await dbHelper.getSingleInspectionIdRecord(inspectionId);
        if(fetchInspectionId != null && fetchInspectionId.toList().length > 0) {
          inspectionServerId = fetchInspectionId[0]['inspectionserverid'] ?? 0;
        }

        var response = await _lock.synchronized(() => BackgroundServices.sendDeleteAnswerData(inspectionServerId, deleteAnswerList[j]['answerid']));

        if(response != null){
          if (response['success']!=null && !response['success']) {
            print('${response['reason']}');
          } else {
            await dbHelper.deleteAnswerRequestWithId(deleteAnswerList[j]['answerid']);
          }
        }
      }

      print("Uploading Done");
      var pendingListData = await dbHelper.getAllPendingEndPoints();

      if(pendingListData.toList().length == 0) {
        await dbHelper.deleteBodyOfWaterData();
        await dbHelper.deleteVesselsData();
        await dbHelper.deleteEquipmentsData();
        await dbHelper.deleteDeleteAnswerTableData();
        await dbHelper.deleteAnswerTableData();
        await dbHelper.deleteInspectionIdTableData();
        await dbHelper.deleteLocationImageTableData();
        await dbHelper.deleteCustomerGeneralTableData();
        await dbHelper.deleteServiceGeneralTableData();
      }
        // _progressHUD.state.dismiss();
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => WelcomeNewScreenPage(),
        //   ),
        //   ModalRoute.withName(WelcomeNewScreenPage.tag),
        // );
    }catch (e){
      print("StackTraceSendPendingRequest===$e");
    }
  }

  bool isLoaderVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode ? AppColor.BLACK_COLOR : AppColor.PAGE_COLOR,
      appBar: EmptyAppBar(isDarkMode: isDarkMode),
      drawer: Drawer(
        child: DrawerPage(),
      ),
      body: WillPopScope(
        onWillPop: () async {
          PreferenceHelper.clearPreferenceData(PreferenceHelper.WATER_VESSEL_BODIES);
          PreferenceHelper.clearPreferenceData(PreferenceHelper.WATER_VESSEL_BODIES_ITEM);
          PreferenceHelper.clearPreferenceData(PreferenceHelper.WATER_SELECTED_BODIES);
          PreferenceHelper.clearPreferenceData(PreferenceHelper.EQUIPMENT_ITEMS);
          PreferenceHelper.clearPreferenceData(PreferenceHelper.ANSWER_LIST);
          PreferenceHelper.clearPreferenceData(PreferenceHelper.TEMPLATE_LIST);

          return true;
        },
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () async {
                           _scaffoldKey.currentState.openDrawer();
                          ///
                          ///
                          ///

                          //  syncInspectionRecord();
                           // await dbHelper.getSingleTemplateData("14825");
                           // await dbHelper.getAllTemplateData();
                          // HelperClass.printDatabaseResult();
                           // dbHelper.getTableSchema();

                           // await dbHelper.deleteBodyOfWaterData();
                           // await dbHelper.deleteVesselsData();
                           // await dbHelper.deleteEquipmentsData();
                           // await dbHelper.deleteDeleteAnswerTableData();
                           // await dbHelper.deleteAnswerTableData();
                           // await dbHelper.deleteInspectionIdTableData();
                           // await dbHelper.deleteLocationImageTableData();
                           // await dbHelper.deleteCustomerGeneralTableData();
                           // await dbHelper.deleteServiceGeneralTableData();
                           // await dbHelper.deleteAllPendingRequest();

                          // var formatter = DateFormat('dd-MM-yyyy HH:mm:ss');
                          // String formatted = formatter.format(DateTime.parse("2022-12-28T19:26:27Z"));
                          // String formatted1 = formatter.format(DateTime.parse("2022-12-28T19:28:27Z"));
                          // log("Formatted Date===$formatted");
                          // log("Formatted Date===$formatted1");
                          // DateTime date1 = DateTime.parse("2022-12-28T19:26:27Z");
                          // DateTime date2 = DateTime.parse("2022-12-28T19:28:27Z");

                          // log("Correct===${date1==date2}");
                        },
                        child: Container(
                          child: Image.asset(
                            'assets/ic_menu.png',
                            fit: BoxFit.cover,
                            width: 44,
                            height: 44,
                            color: themeColor,
                          ),
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: 44,
                          maxWidth: 44
                        ),
                        child: userImage != null && _isInternetAvailable
                            ? GestureDetector(
                              onTap: (){
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    child: SettingPage(),
                                    type: PageTransitionType.bottomToTop,
                                    duration: Duration(milliseconds: 500),
                                  )
                                );
                              },
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(22.0),
                                  child: Image.network(
                                    "${GlobalInstance.apiBaseUrl}$userImage",
                                    fit: BoxFit.fill,
                                    width: 44,
                                    height: 44,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      } else {
                                        return Container(
                                          height: (MediaQuery.of(context).size.width -
                                              32),
                                          color: AppColor.WHITE_COLOR,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes
                                                  : null,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                            )
                            : GestureDetector(
                              onTap: () async {
                                Navigator.push(
                                    context,
                                    PageTransition(
                                      child: SettingPage(),
                                      type: PageTransitionType.bottomToTop,
                                      duration: Duration(milliseconds: 500),
                                    )
                                );

                              },
                              child: Container(
                                  child: Image.asset(
                                    'assets/settings/ic_setting_logo.png',
                                    fit: BoxFit.cover,
                                    width: 44,
                                    height: 44,
                                  ),
                                ),
                            ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 8.0,
                        ),
                        //Title
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () async {
                                // await dbHelper.deleteAllTableData("answer");
                                // await dbHelper.deleteAllTableData("pending");
                                // HelperClass.printDatabaseResult();
                                // try {
                                //   throw 'error_example';
                                // } catch (e, s) {
                                //   FirebaseCrashlytics.instance.recordError(e, s, reason: "error example");
                                // }

                                // FirebaseCrashlytics.instance.crash();
                                // await dbHelper.deleteSimpleListTable();
                                try {
                                  // await dbHelper.getSelectedSimpleList("204");
                                  // await dbHelper.getNSingleSimpleList();

                                  // await db.getCheckSingleSimpleList();
                                  // await dbHelper.getSelectedSimpleList("615");
                                  // await dbHelper.getNSingleSimpleList();

                                  // await dbHelper.deleteBodyOfWaterData();
                                  // await dbHelper.deleteVesselsData();
                                  // await dbHelper.deleteEquipmentsData();
                                  // await dbHelper.deleteSimpleListTable();
                                  //
                                  // dbHelper.getAllPendingEndPoints();
                                  // dbHelper.getAllPendingVesselData();
                                  // dbHelper.getAllPendingEquipmentData();
                                  // fetchCountSimpleList();
                                } catch(e) {
                                  log("StackTrace====$e");
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 24.0),
                                child: Text(
                                  lang == "en" ? welcomeTitleEn : welcomeTitleEs,
                                  style: TextStyle(
                                    fontSize: TextSize.greetingTitleText,
                                    color: themeColor,
                                    fontWeight: FontWeight.w700,
                                    fontStyle: FontStyle.normal,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ),

                            ///Sync Now Start
                            // GestureDetector(
                            //   onTap: (){
                            //     if(_isInternetAvailable) {
                            //       openProgressDialog();
                            //       totalPendingData = inspectionList.length;
                            //       totalPendingIndex = inspectionList.length - 1;
                            //       for(int i=0; i<inspectionList.length; i++) {
                            //         insertTemplateDetailIntoLocalDB(inspectionList[i]['inspectiondefid']);
                            //       }
                            //     } else {
                            //       HelperClass.showSnackBar(context, "Please check your internet connection");
                            //     }
                            //   },
                            //   child: Container(
                            //       margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                            //     child: GradientText(
                            //       "Sync Now",
                            //       gradient: LinearGradient(
                            //           colors: AppColor.gradientColor(1.0)
                            //       ),
                            //       style: TextStyle(
                            //         fontSize: TextSize.bodyText,
                            //         fontWeight: FontWeight.w700,
                            //         fontStyle: FontStyle.normal,
                            //         decoration: TextDecoration.underline
                            //       ),
                            //     ),
                            //   ),
                            // ),

                            /// Sync Now End
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 24.0, vertical: 8.0),
                          padding: EdgeInsets.symmetric(horizontal: 0.0),
                          child: Text(
                            lang == "en" ? welcomeSubTitleEn : welcomeSubTitleEs,
                            style: TextStyle(
                              fontSize: TextSize.subjectTitle,
                              color: themeColor,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),


                        /*******************************
                         * Background service testing
                         * Start
                         *******************************/
/***

                        InkWell(
                          onTap: () async {
                            try {
                              // var simplelistid = "317";
                              // var requestJson = {"answer": ""};
                              //
                              //  var result = await dbHelper.insertPendingUrl({
                              //   "url": "auth/inspection/1353/743/item/$simplelistid",
                              //   "verb": "POST",
                              //   "payload": json.encode(requestJson),
                              //   "imagepath": '',
                              //   "noteimagepath": ''
                              // });
                              //
                              //
                              // print("Result ==== $result");

                              // HelperClass.callbackDispatcher();
                              // print("Result ==== $result");
                              //
                              await dbHelper.deleteAllTableData("answer");
                              await dbHelper.deleteAllTableData("pending");

                              var pendingList = await dbHelper.getAllPendingEndPoints();

                              log("PENDING LIST====${pendingList.toList()}");
                              log("TYPE=====${pendingList.runtimeType}");
                              // if(pendingList != null) {
                              //   for (int i = 0; i < pendingList.toList().length; i++) {
                              //     await BackgroundServices.sendPendingRequestToServer(pendingList[i]);
                              //   }
                              // }
                              log(AllHttpRequest.apiUrl);
                              // await Workmanager().cancelAll();
                              print('Cancel all tasks completed');
                            } catch (e){
                              log("StackTrace====$e");
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            color: AppColor.THEME_PRIMARY,
                            child: Text(
                              'Delete Request',
                              style: TextStyle(
                                  fontSize: TextSize.subjectTitle,
                                  color: AppColor.WHITE_COLOR,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: "WorkSans"),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),

                        InkWell(
                          onTap: () async {
                            try {
                              Workmanager().cancelAll();
                            } catch (e){
                              log("StackTrace====$e");
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            color: AppColor.THEME_PRIMARY,
                            child: Text(
                              'Cancel Work Manager',
                              style: TextStyle(
                                  fontSize: TextSize.subjectTitle,
                                  color: AppColor.WHITE_COLOR,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: "WorkSans"),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),

                        InkWell(
                          onTap: () async {
                            try {
                              // var result = await dbHelper.insertPendingUrl({
                              //   "url": "https://www.getmydottie.com/api/request",
                              //   "verb": "POST",
                              //   "payload": "request parameter",
                              //   "imagepath": "ImagePath"
                              // });
                              // print("Result ==== $result");

                              sendPendingRequest();
                            } catch (e){
                              log("StackTrace====$e");
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            color: AppColor.THEME_PRIMARY,
                            child: Text(
                              'Send Request',
                              style: TextStyle(
                                  fontSize: TextSize.subjectTitle,
                                  color: AppColor.WHITE_COLOR,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: "WorkSans"),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),

                        InkWell(
                          onTap: () async {
                            try{
                              // var pendingList = await dbHelper.getAllPendingEndPoints();
                              //
                              // const JsonEncoder encoder = JsonEncoder.withIndent('  ');
                              //
                              // log("PENDING LIST====>>>>(${encoder.convert(pendingList)})}");
                              // // log("PENDING LIST====${pendingList.toList()}");
                              // print("TYPE=====${pendingList.runtimeType}");
                              // print("PENDING LIST====${pendingList.toList()}");
                              // print("LENGTH=====${pendingList.toList().length}");

                              final dbHelper = DatabaseHelper.instance;
                              print("sendPendingRequest=>Main Call()");

                              var pendingList = await dbHelper.getAllPendingEndPoints();
                              const JsonEncoder encoder = JsonEncoder.withIndent('  ');

                              log("PENDING LIST====>>>>(${encoder.convert(pendingList)})}");

                            }catch (e){
                              print("StackTrace===$e");
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            color: AppColor.THEME_PRIMARY,
                            child: Text(
                              'Get All Request',
                              style: TextStyle(
                                  fontSize: TextSize.subjectTitle,
                                  color: AppColor.WHITE_COLOR,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: "WorkSans"),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
***/
                        /*******************************
                         * Background service testing
                         * End
                         *******************************/

                        Visibility(
                          visible: !_isInternetAvailable,
                          child: Container(
                            margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0),
                            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: AppColor.DIVIDER, borderRadius: BorderRadius.all(Radius.circular(32.0))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(right: 16.0),
                                        child: Image.asset(
                                          'assets/welcome/ic_no_internet_connection.png',
                                          fit: BoxFit.cover,
                                          height: 56.0,
                                          width: 56.0,
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: Text(
                                            'No Internet\nConnection',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: AppColor.BLACK_COLOR,
                                              fontWeight: FontWeight.w700,
                                              fontStyle: FontStyle.normal,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 16.0),
                                        child: Image.asset(
                                          'assets/welcome/ic_close_internet.png',
                                          fit: BoxFit.cover,
                                          height: 40.0,
                                          width: 40.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 16,
                                ),

                                Container(
                                  child: Text(
                                    'When you’re back online, make your inspections available offline, so you can get to them anytime.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColor.BLACK_COLOR,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FontStyle.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        ListView.builder(
                          itemCount: inspectionList != null ? inspectionList.length : 0,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            if (inspectionList[index]['disabled'] != null && inspectionList[index]['disabled']) {
                              return Container();
                            } else {
                              var inspectionListData = inspectionList[index]['txt'][lang] ?? inspectionList[index]['txt']['en'];
                              return Container(
                                margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0),
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(32.0))),
                                height: 180,
                                child: Stack(
                                  fit: StackFit.expand,
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(32.0)),
                                          gradient: LinearGradient(
                                            colors: (index+1) % 3 == 0
                                            ? [Color(0xff764BA2), Color(0xff667EEA)]
                                            : (index+1) % 2 == 0
                                            ? [Color(0xffA8BDFD), Color(0xff884E82)]
                                            : [Color(0xff63DFFF), Color(0xff8B86D6)],
                                          )
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(32.0))),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(32.0),
                                        child: Image.asset(
                                          index % 3 == 0
                                              ? 'assets/welcome/ic_welcome_background1.png'
                                              : index % 2 == 0
                                                  ? 'assets/welcome/ic_welcome_background2.png'
                                                  : 'assets/welcome/ic_welcome_background3.png',
                                          fit: BoxFit.fill,
                                          // height: 64.0,
                                          // width: 64.0,
                                        ),
                                      ),
                                    ),


                                    // Container(
                                    //   decoration: BoxDecoration(
                                    //       borderRadius: BorderRadius.all(Radius.circular(32.0))),
                                    //   child: ClipRRect(
                                    //     borderRadius: BorderRadius.circular(32.0),
                                    //     child: Image.asset(
                                    //       'assets/welcome/welcome_bg.png',
                                    //       fit: BoxFit.fill,
                                    //       height: 64.0,
                                    //       width: 64.0,
                                    //     ),
                                    //   ),
                                    // ),
                                    Positioned(
                                      top: 16,
                                      bottom: 16,
                                      left: 16,
                                      right: 16,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      child: Text(
                                                        '${inspectionListData['title']}',
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          color: AppColor.BLACK_COLOR,
                                                          fontWeight: FontWeight.w700,
                                                          fontStyle: FontStyle.normal,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: 24.0),
                                                    child: Image.asset(
                                                      'assets/complete_inspection/ic_inspection_icon.png',
                                                      fit: BoxFit.cover,
                                                      height: 48.0,
                                                      width: 48.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 40,
                                          ),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              InkWell(
                                                onTap: () async {
                                                  try {
                                                    var inspectionName =
                                                        "${inspectionListData['title']}";
                                                    PreferenceHelper
                                                        .setPreferenceData(
                                                            PreferenceHelper
                                                                .INSPECTION_NAME,
                                                            "$inspectionName");

                                                    print("InspectionName===>>>$inspectionName");
                                                  } catch (e) {
                                                    print("LocationNameNotFoundException====>>>>$e");
                                                  }

                                                  var simpleListItems = await dbHelper.getSingleSimpleList();
                                                  var resultList = simpleListItems.toList();

                                                  if(resultList.length > 0) {
                                                    if (_isInternetAvailable) {
                                                      getInspectionDetail(inspectionList[index]['inspectiondefid'], inspectionList[index]['lastUpdated']);
                                                    } else {
                                                      loadTemplateDetailFromLocalDb(inspectionList[index]['inspectiondefid']);
                                                    }
                                                  } else {
                                                    HelperClass.displayDialog(context, "Please check your internet connection");
                                                  }
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                                  decoration: BoxDecoration(
                                                      // gradient:
                                                      //     LinearGradient(colors: [
                                                      //   Color(0xff013399),
                                                      //   Color(0xffBC96E6),
                                                      // ]),
                                                    color: Colors.black,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  16.0))),
                                                  child: Center(
                                                    child: Text(
                                                      lang == "en"
                                                          ? startEn
                                                          : startEs,
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        color:
                                                            AppColor.WHITE_COLOR,
                                                        fontSize:
                                                            TextSize.bodyText,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontStyle:
                                                            FontStyle.normal,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              ClipRRect(
                                                child: Image.asset(
                                                  inspectionList[index]['isCached'] ?? false
                                                      ? "assets/welcome/ic_online_download.png"
                                                      : "assets/welcome/ic_offline_download.png",
                                                  height: 40,
                                                  width: 40,
                                                ),
                                                borderRadius: BorderRadius.all(Radius.circular(22)),
                                              ),
                                              // Container(
                                              //   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              //   decoration: BoxDecoration(
                                              //       color: Color(0xffE5E5E5),
                                              //       borderRadius: BorderRadius.all(Radius.circular(16.0))),
                                              //   child: Center(
                                              //     child: Text(
                                              //       inspectionList[index]['accessname'] == "Basic Safety"
                                              //           ? lang == "en"
                                              //               ? basicEn
                                              //               : basicEs
                                              //           : '${inspectionList[index]['accessname']}',
                                              //       textAlign: TextAlign.center,
                                              //       style: TextStyle(
                                              //         color: Color(0xff808080),
                                              //         fontSize: 12,
                                              //         fontWeight: FontWeight.w700,
                                              //         fontStyle: FontStyle.normal,
                                              //       ),
                                              //     ),
                                              //   ),
                                              // ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    Visibility(
                                      visible: !_isInternetAvailable && !inspectionList[index]['isCached'] ?? false,
                                      child: Container(
                                        // margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0),
                                        width: MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          color: AppColor.GREY_COLOR.withOpacity(0.45),
                                            borderRadius: BorderRadius.all(Radius.circular(32.0))),
                                        height: 180,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return Container(
                              margin: EdgeInsets.only(
                                  left: 16.0, right: 16.0, top: 32.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 180.0,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(32.0),
                                            bottomRight: Radius.circular(32.0))),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          bottom: -10.0,
                                          right: 0.0,
                                          left: 0.0,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(32.0),
                                              topRight: Radius.circular(32.0),
                                            ),
                                            child: Image.asset(
                                              "assets/ic_welcome_bg.png",
                                              height: 180.0,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: Image.asset(
                                            "assets/ic__welcome_pool.png",
                                            height: 80.0,
                                            width: 80.0,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: AppColor.ACCENT_COLOR
                                            .withOpacity(0.12),
//                        color: Colors.yellowAccent.shade400,
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(32.0),
                                          bottomRight: Radius.circular(32.0),
                                        )),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 0.0,
                                        ),
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 36.0, vertical: 16.0),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${inspectionList[index]['txt']['en']['title']}',
                                            style: TextStyle(
                                                fontSize: 24,
                                                color: AppColor.ACCENT_COLOR,
                                                fontWeight: FontWeight.w600,
                                                fontStyle: FontStyle.normal,
                                                fontFamily: "WorkSans"),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 36.0),
                                          alignment: Alignment.center,
                                          child: Text(
                                            inspectionList[index]['txt']['en']
                                                        ['helpertext'] !=
                                                    null
                                                ? '${inspectionList[index]['txt']['en']['helpertext']}'
                                                : 'Provides a review, documentation and recommendations of potential safety hazards',
                                            style: TextStyle(
                                                fontSize: TextSize.subjectTitle,
                                                color: AppColor.TYPE_PRIMARY
                                                    .withOpacity(0.6),
                                                fontWeight: FontWeight.w500,
                                                fontStyle: FontStyle.normal,
                                                height: 1.3,
                                                fontFamily: "WorkSans"),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Center(
                                          child: InkWell(
                                            onTap: () {
                                              getInspectionDetail(
                                                  inspectionList[index]
                                                      ['inspectiondefid'], inspectionList[index]['lastUpdated']);
                                            },
                                            child: Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 24.0,
                                                  vertical: 28.0),
                                              height: 56.0,
                                              width: 140,
                                              decoration: BoxDecoration(
                                                  gradient:
                                                      LinearGradient(colors: [
                                                    Color(0xff013399),
                                                    Color(0xffBC96E6),
                                                  ]),
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(16.0))),
                                              child: Center(
                                                child: Text(
                                                  'Start',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: AppColor.WHITE_COLOR,
                                                    fontSize:
                                                        TextSize.subjectTitle,
                                                    fontWeight: FontWeight.w700,
                                                    fontStyle: FontStyle.normal,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),

                        SizedBox(
                          height: 120.0,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            _progressHUD,
          ],
        ),
      ),
    );
  }

  /// Undo Code Start
  // var placesSearch = PlacesSearch(
  //   apiKey:
  //       'sk.eyJ1IjoiaW5zcGVjdG9yZG90dGllIiwiYSI6ImNsMTI4NzhhdzAwb2IzY210b3c3aWJudmwifQ.HSfuYo00hwQjYcJliVq8Mg',
  //   limit: 15,
  // );

  // Future<List<MapBoxPlace>> getPlaces() => placesSearch.getPlaces("haz");
  ///Undo Code End

  void getProfileDetail() async {
    FocusScope.of(context).requestFocus(FocusNode());
    _progressHUD.state.show();
    var response = await request.getAuthRequest("auth/me");

    _progressHUD.state.dismiss();
    if (response != null) {
      if (response['success'] != null && !response['success']) {
        if(response['reason'] == "Invalid JWT Token" || response['reason'] == "Expired JWT Token"){
          PreferenceHelper.clearUserPreferenceData(context);

          // PreferenceHelper.clearPreferenceData(PreferenceHelper.LANGUAGE);
          // PreferenceHelper.clearPreferenceData(PreferenceHelper.DATE_FORMAT);
          // PreferenceHelper.clearPreferenceData(PreferenceHelper.TIME_FORMAT);
          // PreferenceHelper.clearPreferenceData(PreferenceHelper.BUSINESS_HOUR);
          // PreferenceHelper.clearPreferenceData(PreferenceHelper.ROLES);

          Navigator.pop(context);
          Navigator.pushAndRemoveUntil(
              context,
              SlideRightRoute(
                  page: LoginPage1()
              ),
              ModalRoute.withName(LoginPage1.tag)
          );
        } else {
          CustomToast.showToastMessage('${response['reason']}');
        }
      } else {
        var userData = {
          "username": "${response['username']}",
          "firstname": "${response['firstname']}",
          "lastname": "${response['lastname']}",
          "nickname": response['nickname'],
          "avatar": response['avatar']
        };
        setState(() {
          name = response['firstname'];
          userImage = response['avatar'];
        });
        PreferenceHelper.saveProfilePreferenceData(userData);
        PreferenceHelper.setPreferenceData(PreferenceHelper.LAST_NAME, response['lastname']);

        var profileData = {
          "payload": json.encode(response)
        };
        dbHelper.insertProfileDetailData(profileData);
        getInspectionTemplateList();
      }
    }
  }

  Future loadProfileDetailFromLocalDb() async {
    try{
      var response = await dbHelper.getProfileDetailData();
      var resultList = response.toList();

      log("responseType===${resultList.runtimeType}");

      if(resultList.length > 0) {
        var resultData = json.decode(resultList[0]['payload']);
        var userData = {
          "username": "${resultData['username']}",
          "firstname": "${resultData['firstname']}",
          "lastname": "${resultData['lastname']}",
          "nickname": resultData['nickname'],
          "avatar": resultData['avatar']
        };
        setState(() {
          name = resultData['firstname'];
          userImage = resultData['avatar'];
        });
        PreferenceHelper.saveProfilePreferenceData(userData);
        PreferenceHelper.setPreferenceData(PreferenceHelper.LAST_NAME, resultData['lastname']);
      }

      templateListFromLocalDb();
    }catch(e) {
      log("loadProfileDetailFromLocalDbStackTrace====$e");
    }
  }

  Future getInspectionTemplateList() async {
    // _progressHUD.state.show();
    var response = await request.getAuthRequest("auth/buildinspection");

    _progressHUD.state.dismiss();

    if (response != null) {
      print(response.runtimeType);
      if (response is List<dynamic>) {

        for(int i=0; i<response.length; i++) {
          var result = await dbHelper.getSingleTemplateData(response[i]['inspectiondefid']);
          response[i]['isCached'] = result == null ? false : result.length > 0;
        }
        setState(() {
          inspectionList = [];
          inspectionList = response;
        });

        PreferenceHelper.setPreferenceData(PreferenceHelper.TEMPLATE_LIST, json.encode(inspectionList));

        // insertSimpleListIds();
        var templateData = {
          "payload": json.encode(response),
        };
        dbHelper.insertTemplateListData(templateData);

        if(!alreadyOpened) {
          syncInspectionRecord();
        }
      } else {
        if (response['success'] != null && !response['success']) {
          CustomToast.showToastMessage('${response['reason']}');
        }
      }
    }
  }

  Future templateListFromLocalDb() async {
    try{
      var response = await dbHelper.getAllTemplateListData();
      var resultList = response.toList();

      log("responseType===${resultList.runtimeType}");
      log("Payload====${resultList.length}");

      if(resultList.length > 0) {
        inspectionList.clear();
        var newArr = [];
        newArr.addAll(json.decode(resultList[0]['payload']));

        for(int i=0; i<newArr.length; i++) {
          var result = await dbHelper.getSingleTemplateData(newArr[i]['inspectiondefid']);
          newArr[i]['isCached'] = result == null ? false : result.length > 0;
        }

        setState(() {
          inspectionList = newArr;
        });

        log("Payload====${resultList[0]['payload']}");
      }
    }catch(e) {
      log("templateListFromLocalDbStackTrace====$e");
    }
  }

  Future getInspectionDetail(inspectionDefId, lastUpdated) async {
    _progressHUD.state.show();
    var response =
        await request.getAuthRequest("auth/buildinspection/$inspectionDefId");

    _progressHUD.state.dismiss();
    if (response != null) {
      print(response.runtimeType);
      try {
        var transformedData = adjacencyTransform(response);

        const JsonEncoder encoder = JsonEncoder.withIndent('  ');
        log("ChildrenData====>>>>${encoder.convert(transformedData)}");
        PreferenceHelper.clearPreferenceData(PreferenceHelper.WATER_VESSEL_BODIES);
        PreferenceHelper.clearPreferenceData(PreferenceHelper.WATER_VESSEL_BODIES_ITEM);
        PreferenceHelper.clearPreferenceData(PreferenceHelper.WATER_SELECTED_BODIES);
        PreferenceHelper.clearPreferenceData(PreferenceHelper.EQUIPMENT_ITEMS);
        PreferenceHelper.clearPreferenceData(PreferenceHelper.ANSWER_LIST);
        PreferenceHelper.clearPreferenceData(PreferenceHelper.TEMPLATE_LIST);

        InspectionPreferences.clearPreferenceData(InspectionPreferences.INSPECTION_CHILD_DATA);
        InspectionPreferences.setPreferenceData(
            InspectionPreferences.INSPECTION_CHILD_DATA,
            json.encode(transformedData));

        var templateData = {
          "templateid": inspectionDefId,
          "lastUpdated": "$lastUpdated",
          "payload": "${json.encode(transformedData).replaceAll("'", "@@@")}"
        };

        dbHelper.insertTemplateDetailData(templateData);

        ///Start inspection
        openNextScreen(inspectionDefId, transformedData);
      } catch (e) {
        print("Error API====$e");
      }
    }
  }

  Future loadTemplateDetailFromLocalDb(id) async {
    try{
      var response = await dbHelper.getSingleTemplateData(id);
      var resultList = response.toList();

      log("responseType===${resultList.runtimeType}");

      if(resultList.length > 0) {
        var resultData = resultList[0]['payload'].toString().replaceAll("@@@", "'");
        var transformedData = json.decode(resultData);

        // const JsonEncoder encoder = JsonEncoder.withIndent('  ');
        // log("ChildrenData====>>>>${encoder.convert(transformedData)}");
        PreferenceHelper.clearPreferenceData(PreferenceHelper.WATER_VESSEL_BODIES);
        PreferenceHelper.clearPreferenceData(PreferenceHelper.WATER_VESSEL_BODIES_ITEM);
        PreferenceHelper.clearPreferenceData(PreferenceHelper.WATER_SELECTED_BODIES);
        PreferenceHelper.clearPreferenceData(PreferenceHelper.EQUIPMENT_ITEMS);
        PreferenceHelper.clearPreferenceData(PreferenceHelper.ANSWER_LIST);
        PreferenceHelper.clearPreferenceData(PreferenceHelper.TEMPLATE_LIST);

        InspectionPreferences.clearPreferenceData(InspectionPreferences.INSPECTION_CHILD_DATA);
        InspectionPreferences.setPreferenceData(
          InspectionPreferences.INSPECTION_CHILD_DATA,
          json.encode(transformedData));

        openNextScreen(id, transformedData);
      } else {
        HelperClass.displayDialog(context, "Inspection detail not found for this template, please check internet connection or try different template");
        // CustomToast.showToastMessage("Inspection detail not found for this template, please check internet connection or try different template");
      }
    }catch(e) {
      log("loadTemplateDetailFromLocalDbStackTrace====$e");
    }
  }

  Map getInspectionData(keyName, keyValue, data) {
    var resultData;
    for (var item in data) {
      if (item[keyName] == keyValue) {
        resultData = item;
        return resultData;
      }

      if (item.containsKey('children')) {
        return getInspectionData(keyName, keyValue, item['children']);
      }
    }

    return resultData;
  }

  static Map adjacencyTransform(nsResult) {
    int ix = 0;
    void build(container) {
      container["children"] = [];
      if (container["rgt"] - container["lft"] < 2) {
        return;
      }
      while ((++ix < nsResult.length) &&
          (nsResult[ix]["lft"] > container["lft"]) &&
          (nsResult[ix]["rgt"] < container["rgt"])) {
        container["children"].add(nsResult[ix]);
        build(nsResult[ix]);
      }
      if (ix < nsResult.length) {
        ix--;
      }
    }

    if (nsResult.length > 0) {
      build(nsResult[0]);
      return nsResult[0];
    }
    return {"children": []};
  }

  void openNextScreen(inspectionDefIdLocal, inspectiondef) async {
    try {
      var transformedData = HelperClass.unroll(null, inspectiondef, [], [], []);
      const JsonEncoder encoder = JsonEncoder.withIndent('  ');

      log("TransformedData====>>>>${encoder.convert(transformedData)}");
      InspectionPreferences.clearPreferenceData(
          InspectionPreferences.INSPECTION_DATA);
      InspectionPreferences.setPreferenceData(
          InspectionPreferences.INSPECTION_DATA,
          json.encode(transformedData['flow']));

      var inspectionData;
      int index;

      print("Index====0");
      print("Length====${transformedData.length}");
      for (int i = 0; i < transformedData['flow'].length; i++) {
        var data = await InspectionUtils.getInspectionBlockTypeData(transformedData['flow'][i], transformedData['flow'].length);
        if (data != null) {
          print("Index=====$i>>>>${data.runtimeType}");
          if (data.runtimeType == InspectionAddCustomer) {
            inspectionData = transformedData['flow'][i];
            index = i;
            break;
          }
        }
      }

      if (inspectionData != null) {
        InspectionPreferences.clearPreferenceData(InspectionPreferences.INSPECTION_INDEX);
        InspectionPreferences.setInspectionId(InspectionPreferences.INSPECTION_INDEX, ++index);

        Navigator.push(
            context,
            SlideRightRoute(
                page: InspectionAddCustomer(
              detail: inspectionData,
              inspectionDefId: inspectionDefIdLocal,
            )));
      }
    } catch (e) {
      print("Error====$e");
    }
  }

  Future beginInspection(inspectionDefIdLocal, inspectiondef) async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());

    var requestJson = {"inspectiondefid": inspectionDefIdLocal ?? "1"};

    var requestParam = json.encode(requestJson);
    var response = await request.postRequest("auth/inspection", requestParam);

    _progressHUD.state.dismiss();

    if (response != null) {
      if (response['success'] != null && !response['success']) {
        CustomToast.showToastMessage('${response['reason']}');
      } else {
        var transformedData = HelperClass.unroll(
            response['inspectionid'], inspectiondef, [], [], []);
        const JsonEncoder encoder = JsonEncoder.withIndent('  ');

        log("TransformedData====>>>>(${encoder.convert(transformedData)})}");
        PreferenceHelper.setPreferenceData(PreferenceHelper.INSPECTION_ID, "${response['inspectionid']}");
        InspectionPreferences.clearPreferenceData(InspectionPreferences.INSPECTION_DATA);
        InspectionPreferences.setPreferenceData(
            InspectionPreferences.INSPECTION_DATA,
            json.encode(transformedData['flow']));

        var inspectionData;
        int index;
        for (int i = 0; i < transformedData['flow'].length; i++) {
          var data = await InspectionUtils.getInspectionBlockTypeData(
              transformedData['flow'][i], transformedData['flow'].length);
          if (data != null) {
            print("Index=====$i>>>>${data.runtimeType}");
            if (data.runtimeType == InspectionAddCustomer) {
              inspectionData = transformedData['flow'][i];
              index = i;
              break;
            }
          }
        }

        if (inspectionData != null) {
          InspectionPreferences.clearPreferenceData(
              InspectionPreferences.INSPECTION_INDEX);
          InspectionPreferences.setInspectionId(
              InspectionPreferences.INSPECTION_INDEX, ++index);

          Navigator.push(
              context,
              SlideRightRoute(
                  page: InspectionAddCustomer(
                detail: inspectionData,
                inspectionDefId: inspectionDefIdLocal,
              )));
        }
      }
    }
  }

  void fetchCountSimpleList() async {
    FocusScope.of(context).requestFocus(FocusNode());
    _progressHUD.state.show();
    var response = await request.getAuthRequest("auth/simplelist");

    _progressHUD.state.dismiss();
    if (response != null) {
      if (response.runtimeType == List) {
        dbHelper.deleteSimpleListTable();
        var simpleListData;
        for (int i = 0; i < response.length; i++) {
          simpleListData = {
            "simplelistid": response[i]['simplelistid'],
            "slug": response[i]['slug'],
            "svgicon": response[i]['svgicon'],
            "lft": response[i]['lft'],
            "rgt": response[i]['rgt'],
            "isList": "${response[i]['isList']}",
            "label": response[i]['label'],
          };
          await dbHelper.insertSimpleListRecordIntoLocalDb(simpleListData);
        }
      } else if (response['success'] != null && !response['success']) {
        CustomToast.showToastMessage('${response['reason']}');
      }
    }
  }

  void openProgressDialog() {
    showDialog(
        context: context,
        barrierColor: isDarkMode ? Color(0xff000000).withOpacity(0.8) : Color(0xff000000).withOpacity(0.5),
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, myState) {
              state = myState;
              // percentValue = 0.0;
              return Dialog(
                backgroundColor: isDarkMode ? Color(0xffF2F2F2).withOpacity(0.8) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minHeight: 140,
                      maxHeight: 150
                  ),
                  child: WillPopScope(
                    onWillPop: () async {
                      return true;
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: (){
                              Navigator.pop(context);
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                "Syncing in progress....",
                                style: TextStyle(
                                  color: AppColor.BLACK_COLOR,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16,),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 16),
                            child: LinearPercentIndicator(
                              animationDuration: 200,
                              backgroundColor: Color(0xffE5E5E5),
                              percent: percentValue,
                              lineHeight: 8.0,
                              linearGradient: LinearGradient(
                                  colors: AppColor.gradientColor(1.0)
                              ),
                              // progressColor: AppColor.HEADER_COLOR,
                            ),
                          ),
                          SizedBox(height: 16,),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Text(
                                    "${(percentValue*100).ceil()}%",
                                    style: TextStyle(
                                      color: AppColor.BLACK_COLOR,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Visibility(
                                      visible: percentValue != 1.0,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            alreadyOpened = false;
                                            state = null;
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          height: 40.0,
                                          width: 80,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(24.0))),
                                          child: Center(
                                            child: Text(
                                              'Cancel',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: AppColor.WHITE_COLOR,
                                                fontSize: TextSize.subjectTitle,
                                                fontWeight: FontWeight.w700,
                                                fontStyle: FontStyle.normal,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    Visibility(
                                      visible: percentValue == 1.0,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            alreadyOpened = false;
                                            for(int i=0; i<inspectionList.length; i++) {
                                              inspectionList[i]['isCached'] = true;
                                            }
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          height: 40.0,
                                          width: 80,
                                          margin: EdgeInsets.only(left: 16),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(24.0))),
                                          child: Center(
                                            child: Text(
                                              'Done',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: AppColor.WHITE_COLOR,
                                                fontSize: TextSize.subjectTitle,
                                                fontWeight: FontWeight.w700,
                                                fontStyle: FontStyle.normal,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        barrierDismissible: false);
  }

  void setPercentageData() {
    try {
      var progress = (((totalPendingData - totalPendingIndex) / (totalPendingData)) * 100) / 100;
      if (state != null) {
        setState(() {
          state(() {
            percentValue = progress >= 1 ? 1 : progress;
            totalPendingIndex--;
          });
        });
      }
      if(progress >= 1) {
        setState(() {
          for(int i=0; i<inspectionList.length; i++) {
            inspectionList[i]['isCached'] = true;
          }
        });
      }
    } catch (e) {
      log("setPercentageDataStackTrace====$e");
    }
  }

  Future insertTemplateDetailIntoLocalDB(inspectionDefId, lastUpdated) async {
    var response = await request.getAuthRequest("auth/buildinspection/$inspectionDefId");

    if (response != null) {
      print(response.runtimeType);
      if(response is List<dynamic>) {
        try {
          var transformedData = adjacencyTransform(response);

          log("lastUpdated===$lastUpdated");
          var templateData = {
            "templateid": inspectionDefId,
            "lastUpdated": "$lastUpdated",
            "payload": "${json.encode(transformedData).replaceAll("'", "@@@")}"
          };

          await dbHelper.insertTemplateDetailData(templateData);

          setPercentageData();
          ///Start inspection
          // openNextScreen(inspectionDefId, transformedData);
        } catch (e) {
          setPercentageData();
          print("insertTemplateDetailIntoLocalDBStackTrace====$e");
        }
      } else {
        if (response['success'] != null && !response['success']) {
          print("insertTemplateDetailIntoLocalDBError");
        }
        setPercentageData();
      }
    } else {
      setPercentageData();
    }
  }

  Future insertInspectionListIntoLocalDB() async {
    var response = await request.getAuthRequest("auth/inspection");

    if (response != null) {
      print(response.runtimeType);
      if(response is List<dynamic>) {
        try {
          var inspectionData = {
            "payload": json.encode(response)
          };

          await dbHelper.insertInspectionListData(inspectionData);

          if (response is List<dynamic>) {
            await Future.wait(response.map((responseData) async {
              var result = await dbHelper.getSingleStartedInspectionData("${responseData['inspectionid']}");

              if(result.toList().length > 0) {
                if(responseData['completed'] == null || "${responseData['completed']}" == "null") {
                  if("${result[0]['lastUpdated']}" != "null" && "${responseData['lastUpdated']}" != "null"){
                    if (DateTime.parse("${responseData['lastUpdated']}") != DateTime.parse("${result[0]['lastUpdated']}")) {
                      // await _lock.synchronized(() => insertInspectionDetailIntoLocalDB(response[i]['inspectionid'], response[i]['lastUpdated']));
                      insertInspectionDetailIntoLocalDB(responseData['inspectionid'], responseData['lastUpdated']);
                    } else {
                      setPercentageData();
                    }
                  } else {
                    // await _lock.synchronized(() => insertInspectionDetailIntoLocalDB(response[i]['inspectionid'], response[i]['lastUpdated']));
                    insertInspectionDetailIntoLocalDB(responseData['inspectionid'], responseData['lastUpdated']);
                  }
                }
              } else {
                // await _lock.synchronized(() => insertInspectionDetailIntoLocalDB(response[i]['inspectionid'], response[i]['lastUpdated']));
                insertInspectionDetailIntoLocalDB(responseData['inspectionid'], responseData['lastUpdated']);
              }
            }));
          }

          setPercentageData();
          ///Start inspection
          // openNextScreen(inspectionDefId, transformedData);
        } catch (e) {
          setPercentageData();
          print("insertInspectionListIntoLocalDBStackTrace====$e");
        }
      } else {
        if (response['success'] != null && !response['success']) {
          if (state != null) {
            setState(() {
              state(() {
                totalPendingIndex = totalPendingIndex - inspectionCount;
              });
            });
          }
          print("insertInspectionListIntoLocalDBError");
        }
        setPercentageData();
      }
    } else {
      setPercentageData();
    }
  }

  Future insertInspectionDetailIntoLocalDB(inspectionId, lastUpdated) async {
    var response = await request.getAuthRequest("auth/buildinspection/inspection/$inspectionId");

    if (response != null) {
      print(response.runtimeType);
      if (response['success'] != null && !response['success']) {
        setPercentageData();
        print("insertTemplateDetailIntoLocalDBError");
      } else {
        try {
          var inspectionData = {
            "inspectionid": inspectionId,
            "lastUpdated": "$lastUpdated",
            "payload": "${json.encode(response).replaceAll("'", "@@@")}"
          };

          await dbHelper.insertStartedInspectionDetailData(inspectionData);
          setPercentageData();
          ///Start inspection
          // openNextScreen(inspectionDefId, transformedData);
        } catch (e) {
          setPercentageData();
          print("insertInspectionDetailIntoLocalDBStackTrace====$e");
        }
      }
    } else {
      setPercentageData();
    }
  }

  Future insertCustomerListIntoLocalDB() async {
    var response = await request.getAuthRequest("auth/myclient");

    if (response != null) {
      print(response.runtimeType);
      if(response is List<dynamic>) {
        try {
          var customerListData = {
            "payload": json.encode(response)
          };
          await dbHelper.insertCustomerListData(customerListData);

          if (response is List<dynamic>) {
            await Future.wait(response.map((responseData) async {
              var result = await dbHelper.getSingleCustomerData("${responseData['clientid']}");

              if(result.toList().length > 0) {
                if("${responseData['lastUpdated']}" != "null" && "${result[0]['lastUpdated']}" != "null") {
                  if (DateTime.parse("${responseData['lastUpdated']}") != DateTime.parse("${result[0]['lastUpdated']}")) {
                    // await _lock.synchronized(() => insertCustomerListDetailIntoLocalDB(response[i]['clientid'], response[i]['lastUpdated']));
                    insertCustomerListDetailIntoLocalDB(responseData['clientid'], responseData['lastUpdated']);
                  } else {
                    setPercentageData();
                  }
                } else {
                  // await _lock.synchronized(() => insertCustomerListDetailIntoLocalDB(response[i]['clientid'], response[i]['lastUpdated']));
                  insertCustomerListDetailIntoLocalDB(responseData['clientid'], responseData['lastUpdated']);
                }
              } else {
                // await _lock.synchronized(() => insertCustomerListDetailIntoLocalDB(response[i]['clientid'], response[i]['lastUpdated']));
                insertCustomerListDetailIntoLocalDB(responseData['clientid'], responseData['lastUpdated']);
              }
            }));
            // for(int i=0; i<response.length; i++) {
            //
            // }
          }

          setPercentageData();

          ///Start inspection
          // openNextScreen(inspectionDefId, transformedData);
        } catch (e) {
          setPercentageData();
          print("insertCustomerListIntoLocalDBStackTrace====$e");
        }
      } else {
        if (response['success'] != null && !response['success']) {
          if (state != null) {
            setState(() {
              state(() {
                totalPendingIndex = totalPendingIndex - customerCount;
              });
            });
          }
          print("insertTemplateDetailIntoLocalDBError");
        }
        setPercentageData();
      }
    } else {
      setPercentageData();
    }
  }

  Future insertCustomerListDetailIntoLocalDB(clientId, lastUpdated) async {
    log("clientId====$clientId,  lastUpdated===$lastUpdated");
    var response = await request.getAuthRequest("auth/myclient/$clientId");

    if (response != null) {
      if (response['success'] != null && !response['success']) {
        setPercentageData();
        print("insertTemplateDetailIntoLocalDBError");
      } else {
        log("response.runtimeType==${response.runtimeType}, CustomerDetailData===$response");
        try {
          var customerData = {
            "customerid": "$clientId",
            "lastUpdated": "$lastUpdated",
            "payload": json.encode(response)
          };
          await dbHelper.insertCustomerDetailData(customerData);

          setPercentageData();
          ///Start inspection
          // openNextScreen(inspectionDefId, transformedData);
        } catch (e) {
          setPercentageData();
          print("insertCustomerListDetailIntoLocalDBStackTrace===$e");
        }
      }
    } else {
      setPercentageData();
    }
  }

  Future syncInspectionRecord() async {
    // try {
      // log("Hello===$inspectionList");
      // _progressHUD.state.show();
      setState(() {
        alreadyOpened = true;
      });
      openProgressDialog();
      int templateCount = 0;

      templateCount = inspectionList.length ?? 0;

      setState(() {
        if(state != null) {
          state((){
            totalPendingData = (1 + inspectionCount) + (1 + customerCount) + (templateCount);
            totalPendingIndex = totalPendingData - 1;
          });
        } else {
          totalPendingData = (1 + inspectionCount) + (1 + customerCount) + (templateCount);
          totalPendingIndex = totalPendingData - 1;
        }
      });

      await Future.wait(inspectionList.map((inspectionData) async {
        var result = await dbHelper.fetchLastUpdatedTemplateDetail("${inspectionData['inspectiondefid']}");

        // log("result===$result");
        if(result.toList().length > 0) {
          if(("${result[0]['lastUpdated']}" != "null" && "${inspectionData['lastUpdated']}" != "null" )) {
            if (DateTime.parse("${inspectionData['lastUpdated']}") != DateTime.parse("${result[0]['lastUpdated']}")) {
              // await _lock.synchronized(() => insertTemplateDetailIntoLocalDB(inspectionList[i]['inspectiondefid'], inspectionList[i]['lastUpdated']));
              await insertTemplateDetailIntoLocalDB(inspectionData['inspectiondefid'], inspectionData['lastUpdated']);
            } else {
              setPercentageData();
            }
          } else {
            // await _lock.synchronized(() => insertTemplateDetailIntoLocalDB(inspectionList[i]['inspectiondefid'], inspectionList[i]['lastUpdated']));
            await insertTemplateDetailIntoLocalDB(inspectionData['inspectiondefid'], inspectionData['lastUpdated']);
          }
        } else {
          // await _lock.synchronized(() => insertTemplateDetailIntoLocalDB(inspectionList[i]['inspectiondefid'], inspectionList[i]['lastUpdated']));
          await insertTemplateDetailIntoLocalDB(inspectionData['inspectiondefid'], inspectionData['lastUpdated']);
        }
      }));

      // await _lock.synchronized(() => insertCustomerListIntoLocalDB());
      // await _lock.synchronized(() => insertInspectionListIntoLocalDB());
      await insertCustomerListIntoLocalDB();
      await insertInspectionListIntoLocalDB();

      // _progressHUD.state.dismiss();
      // int totalCount =
    // } catch(e) {
    //   // _progressHUD.state.dismiss();
    //   log("syncInspectionRecordStackTrace====$e");
    // }
  }

  Future getInspectionCount() async {
    var response = await request.getAuthRequest("auth/inspection/count");
    if(response != null) {
      if(response['success'] != null && !response['success']) {
        print("false");
      } else {
        setState(() {
          inspectionCount = response['incomplete'] ?? 0;
        });
      }
    }
    return inspectionCount;
  }

  Future getCustomerCount() async {
    var response = await request.getAuthRequest("auth/myclient/stats");
    if(response != null) {
      if(response['success'] != null && !response['success']) {
        print("false");
      } else {
        setState(() {
          customerCount = response['customers'] != null ? int.parse(response['customers'] ?? "0") : 0;
          log("CustomerCount====$customerCount");
        });
      }
    }
  }
}
