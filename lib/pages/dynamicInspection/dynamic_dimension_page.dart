import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:dottie_inspector/database/database_helper.dart';
import 'package:dottie_inspector/inspectionPreferences/inspection_preferences.dart';
import 'package:dottie_inspector/pages/dynamicInspection/dynamic_complete_inspection_screen.dart';
import 'package:dottie_inspector/pages/dynamicInspection/dynamic_general_page.dart';
import 'package:dottie_inspector/pages/menu/drawer_page.dart';
import 'package:dottie_inspector/pages/menu/index_menu.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_hud/progress_hud.dart';

class DynamicDimensionPage extends StatefulWidget {
  final inspectionData;
  final lastIndex;

  const DynamicDimensionPage({Key key, this.inspectionData, this.lastIndex}) : super(key: key);

  @override
  _DynamicDimensionPageState createState() => _DynamicDimensionPageState();
}

class _DynamicDimensionPageState extends State<DynamicDimensionPage> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final dbHelper = DatabaseHelper.instance;

  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;
  var inspectionItem;
  String equipmentName = "Pool";
  var elevation = 0.0;
  final _scrollController = ScrollController();
  var answerId = "";
  int previousLength = 0;
  int previousWidth = 0;
  int previousDepth = 0;
  int volume = 0;
  bool isAnswerChange = false;
  var dynamicData;
  var inspectionData;
  var label = 'Feet';
  List optionList = [];
  List measurementList = [];
  var vesselId;
  var vesselname;
  bool isDimensionSelected;
  var sectionName;
  var completeButtonName = "Next";
  String lang = "en";

  var answerDataList = [];
  var localAnswerResult = [];

  bool isDarkMode = false;
  Color themeColor = AppColor.BLACK_COLOR;

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
    getThemeData();
    getPreferenceData();

    _scrollController.addListener(() {
      setState(() {
        if(_scrollController.position.pixels > _scrollController.position.minScrollExtent){
          elevation = HelperClass.ELEVATION_1;
        } else {
          elevation = HelperClass.ELEVATION;
        }
      });
    });
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
    int inspectionIndex = await InspectionPreferences.getInspectionId(InspectionPreferences.INSPECTION_INDEX);
    lang = await PreferenceHelper.getPreferenceData(PreferenceHelper.LANGUAGE);

    inspectionData = widget.inspectionData;

    var inspectionId = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ID);
    var vesselId1 = inspectionData.containsKey('vesselid') ? inspectionData['vesselid']?? null : null;
    var equipmentId = inspectionData.containsKey('equipmentid') ? inspectionData['equipmentid']?? null : null;
    var bodyOfWaterId = inspectionData.containsKey('bodyofwaterid') ? inspectionData['bodyofwaterid']?? null : null;
    var inspectionDefId = inspectionData['inspectiondefid'];
    var questionId1 = inspectionData['questionid'];

    localAnswerResult = await dbHelper.fetchAnswerRecord(
        inspectionDefId: "$inspectionDefId",
        inspectionId: "$inspectionId",
        questionId: "$questionId1",
        bodyOfWaterId: bodyOfWaterId,
        vesselId: vesselId1,
        equipmentId: equipmentId) ?? [];

    log("inspectionDefId===$inspectionDefId, "
        "InspectionId===$inspectionId, questionId===$questionId1, "
        "bodyOfWaterId===$bodyOfWaterId, vesselId===$vesselId1, "
        "equipmentId===$equipmentId");

    log("Result===$localAnswerResult");

    setState(() {
      dynamicData = inspectionData['txt'][lang] ?? inspectionData['txt']['en'];
      measurementList = inspectionData['children'] ?? [];
      vesselId = inspectionData['vesselid'] ?? '';
      vesselname = inspectionData['vesselname'] ?? '';

      log("AnswerRecord====${inspectionData['answers']}");
      answerDataList = inspectionData['answers'] ?? [];

      sectionName = HelperClass.getSectionText(inspectionData);
      if(widget.lastIndex != null){
        if(widget.lastIndex == inspectionIndex) {
          completeButtonName = "Complete";
        }
      }

      for(int i=0; i<measurementList.length; i++) {
        measurementList[i]['prevAnswer'] = -1;
        if(measurementList[i]['answerscope'] != null){
          if(measurementList[i]['answerscope']['min'] != null) {
            measurementList[i]['value'] = int.parse("${measurementList[i]['answerscope']['min']}");
          } else {
            measurementList[i]['value'] = 0;
          }
        } else {
          measurementList[i]['value'] = 0;
        }
      }

      for(var answer in answerDataList) {
        for(int i=0; i<measurementList.length; i++) {
          if(answer['answer']['values'].containsKey('${measurementList[i]['questionid']}')) {
            measurementList[i]['value'] = answer['answer']['values']['${measurementList[i]['questionid']}'];
            measurementList[i]['prevAnswer'] = answer['answer']['values']['${measurementList[i]['questionid']}'];
          }
        }
        label = answer['units'] ?? "Feet";
      }

      for(var localAnswer in localAnswerResult) {

        var answerData = localAnswer['answer'] != null ? json.decode(localAnswer['answer']) : {};
        for(int i=0; i<measurementList.length; i++) {
          if(answerData['answer']['values'].containsKey('${measurementList[i]['questionid']}')) {
            measurementList[i]['value'] = answerData['answer']['values']['${measurementList[i]['questionid']}'];
            measurementList[i]['prevAnswer'] = answerData['answer']['values']['${measurementList[i]['questionid']}'];
          }
        }
        label = answerData['answer']['units'] ?? "Feet";
      }

      log("MeasurementList===$measurementList");
    });

    Timer(Duration(microseconds: 100), getOptionList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode ? AppColor.BLACK_COLOR : AppColor.PAGE_COLOR,
      appBar: EmptyAppBar(isDarkMode: isDarkMode),
      /*appBar: AppBar(
        elevation: elevation,
        backgroundColor: AppColor.PAGE_COLOR,
        leading: GestureDetector(
          onTap: (){
            _scaffoldKey.currentState.openDrawer();
            // _progressHUD.state.dismiss();
            // getPreferenceData();
//            HelperClass.launchDetail(context, DynamicDimensionPage());
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
                         HelperClass.printDatabaseResult();
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
                 child: SingleChildScrollView (
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: 10.0,),

                          sectionName != null && sectionName != ""
                              ? Container(
                            margin: EdgeInsets.only(left: 24.0,right: 24.0, bottom: 8),
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

                          //Title
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 24.0),
                            child: Text(
                              dynamicData != null
                                  ? dynamicData['title'] ?? ""
                                  : "",
                              style: TextStyle(
                                  fontSize: TextSize.greetingTitleText,
                                  color: themeColor,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.normal,
                              ),
                            ),
                          ),

                        ],
                      ),

                      GestureDetector(
                        onTap: (){
                          bottomSelectNavigation(context);
                        },
                        child: Container(
                          height: 72.0,
                          margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: isDarkMode ? Color(0xff1f1f1f) : AppColor.WHITE_COLOR,
                            borderRadius: BorderRadius.circular(16.0)
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                child: Text(
                                  'Units:',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      color: themeColor,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FontStyle.normal
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    '$label',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        color: themeColor,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FontStyle.normal
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                child: Icon(Icons.keyboard_arrow_down, size: 24.0, color: themeColor,),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Container(
                        margin: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                        child: ListView.builder(
                          itemCount: measurementList != null ? measurementList.length : 0,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            var measurementData = measurementList[index]['txt'][lang] ?? measurementList[index]['txt']['en'];
                            return Container(
                              margin: EdgeInsets.only(bottom: 16.0),
                              padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 16.0),
                              decoration: BoxDecoration(
                                  color: isDarkMode ? Color(0xff1f1f1f) : AppColor.WHITE_COLOR,
                                  borderRadius: BorderRadius.all(Radius.circular(16.0))
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      // measurementList[index]['txt'][lang]
                                      '${measurementData['title']}',
                                      style: TextStyle(
                                          fontSize: TextSize.headerText,
                                          color: themeColor,
                                          fontWeight: FontWeight.w600,
                                          fontStyle: FontStyle.normal,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 24.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: (){
                                            setState(() {
                                              if(measurementList[index]['value'] != 1){
                                                measurementList[index]['value']--;
                                              }
                                            });
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(right: 24.0),
                                            padding: EdgeInsets.all(12.0),
                                            decoration: BoxDecoration(
                                                color: themeColor.withOpacity(0.08),
                                                borderRadius: BorderRadius.circular(24)
                                            ),
                                            alignment: Alignment.center,
                                            child: Icon(
                                                Icons.remove,
                                                color: measurementList[index]['value'] == 1 ? AppColor.TYPE_SECONDARY : themeColor,
                                                size: 24.0
                                            ),
                                          ),
                                        ),
                                        Container(
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${measurementList[index]['value']}',
                                            style: TextStyle(
                                                fontSize: 24.0,
                                                color: themeColor,
                                                fontWeight: FontWeight.w600,
                                                fontStyle: FontStyle.normal
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: (){
                                            setState(() {
                                              measurementList[index]['value']++;
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(12.0),
                                            decoration: BoxDecoration(
                                                color: themeColor.withOpacity(0.08),
                                                borderRadius: BorderRadius.circular(24)
                                            ),
                                            margin: EdgeInsets.only(left: 24.0),
                                            alignment: Alignment.center,
                                            child: Icon(
                                                Icons.add,
                                                color: themeColor,
                                                size: 24.0
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      '$label',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          color: themeColor,
                                          fontWeight: FontWeight.w600,
                                          fontStyle: FontStyle.normal
                                      ),
                                    ),
                                  ),
                                  Container(
                                      margin: EdgeInsets.only(top: 3.0),
                                      child: HelperClass.getMeterScaleWidget(themeColor)
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      ),

                      SizedBox(height: 140.0,)
                    ],
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
                buttonName: "$completeButtonName",
                isActive: true,
                onNextButton: () async {
                  // checkQuestion();
                 /* print("Length==$previousLength, Width==$previousWidth, Depth==$previousDepth");
                  if(answerId == '' && previousLength == 0 && previousWidth == 0 && previousDepth == 0) {
                    openNextScreen();
                  } else if(isAnswerChange){
                    deletePreviousAnswer();
                  } else {

                  }*/

                  var count =0;
                  for(int i=0; i<measurementList.length; i++) {
                    if(measurementList[i]['value'] == measurementList[i]['prevAnswer']) {
                      count++;
                    }
                  }
                  if(count == 0) {
                    openNextScreen();
                  } else {
                    if(answerDataList.length > 0) {
                      updateNewAnswer();
                    } else {
                      var result = await insertDimensionRequestDB();
                      if (result != null) {
                        openNextScreen();
                      } else {
                        CustomToast.showToastMessage('Something Went Wrong!!');
                      }
                    }
                  }

                },
                onBackButton: () async {
                  int inspectionIndex = await InspectionPreferences.getInspectionId(InspectionPreferences.INSPECTION_INDEX);
                  InspectionUtils.decrementIndex(inspectionIndex);
                  Navigator.pop(context);
                },
              )
          ),

          _progressHUD
        ],
      ),
    );
  }

  Future getOptionList() async {
    var optionId = inspectionData['answerscope']['simplelist'] ?? "";
    if(optionId != "") {
      _progressHUD.state.show();
      FocusScope.of(context).requestFocus(FocusNode());
      var response = await request.getAuthRequest("auth/simplelist/list/$optionId");

      _progressHUD.state.dismiss();
      if (response != null) {
        var transformedData = adjacencyTransform(response);

        /*const JsonEncoder encoder = JsonEncoder.withIndent('  ');
        log("ChildrenData====>>>>${encoder.convert(transformedData)}");*/
        setState(() {
          optionList = transformedData['children'];
        });
      }
    }
  }

  void updateNewAnswer() async {
    try{
      Map allPreviousData = await InspectionUtils.getPreviousData();

      var inspectionLocalId = allPreviousData['inspectionid'];
      var prevAnswersList = allPreviousData['answerlist'] ?? [];

      var prevSelectedEquipmentList = allPreviousData['equipmentlist'] ?? [];
      var waterBodiesTemplateData = allPreviousData['bodyofwaterlist'] ?? [];
      var childrenTemplateData = allPreviousData['inspectionDef'] ?? [];

      var pendingAnswer;
      if(answerDataList.length>0) {
        prevAnswersList.removeWhere((item) => item['answerid'] == answerDataList[0]['answerid']);

        pendingAnswer = {
          "inspectionid": inspectionLocalId,
          "answerserverid": answerDataList[0]['answerid'] ?? 0,
          "questionid": answerDataList[0]['questionid'] ?? 0,
          "equipmentid": answerDataList[0]['equipmentid'] ?? 0,
          "vesselid": answerDataList[0]['vesselid'] ?? 0,
          "bodyofwaterid": answerDataList[0]['bodyofwaterid'] ?? 0,
          "simplelistid": answerDataList[0]['simplelistid'] ?? 0,
          "answer": answerDataList[0]['answer'] ?? "",
          "imageurl": answerDataList[0]['image'] == null ? "" : answerDataList[0]['image']['path'] ?? "",
        };
      }

      await dbHelper.insertRecordIntoDeleteTable(
        json.decode(json.encode(pendingAnswer)),
      );

      PreferenceHelper.clearPreferenceData(PreferenceHelper.ANSWER_LIST);
      PreferenceHelper.setPreferenceData(PreferenceHelper.ANSWER_LIST, json.encode(prevAnswersList));

      if(localAnswerResult.length>0) {
        var inspectionId = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ID);
        var vesselId1 = inspectionData.containsKey('vesselid') ? inspectionData['vesselid']?? null : null;
        var equipmentId = inspectionData.containsKey('equipmentid') ? inspectionData['equipmentid']?? null : null;
        var bodyOfWaterId = inspectionData.containsKey('bodyofwaterid') ? inspectionData['bodyofwaterid']?? null : null;
        var inspectionDefId = inspectionData['inspectiondefid'];
        var questionId1 = inspectionData['questionid'];

        await dbHelper.deleteAnswerRecord(
            inspectionDefId: "$inspectionDefId",
            inspectionId: "$inspectionId",
            questionId: "$questionId1",
            bodyOfWaterId: bodyOfWaterId,
            vesselId: vesselId1,
            equipmentId: equipmentId
        );
      }

      ///Start unroll
      var transformedData = HelperClass.unroll(int.parse(inspectionLocalId), childrenTemplateData, waterBodiesTemplateData, prevSelectedEquipmentList, prevAnswersList);

      ///Save inspection data
      InspectionPreferences.clearPreferenceData(InspectionPreferences.INSPECTION_DATA);
      InspectionPreferences.setPreferenceData(
          InspectionPreferences.INSPECTION_DATA,
          json.encode(transformedData['flow'])
      );

      answerDataList.clear();
      var result = await insertDimensionRequestDB();
      if (result != null) {
        openNextScreen();
      } else {
        CustomToast.showToastMessage('Something Went Wrong!!');
      }

    } catch (e) {
      print("saveEvent Error ====$e");
    }
  }

  static Map adjacencyTransform(nsResult) {
    int ix = 0;
    void build(container) {
      container["children"] = [];
      if (container["rgt"] - container["lft"] < 2) {
        return;
      }
      while ((++ix < nsResult.length) && (nsResult[ix]["lft"] > container["lft"]) && (nsResult[ix]["rgt"] < container["rgt"])) {
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

  Future insertDimensionRequestDB() async {
    var result;
    try {
      var inspectionId = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ID);

      var vesselId = widget.inspectionData.containsKey('vesselid') ? widget.inspectionData['vesselid']?? null : null;
      var equipmentId = widget.inspectionData.containsKey('equipmentid') ? widget.inspectionData['equipmentid']?? null : null;
      var bodyOfWaterId = widget.inspectionData.containsKey('bodyofwaterid') ? widget.inspectionData['bodyofwaterid']?? null : null;

      List questionIdList = [];
      List valueList = [];
      for(int i=0; i<measurementList.length; i++){
        questionIdList.add(measurementList[i]['questionid']);
        valueList.add(measurementList[i]['value']);
      }

      var requestJson = "";
      for(int j=0; j<questionIdList.length; j++){
        if(requestJson == ''){
          requestJson =  "\"${questionIdList[j]}\":${valueList[j]}";
        } else {
          requestJson = requestJson + ", \"${questionIdList[j]}\":${valueList[j]}";
        }
      }
      requestJson = "{\"answer\":{\"units\":\"$label\",\"values\":{$requestJson}}}";
      var requestParam = json.encode(json.decode(requestJson));

      var endPoint =  "${widget.inspectionData['endpoint']}";

      result = await dbHelper.insertPendingUrl({
          "url": '$endPoint',
          "verb":'POST',
          "inspectionid": inspectionId,
          "image_id": null,
          "equipmentid": equipmentId,
          "vesselid": vesselId,
          "bodyofwaterid": bodyOfWaterId,
          "inspectiondefid": widget.inspectionData['inspectiondefid'],
          "questionid": widget.inspectionData['questionid'],
          "payload": requestParam,
          "simplelistid": null,
          "imagepath": "",
          "notaimagepath": ""
        }
      );
      print("Result ==== $result");

      var answerData = {
        "proxyid": result,
        "inspectionid": inspectionId,
        "simplelistid": null,
        "image_id": "",
        "equipmentid": equipmentId,
        "vesselid": vesselId,
        "bodyofwaterid": bodyOfWaterId,
        "inspectiondefid": widget.inspectionData['inspectiondefid'],
        "questionid": widget.inspectionData['questionid'],
        "payload": "",
        "answer": requestParam,
        "imageurl": '',
        "imagefileurl": ''
      };

      var answerResult = await dbHelper.insertUpdateAnswerRecord(answerData);
      print("answerResult ==== $answerResult");
    } catch (e){
      log("StackTrace====$e");
    }
    return result;
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
          // MaterialPageRoute(
          //   builder: (context) => CompleteInspectionScreen(),
          // ),
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

  bottomSelectNavigation(context){
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        backgroundColor: Colors.white,
        builder: (context){
          return StatefulBuilder(
            builder: (context1, myState){
              return SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 12.0,),
                      Container(
                        child: ListView.builder(
                          itemCount: optionList != null
                              ? optionList.length
                              : 0,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: (){
                                    myState((){
                                      setState(() {
                                        label = "${optionList[index]['label'][lang] ?? optionList[index]['label']['en']}";
                                      });
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                                    child: Text(
                                      '${optionList[index]['label'][lang] ?? optionList[index]['label']['en']}',
                                      style: TextStyle(
                                          fontSize: TextSize.headerText,
                                          color: themeColor,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'WorkSans'
                                      ),
                                    ),
                                  ),
                                ),
                                Divider(
                                  height: 1.0,
                                  color: AppColor.SEC_DIVIDER,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                                fontSize: TextSize.headerText,
                                color: AppColor.TYPE_SECONDARY,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'WorkSans'
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0,),
                    ],
                  ),
                ),
              );
            },
          );
        }
    );
  }
}
