import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:dottie_inspector/database/database_helper.dart';
import 'package:dottie_inspector/inspectionPreferences/inspection_preferences.dart';
import 'package:dottie_inspector/pages/inspectionMain/reorderScreen/water_bodies_creating_page.dart';
import 'package:dottie_inspector/pages/menu/drawer_page.dart';
import 'package:dottie_inspector/pages/menu/index_menu.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/SlideRightRoute.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/utils/inspection_utils.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:dottie_inspector/widget/bottom_button_widget.dart';
import 'package:dottie_inspector/widget/gradient/grediant_box_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:progress_hud/progress_hud.dart';

class VesselInventorySelectionPage extends StatefulWidget {
  final inspectionData;
  final bodyOfWaterList;
  final vesselList;

  const VesselInventorySelectionPage({Key key, this.inspectionData, this.bodyOfWaterList, this.vesselList}) : super(key: key);

  @override
  _VesselInventorySelectionPageState createState() => _VesselInventorySelectionPageState();
}

class _VesselInventorySelectionPageState extends State<VesselInventorySelectionPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  var elevation = 0.0;
  final _scrollController = ScrollController();
  TextEditingController vesselNameController = TextEditingController();

  final FocusNode vesselFocus = FocusNode();
  bool isVesselFocus = false;
  int doubleTapIndex = -1;

  List vesselList = [];
  List vesselSelectionList = [];
  List waterBodiesList = [];
  var dynamicData;
  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;
  var isVisible = false;
  var inspectionData;
  List waterBodiesPrevList = [];

  var state;
  var vesselState;

  final _vesselScrollController = ScrollController();
  var vesselElevation = 0.0;
  String lang = "en";
  List prevVesselList = [];
  final dbHelper = DatabaseHelper.instance;

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

    vesselFocus.addListener(() {
      if(state != null) {
        setState(() {
          state((){
            isVesselFocus = vesselFocus.hasFocus;
          });
        });
      }
    });

//    setVesselList();
    getThemeData();
    getPreferenceData();
    Timer(Duration(milliseconds: 100), getVesselLocalList);
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

  void getPreferenceData() async {
    lang = await PreferenceHelper.getPreferenceData(PreferenceHelper.LANGUAGE) ?? "en";

    var localWaterBodiesListData = await PreferenceHelper.getPreferenceData(PreferenceHelper.WATER_SELECTED_BODIES);
    List waterBodiesTemplateData = localWaterBodiesListData != null
        ? json.decode(localWaterBodiesListData)
        : [];
    log("All WaterBodies List====>>>>$waterBodiesTemplateData");

    setState(() {
      var data = widget.inspectionData;
      dynamicData = data['txt'][lang] ?? data['txt']['en'];

      inspectionData = data;

      waterBodiesPrevList.addAll(waterBodiesTemplateData);

      for(int i=0; i<waterBodiesTemplateData.length; i++) {
        prevVesselList.addAll(waterBodiesTemplateData[i]['vessels']);
      }
    });

    _vesselScrollController.addListener(() {
      print("VesselScrolling");
      if(vesselState != null) {
        setState(() {
          vesselState(() {
            if (_vesselScrollController.position.pixels > _vesselScrollController.position.minScrollExtent) {
              vesselElevation = HelperClass.ELEVATION_1;
            } else {
              vesselElevation = HelperClass.ELEVATION;
            }
          });
        });
      }
    });

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
                      onTap: () {
                        _scaffoldKey.currentState.openDrawer();
                        // HelperClass.printDatabaseResult();
                        // getPreferenceData();
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
                  controller: _scrollController,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 10.0,),
                        dynamicData == null
                        ? Container()
                        : dynamicData['section'] == null
                        ? Container()
                        : Container(
                          margin: EdgeInsets.symmetric(horizontal: 24),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            dynamicData['section'] ?? "",
                            style: TextStyle(
                              color: themeColor.withOpacity(0.6),
                              fontSize: TextSize.subjectTitle,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        SizedBox(height: 8.0,),

                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 24),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            dynamicData != null
                                ? dynamicData['title'] ?? ""
                                : "Vessel Inventory",
                            style: TextStyle(
                              color: themeColor,
                              fontSize: TextSize.greetingTitleText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                      /*  Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.symmetric(horizontal: 60.0,vertical: 8.0),
                          child: LinearPercentIndicator(
                            animationDuration: 200,
                            backgroundColor: Color(0xffE5E5E5),
                            percent: 0.70,
                            lineHeight: 8.0,
                            progressColor: AppColor.HEADER_COLOR,
                          ),
                        ),
*/
                        dynamicData == null
                            ? Container()
                            : dynamicData['helpertext'] != null
                            ? Container(
                          margin: EdgeInsets.only(left: 24.0,right: 24.0, top: 16.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            dynamicData != null
                                ? dynamicData['helpertext'] ?? ""
                                : '',
                            style: TextStyle(
                                fontSize: TextSize.headerText,
                                color: themeColor,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.normal,
                                height: 1.3
                            ),
                          ),
                        )
                            : Container(),

                        // Container(
                        //   margin: EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0),
                        //   alignment: Alignment.centerLeft,
                        //   child: Text(
                        //     "Vessel",
                        //     style: TextStyle(
                        //         fontSize: TextSize.planeHeaderText,
                        //         color: themeColor,
                        //         fontWeight: FontWeight.w700,
                        //         fontStyle: FontStyle.normal,
                        //         height: 1.3
                        //     ),
                        //     textAlign: TextAlign.center,
                        //   ),
                        // ),

                        SizedBox(height: 16.0,),

                        ///List view new design
                        Container(
                          child: ListView.builder(
                            itemCount: vesselList != null ? vesselList.length + 1 : 1,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              var svgIcon = index == vesselList.length
                                  ? null
                                  : vesselList[index]['svgicon'] == null
                                  ? null
                                  : vesselList[index]['svgicon'].toString().replaceAll("\\", "");

                              return index != vesselList.length
                                  ? GestureDetector(
                                onTap: (){
                                  openEditDeleteBottomSheet(context, vesselList[index], "top");
                                },
                                onLongPress: (){
                                  print("Hello");
                                  setState(() {
                                    bottomSelectNavigation(context, vesselList[index]);

                                    print("$doubleTapIndex");
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? Color(0xff1f1f1f)
                                        : AppColor.TYPE_PRIMARY.withOpacity(0.08),
                                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[

                                      vesselList[index]['svgicon'] == "null"
                                          ? Container(
                                        child: Image.asset(
                                          "assets/ic_pool.png",
                                          width: 48.0,
                                          height: 48.0,
                                        ),
                                      )
                                          : Container(
//                                      child: Image.asset('${vesselList[index]['icon']}'),
                                        child: SvgPicture.string('${vesselList[index]['svgicon'].toString()}'),
//                                      child: SvgPicture.string('<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">\n<path d="M20.1422 21.0175C20.0007 21.0175 19.8591 21.0411 19.7176 21.1118C19.3402 21.2769 18.9392 21.3713 18.5382 21.3713C17.9249 21.3713 17.3352 21.1826 16.8398 20.8288C15.9199 20.1447 14.6461 20.1447 13.7261 20.8288C13.2308 21.1826 12.641 21.3713 12.0277 21.3713C11.4144 21.3713 10.8247 21.1826 10.3294 20.8288C9.88118 20.4985 9.33864 20.3098 8.77251 20.3098C8.20639 20.3098 7.66385 20.4749 7.21567 20.8288C6.72031 21.1826 6.13059 21.3713 5.51729 21.3713C5.11629 21.3713 4.71528 21.3005 4.33786 21.1118C4.21992 21.0411 4.07839 21.0175 3.91327 21.0175C3.39432 21.0175 2.96973 21.4421 2.96973 21.961C2.96973 22.0318 2.96973 22.1025 2.99332 22.1969C3.06408 22.48 3.25279 22.6923 3.51226 22.8102C4.12557 23.1169 4.80964 23.2584 5.4937 23.2348C6.48442 23.2584 7.42797 22.9517 8.22998 22.3856C8.53663 22.1969 8.53663 22.1733 8.74893 22.1733C8.96122 22.1733 8.98481 22.1733 9.29146 22.3856C10.0699 22.9517 11.037 23.2584 12.0041 23.2348C12.9713 23.2584 13.9384 22.9517 14.7168 22.3856C15.0235 22.1969 15.0235 22.1733 15.2358 22.1733C15.4481 22.1733 15.4717 22.1733 15.7783 22.3856C17.17 23.3527 18.9628 23.5179 20.496 22.8102C20.9678 22.5743 21.1565 22.0318 20.9442 21.56C20.9206 21.5128 20.897 21.4892 20.897 21.4657C20.7555 21.1826 20.4724 21.0175 20.1422 21.0175Z" fill="#509BCC"/>\n<path d="M20.9206 17.5736C20.7555 17.3141 20.4489 17.149 20.1422 17.149C20.0007 17.149 19.8591 17.1726 19.7176 17.2434C19.3402 17.4085 18.9392 17.5029 18.5382 17.5029C17.9249 17.5029 17.3352 17.3141 16.8398 16.9603C15.9199 16.2762 14.6461 16.2762 13.7261 16.9603C13.2308 17.3377 12.641 17.5264 12.0277 17.5264C11.4144 17.5264 10.8247 17.3377 10.3294 16.9839C9.88118 16.6301 9.33864 16.465 8.77251 16.465C8.20639 16.465 7.66385 16.6301 7.21567 16.9839C6.72031 17.3613 6.13059 17.55 5.51729 17.5264C5.11629 17.5264 4.71528 17.4557 4.33786 17.267C4.21992 17.1962 4.07839 17.1726 3.91327 17.1726C3.39432 17.1726 2.96973 17.5972 2.96973 18.1162C2.96973 18.1869 2.96973 18.2577 2.99332 18.352C3.06408 18.6115 3.25279 18.8474 3.48868 18.9653C4.10198 19.272 4.78605 19.4135 5.4937 19.3899C6.46084 19.4135 7.42797 19.1069 8.20639 18.5408C8.51304 18.352 8.51304 18.3285 8.72534 18.3285C8.93764 18.3285 8.96122 18.3285 9.26788 18.5408C10.0463 19.1069 11.0134 19.4135 11.9806 19.3899C12.9477 19.4135 13.9148 19.1069 14.6932 18.5172C14.9999 18.3285 14.9999 18.3049 15.2122 18.3049C15.4245 18.3049 15.4481 18.3049 15.7547 18.5172C17.1465 19.4843 18.9392 19.6494 20.4724 18.9418C20.9442 18.7059 21.1329 18.1397 20.9206 17.6916C20.9678 17.6444 20.9442 17.6208 20.9206 17.5736Z" fill="#509BCC"/>\n<path d="M16.4861 15.0967C17.005 15.0967 17.4296 14.6721 17.4296 14.1532V6.51049C17.4296 4.95365 18.0429 3.46757 19.128 2.38249C19.5054 2.00508 19.5054 1.41536 19.128 1.03795C18.7506 0.660529 18.1608 0.660529 17.7834 1.03795C16.9814 1.83996 16.3681 2.80709 15.9671 3.86857H9.5982C9.88126 3.32604 10.2351 2.80709 10.6833 2.38249C11.0607 2.00508 11.0607 1.41536 10.6833 1.03795C10.3059 0.660529 9.71614 0.660529 9.33872 1.03795C7.87623 2.47685 7.07422 4.45829 7.07422 6.51049V14.1532C7.07422 14.6721 7.49881 15.0967 8.01776 15.0967C8.53671 15.0967 8.9613 14.6721 8.9613 14.1532V12.9974H15.4953V14.1532C15.5425 14.6721 15.9671 15.0967 16.4861 15.0967ZM9.00848 6.51049C9.00848 6.20384 9.03207 5.8736 9.07925 5.56695H15.5897C15.5425 5.8736 15.5189 6.20384 15.5189 6.51049V7.59557H9.00848V6.51049ZM9.00848 11.3226V9.27036H15.5425V11.3226H9.00848Z" fill="#509BCC"/>\n</svg>'),
                                        height: 48.0,
                                        width: 48.0,
                                      ),
                                      SizedBox(width: 16.0,),
                                      Expanded(
                                        child: Text(
                                          '${vesselList[index]['label']}',
                                          style: TextStyle(
                                            color: themeColor,
                                            fontSize: TextSize.headerText,
                                            fontStyle: FontStyle.normal,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          maxLines: 2,
                                        ),
                                      ),
                                      SizedBox(height: 8.0,),
                                    ],
                                  ),
                                ),
                              )
                                  : GestureDetector(
                                onTap: (){
                                  openVesselSelectionBottomSheet(context);
                                },
                                child: Theme(
                                  data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                                  child: Container(
                                    margin: EdgeInsets.only(top: 16.0,left: 16.0, right: 16),
                                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 22.0),
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                        ? Color(0xff1f1f1f)
                                        : AppColor.THEME_PRIMARY.withOpacity(0.08),
                                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[

                                        Expanded(
                                          child: Text(
                                            'Add Vessel',
                                            style: TextStyle(
                                              color: themeColor,
                                              fontSize: TextSize.headerText,
                                              fontStyle: FontStyle.normal,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 16.0,),
                                        Container(
                                          alignment: Alignment.center,
                                          width: 36.0,
                                          height: 36.0,
                                          padding: EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                              color: AppColor.THEME_PRIMARY,
                                              borderRadius: BorderRadius.circular(24)
                                          ),
                                          child: Icon(
                                              Icons.add,
                                              color: AppColor.WHITE_COLOR,
                                              size: 20.0
                                          ),
                                        ),


                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        SizedBox(height: 120.0,),

                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: BottomButtonWidget(
              isActive: vesselList.length > 0,
              onBackButton: () async {
                int inspectionIndex = await InspectionPreferences.getInspectionId(InspectionPreferences.INSPECTION_INDEX);
                InspectionUtils.decrementIndex(inspectionIndex);
                Navigator.pop(context);
                // final dbHelper = DatabaseHelper.instance;
                // var result = await dbHelper.getSelectedSimpleList("1");
                // log("Result====$result");
              },
              onNextButton: () async {
                onSaveEvent();
              },
            ),
          ),

          _progressHUD
        ],
      ),
    );
  }
  
  void onSaveEvent() {
    waterBodiesList.clear();
    PreferenceHelper.clearPreferenceData(PreferenceHelper.WATER_BODIES);
    print("Vessel List ====  $vesselList");
    print("Vessel List Length ====  ${vesselList.length}");

    for(int i=0; i<vesselList.length; i++) {
      waterBodiesList.add({
        "simplelistid": vesselList[i]['simplelistid'],
        "body": "${vesselList[i]['label']}",
        "svgicon": "${vesselList[i]['svgicon']}",
        "status": 0,
        "vesselid": vesselList[i]['vesselid'] ?? null
      });
    }

    ///Working
    // if(waterBodiesPrevList.length > 0) {
    //   for(int i=0; i<waterBodiesPrevList.length; i++) {
    //     // "vesselid": 2195,
    //     //                     "vesselname": "Pool",
    //     //                     "vesseltypeid": 2,
    //     //                     "vesseltype": {
    //     //                         "en": "Pool",
    //     //                         "es": "Piscia"
    //     //                     },
    //   }
    // } else {
    //   for(int i=0; i<vesselList.length; i++) {
    //     waterBodiesList.add({
    //       "simplelistid": vesselList[i]['simplelistid'],
    //       "body": "${vesselList[i]['label']}",
    //       "svgicon": "${vesselList[i]['svgicon']}",
    //       "status": 0,
    //       "vesselid": vesselList[i]['vesselid'] ?? null
    //     });
    //   }
    // }


    PreferenceHelper.clearPreferenceData(PreferenceHelper.WATER_BODIES);
    PreferenceHelper.setPreferenceData(
        PreferenceHelper.WATER_BODIES,
        json.encode(waterBodiesList)
    );

    PreferenceHelper.clearPreferenceData(PreferenceHelper.WATER_VESSEL_BODIES);
    PreferenceHelper.setPreferenceData(
        PreferenceHelper.WATER_VESSEL_BODIES,
        json.encode(waterBodiesList)
    );

    print("Water Feature List ====  $waterBodiesList");
    print("Water Feature List Length ====  ${waterBodiesList.length}");

    List newList = [];
    List poolList = [];
    for(int i=0; i<waterBodiesList.length; i++){
      poolList.add(waterBodiesList[i]);
    }
    if(poolList.length > 0){
      newList.add(poolList);
    }

    PreferenceHelper.clearPreferenceData(PreferenceHelper.WATER_BODIES_COUNT);
    PreferenceHelper.setPreferenceData(
        PreferenceHelper.WATER_BODIES_COUNT,
        "${waterBodiesList.length}"
    );

   /* Navigator.push(
        context,
        SlideRightRoute(
            page: WaterBodiesCreatePage(
                waterBodiesList: newList,
                count: waterBodiesList.length
            )
        )
    );*/
    gotoNextScreen(newList);
  }

  void openVesselSelectionBottomSheet(context){
    for(int k=0; k<vesselSelectionList.length; k++) {
      vesselSelectionList[k]['isVesselCountChanged'] = 0;
    }
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        barrierColor: themeColor.withOpacity(0.5),
        isDismissible: false,
        clipBehavior: Clip.none,
        enableDrag: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        builder: (context){
          return StatefulBuilder(
            builder: (context1, myState){
              vesselState = myState;
              return Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height - 50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: (){
                                for(int k=0; k<vesselSelectionList.length; k++){
                                  print("Index===$k, isVesselCountChanged====${vesselSelectionList[k]['isVesselCountChanged']} vesselCountClose===${vesselSelectionList[k]['vesselCountClose']}");

                                  if(vesselSelectionList[k]['isVesselCountChanged'] == 0
                                      && vesselSelectionList[k]['vesselCountClose'] == 0) {
                                    vesselSelectionList[k]['isSelected'] = 0;
                                    vesselSelectionList[k]['count'] = vesselSelectionList[k]['selectedCount'];
                                    vesselSelectionList[k]['selectedCount'] = vesselSelectionList[k]['selectedCount'];
                                  } else {
                                    vesselSelectionList[k]['count'] = vesselSelectionList[k]['selectedCount'];
                                    vesselSelectionList[k]['isSelected'] = 1;
                                  }
                                }

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
                              'Add Vessel',
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
                                    vesselList.clear();
                                    for(int k=0; k<vesselSelectionList.length; k++){
                                      if(vesselSelectionList[k]['isSelected'] == 1){
                                        vesselSelectionList[k]['selectedCount'] = vesselSelectionList[k]['count'];
                                        vesselSelectionList[k]['isVesselCountChanged'] = vesselSelectionList[k]['count'];
                                        vesselSelectionList[k]['vesselCountClose'] = vesselSelectionList[k]['count'];

                                        for(int i=0; i<vesselSelectionList[k]['count']; i++) {
                                          vesselList.add({
                                            "simplelistid": "${vesselSelectionList[k]['simplelistid']}",
                                            "label": i==0 ? "${vesselSelectionList[k]['label']}" : "${vesselSelectionList[k]['label']} ${i+1}",
                                            "svgicon": "${vesselSelectionList[k]['svgicon']}"
                                          });
                                        }
                                      }
                                    }
                                    log("VesselList====$vesselList");
                                  });
                                });

                                Navigator.pop(context);
                              },
                              child: Theme(
                                data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                                child: Container(
                                  alignment: Alignment.bottomCenter,
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: AppColor.gradientColor(1.0)),
                                      borderRadius: BorderRadius.all(Radius.circular(32.0))
                                  ),
                                  margin: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                                  padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 8.0),
                                  child: Center(
                                    child: Text(
                                      'Save',
                                      style: TextStyle(
                                          fontSize: TextSize.headerText,
                                          color: AppColor.WHITE_COLOR,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'WorkSans'
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Visibility(
                          visible: vesselElevation != 0.0,
                          child: Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColor.DIVIDER,
                          )
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          controller: _vesselScrollController,
                          child: Padding(
                            padding: MediaQuery.of(context).viewInsets,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                                  child: ListView.builder(
                                    itemCount: vesselSelectionList != null ? vesselSelectionList.length : 0,
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index){
                                      return GestureDetector(
                                        onTap: (){

                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(top: 16.0),
                                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 22.0),
                                          decoration: BoxDecoration(
                                            color: isDarkMode
                                                ? Color(0xff1F1F1F)
                                                : AppColor.TYPE_PRIMARY.withOpacity(0.08),
                                            borderRadius: BorderRadius.all(Radius.circular(32.0)),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  vesselSelectionList[index]['svgicon'] == null
                                                      ? Container(
                                                    child: Image.asset(
                                                      "assets/ic_pool.png",
                                                      width: 48.0,
                                                      height: 48.0,
                                                    ),
                                                  )
                                                      : Container(
                                                    child: SvgPicture.string('${vesselSelectionList[index]['svgicon'].toString()}'),
                                                    height: 48.0,
                                                    width: 48.0,
                                                  ),
                                                  SizedBox(width: 16.0,),
                                                  Expanded(
                                                    child: Text(
                                                      '${vesselSelectionList[index]['label']}',
                                                      style: TextStyle(
                                                        color: themeColor,
                                                        fontSize: TextSize.headerText,
                                                        fontStyle: FontStyle.normal,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 16.0,),

                                                  GestureDetector(
                                                    onTap: (){
                                                      setState(() {
                                                        myState((){
                                                          vesselSelectionList[index]['isSelected'] = vesselSelectionList[index]['isSelected'] == 0 ? 1 : 0;
                                                        });
                                                      });
                                                    },
                                                    child: Container(
                                                      margin: EdgeInsets.only(left: 8.0),
                                                      height: 48.0,
                                                      width: 48.0,
                                                      child: Image.asset(
                                                        vesselSelectionList[index]['isSelected'] == 1
                                                            ? 'assets/complete_inspection/ic_check_icon.png'
                                                            : 'assets/complete_inspection/ic_unchecked_icon.png',
                                                        height: 150,
                                                        width: 150,
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              //Selection tab
                                              Visibility(
                                                visible: vesselSelectionList[index]['isSelected'] == 1,
                                                child: Container (
                                                  child: Row (
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: (){
                                                          if(vesselSelectionList[index]['count'] != vesselSelectionList[index]['selectedCount']) {
                                                            setState(() {
                                                              myState(() {
                                                                vesselSelectionList[index]['count']--;
                                                              });
                                                            });
                                                          }
                                                        },
                                                        child: Container (
                                                          // padding: EdgeInsets.all(8.0),
                                                          width: 48,
                                                          height: 48,
                                                          decoration: BoxDecoration(
                                                              color: vesselSelectionList[index]['count'] == vesselSelectionList[index]['selectedCount']
                                                                  ? AppColor.THEME_PRIMARY.withOpacity(0.12)
                                                                  : vesselSelectionList[index]['count'] == 0
                                                                  ? AppColor.THEME_PRIMARY.withOpacity(0.12)
                                                                  : AppColor.THEME_PRIMARY,
                                                              borderRadius: BorderRadius.circular(24)
                                                          ),
                                                          alignment: Alignment.center,
                                                          child: Icon(
                                                              Icons.remove,
                                                              color: vesselSelectionList[index]['count'] == vesselSelectionList[index]['selectedCount'] ? AppColor.PAGE_COLOR : AppColor.WHITE_COLOR,
                                                              size: 18.0
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        margin: EdgeInsets.symmetric(horizontal: 12.0),
                                                        alignment: Alignment.center,
                                                        child: Text(
                                                          "${vesselSelectionList[index]['count']}",
                                                          style: TextStyle(
                                                              fontSize: 22.0,
                                                              color: themeColor,
                                                              fontWeight: FontWeight.w700,
                                                              fontStyle: FontStyle.normal
                                                          ),
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: (){
                                                          setState(() {
                                                            myState((){
                                                              vesselSelectionList[index]['count']++;
                                                            });
                                                          });
                                                        },
                                                        child: Container(
                                                          width: 48,
                                                          height: 48,
                                                          decoration: BoxDecoration(
                                                              color: AppColor.THEME_PRIMARY,
                                                              borderRadius: BorderRadius.circular(24)
                                                          ),
                                                          alignment: Alignment.center,
                                                          child: Icon(
                                                              Icons.add,
                                                              color: AppColor.WHITE_COLOR,
                                                              size: 18.0
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                SizedBox(height: 80,)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                ),
              );
            },
          );
        }
    );
  }

  void openAddCommentBottomSheet(context){
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        barrierColor: themeColor.withOpacity(0.5),
        isDismissible: false,
        clipBehavior: Clip.none,
        enableDrag: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        builder: (context){
          return StatefulBuilder(
            builder: (context1, myState){
              return SingleChildScrollView(
                child: Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height - 50,
                    child: ListView(
//                      crossAxisAlignment: CrossAxisAlignment.center,
//                      mainAxisAlignment: MainAxisAlignment.start,
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
                                    isDarkMode
                                        ? 'assets/ic_dark_close.png'
                                        : 'assets/ic_back_close.png',
                                    height: 44.0,
                                    width: 44.0,
                                  ),
                                ),
                              ),

                              Text(
                                'Add Vessel',
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
                                      vesselList.clear();
                                      for(int k=0; k<vesselSelectionList.length; k++){
                                        vesselSelectionList[k]['selectedCount'] = vesselSelectionList[k]['count'];
                                        for(int i=0; i<vesselSelectionList[k]['count']; i++) {
                                          vesselList.add({
                                            "simplelistid": "${vesselSelectionList[k]['simplelistid']}",
                                            "label": "${vesselSelectionList[k]['label']} ${i+1}",
                                            "svgicon": "${vesselSelectionList[k]['svgicon']}"
                                          });
                                        }
                                      }
                                      log("VesselList====$vesselList");
                                    });
                                  });

                                  Navigator.pop(context);
                                },
                                child: Theme(
                                  data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                                  child: Container(
                                    alignment: Alignment.bottomCenter,
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: AppColor.gradientColor(1.0)),
                                        borderRadius: BorderRadius.all(Radius.circular(32.0))
                                    ),
                                    margin: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                                    padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 8.0),
                                    child: Center(
                                      child: Text(
                                        'Save',
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

                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                          child: GridView.builder(
                            itemCount: vesselSelectionList != null ? vesselSelectionList.length : 0,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.88,
                              mainAxisSpacing: 0.0,
                              crossAxisSpacing: 16.0,
                            ),
                            itemBuilder: (context, index){
                              return GestureDetector(
                                onTap: (){

                                },
                                child: Container(
                                  margin: EdgeInsets.only(top: 16.0),
                                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 16.0),
                                  decoration: BoxDecoration(
                                    color: themeColor.withOpacity(0.08),
                                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      vesselSelectionList[index]['svgicon'] == null
                                      ? Container(
                                        child: Image.asset(
                                            "assets/ic_pool.png",
                                          width: 48.0,
                                          height: 48.0,
                                        ),
                                      )
                                      : Container(
//                                        child: Image.asset(
//                                           "${vesselSelectionList[index]['svgicon']}"
//                                        ),
                                        child: SvgPicture.string('${vesselSelectionList[index]['svgicon'].toString()}'),
                                        height: 48.0,
                                        width: 48.0,
                                      ),
                                      SizedBox(height: 8.0,),
                                      Expanded(
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "${vesselSelectionList[index]['label']}",
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 16.0,
                                              fontStyle: FontStyle.normal,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8.0,),

                                      Container (
                                        margin: EdgeInsets.only(top: 6.0),
                                        child: Row (
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            GestureDetector(
                                              onTap: (){
                                                if(vesselSelectionList[index]['count'] != vesselSelectionList[index]['selectedCount']) {
                                                  setState(() {
                                                    myState(() {
                                                      vesselSelectionList[index]['count']--;
                                                    });
                                                  });
                                                }
                                              },
                                              child: Container (
                                                margin: EdgeInsets.only(right: 16.0),
                                                padding: EdgeInsets.all(8.0),
                                                decoration: BoxDecoration(
                                                    color: vesselSelectionList[index]['count'] == vesselSelectionList[index]['selectedCount']
                                                          ? AppColor.THEME_PRIMARY.withOpacity(0.12)
                                                          : AppColor.THEME_PRIMARY,
                                                    borderRadius: BorderRadius.circular(24)
                                                ),
                                                alignment: Alignment.center,
                                                child: Icon(
                                                    Icons.remove,
                                                    color: vesselSelectionList[index]['count'] == vesselSelectionList[index]['selectedCount'] ? AppColor.PAGE_COLOR : AppColor.WHITE_COLOR,
                                                    size: 14.0
                                                ),
                                              ),
                                            ),
                                            Container(
                                              alignment: Alignment.center,
                                              child: Text(
                                                "${vesselSelectionList[index]['count']}",
                                                style: TextStyle(
                                                    fontSize: 22.0,
                                                    color: themeColor,
                                                    fontWeight: FontWeight.w700,
                                                    fontStyle: FontStyle.normal
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: (){
                                                setState(() {
                                                  myState((){
                                                    vesselSelectionList[index]['count']++;
                                                  });
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(8.0),
                                                decoration: BoxDecoration(
                                                    color: AppColor.THEME_PRIMARY,
                                                    borderRadius: BorderRadius.circular(24)
                                                ),
                                                margin: EdgeInsets.only(left: 16.0),
                                                alignment: Alignment.center,
                                                child: Icon(
                                                    Icons.add,
                                                    color: AppColor.WHITE_COLOR,
                                                    size: 14.0
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
    );
  }

  void openEditDeleteBottomSheet(context, vesselMap, type){
    log("VesselData====${vesselMap}");
    vesselNameController.text = "${vesselMap['label']}";
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        clipBehavior: Clip.none,
        barrierColor: themeColor.withOpacity(0.5),
        isDismissible: false,
        enableDrag: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        builder: (context){
          return StatefulBuilder(
            builder: (context1, myState){
              state = myState;
              return Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height - 50,
                // height: (MediaQuery.of(context).size.height - 50) +
                //     MediaQuery.of(context).viewInsets.bottom,
                // padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
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
                                isDarkMode
                                    ? 'assets/ic_dark_close.png'
                                    : 'assets/ic_back_close.png',
                                height: 44.0,
                                width: 44.0,
                              ),
                            ),
                          ),

                          Text(
                            "${vesselMap['label']}",
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
                                  if(vesselNameController.text != ''){
                                    vesselMap['label'] = "${vesselNameController.text}";
                                  }
                                });
                              });

                              Navigator.pop(context);
                              if(type == "bottom"){
                                Navigator.pop(context);
                              }
                            },
                            child: Theme(
                              data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                              child: Container(
                                alignment: Alignment.bottomCenter,
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: AppColor.gradientColor(1.0)),
                                    borderRadius: BorderRadius.all(Radius.circular(32.0))
                                ),
                                margin: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                                padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 8.0),
                                child: Center(
                                  child: Text(
                                    'Save',
                                    style: TextStyle(
                                        fontSize: TextSize.headerText,
                                        color: AppColor.WHITE_COLOR,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'WorkSans'
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
                      child: SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // Vessel Name
                              Container(
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isVesselFocus && isDarkMode
                                          ? AppColor.gradientColor(0.32)
                                          : isVesselFocus
                                          ? AppColor.gradientColor(0.16)
                                          : isDarkMode
                                          ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                                          : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
                                    ),
                                    borderRadius: BorderRadius.circular(16.0),
                                    border: GradientBoxBorder(
                                        gradient: LinearGradient(
                                          colors: isVesselFocus
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
                                      'Nick name (Optional)',
                                      style: TextStyle(
                                          fontSize: TextSize.bodyText,
                                          color: themeColor,
                                          fontWeight: FontWeight.w600,
                                          fontStyle: FontStyle.normal,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SingleChildScrollView(
                                      child: TextFormField(
                                        controller: vesselNameController,
                                        focusNode: vesselFocus,
                                        onFieldSubmitted: (term) {
                                          vesselFocus.unfocus();
                                        },
                                        textInputAction: TextInputAction.done,
                                        keyboardType: TextInputType.text,
                                        textAlign: TextAlign.start,
                                        textCapitalization: TextCapitalization.words,
                                        decoration: InputDecoration(
                                          fillColor: AppColor.WHITE_COLOR,
                                          hintText: "Add",
                                          filled: false,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.only(top: 0,),
                                          hintStyle: TextStyle(
                                              fontSize: TextSize.headerText,
                                              fontWeight: FontWeight.w600,
                                              color: isDarkMode
                                                  ? Color(0xff545454)
                                                  : Color(0xff808080)
                                          ),
                                        ),
                                        style: TextStyle(
                                            color: themeColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: TextSize.headerText
                                        ),
                                        inputFormatters: [LengthLimitingTextInputFormatter(40)],
                                        onChanged: (value){

                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ), // Vessel Name End

                              // Delete button
                              GestureDetector(
                                onTap: (){
                                  setState(() {
                                    myState((){
                                      for(int k=0; k<vesselSelectionList.length; k++){
                                        if("${vesselMap['simplelistid']}" == "${vesselSelectionList[k]['simplelistid']}"){
                                          vesselSelectionList[k]['count'] = vesselSelectionList[k]['count'] > 0
                                              ? vesselSelectionList[k]['count'] - 1
                                              : 0;
                                          vesselSelectionList[k]['selectedCount'] = vesselSelectionList[k]['selectedCount'] > 0
                                              ? vesselSelectionList[k]['selectedCount'] - 1
                                              : 0;
                                          vesselSelectionList[k]['isSelected'] = vesselSelectionList[k]['count'] == 0 ? 0 : 1;
                                        }
                                      }
                                      vesselList.remove(vesselMap);

                                      if(prevVesselList.length>0) {
                                        onSaveDelete(vesselMap['vesselid']);
                                      }
                                    });
                                  });
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                  padding: EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                      color: isDarkMode
                                      ? Color(0xff333333)
                                      : AppColor.WHITE_COLOR,
                                      borderRadius: BorderRadius.circular(16.0)
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(
                                          color: AppColor.RED_COLOR,
                                          fontWeight: FontWeight.w600,
                                          fontSize: TextSize.headerText
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Delete Button End
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
    );
  }

  void onSaveDelete(vesselid) async {
    try{
      ///Children Inspection Data
      var localChildData = await InspectionPreferences.getPreferenceData(InspectionPreferences.INSPECTION_CHILD_DATA);
      var childrenTemplateData = localChildData != null
          ? json.decode(localChildData)
          : [];
      print("All Children List====>>>>$childrenTemplateData");

      ///Selected Vessel List
      var localWaterBodiesListData = await PreferenceHelper.getPreferenceData(PreferenceHelper.WATER_SELECTED_BODIES);
      var waterBodiesTemplateData = localWaterBodiesListData != null
          ? json.decode(localWaterBodiesListData)
          : [];

      ///RemoveDataFromMainList
      var newWaterBodiesData =  getWaterBodiesData(waterBodiesTemplateData, vesselid);
      log("NewWaterListData===$newWaterBodiesData");

      PreferenceHelper.clearPreferenceData(PreferenceHelper.WATER_SELECTED_BODIES);
      PreferenceHelper.setPreferenceData(
          PreferenceHelper.WATER_SELECTED_BODIES,
          json.encode(newWaterBodiesData)
      );

      PreferenceHelper.clearPreferenceData(PreferenceHelper.WATER_BODIES);
      PreferenceHelper.setPreferenceData(
          PreferenceHelper.WATER_BODIES,
          json.encode(newWaterBodiesData)
      );


      ///Previous selected equipments
      var previousSelectedEquipmentListData = await PreferenceHelper.getPreferenceData(PreferenceHelper.EQUIPMENT_ITEMS);
      List prevSelectedEquipmentList = previousSelectedEquipmentListData != null
          ? json.decode(previousSelectedEquipmentListData)
          : [];
      print("All Equipment List====>>>>$prevSelectedEquipmentList");

      ///Inspection Id
      var inspectionLocalId = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ID);
      // print("InspectionId=====>>>>$inspectionLocalId");

      // ///Answer List
      var previousAnswersListData = await PreferenceHelper.getPreferenceData(PreferenceHelper.ANSWER_LIST);
      List prevAnswersList = previousAnswersListData != null
          ? json.decode(previousAnswersListData)
          : [];

      var pendingAnswer;
      for(int i=0; i<prevAnswersList.length; i++) {
        if(prevAnswersList[i]['vesselid'] == vesselid) {
          pendingAnswer = {
            "inspectionid": inspectionLocalId,
            "answerserverid": prevAnswersList[i]['answerid'] ?? 0,
            "questionid": prevAnswersList[i]['questionid'] ?? 0,
            "equipmentid": prevAnswersList[i]['equipmentid'] ?? 0,
            "vesselid": prevAnswersList[i]['vesselid'] ?? 0,
            "bodyofwaterid": prevAnswersList[i]['bodyofwaterid'] ?? 0,
            "simplelistid": prevAnswersList[i]['simplelistid'] ?? 0,
            "answer": prevAnswersList[i]['answer'] ?? "",
            "imageurl": prevAnswersList[i]['image'] == null
                ? ""
                : prevAnswersList[i]['image']['path'] ?? "",
          };

          await dbHelper.insertRecordIntoDeleteTable(
            json.decode(json.encode(pendingAnswer)),
          );
        }
      }
      prevAnswersList.removeWhere((element) => element['vesselid'] == vesselid);
      print("All Answer List====>>>>$prevAnswersList");

      PreferenceHelper.clearPreferenceData(PreferenceHelper.ANSWER_LIST);
      PreferenceHelper.setPreferenceData(PreferenceHelper.ANSWER_LIST, json.encode(prevAnswersList));

      ///Start unroll
      var transformedData = HelperClass.unroll(int.parse(inspectionLocalId), childrenTemplateData, newWaterBodiesData, prevSelectedEquipmentList, prevAnswersList);
      // const JsonEncoder encoder = JsonEncoder.withIndent('  ');
      // log("TransformedData====>>>>${encoder.convert(transformedData)}");

      ///Save inspection data
      InspectionPreferences.clearPreferenceData(InspectionPreferences.INSPECTION_DATA);
      InspectionPreferences.setPreferenceData(
          InspectionPreferences.INSPECTION_DATA,
          json.encode(transformedData['flow'])
      );

      // for(int i=0; i<prevAnswersList.length; i++) {
      //   if(prevAnswersList[i]['vesselid'] == "") {
      //     prevAnswersList.removeWhere((item) => item[]);
      //   }
      // }

      /// gotoNextPage(newList);
    } catch (e) {
      print("saveEvent Error ====$e");
    }
  }

  List getWaterBodiesData(waterBodiesList, vesselid) {
    for(int i=0; i<waterBodiesList.length; i++) {
      waterBodiesList[i]['vessels'].removeWhere((item) => item['vesselid'] == vesselid);
      if (waterBodiesList[i]['vessels'].length == 0) {
        waterBodiesList.removeAt(i);
      }
    }
    setState(() {
      prevVesselList.removeWhere((item) => item['vesselid'] == vesselid);
    });
    return waterBodiesList;
  }

  bottomSelectNavigation(context, vesselMap){
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        barrierColor: themeColor.withOpacity(0.5),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        builder: (context){
          return StatefulBuilder(
            builder: (context1, myState){
              return SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                        child: Text(
                          "${vesselMap['label']}",
                          style: TextStyle(
                              fontSize: TextSize.subjectTitle,
                              color: themeColor,
                              fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: (){
                          openEditDeleteBottomSheet(context, vesselMap, "bottom");
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                          child: Text(
                            'Edit',
                            style: TextStyle(
                                fontSize: TextSize.planeHeaderText,
                                color: themeColor,
                                fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: (){
                          setState(() {
                            myState((){
                              for(int k=0; k<vesselSelectionList.length; k++){
                                if("${vesselMap['simplelistid']}" == "${vesselSelectionList[k]['simplelistid']}"){
                                  vesselSelectionList[k]['count'] = vesselSelectionList[k]['count'] > 0
                                      ? vesselSelectionList[k]['count'] - 1
                                      : 0;
                                  vesselSelectionList[k]['selectedCount'] = vesselSelectionList[k]['selectedCount'] > 0
                                      ? vesselSelectionList[k]['selectedCount'] - 1
                                      : 0;

                                  vesselSelectionList[k]['isSelected'] = vesselSelectionList[k]['count'] == 0 ? 0 : 1;
                                }
                              }
                              vesselList.remove(vesselMap);
                              if(prevVesselList.length>0) {
                                onSaveDelete(vesselMap['vesselid']);
                              }
                            });
                          });
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                          child: Text(
                            'Remove',
                            style: TextStyle(
                                fontSize: TextSize.planeHeaderText,
                                color: AppColor.RED_COLOR,
                                fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      Container(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: (){
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            height: 64.0,
                            width: 120,
                            margin: EdgeInsets.only(bottom: 20.0, top: 8.0),
                            decoration: BoxDecoration(
                                color: isDarkMode
                                ? Color(0xffffffff)
                                : AppColor.BLACK_COLOR,
                                borderRadius: BorderRadius.all(Radius.circular(32.0))
                            ),
                            child: Center(
                              child: Text(
                                'Close',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isDarkMode
                                      ? AppColor.BLACK_COLOR
                                      : AppColor.WHITE_COLOR,
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
              );
            },
          );
        }
    );
  }

  void gotoNextPage(newList) async {
    var listItem = await InspectionPreferences.getPreferenceData(InspectionPreferences.INSPECTION_DETAIL_LIST);
    List inspectionListItem = json.decode(listItem);

    print(inspectionListItem);

    for(int i=0; i<inspectionListItem.length; i++) {
      print("BlockType=====>>>${inspectionListItem[i]['blocktype']}");
      if (inspectionListItem[i]['status'] == 0) {
        if (inspectionListItem[i]['blocktype'] == 'bodyofwater') {
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
                  page: WaterBodiesCreatePage(
                      waterBodiesList: newList,
                      count: waterBodiesList.length
                  )
              )
          );

          print("NewList=====>>>$newList");

        }
      }
    }
  }

  void gotoNextScreen(newList) async {
    var listItemData = await InspectionPreferences.getPreferenceData(InspectionPreferences.INSPECTION_DATA);
    var transformedData = json.decode(listItemData);
    int inspectionIndex = await InspectionPreferences.getInspectionId(InspectionPreferences.INSPECTION_INDEX);

    print(transformedData);

    var pageName;
    var inspectionData;
    int index;

    print("Index====$inspectionIndex");
    print("Length====${transformedData.length}");
    for(int i=inspectionIndex??0; i<transformedData.length; i++) {
      var data = await InspectionUtils.getInspectionBlockTypeData(transformedData[i], transformedData.length);
      if(data != null){
        if(data.runtimeType == WaterBodiesCreatePage){
          inspectionData = transformedData[i];
          pageName = data;
          index = i;
          break;
        }
      }
    }

    if(inspectionData != null){
      InspectionPreferences.clearPreferenceData(InspectionPreferences.INSPECTION_INDEX);
      InspectionPreferences.setInspectionId(
          InspectionPreferences.INSPECTION_INDEX,
          ++index
      );
      Navigator.push(
          context,
          SlideRightRoute(
              page: WaterBodiesCreatePage(
                waterBodiesList: newList,
                count: waterBodiesList.length,
                inspectionData: inspectionData,
              )
          )
      );
    }
  }

  Future getVesselLocalList() async {
    final dbHelper = DatabaseHelper.instance;
    var result = await dbHelper.getSelectedSimpleList("1");
    if (result != null) {

      setState(() {
        result = result.map((element) => Map<String, dynamic>.of(element)).toList();

        var transformedData = adjacencyTransform(result);
        var response = transformedData['children'];
        List vesselDataList = [];
        print(lang);
        if(lang == "en") {
          for(int i=0; i<response.length; i++){
            if(inspectionData['vesseltype'].contains(response[i]['simplelistid'])) {
              vesselDataList.add(response[i]);
            }
          }
        }
        // else {
        //   for(int i=0; i<response[0]['children'].length; i++){
        //     log("Index===$i, ${response[0]['children'][i]['simplelistid']}");
        //     if(inspectionData['vesseltype'].contains(response[0]['children'][i]['simplelistid'])) {
        //       vesselDataList.add(response[0]['children'][i]);
        //     }
        //   }
        // }

        vesselSelectionList.addAll(vesselDataList);

        // log("VesselDataList====$vesselSelectionList");

        List allIds = [];
        for(int i=0; i<vesselSelectionList.length; i++){
          log("VesselDataList====${vesselSelectionList[i]['simplelistid']}");
          vesselSelectionList[i]['icon'] = 'assets/vessel/ic_vessel_pool.png';
          vesselSelectionList[i]['count'] = 1;
          vesselSelectionList[i]['selectedCount'] = 1;
          vesselSelectionList[i]['isSelected'] = 0;
          vesselSelectionList[i]['isVesselCountChanged'] = 0;
          vesselSelectionList[i]['vesselCountClose'] = 0;

          for(int j=0; j<prevVesselList.length; j++) {
            if(vesselSelectionList[i]['simplelistid'] == prevVesselList[j]['vesseltypeid']) {
              int count = 1;
              if(allIds.contains(vesselSelectionList[i]['simplelistid'])) {
                count++;
              }

              vesselSelectionList[i]['icon'] = 'assets/vessel/ic_vessel_pool.png';
              vesselSelectionList[i]['count'] = count;
              vesselSelectionList[i]['selectedCount'] = count;
              vesselSelectionList[i]['isSelected'] = 1;
              vesselSelectionList[i]['isVesselCountChanged'] = count;
              vesselSelectionList[i]['vesselCountClose'] = count;
              vesselSelectionList[i]['vesselid'] = prevVesselList[j]['vesselid'];

              vesselList.add(vesselSelectionList[i]);

              allIds.add(vesselSelectionList[i]['simplelistid']);
            }
          }
        }
      });
    }
  }

  Future getVesselList() async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var response = await request.getAuthRequest("auth/simplelist/$lang/vessel");

    _progressHUD.state.dismiss();
    if (response != null) {
      setState(() {
        List vesselDataList = [];
        print(lang);
        if(lang == "en") {
          for(int i=0; i<response.length; i++){
              if(inspectionData['vesseltype'].contains(response[i]['simplelistid'])) {
                vesselDataList.add(response[i]);
              }
            // vesselDataList.add(response[i]);
          }
        } else {
          for(int i=0; i<response[0]['children'].length; i++){
            log("Index===$i, ${response[0]['children'][i]['simplelistid']}");
              if(inspectionData['vesseltype'].contains(response[0]['children'][i]['simplelistid'])) {
                vesselDataList.add(response[0]['children'][i]);
              }
          }
        }

        log(vesselDataList.toString());


        vesselSelectionList.addAll(vesselDataList);

        // printWrapped(vesselSelectionList[0]['svgicon'].toString().replaceAll("\\", ""));
        // printWrapped("Hello======\\");

//        vesselList[index]['svgicon'].toString().replaceAll("\\", "")

        for(int i=0; i<vesselSelectionList.length; i++){
          vesselSelectionList[i]['icon'] = 'assets/vessel/ic_vessel_pool.png';
          vesselSelectionList[i]['count'] = 1;
          vesselSelectionList[i]['selectedCount'] = 1;
          vesselSelectionList[i]['isSelected'] = 0;
          vesselSelectionList[i]['isVesselCountChanged'] = 0;
          vesselSelectionList[i]['vesselCountClose'] = 0;
        }
      });
    }
  }

  void printWrapped(String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  Map<String, dynamic> adjacencyTransform(List<dynamic> nsResult) {
    try {
      int ix = 0;
      void build(Map<String, dynamic> container) {
        container["children"] = [];
        if (container["rgt"] - container["lft"] < 2) {
          return;
        }

        while ((++ix < nsResult.length) &&
            (nsResult[ix]["lft"] > container["lft"]) &&
            (nsResult[ix]["rgt"] < container["rgt"])) {

          try {
            var entries = nsResult[ix]['label'].toString()
                .substring(1,nsResult[ix]['label'].length-1)
                .split(RegExp(r',\s?'))
                .map((e) => e.split(RegExp(r':\s?')))
                .map((e) => MapEntry(e.first, e.last));
            var result = Map.fromEntries(entries);

            var newData = jsonDecode(json.encode(result));
            nsResult[ix]['label'] = newData[lang] == null
                                  ? newData['en'].toString().replaceAll("##", "\'").replaceAll("@@", "\"")
                                  : newData[lang].toString().replaceAll("##", "\'").replaceAll("@@", "\"");
          } catch(e) {
            log("StackTraceMapEntryMultiple====$e");
          }
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
    } catch(e) {
      log("StackTrace====$e");
    }

    return {"children":[]};
  }
}
