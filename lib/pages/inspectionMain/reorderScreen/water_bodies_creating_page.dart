import 'dart:convert';
import 'dart:developer';

import 'package:dottie_inspector/database/database_helper.dart';
import 'package:dottie_inspector/inspectionPreferences/inspection_preferences.dart';
import 'package:dottie_inspector/pages/dynamicInspection/dynamic_general_page.dart';
import 'package:dottie_inspector/pages/menu/drawer_page.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/SlideRightRoute.dart';
import 'package:dottie_inspector/utils/custom_toast.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/utils/inspection_utils.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:dottie_inspector/widget/bottom_button_widget.dart';
import 'package:dottie_inspector/widget/dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:progress_hud/progress_hud.dart';

class WaterBodiesCreatePage extends StatefulWidget {
  final waterBodiesList;
  final count;
  final inspectionData;

  const WaterBodiesCreatePage({Key key, this.waterBodiesList, this.count, this.inspectionData})
      : super(key: key);

  @override
  _WaterBodiesCreatePageState createState() => _WaterBodiesCreatePageState();
}

class _WaterBodiesCreatePageState extends State<WaterBodiesCreatePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List waterBodiesList;
  List newBodyOfWaterList = [];
  List allBodyOfWaterList = [];
  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;
  var elevation = 0.0;
  final _scrollController = ScrollController();
  List waterBodies = [];
  var inspectionData;
  var dynamicData;
  final dbHelper = DatabaseHelper.instance;

  JsonEncoder encoder = JsonEncoder.withIndent('  ');

  bool isDarkMode = false;
  Color themeColor = AppColor.BLACK_COLOR;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      print(widget.count);
      if(widget.count == 1)
        showLoading(context);
    });
    _progressHUD = ProgressHUD(
      backgroundColor: Colors.transparent,
      color: Colors.white,
      containerColor: AppColor.LOADER_COLOR,
      borderRadius: 5.0,
      loading: _loading,
      text: 'Loading...',
    );

    waterBodiesList = widget.waterBodiesList;

    _scrollController.addListener(() {
      setState(() {
        if(_scrollController.position.pixels > _scrollController.position.minScrollExtent){
          elevation = HelperClass.ELEVATION_1;
        } else {
          elevation = HelperClass.ELEVATION;
        }
      });
    });

    getThemeData();
    getPreferenceData();
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
    var listItem = await PreferenceHelper.getPreferenceData(PreferenceHelper.WATER_BODIES);
    String lang = await PreferenceHelper.getPreferenceData(PreferenceHelper.LANGUAGE);

    var localWaterBodiesListData = await PreferenceHelper.getPreferenceData(PreferenceHelper.WATER_SELECTED_BODIES);
    List waterBodiesTemplateData = localWaterBodiesListData != null
        ? json.decode(localWaterBodiesListData)
        : [];
    log("All WaterBodies List====>>>>$waterBodiesTemplateData");

    setState(() {
      waterBodies = json.decode(listItem);

      log("InspectionData=====>>>>>${widget.inspectionData}");
      var data = widget.inspectionData;
      dynamicData = data['txt'][lang] ?? data['txt']['en'];

      inspectionData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode ? AppColor.BLACK_COLOR : AppColor.PAGE_COLOR,
      appBar: EmptyAppBar(isDarkMode: isDarkMode),
      // appBar: AppBar(
      //   centerTitle: true,
      //   elevation: elevation,
      //   backgroundColor: AppColor.PAGE_COLOR,
      //   leading: GestureDetector(
      //     onTap: (){
      //       Navigator.pop(context);
      //     },
      //     child: Container(
      //       padding: EdgeInsets.all(16.0),
      //       child: Image.asset(
      //         'assets/ic_close.png',
      //         fit: BoxFit.cover,
      //         height: 28.0,
      //         width: 28.0,
      //       ),
      //     ),
      //   ),
      // ),
      drawer: Drawer(
        child: DrawerPage(),
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
                        // await dbHelper.deleteBodyOfWaterData();
                        // await dbHelper.deleteVesselsData();
                        //
                        // allBdyOfWaterList.clear();
                        getThemeData();
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

                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            dynamicData != null
                                ? dynamicData['section'] ?? ""
                                : "",
                            style: TextStyle(
                              color: themeColor.withOpacity(0.6),
                              fontSize: TextSize.subjectTitle,
                              fontWeight: FontWeight.w600,
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
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 24.0,vertical: 8.0),
                          child: Text(
                            dynamicData != null
                                ? dynamicData['title'] ?? ""
                                : "",
                            style: TextStyle(
                                fontSize: TextSize.pageTitleText,
                                color: themeColor,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                                height: 1.3
                            ),
                          ),
                        ),

                        dynamicData == null
                            ? Container()
                            : dynamicData['helpertext'] != null
                            ? Container(
                          margin: EdgeInsets.only(left: 24.0,right: 24.0),
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

                        SizedBox(height: 8.0,),

                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: 500.0
                          ),
                          child: Container(
                            margin: EdgeInsets.only(top: 16.0),
                            child: ListView.builder(
                              itemCount: waterBodiesList != null ? waterBodiesList.length : 0,
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index){
                                return waterBodiesList[index].length > 0
                                  ? Container(
                                  margin: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16),
                                    child: DottedBorder(
                                    radius: Radius.circular(32.0),
                                    borderType: BorderType.RRect,
                                    strokeWidth: 5.0,
                                    strokeCap: StrokeCap.square,
                                    dashPattern: [5,10],
                                      child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                                      decoration: BoxDecoration(
                                         color: AppColor.TRANSPARENT,
                                         borderRadius: BorderRadius.circular(24.0)
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          ListView.builder(
                                            itemCount: waterBodiesList[index] != null ? waterBodiesList[index].length : 0,
                                            physics: NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemBuilder: (context, subIndex){
                                              print("$index, $subIndex====${waterBodiesList[index][subIndex]['svgicon']}");
                                              return Container(
                                                margin: EdgeInsets.only(top: 12.0),
                                                padding: EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                    color: isDarkMode
                                                    ? Color(0xff1f1f1f)
                                                    : Color(0xffffffff),
                                                    borderRadius: BorderRadius.circular(24)
                                                ),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    /*Container(
                                                      decoration: BoxDecoration(
                                                          color: AppColor.BACKGROUND_COLOR.withOpacity(0.12),
                                                          borderRadius: BorderRadius.circular(24)
                                                      ),
                                                      padding: EdgeInsets.all(12.0),
                                                      child: Image.asset(
                                                        '${waterBodiesList[index][subIndex]['svgicon']}',
                                                        width: 24.0,
                                                        height: 24.0,
                                                        color: AppColor.THEME_PRIMARY,
                                                      ),
                                                    ),*/
                                                    Container(
                                                      decoration: BoxDecoration(
                                                          color: isDarkMode
                                                          ? Color(0xff333333)
                                                          : AppColor.TYPE_PRIMARY.withOpacity(0.08),
                                                          borderRadius: BorderRadius.circular(24)
                                                      ),
                                                      padding: EdgeInsets.all(12.0),
                                                      child: waterBodiesList[index][subIndex]['svgicon'] == "null"
                                                        ? Image.asset(
                                                        'assets/ic_pool.png',
                                                        width: 24.0,
                                                        height: 24.0,
                                                        color: AppColor.THEME_PRIMARY,
                                                      )
                                                      : Container(
                                                          height: 24.0,
                                                          width: 24.0,
                                                          child: SvgPicture.string(
                                                              '${waterBodiesList[index][subIndex]['svgicon'].toString().replaceAll("\\", "")}'
                                                          ),
                                                        ),
                                                      ),
                                                    SizedBox(width: 16.0,),
                                                    Expanded(
                                                      child: Container(
                                                        padding: EdgeInsets.only(right: 8.0),
                                                        child: Text(
                                                          '${waterBodiesList[index][subIndex]['body']}',
                                                          style: TextStyle(
                                                              color: themeColor,
                                                              fontSize: TextSize.headerText,
                                                              fontStyle: FontStyle.normal,
                                                              fontWeight: FontWeight.w600
                                                          ),
                                                        ),
                                                      ),
                                                    ),

                                                    GestureDetector(
                                                      onTap: (){
                                                        bottomSelectNavigation(context, index, subIndex, waterBodiesList[index][subIndex]);
                                                      },
                                                      child: Container(
                                                        margin: EdgeInsets.only(left: 8.0),
                                                        height: 48.0,
                                                        width: 48.0,
                                                        decoration: BoxDecoration(
                                                            color: themeColor.withOpacity(0.08),
                                                            shape: BoxShape.circle,
                                                            border: Border.all(
                                                              color: isDarkMode
                                                              ? Color(0xff757575)
                                                              : AppColor.TYPE_PRIMARY.withOpacity(0.6),
                                                              width: 4.0,
                                                            )
                                                        ),
                                                        child: Icon(
                                                          Icons.done,
                                                          size: 24.0,
                                                          color: AppColor.TRANSPARENT,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                          Container(
                                            alignment: Alignment.bottomRight,
                                            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                            child: Text(
                                              'BODY OF WATER ${index+1}',
                                              style: TextStyle(
                                                  color: themeColor,
                                                  fontSize: TextSize.bodyText,
                                                  fontStyle: FontStyle.normal,
                                                  fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                ),
                                    ),
                                  )
                                  : Container();
                              },
                            ),
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

          // Submit
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: BottomButtonWidget(
              isActive: true,
              onBackButton: () async {
                int inspectionIndex = await InspectionPreferences.getInspectionId(InspectionPreferences.INSPECTION_INDEX);
                InspectionUtils.decrementIndex(inspectionIndex);
                Navigator.pop(context);

                // final dbHelper = DatabaseHelper.instance;
                // await dbHelper.deleteBodyOfWaterData();
                // await dbHelper.deleteVesselsData();
              },
              onNextButton: (){
                createWaterOfBodies();
                // const JsonEncoder encoder = JsonEncoder.withIndent('  ');
                // log("TransformedData====>>>>${encoder.convert(waterBodiesList)}");
                //
                // // log('Print===>>>$waterBodiesList');
                // print('PrintLength===>>>${waterBodiesList.length}');
              },
            )
          ),

          _progressHUD
        ],
      ),
    );
  }

  bottomSelectNavigation(context, mainIndex, subIndex, vessel){
    final _scrollBarController = ScrollController();

    showModalBottomSheet(
        context: context,
        barrierColor: themeColor.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        builder: (context){
          return StatefulBuilder(
            builder: (context1, myState){
              return ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 220.0
                ),
                child: Container(
                  height: 270.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 12.0,),
                      Container(
                        padding: EdgeInsets.only(left: 20.0, right:20.0, top: 16.0, bottom: 4.0),
                        child: Text(
                          'Reassign ${vessel['body']} to a body of water:',
                          style: TextStyle(
                              fontSize: TextSize.headerText,
                              color: themeColor,
                              fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Divider(
                        height: 1.0,
                        color: AppColor.SEC_DIVIDER,
                      ),
                      Container(
                        height: 140.0,
                        padding: EdgeInsets.only(left: 20.0, right:20.0),
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: waterBodiesList != null ? waterBodiesList.length+1 : 0,
                          itemBuilder: (context, index){
                            return Visibility(
                              visible: mainIndex+1 != index,
                              child: GestureDetector(
                                onTap: (){
                                    setState(() {
                                      myState((){
                                        if(index == 0){
                                          List newList = List();
                                          newList.add(vessel);
                                          waterBodiesList.add(newList);
                                        } else {
                                          waterBodiesList[index - 1].add({
                                            "simplelistid": "${vessel['simplelistid']}",
                                            "body": "${vessel['body']}",
                                            "svgicon": "${vessel['svgicon']}",
                                            "status": vessel['status']
                                          });
                                        }
                                        waterBodiesList[mainIndex].removeAt(subIndex);
                                        Navigator.pop(context);
                                        print("\n===============\nWaterBodies=====>$waterBodiesList\n===============");
                                      });
                                    });
                                },
                                child: Container(
                                  padding: EdgeInsets.only(top: 16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      index == 0
                                      ? Container(
                                        child: DottedBorder(
                                          dashPattern: [8,4],
                                          strokeWidth: 4,
                                          radius: Radius.circular(40),
                                          borderType: BorderType.RRect,
                                          color: Colors.transparent,
                                          child: Container(
                                            padding: EdgeInsets.all(16),
                                            child: Image.asset(
                                              'assets/new_ui/ic_plus.png',
                                              fit: BoxFit.contain,
                                              height: 32.0,
                                              width: 32.0,
                                              color: themeColor,
                                            ),
                                          ),
                                        ),
                                      )
                                      : Container(
                                        margin: EdgeInsets.only(left: 16),
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(40),
                                          gradient: LinearGradient(
                                            colors: AppColor.gradientColor(0.24)
                                          )
                                        ),
                                        child: Image.asset(
                                          'assets/new_ui/ic_new_body_surface.png',
                                          width: 40.0,
                                          height: 40.0,
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 16),
                                        width: 72,
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.only(top: 8.0),
                                        child: Center(
                                          child: Text(
                                            index == 0 ? 'New' : index < 10 ? '0$index' : '$index',
                                            // '10',
                                            style: TextStyle(
                                                color: themeColor,
                                                fontSize: TextSize.subjectTitle,
                                                fontStyle: FontStyle.normal,
                                                fontWeight: FontWeight.w600,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
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

                      Container(
                        margin: EdgeInsets.only(top: 8),
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 120.0,
                            height: 40.0,
//                        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Color(0xffffffff)
                                    : AppColor.BLACK_COLOR,
                                borderRadius: BorderRadius.all(Radius.circular(32.0))
                            ),
                            child: Center(
                              child: Text(
                                'Cancel',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isDarkMode
                                      ? AppColor.BLACK_COLOR
                                      : AppColor.WHITE_COLOR,
                                  fontSize: TextSize.subjectTitle,
                                  fontWeight: FontWeight.w500,
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

  void createWaterOfBodies() async {
    var response;

    for(int i=0; i<waterBodiesList.length; i++){
      var bodyName = "";
      for(int k=0; k<waterBodiesList[i].length; k++){
        bodyName = bodyName + (bodyName.isEmpty ? "" : " & ") + waterBodiesList[i][k]['body'];
      }
      newBodyOfWaterList.add({
        "name": bodyName,
        "type": "water bodies",
        "isInspected": false,
      });

      if(waterBodiesList[i].length > 0){
         response = await updateLocalDBWaterBodies(i);
       }
      /// online
      // if(waterBodiesList[i].length > 0){
      //   response = await updateWaterBodies(i);
      // }
    }
  /*  log("Prev List Data=====>>>>${waterBodiesList.toString()}");
    List newWaterBodiesListData = [];
    List newVesselWaterBodiesListData = [];
    for(int i=0; i<waterBodiesList.length; i++){
      for(int j=0; j<waterBodiesList[i].length; j++){
        newVesselWaterBodiesListData.add(waterBodiesList[i][j]);
      }
      newWaterBodiesListData.add({
        "vessels": newVesselWaterBodiesListData
      });
    }

    log("New List Data=====>>>>${newWaterBodiesListData.toString()}");*/

    if(response != null) {
      print("WaterBodies111====$newBodyOfWaterList");
      PreferenceHelper.clearPreferenceData(PreferenceHelper.WATER_VESSEL_BODIES_ITEM);
      PreferenceHelper.setPreferenceData(
          PreferenceHelper.WATER_VESSEL_BODIES_ITEM,
          json.encode(newBodyOfWaterList)
      );
      print("waterBodies222====>>>>$newBodyOfWaterList");

      PreferenceHelper.clearPreferenceData(PreferenceHelper.WATER_VESSEL_BODIES);
      PreferenceHelper.setPreferenceData(
          PreferenceHelper.WATER_VESSEL_BODIES,
          json.encode(waterBodies)
      );

      ///Previous selected equipments
      var previousSelectedEquipmentListData = await PreferenceHelper.getPreferenceData(PreferenceHelper.EQUIPMENT_ITEMS);
      List prevSelectedEquipmentList = previousSelectedEquipmentListData != null
          ? json.decode(previousSelectedEquipmentListData)
          : [];
      print("All Equipment List====>>>>$prevSelectedEquipmentList");

      PreferenceHelper.clearPreferenceData(PreferenceHelper.WATER_BODIES);
      PreferenceHelper.setPreferenceData(
          PreferenceHelper.WATER_BODIES,
          json.encode(waterBodies)
      );
      /// Testing
      ///
      log("Water List Data=====>>>>${allBodyOfWaterList.toString()}");
      PreferenceHelper.clearPreferenceData(PreferenceHelper.WATER_SELECTED_BODIES);
      PreferenceHelper.setPreferenceData(
          PreferenceHelper.WATER_SELECTED_BODIES,
          json.encode(allBodyOfWaterList)
      );
      var localChildData = await InspectionPreferences.getPreferenceData(InspectionPreferences.INSPECTION_CHILD_DATA);
      var childrenTemplateData = localChildData != null
                              ? json.decode(localChildData)
                              : [];
      const JsonEncoder encoder = JsonEncoder.withIndent('  ');
      // log("ChildrenData====${encoder.convert(childrenTemplateData)}");

      ///Answer List
      var previousAnswersListData = await PreferenceHelper.getPreferenceData(PreferenceHelper.ANSWER_LIST);
      List prevAnswersList = previousAnswersListData != null
          ? json.decode(previousAnswersListData)
          : [];
      print("All Answer List====>>>>$prevAnswersList");

      /*** Set the answer list to shared preferences ***/
      PreferenceHelper.clearPreferenceData(PreferenceHelper.ANSWER_LIST);
      PreferenceHelper.setPreferenceData(PreferenceHelper.ANSWER_LIST, json.encode(prevAnswersList));

      var inspectionLocalId = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ID);
      var transformedData = HelperClass.unroll(int.parse(inspectionLocalId), childrenTemplateData, allBodyOfWaterList, prevSelectedEquipmentList, prevAnswersList);

      // log("TransformedData====>>>>>$transformedData");
      log("TransformedData====>>>>${encoder.convert(transformedData)}");

      InspectionPreferences.clearPreferenceData(InspectionPreferences.INSPECTION_DATA);
      InspectionPreferences.setPreferenceData(
          InspectionPreferences.INSPECTION_DATA,
          json.encode(transformedData['flow'])
      );

      openNextScreen();
    }
  }

  Future updateWaterBodies(index) async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var addressId = await PreferenceHelper.getPreferenceData(PreferenceHelper.LOCATION_ID);
    var clientId = await PreferenceHelper.getPreferenceData(PreferenceHelper.CLIENT_ID);

    var requestJson = {};
    var requestParam = json.encode(requestJson);
    var response = await request.postRequest(
        "auth/myclient/$clientId/servicelocation/$addressId/bodyofwater",
        requestParam
    );
    _progressHUD.state.dismiss();

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage('${response['reason']}');
      } else {
//        PreferenceHelper.setPreferenceData(PreferenceHelper.WATER_ID, "${response['bodyofwaterid']}");
        setState(() {
          newBodyOfWaterList[index]['bodyofwaterid'] = response['bodyofwaterid'];
        });
        allBodyOfWaterList.add(response);
        var response1;
        for(int i=0; i<waterBodiesList[index].length; i++) {
          response1 = await createWaterVessels(index, response['bodyofwaterid'], waterBodiesList[index][i]);
        }

        return response1;
       /* Navigator.push(
            context,
            SlideRightRoute(
                page: ReorderWaterBodies()
            )
        );*/
      }
    }
  }

  Future createWaterVessels(index, waterId, waterVesselItem) async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var addressId = await PreferenceHelper.getPreferenceData(PreferenceHelper.LOCATION_ID);
    var clientId = await PreferenceHelper.getPreferenceData(PreferenceHelper.CLIENT_ID);
    var bodyOfWaterId = waterId;
//    var addressId = "6";
//    var clientId = "4";

    var requestJson = {
      "vesseltype":"${waterVesselItem['simplelistid']}",
      "vesselname":"${waterVesselItem['body']}",
      "units":"feet"
    };

    var requestParam = json.encode(requestJson);
    var response = await request.postRequest(
        "auth/myclient/$clientId/servicelocation/$addressId/bodyofwater/$bodyOfWaterId/vessel",
        requestParam
    );
    _progressHUD.state.dismiss();
    setState(() {
      /*var simpleListId = response['vesseltype']['simplelistid'];
      for(int i=0; i<waterBodies.length; i++){
        if("$simpleListId" == waterBodies[i]['simplelistid']){
          waterBodies[i]['vesselid'] = response['vesselid'];
          waterBodies[i]['bodyofwaterid'] = bodyOfWaterId;

          return response;
        }
      }*/

      allBodyOfWaterList[index]['vessels'].add(response);
    });

    return response;
  }

  void showLoading(context) {
    var sLoadingContext;
    print("show loading call");
    showDialog(
      context: context,
      barrierColor: themeColor.withOpacity(0.5),
      barrierDismissible: false,
      builder: (BuildContext loadingContext) {
        sLoadingContext = loadingContext;
        return Center(
          child: Container(
            height: 500,
            margin: EdgeInsets.only(top: 50, bottom: 30),
            child: Dialog(
              backgroundColor: isDarkMode ? Color(0xffF2F2F2).withOpacity(0.8) : Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16.0))
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: 24.0, bottom: 16.0),
                    child: Image.asset(
                      'assets/ic_vessels.png',
                      fit: BoxFit.cover,
                      height: 100.0,
                      width: 100.0,
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'You Can Skip This Step',
                      style: TextStyle(
                          fontSize: 20,
                          color: AppColor.BLACK_COLOR,
                          fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                     'Since you will only be inspecting the pool you can proceed to the next step. Or choose to add more vessels.',
                      style: TextStyle(
                          fontSize: TextSize.subjectTitle,
                          color: AppColor.BLACK_COLOR,
                          fontWeight: FontWeight.w400,
                          height: 1.3
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 16,),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xff3C3C43).withOpacity(0.36),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () async {
                              int inspectionIndex = await InspectionPreferences.getInspectionId(InspectionPreferences.INSPECTION_INDEX);
                              InspectionUtils.decrementIndex(inspectionIndex);
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: 56.0,
                              alignment: Alignment.center,
                              child: Text(
                                'ADD MORE',
                                style: TextStyle(
                                  fontSize: TextSize.subjectTitle,
                                  color: AppColor.THEME_PRIMARY,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 56,
                          child: VerticalDivider(
                            width: 1,
                            thickness: 1,
                            color:  Color(0xff3C3C43).withOpacity(0.36),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: (){
                              Navigator.pop(context);
                              createWaterOfBodies();
                            },
                            child: Container(
                              height: 56.0,
                              alignment: Alignment.center,
                              child: Text(
                                'NEXT STEP',
                                style: TextStyle(
                                  fontSize: TextSize.subjectTitle,
                                  color: AppColor.THEME_PRIMARY,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        )
                      ],
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

  void openNextScreen() async {
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

  /// Add Vessel and Body Of Water into local DB
  Future updateLocalDBWaterBodies(index) async {
    FocusScope.of(context).requestFocus(FocusNode());
    var addressId = await PreferenceHelper.getPreferenceData(PreferenceHelper.LOCATION_ID);
    var clientId = await PreferenceHelper.getPreferenceData(PreferenceHelper.CLIENT_ID);

    var requestJson = {};
    var requestParam = json.encode(requestJson);

    // var endPoint = "auth/myclient/$clientId/servicelocation/$addressId/bodyofwater";
    var endPoint = "auth/myclient/{{clientid}}/servicelocation/{{serviceid}}/bodyofwater";
    var response;
    var bodyData = {
      "bodyofwaterid": 0,
      "bodyofwatergeneralid": 0,
      "serviceaddressid": "$addressId",
      "customerlocalid": clientId,
      "servicelocalid": addressId,
      "payload": json.encode(requestJson),
      "url": "$endPoint",
      "verb": "POST",
      "vessels": []
    };
    log("BodyData====${bodyData['bodyofwaterid']}");
    response = await dbHelper.insertBodyOfWaterData(bodyData);

    if(response != null) {
      PreferenceHelper.setPreferenceData(PreferenceHelper.WATER_ID, "$response");

      setState(() {
        newBodyOfWaterList[index]['bodyofwaterid'] = "$response";
        bodyData['bodyofwaterid'] = response;
      });
      log("bodyOfWater====${bodyData['bodyofwaterid']}");
      allBodyOfWaterList.insert(index, json.decode(json.encode(bodyData)));
      // log("allBodyOfWaterList111====>>>>${encoder.convert(allBodyOfWaterList)}");
      var response1;
      for(int i=0; i<waterBodiesList[index].length; i++) {
        response1 = await createLocalDBWaterVessels(index, "$response", waterBodiesList[index][i]);
      }

      return response1;
    }

   /* var response = await request.postRequest(
        "auth/myclient/$clientId/servicelocation/$addressId/bodyofwater",
        requestParam
    );
    _progressHUD.state.dismiss();

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage('${response['reason']}');
      } else {
//        PreferenceHelper.setPreferenceData(PreferenceHelper.WATER_ID, "${response['bodyofwaterid']}");
        setState(() {
          newBodyOfWaterList[index]['bodyofwaterid'] = response['bodyofwaterid'];
        });
        allBodyOfWaterList.add(response);
        var response1;
        for(int i=0; i<waterBodiesList[index].length; i++) {
          response1 = await createWaterVessels(index, response['bodyofwaterid'], waterBodiesList[index][i]);
        }

        return response1;
        *//* Navigator.push(
            context,
            SlideRightRoute(
                page: ReorderWaterBodies()
            )
        );*//*
      }
    }*/
  }

  Future createLocalDBWaterVessels(index, waterId, waterVesselItem) async {
    // _progressHUD.state.show();
    log("createLocalDBWaterVessels====$waterVesselItem");
    // log("allBodyOfWaterList222====>>>>${encoder.convert(allBodyOfWaterList)}");
    FocusScope.of(context).requestFocus(FocusNode());
    var addressId = await PreferenceHelper.getPreferenceData(PreferenceHelper.LOCATION_ID);
    var clientId = await PreferenceHelper.getPreferenceData(PreferenceHelper.CLIENT_ID);
    var bodyOfWaterId = waterId;
//    var addressId = "6";
//    var clientId = "4";
//     var endPoint = "auth/myclient/$clientId/servicelocation/$addressId/bodyofwater/{{bodyofwaterid}}/vessel";
    var endPoint = "auth/myclient/{{clientid}}/servicelocation/{{serviceid}}/bodyofwater/{{bodyofwaterid}}/vessel";

    var requestJson = {
      "vesseltype":"${waterVesselItem['simplelistid']}",
      "vesselname":"${waterVesselItem['body']}",
      "units":"feet"
    };

    var response;
    var vesselData = {
      "vesselname": "${waterVesselItem['body']}",
      "vesselid": 0,
      "vesselgeneralid": 0,
      "customerlocalid": clientId,
      "servicelocalid": addressId,
      "bodyofwaterid": bodyOfWaterId,
      "bodyofwateridlocal": bodyOfWaterId,
      "vesseltypeloc": "${waterVesselItem['simplelistid']}",
      "vesseltype": {
        "simplelistid": waterVesselItem['simplelistid'] != null ? int.parse("${waterVesselItem['simplelistid']}") : 0,
        "label": "${waterVesselItem['body']}"
      },
      "units": "feet",
      "payload": json.encode(requestJson),
      "url": "$endPoint",
      "verb": "POST"
    };

    response = await dbHelper.insertVesselsData(vesselData);
    log("VesselResponse====$response");
    log("VesselEquipmentData===${allBodyOfWaterList[index]['vessels']}");

    setState(() {
      vesselData['vesselid'] = response;

      var simpleListId = "$response";
      for(int i=0; i<waterBodies.length; i++){
        if("$simpleListId" == waterBodies[i]['simplelistid']){
          waterBodies[i]['vesselid'] = response;
          waterBodies[i]['bodyofwaterid'] = bodyOfWaterId;

          return response;
        }
      }

      // log("Response====$response");
      // log("allBodyOfWaterList333====>>>>${encoder.convert(allBodyOfWaterList)}");
    });

    log("VesselData====$vesselData");

    allBodyOfWaterList[index]['vessels'].add(json.decode(json.encode(vesselData)));
    log("VesselEquipmentData111===${allBodyOfWaterList[index]['vessels']}");

    // log("allBodyOfWaterList444====>>>>${encoder.convert(allBodyOfWaterList)}");
    /*var requestParam = json.encode(requestJson);
    var response = await request.postRequest(
        "auth/myclient/$clientId/servicelocation/$addressId/bodyofwater/$bodyOfWaterId/vessel",
        requestParam
    );
    _progressHUD.state.dismiss();
    setState(() {
      *//*var simpleListId = response['vesseltype']['simplelistid'];
      for(int i=0; i<waterBodies.length; i++){
        if("$simpleListId" == waterBodies[i]['simplelistid']){
          waterBodies[i]['vesselid'] = response['vesselid'];
          waterBodies[i]['bodyofwaterid'] = bodyOfWaterId;

          return response;
        }
      }*//*

      allBodyOfWaterList[index]['vessels'].add(response);
    });*/

    return response;
  }

}
