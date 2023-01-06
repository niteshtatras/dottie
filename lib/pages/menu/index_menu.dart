import 'dart:convert';
import 'dart:developer';

import 'package:dottie_inspector/database/database_helper.dart';
import 'package:dottie_inspector/inspectionPreferences/inspection_preferences.dart';
import 'package:dottie_inspector/pages/dynamicInspection/dynamic_complete_inspection_screen.dart';
import 'package:dottie_inspector/pages/dynamicInspection/dynamic_general_page.dart';
import 'package:dottie_inspector/pages/inspectionMain/vesselEquipmentInventory/vessel_equipment_inventory_selection_screen.dart';
import 'package:dottie_inspector/pages/inspectionMain/vesselInventory/vessel_inventory_selection_screen.dart';
import 'package:dottie_inspector/deadCode/welcome_new_screen.dart';
import 'package:dottie_inspector/pages/settings/setting_page.dart';
import 'package:dottie_inspector/pages/signInPages/login_page_1.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/SlideRightRoute.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:dottie_inspector/utils/empty_menu_app_bar.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/utils/inspection_utils.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:dottie_inspector/widget/GradientText.dart';
import 'package:dottie_inspector/widget/custome_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DrawerIndexPage extends StatefulWidget {
  @override
  _DrawerIndexPageState createState() => _DrawerIndexPageState();
}

class _DrawerIndexPageState extends State<DrawerIndexPage> {

  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;

  final dbHelper = DatabaseHelper.instance;

  List childData = [];
  String inspectionName = "";

  List inspectionList;

  List answerList = [];
  List bodiesOfWaterList = [];
  List vesselList = [];
  List equipmentList = [];
  List generalEquipmentList = [];
  List allVesselEquipmentList = [];

  List transformedData;
  String lang = "en";
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

    setPreferenceData();
    getThemeData();
    // getPreferenceData();
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

  void setPreferenceData() async {
    var language = await PreferenceHelper.getPreferenceData(PreferenceHelper.LANGUAGE) ?? "en";
    var listItemData = await InspectionPreferences.getPreferenceData(InspectionPreferences.INSPECTION_DATA);
    transformedData = json.decode(listItemData);
    var inName = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_NAME) ?? "Safety Inspection";

    var localWaterBodiesListData = await PreferenceHelper.getPreferenceData(PreferenceHelper.WATER_SELECTED_BODIES);
    bodiesOfWaterList = localWaterBodiesListData != null
        ? json.decode(localWaterBodiesListData)
        : [];
    print("All WaterBodies List====>>>>$bodiesOfWaterList");

    ///Previous selected equipments
    var previousSelectedEquipmentListData = await PreferenceHelper.getPreferenceData(PreferenceHelper.EQUIPMENT_ITEMS);
    var localEquipmentList = previousSelectedEquipmentListData != null
        ? json.decode(previousSelectedEquipmentListData)
        : [];
    print("All Equipment List====>>>>$localEquipmentList");

    var previousAnswersListData = await PreferenceHelper.getPreferenceData(PreferenceHelper.ANSWER_LIST);
    answerList = previousAnswersListData != null
        ? json.decode(previousAnswersListData)
        : [];
    // print("All Answer List====>>>>$prevAnswersList");

    for(int i=0; i<bodiesOfWaterList.length; i++) {
      vesselList.addAll(bodiesOfWaterList[i]['vessels']);
    }

    for(int i=0; i<localEquipmentList.length; i++) {
      if(localEquipmentList[i]['vessel'] != null && localEquipmentList[i]['vessel'].length > 0) {
        allVesselEquipmentList.add(localEquipmentList[i]);
      } else if(localEquipmentList[i]['vessel'] != null && localEquipmentList[i]['vessel'].length == 0) {
        equipmentList.add(localEquipmentList[i]);
      }
    }

    setState(() {
      lang = language;
      inspectionName = inName;
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
        "status": true
      };

      setState(() {
        if((transformedData[i]['blocktype'] == 'vessel inventory' ||
            (transformedData[i]['blocktype'] == 'equipment inventory' && (transformedData[i]['txt']['en'] != null && transformedData[i]['txt']['en']['reporttag'] != 'Vessel Equipment')))
            && transformedData[i]['blocktype'] != 'question') {
          childData.add(labelData);
        }

        for(int j=0; j<localEquipmentList.length; j++) {
          for(int k=0; k<transformedData.length; k++) {
            if (transformedData[k]['equipmentid'] == localEquipmentList[j]['equipmentid']) {
              localEquipmentList[j]["index"] = k;
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
          for(int k=0; k<transformedData.length; k++) {
            if (transformedData[k]['vesselid'] == vesselList[j]['vesselid']) {
              vesselList[j]["index"] = k;
              break;
            }
          }
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

  void getPreferenceData() async {
    ///Children Inspection Data
    var listItemData = await InspectionPreferences.getPreferenceData(InspectionPreferences.INSPECTION_DATA);
    var transformedData = json.decode(listItemData);
    int inspectionIndex = await InspectionPreferences.getInspectionId(InspectionPreferences.INSPECTION_INDEX) ?? 0;

    for(int i=0; i < transformedData.toList().length; i++) {
      if(transformedData[i]['questiontype'] == 'label') {
        var labelData = {
          "blocktype": transformedData[i]['blocktype'],
          "questionid": transformedData[i]['questionid'],
          "questiontype": transformedData[i]['questiontype'],
          "txt": transformedData[i]['txt'],
          "index": i,
          "status": (i <= inspectionIndex)
        };

        setState(() {
          childData.add(labelData);
        });
      }
    }

    var inName = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_NAME) ?? "Safety Inspection";
    setState(() {
      inspectionName = inName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? AppColor.BLACK_COLOR : AppColor.PAGE_COLOR,
      appBar: EmptyAppBar(isDarkMode: isDarkMode),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
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
                ),

                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                      "Index",
                      style: TextStyle(
                          fontSize: 32,
                          color: themeColor,
                          fontWeight: FontWeight.w700,
                      )
                  ),
                ),

                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                      "$inspectionName",
                      style: TextStyle(
                        fontSize: 16,
                        color: themeColor,
                        fontWeight: FontWeight.w600,
                      )
                  ),
                ),

                SizedBox(height: 16,),

                Flexible(
                  fit: FlexFit.loose,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
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
                              color: isDarkMode
                                  ? Color(0xff1F1F1F)
                                  : AppColor.WHITE_COLOR,
                            ),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                  dividerColor: Colors.transparent,
                                  splashColor: AppColor.TRANSPARENT,
                                  backgroundColor: AppColor.TYPE_PRIMARY.withOpacity(0.08)
                              ),
                              child: ExpansionTile(
                                title: getExpansionTileTitle(childData[index]['status'], childData[index]['txt']['en']['reporttag']),
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
                                          padding: vesselList.length == 0
                                              ? EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0)
                                              : EdgeInsets.symmetric(horizontal: 0.0, vertical: 12.0),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(32),
                                              color: AppColor.WHITE_COLOR.withOpacity(0.4)
                                          ),
                                          margin: EdgeInsets.only(top: 8),
                                          child: ExpansionTile(
                                            title: getExpansionTileTitle(
                                                true,
                                                vesselList[subIndex]['vesselname']
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
                                                  callBack: (){
                                                    openNextScreen(vesselList[subIndex]['index']);
                                                  },
                                                  isNormalTitle: false
                                              ),
                                              ListView.builder(
                                                itemCount: allVesselEquipmentList != null ? allVesselEquipmentList.length : 0,
                                                shrinkWrap: true,
                                                physics: NeverScrollableScrollPhysics(),
                                                itemBuilder: (context, index1) {
                                                  log("EquipmentData===${allVesselEquipmentList[index1]['index']}");
                                                  return getSectionTitle(
                                                      true,
                                                      allVesselEquipmentList[index1]['equipmentdescription'],
                                                      isChildren: true,
                                                      callBack: (){
                                                        openNextScreen(allVesselEquipmentList[index1]['index']);
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
                                          callBack: (){
                                            openNextScreen(equipmentList[subIndex]['index']);
                                          },
                                          isNormalTitle: false
                                      );
                                    },
                                  ),


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
                                callBack: () {
                                  openNextScreen(childData[index]['index']);
                                }
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          _progressHUD
        ],
      ),
    );
  }

  Widget getSectionTitle(status, title, {isNormalTitle = true, isChildren = false, Function callBack, boxColor}) {
    var color = boxColor ?? AppColor.TYPE_PRIMARY.withOpacity(0.08);
    return GestureDetector(
      onTap: callBack != null ? callBack : (){},
      child: Container(
        margin: isChildren ? EdgeInsets.only(left: 8, right: 8, bottom: 8) : EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.symmetric(horizontal: isChildren ? 8.0 : 16.0, vertical: 12.0),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            // color: isChildren
            //     ? AppColor.TYPE_PRIMARY.withOpacity(0.04)
            //     : AppColor.TYPE_PRIMARY.withOpacity(0.06)
          color: isDarkMode
              ? Color(0xff1F1F1F)
              : AppColor.WHITE_COLOR,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image(
                    image: AssetImage(
                        status
                            ? 'assets/ic_side_menu_icon.png'
                            : 'assets/ic_side_menu_uncompleted.png'
                    ),
                    fit: BoxFit.cover,
                    height: 48.0,
                    width: 48.0,
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    color: status
                        ? AppColor.TRANSPARENT
                        : AppColor.TYPE_PRIMARY.withOpacity(0.8),
                    height: 48.0,
                    width: 48.0,
                  ),
                ),
              ],
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
                maxLines: 1,
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

  Widget getExpansionTileTitle(status, title) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image(
                  image: AssetImage(
                      status
                          ? 'assets/ic_side_menu_icon.png'
                          : 'assets/ic_side_menu_uncompleted.png'
                  ),
                  fit: BoxFit.cover,
                  height: 48.0,
                  width: 48.0,
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  color: status
                      ? AppColor.TRANSPARENT
                      : AppColor.TYPE_PRIMARY.withOpacity(0.8),
                  height: 48.0,
                  width: 48.0,
                ),
              ),
            ],
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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
