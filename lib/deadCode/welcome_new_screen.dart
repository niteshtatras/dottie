import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dottie_inspector/database/database_helper.dart';
import 'package:dottie_inspector/inspectionPreferences/inspection_preferences.dart';
import 'package:dottie_inspector/pages/backgroundServices/background_services.dart';
import 'package:dottie_inspector/pages/menu/drawer_page.dart';
import 'package:dottie_inspector/pages/signInPages/login_page_1.dart';
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
import 'package:dottie_inspector/utils/lock_file.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_hud/progress_hud.dart';

import '../pages/inspectionMain/inspection_adding_customer.dart';

// Toggle this to cause an async error to be thrown during initialization
// and to test that runZonedGuarded() catches the error
const _kShouldTestAsyncErrorOnInit = false;

// Toggle this for testing Crashlytics in your app locally.
const _kTestingCrashlytics = true;

class WelcomeNewScreenPage extends StatefulWidget {
  static String tag = 'welcome-new-screen';
  @override
  _WelcomeNewScreenPageState createState() => _WelcomeNewScreenPageState();
}

class _WelcomeNewScreenPageState extends State<WelcomeNewScreenPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final dbHelper = DatabaseHelper.instance;

  // final MyConnectivity _connectivity = MyConnectivity.instance;
  bool _isInternetAvailable = true;

  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;
  String name = "";
  List inspectionList = [];
  var imagePath;
  var userImage;
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  String lang = "en";
  Future<void> _initializeFlutterFireFuture;

  Future<void> _testAsyncErrorOnInit() async {
    Future<void>.delayed(const Duration(seconds: 2), () {
      final List<int> list = <int>[];
      print(list[100]);
    });
  }

  Future<void> _initializeFlutterFire() async {
    /// Wait for Firebase to initialize
    print("Firebase crashlytics initialize");

    if (_kTestingCrashlytics) {
      // Force enable crashlytics collection enabled if we're testing it.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    } else {
      // Else only enable it in non-debug builds.
      // You could additionally extend this to allow users to opt-in.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    }

    if (_kShouldTestAsyncErrorOnInit) {
      await _testAsyncErrorOnInit();
    }
  }

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

    // _initializeFlutterFireFuture = _initializeFlutterFire();
//    var result = 100/0;
//    print(result);
//     _connectivity.initialise();
//     _connectivity.myStream.listen((source) {
//       setState(() {
//         if(source.keys.toList()[0] == ConnectivityResult.none) {
//           print("No Internet found");
//           _isInternetAvailable = false;
//         } else if(source.keys.toList()[0] == ConnectivityResult.mobile) {
//           print("Mobile");
//           _isInternetAvailable = true;
//           getProfileDetail();
//         } else if(source.keys.toList()[0] == ConnectivityResult.wifi) {
//           print("WIFI");
//           _isInternetAvailable = true;
//           getProfileDetail();
//         }
//       });
//     });

    // Workmanager().registerPeriodicTask(
    //   "2", "simplePeriodicTask",
    //   existingWorkPolicy: ExistingWorkPolicy.replace,
    //   frequency: Duration(minutes: 5), //when should it check the link
    //   initialDelay: Duration(seconds: 10), //duration before showing the notification
    //   constraints: Constraints(
    //     networkType: NetworkType.connected,
    //   ),
    // );

    // initNotification();

    getPreferenceData();
  }

  void getPreferenceData() async {

    var language = await PreferenceHelper.getPreferenceData(PreferenceHelper.LANGUAGE) ?? "en";
    var firstName = await PreferenceHelper.getPreferenceData(PreferenceHelper.FIRST_NAME) ?? "";
    var userAvatar = await PreferenceHelper.getPreferenceData(PreferenceHelper.USER_AVATAR) ?? "";

    setState(() {
      lang = language;
      name = firstName;
      userImage = userAvatar;
    });

    initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    Timer(Duration(milliseconds: 100), fetchCountSimpleList);
    Timer(Duration(milliseconds: 200), sendPendingRequest);
  }

  void insertSimpleListIds() async {
    try {
      final dbHelper = DatabaseHelper.instance;
      var pendingList = await dbHelper.getSingleSimpleList();
      if(pendingList.length==0){
        fetchAllSimpleList();
      }
    } catch(e){
      print(e);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _connectivitySubscription?.cancel();
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
        if (_connectivityResult == ConnectivityResult.none) {
          print("No Internet found");
          _isInternetAvailable = false;
        } else if (_connectivityResult == ConnectivityResult.mobile) {
          print("Mobile");
          _isInternetAvailable = true;
          getProfileDetail();
        } else if (_connectivityResult == ConnectivityResult.wifi) {
          print("WIFI");
          _isInternetAvailable = true;
          getProfileDetail();
        }
      });
    });
  }

  void initNotification() {
    // var initializationSettingsAndroid = new AndroidInitializationSettings('app_icon');
    // var initializationSettingsIOS = new IOSInitializationSettings();
    // var initializationSettings = new InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    // flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    // flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);
  }

  void onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
            },
          )
        ],
      ),
    );
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    /*await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => NotificationPage()),
    );*/
  }

  /***
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Configure BackgroundFetch.
    try {
      var status = await BackgroundFetch.configure(BackgroundFetchConfig(
        minimumFetchInterval: 15,
        /*
        forceAlarmManager: false,
        stopOnTerminate: false,
        startOnBoot: true,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.NONE,

         */
      ), _onBackgroundFetch, _onBackgroundFetchTimeout);
      print('[BackgroundFetch] configure success: $status');

      // Schedule a "one-shot" custom-task in 10000ms.
      // These are fairly reliable on Android (particularly with forceAlarmManager) but not iOS,
      // where device must be powered (and delay will be throttled by the OS).
      BackgroundFetch.scheduleTask(TaskConfig(
          taskId: "com.transistorsoft.customtask",
          delay: 15000,
          periodic: true,
          forceAlarmManager: true,
          stopOnTerminate: false,
          enableHeadless: true
      ));
    } on Exception catch(e) {
      print("[BackgroundFetch] configure ERROR: $e");
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  /// This event fires shortly before your task is about to timeout.  You must finish any outstanding work and call BackgroundFetch.finish(taskId).
  void _onBackgroundFetchTimeout(String taskId) {
    print("[BackgroundFetch] TIMEOUT: $taskId");
    BackgroundFetch.finish(taskId);
  }

  void _onBackgroundFetch(taskId) async {
    sendPendingRequest();
    if (taskId == "com.transistorsoft.customtask") {
      // Schedule a one-shot task when fetch event received (for testing).
      BackgroundFetch.scheduleTask(TaskConfig(
          taskId: "com.transistorsoft.customtask",
          delay: 15000,
          periodic: false,
          forceAlarmManager: true,
          stopOnTerminate: false,
          enableHeadless: true,
          requiresNetworkConnectivity: true,
          requiresCharging: true
      ));
    }
  }
 ****/

  // void sendPendingRequest() async {
  //   try {
  //     final dbHelper = DatabaseHelper.instance;
  //     var pendingList = await dbHelper.getAllPendingEndPoints();
  //
  //     final _lock = LockSynchronized.getLockInstance();
  //     print("PENDING LIST====${pendingList.toList()}");
  //     if (pendingList != null) {
  //       for (int i = 0; i < pendingList.toList().length; i++) {
  //         await _lock.synchronized(() =>
  //             BackgroundServices.sendPendingRequestToServer(pendingList[i]));
  //       }
  //     }
  //     print("Uploading Done");
  //   } catch (e) {
  //     print("StackTrace===$e");
  //   }
  // }

  void sendPendingRequest() async {
    try{
      // _progressHUD.state.show();
      // openProgressDialog();
      final dbHelper = DatabaseHelper.instance;
      var pendingList = await dbHelper.getAllPendingEndPoints();
      var bodyOfWaterList = await dbHelper.getPendingBodyOfWaterData();
      var vesselList = await dbHelper.getAllPendingVesselData();
      var equipmentList = await dbHelper.getAllPendingEquipmentData();

      final _lock = LockSynchronized.getLockInstance();
      // print("PENDING LIST====${pendingList.toList()}");
      // int totalPendingData = (pendingList != null ? pendingList.toList().length : 0)
      //     + (bodyOfWaterList != null ? bodyOfWaterList.toList().length : 0)
      //     + (vesselList != null ? vesselList.toList().length : 0)
      //     + (equipmentList != null ? equipmentList.toList().length : 0) ;

      for(int j=0; j<bodyOfWaterList.toList().length; j++) {
        log("BodyOfWaterEndPoint====${bodyOfWaterList[j]['url']}");
        var response = await _lock.synchronized(() => BackgroundServices.sendPendingVesselBodyEquipmentData(bodyOfWaterList[j]['payload'], bodyOfWaterList[j]['url']));

        if(response != null){
          if (response['success']!=null && !response['success']) {
            print('${response['reason']}');
          } else {
            await dbHelper.updateBodyOfWaterRecord(
                bodyOfWaterList[j]['bodyofwateridlocal'],
                "${response['bodyofwaterid']}");
          }
        }
      }

      for(int k=0; k<vesselList.toList().length; k++) {
        try {
          var bodyofwaterid = vesselList[k]['bodyofwaterid'] ?? 0;
          var payload = vesselList[k]['payload'];
          var endPoint = vesselList[k]['url'];

          bodyofwaterid = bodyofwaterid == "" || bodyofwaterid == "null" ? 0 : bodyofwaterid;

          var fetchBodyOfWaterRecord = await dbHelper.getSingleBodyOfWaterRecord(bodyofwaterid);
          if (fetchBodyOfWaterRecord != null && fetchBodyOfWaterRecord.toList().length > 0) {
            endPoint = endPoint.toString().replaceAll("{{bodyofwaterid}}", "${fetchBodyOfWaterRecord[0]['bodyofwaterid']}");
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
          log("VesselEndPoint==$k==$endPoint");
        } catch(e) {
          log("VesselRecordIssue===$e");
        }
      }

      for(int x=0; x<equipmentList.toList().length; x++) {
        var vesselid = equipmentList[x]['vesselid'] ?? 0;
        var payload = equipmentList[x]['payload'];
        var endPoint = equipmentList[x]['url'];

        vesselid = vesselid == "" || vesselid == "null" ? 0 : vesselid;

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

        log("EquipmentEndpoint===$x=$endPoint");
        log("EquipmentPayload===$x=$payload");

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

          vesselid = vesselid == "" || vesselid == "null" ? 0 : vesselid;
          equipmentid = equipmentid == "" || equipmentid == "null" ? 0 : equipmentid;
          bodyofwaterid = bodyofwaterid == "" || bodyofwaterid == "null" ? 0 : bodyofwaterid;

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

          log("PendingRecordEndpoint==$y==$endPoint");
          response = await _lock.synchronized(() => BackgroundServices.sendPendingRequestToServer(pendingList[y], endPoint));
        } catch(e) {
          log("PendingRecord====$e");
        }
      }

      print("Uploading Done");
      var pendingListData = await dbHelper.getAllPendingEndPoints();

      if(pendingListData.toList().length == 0) {
        await dbHelper.deleteBodyOfWaterData();
        await dbHelper.deleteVesselsData();
        await dbHelper.deleteEquipmentsData();
        await dbHelper.deleteDeleteAnswerTableData();
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

  // @override
  // void dispose() {
  //   _connectivity.disposeStream();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColor.PAGE_COLOR,
      appBar: EmptyAppBar(isDarkMode: false),
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
                      GestureDetector(
                        onTap: () {
                          _scaffoldKey.currentState.openDrawer();
                          // checkRemoveWhereCondition();
                          // _progressHUD.state.show();
                          // HelperClass.printDatabaseResult();
                        },
                        child: Container(
                          child: Image.asset(
                            'assets/ic_menu.png',
                            fit: BoxFit.cover,
                            width: 44,
                            height: 44,
                          ),
                        ),
                      ),
                      userImage != null
                          ? ClipRRect(
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
                            )
                          : Container(
                              child: Image.asset(
                                'assets/settings/ic_setting_logo.png',
                                fit: BoxFit.cover,
                                width: 44,
                                height: 44,
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
                        GestureDetector(
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
                              // dbHelper.getPendingBodyOfWaterData();
                              // dbHelper.getAllPendingVesselData();
                              // dbHelper.getAllPendingEquipmentData();
                              fetchCountSimpleList();
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
                                color: AppColor.BLACK_COLOR,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 24.0, vertical: 8.0),
                          padding: EdgeInsets.symmetric(horizontal: 0.0),
                          child: Text(
                            lang == "en" ? welcomeSubTitleEn : welcomeSubTitleEs,
                            style: TextStyle(
                              fontSize: TextSize.subjectTitle,
                              color: AppColor.BLACK_COLOR,
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
                                  fontFamily: "WorkSans"),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),

                        GestureDetector(
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
                                  fontFamily: "WorkSans"),
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

                        ListView.builder(
                          itemCount:
                              inspectionList != null ? inspectionList.length : 0,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            if (inspectionList[index]['disabled'] != null &&
                                inspectionList[index]['disabled']) {
                              return Container();
                            } else {
                              var inspectionListData = inspectionList[index]
                                      ['txt'][lang] ??
                                  inspectionList[index]['txt']['en'];
                              return Container(
                                margin: EdgeInsets.only(
                                    left: 16.0, right: 16.0, top: 24.0),
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(32.0))),
                                height: 180,
                                child: Stack(
                                  fit: StackFit.expand,
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(32.0))),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(32.0),
                                        child: Image.asset(
                                          index % 3 == 0
                                              ? 'assets/welcome/ic_welcome_background.png'
                                              : index % 2 == 0
                                                  ? 'assets/welcome/ic_welcome_background2.png'
                                                  : 'assets/welcome/ic_welcome_background1.png',
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      child: Text(
                                                        '${inspectionListData['title']}',
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          color: AppColor
                                                              .BLACK_COLOR,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontStyle:
                                                              FontStyle.normal,
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
                                                      height: 64.0,
                                                      width: 64.0,
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              GestureDetector(
                                                onTap: () async {
                                                  try {
                                                    var inspectionName =
                                                        "${inspectionListData['title']}";
                                                    PreferenceHelper
                                                        .setPreferenceData(
                                                            PreferenceHelper
                                                                .INSPECTION_NAME,
                                                            "$inspectionName");

                                                    print(
                                                        "InspectionName===>>>$inspectionName");
                                                  } catch (e) {
                                                    print(
                                                        "LocationNameNotFoundException====>>>>$e");
                                                  }

                                                  getInspectionDetail(
                                                      inspectionList[index]
                                                          ['inspectiondefid']);
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                                  decoration: BoxDecoration(
                                                      gradient:
                                                          LinearGradient(colors: [
                                                        Color(0xff013399),
                                                        Color(0xffBC96E6),
                                                      ]),
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
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 12, vertical: 8),
                                                decoration: BoxDecoration(
                                                    color: Color(0xffE5E5E5),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                16.0))),
                                                child: Center(
                                                  child: Text(
                                                    inspectionList[index]
                                                                ['accessname'] ==
                                                            "Basic Safety"
                                                        ? lang == "en"
                                                            ? basicEn
                                                            : basicEs
                                                        : '${inspectionList[index]['accessname']}',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Color(0xff808080),
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w700,
                                                      fontStyle: FontStyle.normal,
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
                                          child: GestureDetector(
                                            onTap: () {
                                              getInspectionDetail(
                                                  inspectionList[index]
                                                      ['inspectiondefid']);
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
            _progressHUD
          ],
        ),
      ),
    );
  }

  void getProfileDetail() async {
    FocusScope.of(context).requestFocus(FocusNode());
    _progressHUD.state.show();
    var response = await request.getAuthRequest("auth/me");

    _progressHUD.state.dismiss();
    if (response != null) {
      if (response['success'] != null && !response['success']) {
        if(response['reason'] == "Invalid JWT Token" || response['reason'] == "Expired JWT Token"){
          PreferenceHelper.clearUserPreferenceData(context);
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

        if(response['preferences'] != null) {
          PreferenceHelper.setPreferenceData(PreferenceHelper.LANGUAGE, response['preferences']['lang'] ?? "en");
          PreferenceHelper.setPreferenceData(PreferenceHelper.TIME_FORMAT, response['preferences']['TimeFormat'] ?? "hh:mm a");
          PreferenceHelper.setPreferenceData(PreferenceHelper.DATE_FORMAT, response['preferences']['DateFormat'] ?? "dd-mm-yyyy");
        }

        if(response['roles'] != null) {
          if(response['roles'].runtimeType == List) {
            PreferenceHelper.setRoleData(response['roles'].contains("Owner"));
          }
        }
        getInspectionTemplateList();
      }
    }
  }

  Future getInspectionTemplateList() async {
    // _progressHUD.state.show();
    var response = await request.getAuthRequest("auth/buildinspection");

    _progressHUD.state.dismiss();

    if (response != null) {
      print(response.runtimeType);
      if (response is List<dynamic>) {
        setState(() {
          inspectionList = [];
          inspectionList = response;
        });

        // insertSimpleListIds();
      } else {
        if (response['success'] != null && !response['success']) {
          CustomToast.showToastMessage('${response['reason']}');
        }
      }
    }
  }

  Future getInspectionDetail(inspectionDefId) async {
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

        ///Start inspection
        openNextScreen(inspectionDefId, transformedData);
      } catch (e) {
        print("Error API====$e");
      }
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

      log("TransformedData====>>>>(${encoder.convert(transformedData)})}");
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
        PreferenceHelper.setPreferenceData(
            PreferenceHelper.INSPECTION_ID, "${response['inspectionid']}");
        InspectionPreferences.clearPreferenceData(
            InspectionPreferences.INSPECTION_DATA);
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
        log("Length ==== ${response.length}");
        var result = await dbHelper.getTotalCountSimpleList();

        print("Result===${result[0]['NUM'].runtimeType}");

        if(response.length != result[0]['NUM']){
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
            await dbHelper.insertAllSimpleListRecord(simpleListData);
          }
        }
      } else if (response['success'] != null && !response['success']) {
        CustomToast.showToastMessage('${response['reason']}');
      }
    }
  }

  void fetchAllSimpleList() async {
    FocusScope.of(context).requestFocus(FocusNode());
    _progressHUD.state.show();
    var response = await request.getAuthRequest("auth/simplelist");

    _progressHUD.state.dismiss();
    if (response != null) {
      if(response.runtimeType == List) {
        final dbHelper = DatabaseHelper.instance;
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
          await dbHelper.insertAllSimpleListRecord(simpleListData);
        }
      } else if (response['success'] != null && !response['success']) {
        CustomToast.showToastMessage('${response['reason']}');
      }
    }
  }
}

//(nsResult)=>{
//	var ix=0;
//	var build=(container)=>{
//		container.children=[];
//		if(container.rgt - container.lft < 2) {
//			return;
//		}
//		while((++ix < nsResult.length) && (nsResult[ix].lft > container.lft) && (nsResult[ix].rgt < container.rgt)) {
//			container.children.push(nsResult[ix]);
//			build(nsResult[ix]);
//		}
//
//		if(ix<nsresult.length) {
//			ix--;
//		}
//	}
//	if(nsResult.length > 0) {
//		build(nsResult[0]);
//		return nsResult[0];
//	}
//	return null;
//}
