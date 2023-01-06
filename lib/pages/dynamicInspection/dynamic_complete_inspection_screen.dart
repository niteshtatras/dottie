import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dottie_inspector/connection_mixin.dart';
import 'package:dottie_inspector/database/database_helper.dart';
import 'package:dottie_inspector/pages/backgroundServices/background_services.dart';
import 'package:dottie_inspector/deadCode/welcome_new_screen.dart';
import 'package:dottie_inspector/pages/menu/drawer_page.dart';
import 'package:dottie_inspector/pages/menu/index_menu.dart';
import 'package:dottie_inspector/pages/welcome/welcome_navigation_screen.dart';
import 'package:dottie_inspector/pages/welcome/welcome_template_screen.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:dottie_inspector/utils/globalInstance.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/utils/lock_file.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:synchronized/synchronized.dart';
import 'package:url_launcher/url_launcher.dart';

class CompleteInspectionScreen extends StatefulWidget {

  @override
  _CompleteInspectionScreenState createState() => _CompleteInspectionScreenState();
}

class _CompleteInspectionScreenState extends State<CompleteInspectionScreen> with MyConnection {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  // final dbHelper = DatabaseHelper.instance;
  var state;

  String customerName = "";
  String inspectionName = "";
  String locationName = "";

  ProgressHUD _progressHUD;
  var _loading = false;

  var allDataUploaded = false;
  static double percentValue = 0.0;
  int totalPendingIndex = 0;

  bool isDarkMode = false;
  Color themeColor = AppColor.BLACK_COLOR;

  bool _isInternetAvailable = true;

  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

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
      text: 'Uploading...',
    );

    initConnectivity();
    getThemeData();
    setBasicData();
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
      } else if ((_connectivityResult == ConnectivityResult.mobile) || (_connectivityResult == ConnectivityResult.wifi)) {
        _isInternetAvailable = true;
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    // connectivity.disposeStream();
    super.dispose();
  }

  void getThemeData() async {
    await PreferenceHelper.getPreferenceData(PreferenceHelper.THEME_MODE).then((value){
      setState(() {
        var themeMode = value == null ? "" : value;
        log("ThemeData===$themeMode");
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

  void setBasicData() async {
    var cName = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_CUSTOMER_NAME) ?? "Bruce Wayne";
    var inName = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_NAME) ?? "Safety Inspection";
    var locName = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_SERVICE_LOCATION) ?? "2972 Westheimer Rd. Santa Ana, Illinois 85486";

    print("CustomerName====$cName");
    print("InspectionName====$inName");
    print("LocationName====$locName");
    setState(() {
      customerName = cName;
      inspectionName = inName;
      locationName = locName;
    });
    print("CustomerName====$customerName");
    print("InspectionName====$inspectionName");
    print("LocationName====$locationName");
  }

  Future writeSlow(int value) async {
    await Future.delayed(new Duration(milliseconds: 50));
    print(value);
  }

  Future write() async {
    List<int> values;
    for(int i=0; i<100; i++) {
      print("Value==>$i");
      // print("Values==>${values.length}");
      if(state != null){
        setState(() {
          state((){
            percentValue = (((i+1)*100)/100)/100;
          });
        });
      }

      print("Percent Value====$percentValue");
      await writeSlow(i);
    }
  }

  Future write1234() async {
    // _progressHUD.state.dismiss();
    openProgressDialog();
    await write();
  }

  void sendPendingRequest() async {
    try{
      // _progressHUD.state.show();
      // if(state != null){
      //   setState(() {
      //     state((){
      //       percentValue = 0.0;
      //     });
      //   });
      // }
      openProgressDialog();
      final dbHelper = DatabaseHelper.instance;
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
      int totalPendingData =  (inspectionIdList != null ? inspectionIdList.toList().length : 0)
                              + (customerList != null ? customerList.toList().length : 0)
                              + (locationImageList != null ? locationImageList.toList().length : 0)
                              + (serviceAddressList != null ? serviceAddressList.toList().length : 0)
                              + (pendingList != null ? pendingList.toList().length : 0)
                              + (bodyOfWaterList != null ? bodyOfWaterList.toList().length : 0)
                              + (vesselList != null ? vesselList.toList().length : 0)
                              + (equipmentList != null ? equipmentList.toList().length : 0)
                              + (deleteAnswerList != null ? deleteAnswerList.toList().length : 0);

      totalPendingIndex = totalPendingData - 1;
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
        setPercentageData(totalPendingData);
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
            }
          }
        }
        setPercentageData(totalPendingData);
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
          }*/
        }
        setPercentageData(totalPendingData);
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
        setPercentageData(totalPendingData);
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

        setPercentageData(totalPendingData);
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
          setPercentageData(totalPendingData);
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

        setPercentageData(totalPendingData);
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

          setPercentageData(totalPendingData);
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

      if(totalPendingData <= 0) {
        if(state != null){
          setState(() {
            state((){
              percentValue = 1.0;
            });
          });
        }
        setState(() {
          allDataUploaded = true;
        });
      }
      print("Uploading Done");
      var pendingListData = await dbHelper.getAllPendingEndPoints();

      if(pendingListData.toList().length == 0) {
        setState(() {
          allDataUploaded = true;
          if(state != null) {
            state((){
              percentValue = 1.0;
            });
          }
        });

        await dbHelper.deleteCustomerGeneralTableData();
        await dbHelper.deleteServiceGeneralTableData();
        await dbHelper.deleteLocationImageTableData();
        await dbHelper.deleteBodyOfWaterData();
        await dbHelper.deleteVesselsData();
        await dbHelper.deleteEquipmentsData();
        await dbHelper.deleteDeleteAnswerTableData();
        await dbHelper.deleteAnswerTableData();
        await dbHelper.deleteInspectionIdTableData();
      }
    }catch (e){
      print("StackTrace===$e");
    }
  }

  void setPercentageData(int totalPendingData) {
    if(state != null){
      setState(() {
        state((){
          percentValue = (((totalPendingData-totalPendingIndex)/(totalPendingData))*100)/100;
          totalPendingIndex--;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode ? AppColor.BLACK_COLOR : AppColor.PAGE_COLOR,
      appBar: EmptyAppBar(isDarkMode: isDarkMode),
      /*appBar: AppBar(
        elevation: 0.0,
        backgroundColor: AppColor.PAGE_COLOR,
        leading: GestureDetector(
          onTap: (){
            _scaffoldKey.currentState.openDrawer();
            // _progressHUD.state.dismiss();
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
        child: DrawerIndexPage(),
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
                ///AppBar Start
                // Container(
                //   margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                //   child: GestureDetector(
                //     onTap: () {
                //       _scaffoldKey.currentState.openDrawer();
                //       // initConnectivity();
                //       HelperClass.printDatabaseResult();
                //       // openProgressDialog();
                //       // setBasicData();
                //     },
                //     child: Container(
                //       child: Image.asset(
                //         'assets/ic_menu.png',
                //         fit: BoxFit.cover,
                //         width: 44,
                //         height: 44,
                //         color: isDarkMode ? AppColor.WHITE_COLOR : AppColor.BLACK_COLOR,
                //       ),
                //     ),
                //   ),
                // ),
                ///AppBar End

                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: 4.0,),
/***
                          /*******************************
                           * Background service testing
                           * Start
                           *******************************/

                          GestureDetector(
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
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),

                          GestureDetector(
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
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),

                          GestureDetector(
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
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),

                          /*******************************
                           * Background service testing
                           * End
                           *******************************/
***/
                          Container(
                            margin: EdgeInsets.only(top: 0.0, left: 8.0, right: 8.0, bottom: 10.0),
                            padding: EdgeInsets.all(12),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32.0),
                                gradient: LinearGradient(
                                    colors: AppColor.gradientColor(1.0)
                                 ),
                                // boxShadow: [
                                //   BoxShadow(
                                //       color: themeColor.withOpacity(0.16),
                                //       blurRadius: 1.0
                                //   )
                                // ],
                              image: DecorationImage(
                                image: AssetImage(
                                  'assets/complete_inspection/ic_complete_inspection.png',
                                ),
                                fit: BoxFit.fill,

                              )
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 16,),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(left: 16.0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(32.0),
                                          child: CircleAvatar(
                                            radius: 32.0,
                                            child: Image(
                                              image: AssetImage('assets/ic_inspector_logo.png'),
                                              fit: BoxFit.cover,
                                              height: 64.0,
                                              width: 64.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                                          alignment: Alignment.centerLeft,
                                          child: Image(
                                            image: AssetImage(
                                              'assets/ic_dark_logo_dottie.png',
                                            ),
                                            fit: BoxFit.cover,
                                            height: 31.0,
                                            width: 75.0,
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: true,
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
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 16.0),
                                  child: Text(
                                    allDataUploaded
                                    ? '$inspectionName completed!'
                                    : '$inspectionName',
                                    style: TextStyle(
                                        fontSize: 32,
                                        color: AppColor.WHITE_COLOR,
                                        fontWeight: FontWeight.w700,
                                        fontStyle: FontStyle.normal,
                                      height: 1.5
                                    ),
                                  ),
                                ),
                                Container(
                                  margin:
                                  EdgeInsets.only(left: 16.0,right: 16.0),
                                  child: Text(
                                    'Create good will and safer pools',
                                    style: TextStyle(
                                        fontSize: TextSize.headerText,
                                        color: AppColor.WHITE_COLOR,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FontStyle.normal,
                                        height: 1.3,),
                                  ),
                                ),

                                GestureDetector(
                                  onTap: () async {
                                    ///
                                    String lang = await PreferenceHelper.getPreferenceData(PreferenceHelper.LANGUAGE);
                                    var pdfToken = await PreferenceHelper.getPreferenceData(PreferenceHelper.PDF_TOKEN);
                                    var pdfUrl = "${GlobalInstance.apiBaseUrl}report/pdf/$pdfToken/$lang";

                                    print("PDF_URL===>>$pdfUrl");

                                    if(_isInternetAvailable) {
                                      if (allDataUploaded) {
                                        _launchURL("$pdfUrl");
                                      } else {
                                        sendPendingRequest();
                                      }
                                      // sendPendingRequest();
                                    } else {
                                      HelperClass.showSnackBar(context, "Please check internet connection");
                                    }

                                    // await dbHelper.deleteLocationImageTableData();
                                    // await dbHelper.getServiceGeneralData();
                                    // await dbHelper.getInspectionIdData();
                                    // await dbHelper.getLocationImageData();
                                    ///
                                    // openProgressDialog();
                                   /* if(await HelperClass.internetConnectivity()) {
                                      if(allDataUploaded){
                                        _launchURL("$pdfUrl");
                                      } else {
                                        sendPendingRequest();
                                        // write1234();
                                      }
                                    } else {
                                      HelperClass.openSnackBar(context);
                                    }*/
                                    // write1234();
                                    // openProgressDialog();

                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 12.0, vertical: 24.0),
                                    height: 56.0,
                                    width: 180,
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(24.0))),
                                    child: Center(
                                      child: Text(
                                        allDataUploaded
                                        ? 'View Inspection'
                                        : 'Send Data',
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
                              ],
                            ),
                          ),

                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 16.0),
                            padding: EdgeInsets.only(top: 0.0, left: 24.0, right: 24.0, bottom: 24.0),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32.0),
                                color: themeColor.withOpacity(0.04),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      top: 32.0),
                                  child: Text(
                                    'The details',
                                    style: TextStyle(
                                        fontSize: 24,
                                        color: themeColor,
                                        fontWeight: FontWeight.w700,
                                        fontStyle: FontStyle.normal,),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 16),
                                  child: Text(
                                    'Inspection Type',
                                    style: TextStyle(
                                        fontSize: TextSize.subjectTitle,
                                        color: themeColor,
                                        fontWeight: FontWeight.w700,
                                        fontStyle: FontStyle.normal,
                                        height: 1.3,),
                                  ),
                                ),

                                Container(
                                  margin: EdgeInsets.only(top: 4),
                                  child: Text(
                                    '$inspectionName',
                                    style: TextStyle(
                                        fontSize: TextSize.subjectTitle,
                                        color: themeColor,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.normal,
                                        height: 1.3,),
                                  ),
                                ),

                                ////////
                                Container(
                                  margin: EdgeInsets.only(top: 24),
                                  child: Text(
                                    'Customer',
                                    style: TextStyle(
                                        fontSize: TextSize.subjectTitle,
                                        color: themeColor,
                                        fontWeight: FontWeight.w700,
                                        fontStyle: FontStyle.normal,
                                        height: 1.3,),
                                  ),
                                ),

                                Container(
                                  margin: EdgeInsets.only(top: 4),
                                  child: Text(
                                    '$customerName',
                                    style: TextStyle(
                                        fontSize: TextSize.subjectTitle,
                                        color: themeColor,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.normal,
                                        height: 1.3,),
                                  ),
                                ),

                                Container(
                                  margin: EdgeInsets.only(top: 24),
                                  child: Text(
                                    'Service address',
                                    style: TextStyle(
                                        fontSize: TextSize.subjectTitle,
                                        color: themeColor,
                                        fontWeight: FontWeight.w700,
                                        fontStyle: FontStyle.normal,
                                        height: 1.3,),
                                  ),
                                ),

                                Container(
                                  margin: EdgeInsets.only(top: 4),
                                  child: Text(
                                    '$locationName',
                                    style: TextStyle(
                                        fontSize: TextSize.subjectTitle,
                                        color: themeColor,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.normal,
                                        height: 1.3,),
                                  ),
                                ),

                                Container(
                                  margin: EdgeInsets.only(top: 32, bottom: 32),
                                  child: RichText(
                                    text: TextSpan(
                                      text: "*To edit your inspection please visit ",
                                        style: TextStyle(
                                            fontSize: TextSize.subjectTitle,
                                            color: themeColor,
                                            fontWeight: FontWeight.w500,
                                            fontStyle: FontStyle.normal,
                                            height: 1.3,),
                                      children: [
                                        //*To edit your inspection please visit inspectordottie.com on a desktop.
                                        TextSpan(
                                          text: "inspectordottie.com",
                                          style: TextStyle(
                                            decoration: TextDecoration.underline,
                                              fontSize: TextSize.subjectTitle,
                                              color: themeColor,
                                              fontWeight: FontWeight.w700,
                                              fontStyle: FontStyle.normal,
                                              height: 1.3,),
                                        ),
                                        TextSpan(
                                          text: ' on a desktop.',
                                          style: TextStyle(
                                              fontSize: TextSize.subjectTitle,
                                              color: themeColor,
                                              fontWeight: FontWeight.w500,
                                              fontStyle: FontStyle.normal,
                                              height: 1.3,),
                                        )
                                      ]
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ),

                          Visibility(
                            visible: allDataUploaded,
                            child: Container(
                              alignment: Alignment.center,
                              child: GestureDetector(
                                onTap: () async {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WelcomeNavigationScreen(),
                                    ),
                                    ModalRoute.withName(WelcomeNavigationScreen.tag),
                                  );
                                  // var pendingList = await dbHelper.getAllPendingEndPoints();
                                  //
                                  // log("PENDING LIST====${pendingList.toList()}");
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 24.0, vertical: 24.0),
                                  height: 56.0,
                                  width: 180,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: isDarkMode
                                        ? Color(0xff333333)
                                        : Colors.black,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(24.0))),
                                  child: Center(
                                    child: Text(
                                      'Return Home',
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            _progressHUD
          ],
        ),
      ),
    );
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
                                "Uploading the inspection....",
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

                                Visibility(
                                  visible: percentValue == 1.0,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                      setState(() {
                                        allDataUploaded = true;
                                      });
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

  void _launchURL(_url) async {
    if (!await launch(_url)) throw 'Could not launch $_url';
  }
}
