import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dottie_inspector/connection_mixin.dart';
import 'package:dottie_inspector/database/database_helper.dart';
import 'package:dottie_inspector/inspectionPreferences/inspection_preferences.dart';
import 'package:dottie_inspector/pages/inspectionMain/vesselInventory/vessel_inventory_selection_screen.dart';
import 'package:dottie_inspector/pages/menu/drawer_page.dart';
import 'package:dottie_inspector/pages/menu/index_menu.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/SlideRightRoute.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:dottie_inspector/utils/globalInstance.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/utils/inspection_utils.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:dottie_inspector/widget/bottom_general_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:progress_hud/progress_hud.dart';

import 'dynamic_complete_inspection_screen.dart';

class DynamicGeneralPage extends StatefulWidget {
  static String tag = 'dynamic-general-page';
  final inspectionData;

  const DynamicGeneralPage({Key key, this.inspectionData}) : super(key: key);
  @override
  _DynamicGeneralPageState createState() => _DynamicGeneralPageState();
}

class _DynamicGeneralPageState extends State<DynamicGeneralPage> with MyConnection{
  double progress = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final dbHelper = DatabaseHelper.instance;

  var dynamicData;
  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;
  var svgRawImage;
  var bgImage;
  var inspectionItem;
  var sectionName;

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
    getThemeData();
    getInspectionData();
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

  void getInspectionData() async {
    await Future.delayed(Duration.zero);
    String lang = await PreferenceHelper.getPreferenceData(PreferenceHelper.LANGUAGE);

    setState(() {
      var data = widget.inspectionData;
      dynamicData = data['txt'][lang] ?? data['txt']['en'];
      sectionName = HelperClass.getSectionText(widget.inspectionData);

      svgRawImage = data['blocksvgicon'];
      bgImage = data['blockimage'] != null ? data['blockimage']['path'].toString().substring(1) ?? null : null;

      log("${GlobalInstance.apiBaseUrl}$bgImage");
    });
  }

  void getPreferenceData() async {
    var preferenceData = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ITEM);
    var inspectionData = json.decode(preferenceData);

    setState(() {
      inspectionItem = inspectionData;

      print(inspectionItem);
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: GestureDetector(
                      onTap: () async {
                        _scaffoldKey.currentState.openDrawer();
                        initConnectivity();

                        // var result = await dbHelper.allAnswerRecord();
                        // const JsonEncoder encoder = JsonEncoder.withIndent('  ');
                        // log("AllAnswerRecord====>>>>${encoder.convert(result)}");

                        // var equipmentList = await dbHelper.getAllPendingEquipmentData();
                        //
                        // log("EquipmentList====$equipmentList");
                        // HelperClass.printDatabaseResult();
                        // var bodyOfWaterList = await dbHelper.getPendingBodyOfWaterData();
                        // var vesselList = await dbHelper.getAllPendingVesselData();
                        //
                        // const JsonEncoder encoder = JsonEncoder.withIndent('  ');
                        // log("bodyOfWaterList====>>>>${encoder.convert(bodyOfWaterList)}");
                        // log("vesselList====>>>>${encoder.convert(vesselList)}");
                        //
                        // // log("Water List Data=====>>>>${allBodyOfWaterList.toString()}");
                        // var allBodyOfWaterList = await PreferenceHelper.getPreferenceData(PreferenceHelper.WATER_SELECTED_BODIES);
                        //
                        //
                        // log("Water List Data=====>>>>${encoder.convert(allBodyOfWaterList)}");
                      },
                      child: Container(
                        child: Image.asset(
                          'assets/ic_menu.png',
                          fit: BoxFit.cover,
                          width: 44,
                          height: 44,
                          color: isDarkMode ? AppColor.WHITE_COLOR : AppColor.BLACK_COLOR,
                        ),
                      ),
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: GestureDetector(
                      onTap: () {
                        HelperClass.cancelInspection(context);
                      },
                      child: Image.asset(
                        isDarkMode
                            ? 'assets/ic_dark_close.png'
                            : 'assets/ic_clear.png',
                        fit: BoxFit.cover,
                        width: 44,
                        height: 44,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10.0,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [

                              sectionName != null && sectionName != ""
                                  ? Container(
                                margin: EdgeInsets.only(left: 0.0,right: 0.0, bottom: 8),
                                child: Text(
                                  sectionName,
                                  style: TextStyle(
                                    color: themeColor,
                                    fontSize: TextSize.subjectTitle,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                                  : Container(),

                              Text(
                                dynamicData == null
                                ? ""
                                : dynamicData['title'] != null
                                    ? '${dynamicData['title']}'
                                    : '',
                                style: TextStyle(
                                    color: themeColor,
                                    fontSize: TextSize.pageTitleText,
                                    fontWeight: FontWeight.w700),
                              ),

                              dynamicData == null
                              ? Container()
                              : dynamicData['helpertext'] == null
                              ? Container()
                              : Container(
                                margin: EdgeInsets.only(top: 16),
                                child: Text(
                                  dynamicData == null
                                      ? ""
                                      : dynamicData['helpertext'] != null
                                      ? '${dynamicData['helpertext']}'
                                      : '',
                                  style: TextStyle(
                                      color: themeColor.withOpacity(1.0),
                                      fontSize: TextSize.subjectTitle,
                                      height: 1.3,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),


                           /*   Container(
                                child: SvgPicture.string(svgRawImage),
                              )*/
                            ],
                          ),
                        ),


                        _isInternetAvailable
                        ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            bgImage != null
                                ? Container(
                              margin: EdgeInsets.symmetric(vertical: 32.0),
                              padding: EdgeInsets.all(1),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16.0),
                                    child: /*CachedNetworkImage(
                                      imageUrl: "${GlobalInstance.apiBaseUrl}$bgImage",
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
                                      "${GlobalInstance.apiBaseUrl}$bgImage",
                                      fit: BoxFit.cover,
                                      width: MediaQuery.of(context).size.width,
                                      height: (MediaQuery.of(context).size.width - 32),
                                      loadingBuilder: (context, child, loadingProgress){
                                        if(loadingProgress == null) {
                                          return child;
                                        } else {
                                          return Container(
                                            height: (MediaQuery.of(context).size.width - 32),
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
                                    height: 80.0,
                                    width: 80.0,
                                  )
                                      : Container(),
                                ],
                              ),
                            )
                                : Container(
                              margin: EdgeInsets.symmetric(vertical: 32.0),
                              padding: EdgeInsets.all(1),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16.0),
                                child: Image.asset(
                                  'assets/section_fallback_image.png',
                                  fit: BoxFit.cover,
                                  height: (MediaQuery.of(context).size.width - 32),
                                  width: (MediaQuery.of(context).size.width),
                                ),
                              ),
                            ),
                          ],
                        )
                        : Container(
                          margin: EdgeInsets.symmetric(vertical: 32.0),
                          padding: EdgeInsets.all(1),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: Image.asset(
                              'assets/section_fallback_image.png',
                              fit: BoxFit.cover,
                              height: (MediaQuery.of(context).size.width - 32),
                              width: (MediaQuery.of(context).size.width),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 120.0,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          BottomGeneralButton(
            isActive: true,
            buttonName: "Start Now",
            onStartButton: (){
//                getPreferenceData();
              openNextScreen();
            },
          ),

          _progressHUD
        ],
      ),
    );
  }

  void gotoNextPage() async {
    var listItem = await InspectionPreferences.getPreferenceData("${InspectionPreferences.INSPECTION_CHAPTER_DETAIL_LIST}");
    List inspectionListItem = json.decode(listItem);

    print("Inspection Detail====>>>$inspectionListItem");
    var inspectionData;

    if(inspectionListItem != null && inspectionListItem.length > 0) {
      inspectionData = inspectionListItem[0];

      if(inspectionData != null){
        inspectionListItem.removeAt(0);
        // Section inspection list
        InspectionPreferences.clearPreferenceData(InspectionPreferences.INSPECTION_CHAPTER_DETAIL_LIST);
        InspectionPreferences.setPreferenceData(
            InspectionPreferences.INSPECTION_CHAPTER_DETAIL_LIST,
            json.encode(inspectionListItem)
        );

        var pageName = await InspectionUtils.getInspectionBlockType(
            inspectionData['questiontype'],
            inspectionData
        );

        if(pageName != null) {
          Navigator.push(
              context,
              SlideRightRoute(
                  page: pageName
              )
          );
        }
      }
    } else {
      gotoMainList();
    }
  }

  void gotoMainList() async {
    var listItem = await InspectionPreferences.getPreferenceData(InspectionPreferences.INSPECTION_DETAIL_LIST);
    List inspectionListItem = json.decode(listItem);

    print(inspectionListItem);

    for(int i=0; i<inspectionListItem.length; i++) {
      print("BlockType=====>>>${inspectionListItem[i]['blocktype']}");
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
        } else if(inspectionListItem[i]['blocktype'] == 'vessel inventory') {
          var inspectionData = inspectionListItem[i];
          inspectionListItem[i]['status'] = 1;

          // All Inspection List
          InspectionPreferences.clearPreferenceData(InspectionPreferences.INSPECTION_DETAIL_LIST);
          InspectionPreferences.setPreferenceData(
              InspectionPreferences.INSPECTION_DETAIL_LIST,
              json.encode(inspectionListItem)
          );

          Navigator.push(
              context,
              SlideRightRoute(
                  page: VesselInventorySelectionPage(
                      inspectionData : inspectionData
                  )
              )
          );
          break;
        } else {

        }
      }
    }
  }

  void getInspectionSection(id) async {
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

  void openNextScreen() async {
    var listItemData = await InspectionPreferences.getPreferenceData(InspectionPreferences.INSPECTION_DATA);
    var transformedData = json.decode(listItemData);
    int inspectionIndex = await InspectionPreferences.getInspectionId(InspectionPreferences.INSPECTION_INDEX);

    print(transformedData);

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
      var inspectionData;
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
          Navigator.pushAndRemoveUntil(
            context,
            SlideRightRoute(
                page: DynamicGeneralPage(
                  inspectionData: inspectionData,
                )
            ),
            ModalRoute.withName(DynamicGeneralPage.tag),
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

  void gotoNextScreen() async {
    var listItemData = await InspectionPreferences.getPreferenceData(InspectionPreferences.INSPECTION_DATA);
    var vesselWaterList = await InspectionPreferences.getPreferenceData(InspectionPreferences.INSPECTION_CHILD_DATA);
    var transformedData = json.decode(listItemData);
    int inspectionIndex = await InspectionPreferences.getInspectionId(InspectionPreferences.INSPECTION_INDEX);

    print(transformedData);

    var pageName;
    var inspectionData;
    var localInspectionData;
    int index;
    for(int i=inspectionIndex??0; i<transformedData.length; i++) {
      if(transformedData[i]['blocktype'] == 'group'){
        if(transformedData[i]['blockscope']['vesseltype'].contains(inspectionItem['simplelistid'])){
          var data = await InspectionUtils.getInspectionBlockTypeData(transformedData[++i], transformedData.length);
          if(data != null){
            pageName = data;
            inspectionData = transformedData[i];
            index = i;
            break;
          }
        } else {
          HelperClass.getInspectionData(
              "inspectiondefid",
              transformedData[i]['inspectiondefid'],
              json.decode(vesselWaterList)['children'],
                  (data){
                if(localInspectionData!= null) {
                  localInspectionData = data;
                }
              });

          var localInspectionDefId = localInspectionData['children'][localInspectionData['children'].length-1]['inspectiondefid'];
          for(int j=inspectionIndex??0; j<transformedData.length; j++) {
            if(transformedData[j]['inspectiondefid'] == localInspectionDefId) {
              InspectionPreferences.clearPreferenceData(InspectionPreferences.INSPECTION_INDEX);
              InspectionPreferences.setInspectionId(
                  InspectionPreferences.INSPECTION_INDEX,
                  ++j
              );
            }
          }
        }
      } else {
        var data = await InspectionUtils.getInspectionBlockTypeData(transformedData[i], transformedData.length);
        if(data != null){
          pageName = data;
          inspectionData = transformedData[i];
          index = i;
          break;
        }
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
}
