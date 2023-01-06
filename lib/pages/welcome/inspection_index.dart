import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dottie_inspector/connection_mixin.dart';
import 'package:dottie_inspector/database/database_helper.dart';
import 'package:dottie_inspector/inspectionPreferences/inspection_preferences.dart';
import 'package:dottie_inspector/pages/dynamicInspection/dynamic_complete_inspection_screen.dart';
import 'package:dottie_inspector/pages/dynamicInspection/dynamic_general_page.dart';
import 'package:dottie_inspector/pages/inspectionMain/vesselEquipmentInventory/vessel_equipment_inventory_selection_screen.dart';
import 'package:dottie_inspector/pages/inspectionMain/vesselInventory/vessel_inventory_selection_screen.dart';
import 'package:dottie_inspector/pages/signInPages/login_page_1.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/SlideRightRoute.dart';
import 'package:dottie_inspector/utils/custom_toast.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:dottie_inspector/utils/empty_ios_appbar.dart';
import 'package:dottie_inspector/utils/globalInstance.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/utils/inspection_utils.dart';
import 'package:dottie_inspector/utils/language.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:dottie_inspector/widget/GradientText.dart';
import 'package:dottie_inspector/widget/custome_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InspectionIndexScreen extends StatefulWidget {
  final inspectionId;
  final lastUpdated;
  const InspectionIndexScreen({Key key, @required this.inspectionId, @required this.lastUpdated}) : super(key: key);

  @override
  _InspectionIndexScreenState createState() => _InspectionIndexScreenState();
}

class _InspectionIndexScreenState extends State<InspectionIndexScreen> with MyConnection {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final dbHelper = DatabaseHelper.instance;

  String lang = "en";
  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;
  List inspectionList;
  List childData = [];
  var customerName = "";
  var serviceAddress = "";
  var serviceImage = "";

  List answerList = [];
  List bodiesOfWaterList = [];
  List vesselList = [];
  List equipmentList = [];
  List generalEquipmentList = [];
  List allVesselEquipmentList = [];

  List transformedData;

  bool isIos = Platform.isIOS;
  bool isDarkMode = false;
  Color themeColor = AppColor.BLACK_COLOR;

  bool _isInternetAvailable = true;

  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

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

    initConnectivity();

    getPreferenceData();
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

  void setPreferenceData() async {
    var language = await PreferenceHelper.getPreferenceData(PreferenceHelper.LANGUAGE) ?? "en";
    setState(() {
      lang = language;
      childData = [];
    });

    for(int i=0; i < transformedData.toList().length; i++) {
      var labelData = {
        "blocktype": transformedData[i]['blocktype'],
        "questionid": transformedData[i]['questionid'],
        "questiontype": transformedData[i]['questiontype'],
        "txt": transformedData[i]['txt'],
        "vessellist": vesselList,
        "bodyofwaterlist": bodiesOfWaterList,
        "equipmentlist": equipmentList,
        "index": i,
        "isExpand": false,
        "status": true,
        "blockimage": transformedData[i]['blockimage'],
        "blocksvgicon": transformedData[i]['blocksvgicon']
      };

      setState(() {
        if((transformedData[i]['blocktype'] == 'vessel inventory' ||
            (transformedData[i]['blocktype'] == 'equipment inventory' && (transformedData[i]['txt']['en'] != null && transformedData[i]['txt']['en']['reporttag'] != 'Vessel Equipment')))
            && transformedData[i]['blocktype'] != 'question') {
          childData.add(labelData);
        }

        for(int j=0; j<equipmentList.length; j++) {
          for(int k=0; k<transformedData.length; k++) {
            if (transformedData[k]['equipmentid'] == equipmentList[j]['equipmentid']) {
              equipmentList[j]["index"] = k;
              break;
            }
          }
        }

        for(int j=0; j<allVesselEquipmentList.length; j++) {
          for(int k=0; k<transformedData.length; k++) {
            if (transformedData[k]['equipmentid'] == allVesselEquipmentList[j]['equipmentid']) {
              allVesselEquipmentList[j]["index"] = k;
              break;
            }
          }
        }

        for(int j=0; j<vesselList.length; j++) {
          for (int k = 0; k < transformedData.length; k++) {
            if (transformedData[k]['vesselid'] == vesselList[j]['vesselid']) {
              vesselList[j]["index"] = k;
              break;
            }
          }

          // for (int k = 0; k < transformedData.length; k++) {
          //   for(int )
          //   if (transformedData[k]['vesselid'] == vesselList[j]['vesselid']) {
          //     vesselList[j]["index"] = k;
          //     break;
          //   }
          // }
        }


        if(transformedData[i]['blocktype'] == 'section') {
          if((transformedData[i]['vesselid'] == null && transformedData[i]['equipmentid'] != null) ) {
            log("EquipmentData");
          } else if(transformedData[i]['vesselid'] != null && transformedData[i]['equipmentid'] == null) {
            log("VesselData");
          } else {
            childData.add(labelData);
          }
        }
      });
    }

    log("VesselList123====$vesselList");
    log("EquipmentList123 ==== $equipmentList");
    log("VesselEquipmentList123 ==== $allVesselEquipmentList");
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
    var inspectionId = widget.inspectionId;
    var lastUpdated = widget.lastUpdated;

    setState(() {
      _connectivityResult = result;
      if (_connectivityResult == ConnectivityResult.none) {
        _isInternetAvailable = false;
        loadStartedInspectionDetailFromLocalDb(inspectionId);
      } else if ((_connectivityResult == ConnectivityResult.mobile) || (_connectivityResult == ConnectivityResult.wifi)) {
        _isInternetAvailable = true;
        getInspectionDetails(inspectionId, lastUpdated);
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode ? AppColor.BLACK_COLOR : AppColor.PAGE_COLOR,
      appBar: EmptyAppBar(isDarkMode: isDarkMode),
      body: Stack(
        fit: StackFit.loose,
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: InkWell(
                  onTap: () async  {
                    Navigator.pop(context);
                    // getPreferenceData();
                    // SharedPreferences prefs = await SharedPreferences.getInstance();
                    // String refreshToken = await PreferenceHelper.getPreferenceData(PreferenceHelper.REFRESH_TOKEN);
                    //
                    // log("TestRefreshToken====$refreshToken");
                  },
                  child: Container(
                    child: Image.asset(
                      'assets/ic_close_button.png',
                      fit: BoxFit.cover,
                      width: 48,
                      height: 48,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
              childData != null && childData.length > 0
              ? Flexible(
                child: SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 12),
                          child: GradientText(
                            "$customerName",
                            style: TextStyle(
                                fontSize: TextSize.subjectTitle,
                                fontWeight: FontWeight.w700
                            ),
                            gradient: LinearGradient(
                                colors: AppColor.gradientColor(1.0)
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: Text(
                            "$serviceAddress",
                            style: TextStyle(
                              fontSize: TextSize.pageTitleText,
                              color: themeColor,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.normal,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 16),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                maxHeight: 230.0
                            ),
                            child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32.0),
                                ),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(32.0),
                                    child: Container(
                                      height: 230,
                                      color: AppColor.WHITE_COLOR,
                                      child:  serviceImage == ""
                                      ? Container(
                                        padding: EdgeInsets.all(1),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(16.0),
                                          child: Image.asset(
                                            'assets/section_fallback_image.png',
                                            fit: BoxFit.cover,
                                            height: 230,
                                          ),
                                        ),
                                      )
                                      : _isInternetAvailable
                                      ? Image.network(
                                        "$serviceImage",
                                        height: 230,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress){
                                          if(loadingProgress == null) {
                                            return child;
                                          } else {
                                            return Container(
                                              height: 230,
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
                                      )
                                      :  Container(
                                        padding: EdgeInsets.all(1),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(16.0),
                                          child: Image.asset(
                                            'assets/section_fallback_image.png',
                                            fit: BoxFit.cover,
                                            height: 230,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                            ),
                          ),
                        ),

                        Flexible(
                          fit: FlexFit.loose,
                          child: ListView.builder(
                            itemCount: childData.length,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return IgnorePointer(
                                ignoring: false,
                                child: childData[index]['blocktype'] == "vessel inventory"
                                        || childData[index]['blocktype'] == "equipment inventory"
                                    // || childData[index]['txt']['en']['reporttag'] == "Equipment"
                                ? Container(
                                  margin: EdgeInsets.only(bottom: 8),
                                  padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 12.0),
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(32),
                                      // color: AppColor.TYPE_PRIMARY.withOpacity(0.08)
                                    color: isDarkMode
                                        ? Color(0xff1F1F1F)
                                        : AppColor.TYPE_PRIMARY.withOpacity(0.08),
                                  ),
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                        dividerColor: Colors.transparent,
                                        splashColor: AppColor.TRANSPARENT,
                                        backgroundColor: AppColor.TYPE_PRIMARY.withOpacity(0.08)
                                    ),
                                    child: ExpansionTile(
                                      title: getExpansionTileTitle(childData[index]['status'], childData[index]['txt']['en']['reporttag'], childData[index]),
                                      initiallyExpanded: false,
                                      maintainState: true,
                                      childrenPadding: EdgeInsets.symmetric(vertical: 12),
                                      onExpansionChanged: (value) {
                                        setState(() {
                                          childData[index]['isExpand'] = value;
                                        });
                                      },
                                      trailing: getTrailingIcon(childData[index]['isExpand']),
                                      children: [
                                        childData[index]['blocktype'] == "vessel inventory"
                                        ? Container(
                                          margin: vesselList.length == 0
                                                    ? EdgeInsets.only(top: 0.0, bottom: 0.0,left: 16, right: 16)
                                                    : EdgeInsets.only(top: 0.0, bottom: 16.0,left: 16, right: 16),
                                          width: MediaQuery.of(context).size.width,
                                          child: ListView.builder(
                                            itemCount: vesselList != null ? vesselList.length : 0,
                                            shrinkWrap: true,
                                            physics: NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, subIndex) {
                                              return Container(
                                                margin: EdgeInsets.only(top: 8),
                                                padding: vesselList.length == 0
                                                    ? EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0)
                                                    : EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(32),
                                                    color: isDarkMode
                                                     ? Color(0xff1f1f1f)
                                                        : AppColor.TYPE_PRIMARY.withOpacity(0.04)
                                                ),
                                                child: ExpansionTile(
                                                  title: getExpansionTileTitle(
                                                    true,
                                                    vesselList[subIndex]['vesselname'],
                                                    childData[index]
                                                  ),
                                                  trailing: getTrailingIcon(vesselList[subIndex]['isExpand'] ?? false),
                                                  childrenPadding: EdgeInsets.symmetric(vertical: 12),
                                                  onExpansionChanged: (value) {
                                                    setState(() {
                                                      vesselList[subIndex]['isExpand'] = value;
                                                    });
                                                  },
                                                  children: [
                                                    getSectionTitle(
                                                        true,
                                                        vesselList[subIndex]['vesselname'],
                                                        isChildren: true,
                                                        data: childData[index],
                                                        callBack: (){
                                                          openNextScreen(vesselList[subIndex]['index']);
                                                        },
                                                        isNormalTitle: false
                                                    ),
                                                    ListView.builder(
                                                      //bodiesOfWaterList[i]['vessels'][j]['equipment']
                                                      // itemCount: allVesselEquipmentList != null ? allVesselEquipmentList.length : 0,
                                                      itemCount: vesselList[subIndex]['equipment'] != null ? vesselList[subIndex]['equipment'].length : 0,
                                                      shrinkWrap: true,
                                                      physics: NeverScrollableScrollPhysics(),
                                                      itemBuilder: (context, index1) {
                                                        var vesselEquipmentData = vesselList[subIndex]['equipment'][index1];
                                                        log("EquipmentData===$vesselEquipmentData");
                                                        return getSectionTitle(
                                                            true,
                                                            vesselEquipmentData['equipmentdescription'],
                                                            isChildren: true,
                                                            data: childData[index],
                                                            callBack: (){
                                                              // openNextScreen(vesselEquipmentData['index']);
                                                            },
                                                            isNormalTitle: false
                                                        );
                                                      },
                                                    ),

                                                    getExtraVesselEquipment(
                                                        "Add Equipment",
                                                        () async {
                                                          var inspectionData =  await getInspectionData(equipmentList[index]['index']);
                                                          Navigator.push(
                                                              context,
                                                              SlideRightRoute(
                                                                  page: VesselEquipmentInventorySelectionPage(
                                                                    inspectionData: inspectionData,
                                                                  )
                                                              )
                                                          );
                                                    })
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                        : ListView.builder(
                                          itemCount: equipmentList != null ? equipmentList.length : 0,
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, subIndex) {
                                            return getSectionTitle(
                                                true,
                                                equipmentList[subIndex]['equipmentdescription'],
                                                isChildren: true,
                                                data: childData[index],
                                                callBack: (){
                                                  openNextScreen(equipmentList[subIndex]['index']);
                                                },
                                                isNormalTitle: false
                                            );
                                          },
                                        ),

                                        // childData[index]['blocktype'] == "vessel inventory"
                                        // ? ListView.builder(
                                        //   itemCount: bodiesOfWaterList != null ? bodiesOfWaterList.length : 0,
                                        //   shrinkWrap: true,
                                        //   physics: NeverScrollableScrollPhysics(),
                                        //   itemBuilder: (context, index) {
                                        //     return getSectionTitle(true, equipmentList[index]['equipmentdescription'], true);
                                        //   },
                                        // )
                                        // : ListView.builder(
                                        //   itemCount: equipmentList != null ? equipmentList.length : 0,
                                        //   shrinkWrap: true,
                                        //   physics: NeverScrollableScrollPhysics(),
                                        //   itemBuilder: (context, index) {
                                        //     return getSectionTitle(true, equipmentList[index]['equipmentdescription'], true);
                                        //   },
                                        // ),

                                        childData[index]['blocktype'] == "vessel inventory"
                                        ? getExtraVesselEquipment(
                                            "Add Vessel",
                                            () async {
                                              var inspectionData = await getInspectionData(childData[index]['index']);
                                              Navigator.push(
                                                context,
                                                SlideRightRoute(
                                                  page: VesselInventorySelectionPage(
                                                    vesselList: vesselList,
                                                    bodyOfWaterList: bodiesOfWaterList,
                                                    inspectionData: inspectionData,
                                                  )
                                                )
                                              );
                                            },
                                            margin: 16.0)
                                        : getExtraVesselEquipment(
                                            "Add Equipment",
                                            () async {
                                              log("Ind====${childData[index]['index']}");
                                              var inspectionData = await getInspectionData(childData[index]['index']);
                                              // log("InspectionData====$inspectionData");
                                              Navigator.push(
                                                  context,
                                                  SlideRightRoute(
                                                      page: VesselEquipmentInventorySelectionPage(
                                                        inspectionData: inspectionData,
                                                      )
                                                  )
                                              );
                                            },
                                            margin: 16.0)
                                      ],
                                    ),
                                  ),
                                )
                                : InkWell(
                                  onTap: () {

                                  },
                                  child: getSectionTitle(
                                      childData[index]['status'],
                                      childData[index]['txt']['en']['reporttag'],
                                      isChildren: false,
                                      data: childData[index],
                                      callBack: () {
                                         openNextScreen(childData[index]['index']);
                                    }
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        SizedBox(height: 16,)
                      ],
                    ),
                  ),
                ),
              )
              : Container(),
            ],
          ),

          _progressHUD
        ]
      ),
    );
  }

  Future getInspectionDetails(inspectionId, lastUpdated) async {
    _progressHUD.state.show();
    var response = await request.getAuthRequest("auth/buildinspection/inspection/$inspectionId");

    _progressHUD.state.dismiss();

    if (response != null) {
      print(response.runtimeType);
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
        var inspectionData = {
          "inspectionid": inspectionId,
          "lastUpdated": "$lastUpdated",
          "payload": "${json.encode(response).replaceAll("'", "@@@")}"
        };

        dbHelper.insertStartedInspectionDetailData(inspectionData);
        saveEvent(response);
      }
    }
  }

  Future loadStartedInspectionDetailFromLocalDb(inspectionId) async {
    try{
      var response = await dbHelper.getSingleStartedInspectionData(inspectionId);
      var resultList = response.toList();

      log("responseType===${resultList.runtimeType}");

      if(resultList.length > 0) {
        var resultData = resultList[0]['payload'].toString().replaceAll("@@@", "'");
        log("ResponseHelperType111====${resultData.runtimeType}");

        var resultData1 = json.decode(resultData.toString());
        // log("ResponseHelper====$resultData");
        log("ResponseHelperType====${resultData1.runtimeType}");

        saveEvent(resultData1);
      } else {
        HelperClass.displayDialog(context, "Inspection detail not found for this inspection, please check internet connection or try different inspection");
      }
    } catch(e) {
      log("loadStartedInspectionDetailFromLocalDbStackTrace===$e");
    }
  }

  saveEvent(response) async {
    try{

      var inspectionId = "${response['inspection']['inspectionid']??"-1"}";
      var inspectionDefId = "${response['inspection']['inspectiondefid']??"0"}";

      try {
        await dbHelper.insertInspectionId({
          "url": '',
          "verb": 'POST',
          "inspectionlocalid": "$inspectionId",
          "inspectionserverid": "$inspectionId",
          "isinspectionserverid": 1,
          "serviceaddressid": "",
          "servicelocalid": "",
          "inspectiondefid": inspectionDefId ?? "1",
          "payload": "",
        });
      } catch(e) {
        log("InspectionIndexScreenInsertInspectionIdStackTrace===$e");
      }


      setState(() {
        PreferenceHelper.clearPreferenceData(PreferenceHelper.WATER_VESSEL_BODIES);
        PreferenceHelper.clearPreferenceData(PreferenceHelper.WATER_VESSEL_BODIES_ITEM);
        PreferenceHelper.clearPreferenceData(PreferenceHelper.WATER_SELECTED_BODIES);
        PreferenceHelper.clearPreferenceData(PreferenceHelper.EQUIPMENT_ITEMS);
        PreferenceHelper.clearPreferenceData(PreferenceHelper.ANSWER_LIST);
        PreferenceHelper.clearPreferenceData(PreferenceHelper.TEMPLATE_LIST);
        InspectionPreferences.clearPreferenceData(InspectionPreferences.INSPECTION_DATA);
        InspectionPreferences.clearPreferenceData(InspectionPreferences.INSPECTION_CHILD_DATA);

        customerName = response['inspection']["firstname"] ?? "" + response['inspection']["lastname"] ?? "";
        serviceAddress = response['inspection']['address'] != null
            ? "${response['inspection']['address']['serviceaddressnick'] ?? ""}, ${response['inspection']['address']['statename'] ?? ""}"
            : "";
        serviceImage = response['inspection']['address'] == null
            ? ""
            : response['inspection']['address']['image'] != null
            ? "${GlobalInstance.apiBaseUrl}${response['inspection']['address']['image']['path'] ?? ""}"
            : "";

        var serviceId = response['inspection']['addressid'] != null
            ? response['inspection']['addressid']
            : "";

        answerList = response['inspection']['answers'] ?? [];
        bodiesOfWaterList = response['bodiesofwater'] ?? [];
        equipmentList = response['equipment'] ?? [];

        List allEquipmentList = [];
        allEquipmentList.addAll(equipmentList);

        for(int i=0; i<bodiesOfWaterList.length; i++) {
          bodiesOfWaterList[i]['serviceaddressid'] = serviceId;
          if(bodiesOfWaterList[i]['vessels'] != null) {
            for (int j = 0; j < bodiesOfWaterList[i]['vessels'].length; j++) {
              bodiesOfWaterList[i]['vessels'][j]['isExpand'] = false;
              var vesselType = {
                "simplelistid": bodiesOfWaterList[i]['vessels'][j]['vesseltypeid'] != null ? bodiesOfWaterList[i]['vessels'][j]['vesseltypeid'] : 0,
                "label": "${bodiesOfWaterList[i]['vessels'][j]['vesselname']}"
              };
              bodiesOfWaterList[i]['vessels'][j]['vesseltype'] = vesselType;
              bodiesOfWaterList[i]['vessels'][j]['bodyofwaterid'] = bodiesOfWaterList[i]['bodyofwaterid'];

              for(int k=0; k<bodiesOfWaterList[i]['vessels'][j]['equipment'].length; k++) {
                bodiesOfWaterList[i]['vessels'][j]['equipment'][k]['vesselid'] = bodiesOfWaterList[i]['vessels'][j]['vesselid'];
                allEquipmentList.add(bodiesOfWaterList[i]['vessels'][j]['equipment'][k]);
                allVesselEquipmentList.add(bodiesOfWaterList[i]['vessels'][j]['equipment'][k]);

                var equipmentType = {
                  "simplelistid": allVesselEquipmentList[j]['equipmenttypeid'] != null ? allVesselEquipmentList[j]['equipmenttypeid'] : 0,
                  "equipmenttype": "${allVesselEquipmentList[j]['equipmentdescription']}"
                };

                bodiesOfWaterList[i]['vessels'][j]['equipment'][k]['equipmenttype'] = equipmentType;
                bodiesOfWaterList[i]['vessels'][j]['equipment'][k]['bodyofwater'] = equipmentType;
                bodiesOfWaterList[i]['vessels'][j]['equipment'][k]['meta'] = equipmentType;
                bodiesOfWaterList[i]['vessels'][j]['equipment'][k]['vessel'] = bodiesOfWaterList[i]['vessels'][j]['vesselid'] == null ? [] : [bodiesOfWaterList[i]['vessels'][j]['vesselid']];
              }
            }
            vesselList.addAll(bodiesOfWaterList[i]['vessels']);
          }
        }

        for(int j=0; j<allVesselEquipmentList.length; j++) {
          allVesselEquipmentList[j]['bodyofwater'] = [];
          allVesselEquipmentList[j]['meta'] = [];
          allVesselEquipmentList[j]['vessel'] = allVesselEquipmentList[j]['vesselid'] == null ? [] : [allVesselEquipmentList[j]['vesselid']];

          var equipmentType = {
            "simplelistid": allVesselEquipmentList[j]['equipmenttypeid'] != null ? allVesselEquipmentList[j]['equipmenttypeid'] : 0,
            "equipmenttype": "${allVesselEquipmentList[j]['equipmentdescription']}"
          };
          allVesselEquipmentList[j]['equipmenttype'] = equipmentType;
        }

        for(int i=0; i<allEquipmentList.length; i++) {
          allEquipmentList[i]['bodyofwater'] = [];
          allEquipmentList[i]['meta'] = [];
          allEquipmentList[i]['vessel'] = allEquipmentList[i]['vesselid'] == null ? [] : [allEquipmentList[i]['vesselid']];

          var equipmentType = {
            "simplelistid": allEquipmentList[i]['equipmenttypeid'] != null ? allEquipmentList[i]['equipmenttypeid'] : 0,
            "equipmenttype": "${allEquipmentList[i]['equipmentdescription']}"
          };
          allEquipmentList[i]['equipmenttype'] = equipmentType;
        }

        log("VesselList====$vesselList");
        log("EquipmentList123456====$allEquipmentList");

        PreferenceHelper.setPreferenceData(
            PreferenceHelper.WATER_SELECTED_BODIES,
            json.encode(bodiesOfWaterList)
        );

        ///All Equipments
        PreferenceHelper.setPreferenceData(
            PreferenceHelper.EQUIPMENT_ITEMS,
            json.encode(allEquipmentList)
        );

        List inspectionDefList = response['inspectiondef'] ?? [];
        var childrenTemplateData = adjacencyTransform(inspectionDefList);

        PreferenceHelper.clearPreferenceData(PreferenceHelper.INSPECTION_ID);
        PreferenceHelper.setPreferenceData(PreferenceHelper.INSPECTION_ID, "$inspectionId");

        PreferenceHelper.clearPreferenceData(PreferenceHelper.PDF_TOKEN);
        PreferenceHelper.setPreferenceData(PreferenceHelper.PDF_TOKEN, "${response['inspection']['pdftoken']}");

        var answerRecord;
        for(int i=0; i<answerList.length; i++) {
          var imageId = answerList[i]['image']['imageid'] ?? 0;
          var imageUrl = answerList[i]['image']['path'] ?? "";

          answerList[i]['proxyid'] = 0;
          answerList[i]['inspectionid'] = int.parse(inspectionId);
          answerList[i]['inspectiondefid'] = int.parse(inspectionDefId);
          answerList[i]['image_id'] = imageId;
          answerList[i]['imageurl'] = imageUrl;
          answerList[i]['imagefileurl'] = "";
          answerList[i]['payload'] = "";

          answerRecord = {
            "proxyid": 0,
            "inspectionid": int.parse(inspectionId),
            "inspectiondefid": int.parse(inspectionDefId),
            "image_id": imageId,
            "imageurl": imageUrl,
            "imagefileurl": "",
            "payload": "",
            "questionid": answerList[i]['questionid'],
            "equipmentid": answerList[i]['equipmentid'],
            "vesselid": answerList[i]['vesselid'],
            "bodyofwaterid": answerList[i]['bodyofwaterid'],
            "simplelistid": answerList[i]['simplelistid'],
            "answer": answerList[i]['answer'],
          };
          dbHelper.insertUpdateAnswerRecord(answerRecord);
        }

        ///Answer save
        PreferenceHelper.clearPreferenceData(PreferenceHelper.ANSWER_LIST);
        PreferenceHelper.setPreferenceData(PreferenceHelper.ANSWER_LIST, json.encode(answerList));

        // log("AnswerList====$answerList");
        var transformedData1 = HelperClass.unroll(int.parse(inspectionId), childrenTemplateData, bodiesOfWaterList, allEquipmentList, answerList);

        const JsonEncoder encoder = JsonEncoder.withIndent('  ');
        log("TransformedData====>>>>${encoder.convert(transformedData1)}");

        InspectionPreferences.setPreferenceData(
            InspectionPreferences.INSPECTION_CHILD_DATA,
            json.encode(childrenTemplateData));

        transformedData = transformedData1['flow'];
        ///Save inspection data
        InspectionPreferences.setPreferenceData(
            InspectionPreferences.INSPECTION_DATA,
            json.encode(transformedData1['flow'])
        );
        setPreferenceData();
      });
    }catch(e) {
      log("SaveEventStackTrace===$e");
    }
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

  Widget getSectionTitle(status, title, {isNormalTitle = true, isChildren = false, data,  Function callBack, boxColor}) {
    var color = boxColor ?? AppColor.TYPE_PRIMARY.withOpacity(0.08);
    var svgRawImage;
    var bgImage;
    svgRawImage = data['blocksvgicon'];
    bgImage = data['blockimage'] != null ? data['blockimage']['path'].toString().substring(1) ?? null : null;

    return GestureDetector(
      onTap: callBack != null ? callBack : (){},
      child: Container(
        margin: isChildren ? EdgeInsets.only(left: 8, right: 8, bottom: 8) : EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.symmetric(horizontal: isChildren ? 8.0 : 16.0, vertical: 12.0),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            // color: isChildren
            //   ? AppColor.TYPE_PRIMARY.withOpacity(0.04)
            //   : AppColor.TYPE_PRIMARY.withOpacity(0.06)
            color: isDarkMode
            ? Color(0xff1F1F1F)
            : AppColor.TYPE_PRIMARY.withOpacity(0.08),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Stack(
            //   children: [
            //     ClipRRect(
            //       borderRadius: BorderRadius.circular(24),
            //       child: Image(
            //         image: AssetImage(
            //             status
            //                 ? 'assets/ic_side_menu_icon.png'
            //                 : 'assets/ic_side_menu_uncompleted.png'
            //         ),
            //         fit: BoxFit.cover,
            //         height: 48.0,
            //         width: 48.0,
            //       ),
            //     ),
            //     ClipRRect(
            //       borderRadius: BorderRadius.circular(24),
            //       child: Container(
            //         color: status
            //             ? AppColor.TRANSPARENT
            //             : AppColor.TYPE_PRIMARY.withOpacity(0.8),
            //         height: 48.0,
            //         width: 48.0,
            //       ),
            //     ),
            //   ],
            // ),

            _isInternetAvailable && bgImage != null
                ? Container(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              padding: EdgeInsets.all(1),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24.0),
                    child: Image.network(
                      "${GlobalInstance.apiBaseUrl}$bgImage",
                      fit: BoxFit.cover,
                      width: 44,
                      height: 44,
                      loadingBuilder: (context, child, loadingProgress){
                        if(loadingProgress == null) {
                          return child;
                        } else {
                          return Container(
                            height: 44,
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

                  svgRawImage != null
                      ? Container(
                    child: SvgPicture.string('$svgRawImage'),
                    height: 24.0,
                    width: 24.0,
                  )
                      : Container(),
                ],
              ),
            )
                : Container(
              margin: EdgeInsets.symmetric(vertical: 0.0),
              padding: EdgeInsets.all(1),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.0),
                child: Image.asset(
                  'assets/section_fallback_image.png',
                  fit: BoxFit.cover,
                  height: 44,
                  width: 44,
                ),
              ),
            ),

            SizedBox(width: 8,),
            Expanded(
              child: Text(
                "$title",
                style: TextStyle(
                  fontSize: TextSize.headerText,
                  color: status
                      ? themeColor
                      : themeColor.withOpacity(0.3),
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            isNormalTitle
                ? Container()
                : getTrailingIcon(false, isAccord: true)
          ],
        ),
      ),
    );
  }

  Widget getExpansionTileTitle(status, title, data) {
    var svgRawImage;
    var bgImage;
    svgRawImage = data['blocksvgicon'];
    bgImage = data['blockimage'] != null ? data['blockimage']['path'].toString().substring(1) ?? null : null;

    return Expanded(
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Stack(
            //   children: [
            //     ClipRRect(
            //       borderRadius: BorderRadius.circular(24),
            //       child: Image(
            //         image: AssetImage(
            //             status
            //                 ? 'assets/ic_side_menu_icon.png'
            //                 : 'assets/ic_side_menu_uncompleted.png'
            //         ),
            //         fit: BoxFit.cover,
            //         height: 48.0,
            //         width: 48.0,
            //       ),
            //     ),
            //     ClipRRect(
            //       borderRadius: BorderRadius.circular(24),
            //       child: Container(
            //         color: status
            //             ? AppColor.TRANSPARENT
            //             : AppColor.TYPE_PRIMARY.withOpacity(0.8),
            //         height: 48.0,
            //         width: 48.0,
            //       ),
            //     ),
            //   ],
            // ),

            _isInternetAvailable && bgImage != null
                ? Container(
              margin: EdgeInsets.symmetric(vertical: 32.0),
              padding: EdgeInsets.all(1),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.network(
                      "${GlobalInstance.apiBaseUrl}$bgImage",
                      fit: BoxFit.cover,
                      width: 44,
                      height: 44,
                      loadingBuilder: (context, child, loadingProgress){
                        if(loadingProgress == null) {
                          return child;
                        } else {
                          return Container(
                            height: 44,
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

                  svgRawImage != null
                      ? Container(
                    child: SvgPicture.string('$svgRawImage'),
                    height: 24.0,
                    width: 24.0,
                  )
                      : Container(),
                ],
              ),
            )
                : Container(
              margin: EdgeInsets.symmetric(vertical: 0.0),
              padding: EdgeInsets.all(1),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.0),
                child: Image.asset(
                  'assets/section_fallback_image.png',
                  fit: BoxFit.cover,
                  height: 44,
                  width: 44,
                ),
              ),
            ),
            SizedBox(width: 8,),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: TextSize.headerText,
                  color:  themeColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getTrailingIcon(isExpand, {isAccord = false}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Image(
        image: isDarkMode
          ? AssetImage(
            isExpand
                ? 'assets/index/ic_dark_drop_down.png'
                : isAccord
                ? 'assets/index/ic_dark_next.png'
                : 'assets/index/ic_dark_next_drop_down.png'
          )
          : AssetImage(
              isExpand
                  ? 'assets/index/ic_light_drop_down.png'
                  : isAccord
                    ? 'assets/index/ic_light_next.png'
                    : 'assets/index/ic_light_next_drop_down.png'
          ),
        fit: BoxFit.cover,
        height: 36.0,
        width: 36.0,
      ),
    );
  }
  
  Widget getExtraVesselEquipment(type, onPressed, {margin}) {
    return Theme(
      data: Theme.of(context).copyWith(splashColor: Colors.transparent),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          margin: EdgeInsets.only(top: 0.0, bottom: 0.0,left: margin??16, right: margin??16),
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          decoration: BoxDecoration(
            // color: AppColor.THEME_PRIMARY.withOpacity(0.08),
              borderRadius: BorderRadius.all(Radius.circular(32.0)),
              gradient: LinearGradient(
                  colors: AppColor.gradientColor(0.24)
              )
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              Expanded(
                child: GradientText(
                  "$type",
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
                  height: 40.0,
                  width: 40.0,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  void openNextScreen(inspectionIndex) async {
    var listItemData = await InspectionPreferences.getPreferenceData(InspectionPreferences.INSPECTION_DATA);
    var transformedData = json.decode(listItemData);

    print("transformedData====$transformedData");
    var inspectionData;

    if(inspectionIndex == transformedData.length) {
      _progressHUD.state.show();
      var result = await HelperClass.completeInspection(dbHelper);
      _progressHUD.state.dismiss();
      if(result != null){
        Navigator.push(
            context,
            SlideRightRoute(
                page: CompleteInspectionScreen()
            )
        );
      }
    } else {
      var pageName;
      int index;

      print("Index====$inspectionIndex");
      print("Length====${transformedData.length}");
      for (int i = inspectionIndex ?? 0; i < transformedData.length; i++) {
        var data = await InspectionUtils.getInspectionBlockTypeData(transformedData[i], transformedData.length);
        if (data != null) {
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
        if(pageName.runtimeType == DynamicGeneralPage) {
          Navigator.push(
            context,
            SlideRightRoute(
                page: DynamicGeneralPage(
                  inspectionData: inspectionData,
                )
            ),
          );
        } else {
          Navigator.push(
              context,
              SlideRightRoute(
                  page: pageName
              )
          );
        }
      }
    }
  }

  Future<Map> getInspectionData(inspectionIndex) async {
    var listItemData = await InspectionPreferences.getPreferenceData(InspectionPreferences.INSPECTION_DATA);
    var transformedData = json.decode(listItemData);

    print("transformedData====$transformedData");
    Map inspectionData;

    var pageName;
    int index;

    print("Index====$inspectionIndex");
    print("Length====${transformedData.length}");
    for (int i = inspectionIndex ?? 0; i < transformedData.length; i++) {
      var data = await InspectionUtils.getInspectionBlockTypeData(transformedData[i], transformedData.length);
      if (data != null) {
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

      return inspectionData;
    }

    return {};
  }
}
