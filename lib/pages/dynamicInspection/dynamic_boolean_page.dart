import 'dart:convert';
import 'dart:developer';

import 'package:dottie_inspector/database/database_helper.dart';
import 'package:dottie_inspector/inspectionPreferences/inspection_preferences.dart';
import 'package:dottie_inspector/pages/dynamicInspection/dynamic_complete_inspection_screen.dart';
import 'package:dottie_inspector/pages/dynamicInspection/dynamic_general_page.dart';
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

class DynamicBooleanPage extends StatefulWidget {
  final inspectionData;
  final lastIndex;

  const DynamicBooleanPage({Key key, this.inspectionData, this.lastIndex}) : super(key: key);
  @override
  _DynamicBooleanPageState createState() => _DynamicBooleanPageState();
}

class _DynamicBooleanPageState extends State<DynamicBooleanPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final dbHelper = DatabaseHelper.instance;

  bool isSafety = false;
  int selectedIndex = -1;
  int isSelected = -1;

  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;
  var dynamicData;
  var inspectionItem;
  var inspectionData;
  JsonEncoder encoder = JsonEncoder.withIndent('  ');
  var sectionName;
  var completeButtonName = "Next";
  var answerDataList = [];
  var localAnswerResult = [];
  int prevAnswer = -1;

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
    String lang = await PreferenceHelper.getPreferenceData(PreferenceHelper.LANGUAGE);

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
      inspectionData = widget.inspectionData;
      dynamicData = inspectionData['txt'][lang] ?? inspectionData['txt']['en'];

      log("AnswerRecord====${inspectionData['answers']}");
      answerDataList = inspectionData['answers'] ?? [];
      isSelected = answerDataList.length <= 0 ? -1 : answerDataList[0]['simplelistid'] == 317 ? 1 : 0;
      prevAnswer = answerDataList.length <= 0 ? -1 : answerDataList[0]['simplelistid'] == 317 ? 1 : 0;

      if(answerDataList.length == 0) {
        isSelected = localAnswerResult.length <= 0 ? -1 : localAnswerResult[0]['simplelistid'] == 317 ? 1 : 0;
        prevAnswer = localAnswerResult.length <= 0 ? -1 : localAnswerResult[0]['simplelistid'] == 317 ? 1 : 0;
      }

      sectionName = HelperClass.getSectionText(inspectionData);
      if(widget.lastIndex != null){
        if(widget.lastIndex == inspectionIndex) {
          completeButtonName = "Complete";
        }
      }
    });

    log("InspectionData===>>>>${encoder.convert(inspectionData)}");
  }

  /*void getInspectionData() async {
    setState(() {
      var data = widget.inspectionData;
      dynamicData = data['txt']['en'];
      questionId = "${data['questionid']}";
    });
  }

  void getPreferenceData() async {
    var preferenceData = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ITEM);
    var inspectionData = json.decode(preferenceData);

    setState(() {
      inspectionItem = inspectionData;
      vesselname = inspectionItem['name'] ?? '';

      print(inspectionItem);
    });
    getInspectionData();
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? AppColor.BLACK_COLOR : AppColor.PAGE_COLOR,
      key: _scaffoldKey,
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: GestureDetector(
                        onTap: () async {
                          _scaffoldKey.currentState.openDrawer();
                          // HelperClass.printDatabaseResult();
                          // var equipmentList = await dbHelper.getAllPendingEquipmentData();
                          //
                          // log("EquipmentList====$equipmentList");

                          // dbHelper.getTableInfo("pending", "notaimagepath");
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
                      margin: EdgeInsets.symmetric(horizontal: 0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: 10.0,),

                          sectionName != null && sectionName != ""
                          ? Container(
                            margin: EdgeInsets.only(left: 24.0,right: 24.0),
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

                          Container(
                            margin: EdgeInsets.only(left: 24.0,right: 24.0, top: 8, bottom: 16),
                            child: Text(
                              dynamicData != null
                                ? dynamicData['title'] ?? ""
                              : "",
//                      'Would you like to include a proposal for your own maintenance services?',
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
                            margin: EdgeInsets.only(left: 24.0,right: 24.0, bottom: 16.0),
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

                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                /*Expanded(
                                  child: GestureDetector(
                                    onTap:(){
                                      setState(() {
                                        isSelected = 1;
                                      });
                                    },
                                    child: Container(
                                      height: 140.0,
                                      padding: EdgeInsets.symmetric(vertical: 10.0),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: isSelected == 1 ? Color(0xFF599C01).withOpacity(0.02) : AppColor.WHITE_COLOR,
                                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                                          border: Border.all(
                                              color: isSelected == 1 ? Color(0xFF599C01) : AppColor.TRANSPARENT,
                                              width: 3.0
                                          )
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.done,
                                            color: Color(0XFF599C01),
                                            size: 64.0,
                                          ),
                                          SizedBox(width: 8.0,),
                                          Text(
                                            'Yes',
                                            style: TextStyle(
                                                fontStyle: FontStyle.normal,
                                                fontSize: TextSize.headerText,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0XFF599C01)
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.0,),
                                Expanded(
                                  child: GestureDetector(
                                    onTap:(){
                                      setState(() {
                                        isSelected = 0;
                                      });
                                    },
                                    child: Container(
                                      height: 140.0,
                                      padding: EdgeInsets.symmetric(vertical: 10.0),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: isSelected == 0 ? Color(0xFFD92C2C).withOpacity(0.02) : AppColor.WHITE_COLOR,
                                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                                          border: Border.all(
                                              color: isSelected == 0 ? Color(0xFFD92C2C) : AppColor.TRANSPARENT,
                                              width: 3.0
                                          )
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.clear,
                                            size: 64.0,
                                            color: Color(0XFFD92C2C),
                                          ),
                                          SizedBox(width: 8.0,),
                                          Text(
                                            'No',
                                            style: TextStyle(
                                                fontStyle: FontStyle.normal,
                                                fontSize: TextSize.headerText,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0XFFD92C2C)
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),*/

                                Expanded(
                                  child: Theme(
                                    data: ThemeData(
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                    ),
                                    child: GestureDetector(
                                      onTap:(){
                                        setState(() {
                                          isSelected = 1;
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(vertical: 0.0),
                                        alignment: Alignment.center,
                                        child: Image.asset(
                                          isSelected == 1
                                          ? 'assets/boolean/ic_yes_selection.png'
                                          : isDarkMode
                                          ? 'assets/boolean/ic_dark_yes_unselected.png'
                                          : 'assets/boolean/ic_yes_unselected.png',
                                          height: MediaQuery.of(context).size.width * 0.5,
                                          width: MediaQuery.of(context).size.width * 0.5,
                                          fit: BoxFit.contain,
                                        )
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16.0,),
                                Expanded(
                                  child: Theme(
                                    data: ThemeData(
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                    ),
                                    child: GestureDetector(
                                      onTap:(){
                                        setState(() {
                                          isSelected = 0;
                                        });
                                      },
                                      child: Container(
                                          padding: EdgeInsets.symmetric(vertical: 0.0),
                                          alignment: Alignment.center,
                                          child: Image.asset(
                                            isSelected == 0
                                            ? 'assets/boolean/ic_no_selection.png'
                                            : isDarkMode
                                              ? 'assets/boolean/ic_dark_no_unselected.png'
                                              : 'assets/boolean/ic_no_unselected.png',
                                            height: MediaQuery.of(context).size.width * 0.5,
                                            width: MediaQuery.of(context).size.width * 0.5,
                                            fit: BoxFit.contain,
                                          )
                                      ),
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

            // Submit
            Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: BottomButtonWidget(
                  buttonName: "$completeButtonName",
                  isActive: isSelected != -1,
                  onNextButton: () async {
                    if(isSelected != -1){
                      // updateBooleanQuestion();
                      // checkQuestion();
                      // openNextScreen();
                      if(isSelected != prevAnswer) {
                        if(prevAnswer != -1){
                          updateNewAnswer();
                        } else {
                          localPostBooleanQuestion();
                        }
                      } else {
                        openNextScreen();
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

            _progressHUD,

          ],
        ),
      ),
    );
  }

  Future localPostBooleanQuestion() async {
    var pendingAnswers = {};
    try {
      var simplelistid = isSelected == 0 ? 316 : 317;
      var endPoint;
      var requestJson;

      if(widget.inspectionData['endpoint'].toString().contains("maint")){
        simplelistid = isSelected == 0 ? 316 : 317;
        requestJson = {
          "include": simplelistid
        };
        endPoint = "${widget.inspectionData['endpoint'].toString()}";
      } else {
        requestJson = {};
        endPoint = "${widget.inspectionData['endpoint'].toString().replaceAll("{simplelistid}", "$simplelistid")}";
      }

      print("booleanEndPoint====$endPoint");
      var inspectionId = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ID) ?? "-1";

      var vesselId = widget.inspectionData.containsKey('vesselid') ? widget.inspectionData['vesselid']?? null : null;
      var equipmentId = widget.inspectionData.containsKey('equipmentid') ? widget.inspectionData['equipmentid']?? null : null;
      var bodyOfWaterId = widget.inspectionData.containsKey('bodyofwaterid') ? widget.inspectionData['bodyofwaterid']?? null : null;

      var inspectiondefid = widget.inspectionData['inspectiondefid'];
      var questionid = widget.inspectionData['questionid'];

      print("QuestionId====${widget.inspectionData['questionid']}");
      print("VesselId====$vesselId");
      var pendingResult = await dbHelper.insertPendingUrl({
          "url": '$endPoint',
          "verb":'POST',
          "inspectionid": "$inspectionId",
          "image_id": null,
          "equipmentid": equipmentId,
          "vesselid": vesselId,
          "bodyofwaterid": bodyOfWaterId,
          "inspectiondefid": '$inspectiondefid',
          "questionid": '$questionid',
          "payload": json.encode(requestJson),
          "simplelistid": null,
          "imagepath": '',
          "notaimagepath": ''
        }
      );

      if(pendingResult != null) {
        pendingAnswers = {
          "proxyid": "$pendingResult",
          "inspectionid": "$inspectionId",
          "inspectiondefid": '$inspectiondefid',
          "questionid": '$questionid',
          "equipmentid": equipmentId,
          "vesselid": vesselId,
          "bodyofwaterid": bodyOfWaterId,
          "simplelistid": isSelected == 0 ? 316 : 317,
          "answer": "",
          "imageurl": "",
          "imagefileurl": "",
          "payload": "" //annotation
        };
        // log("AnswerSaved===>>>>${(pendingAnswers)}");
        var answerResult = await dbHelper.insertUpdateAnswerRecord(
            json.decode(json.encode(pendingAnswers)),
        );
        // print("AnswerResult==== $answerResult");
        if (answerResult != null) {
          checkAnswersAvailability(pendingAnswers, pendingResult);
        } else {
          CustomToast.showToastMessage("Something went wrong!!!");
        }
      } else {
        CustomToast.showToastMessage("Something went wrong!!!");
      }
    }catch (e) {
      log("StackTrace====$e");
    }
    return pendingAnswers;
  }

  void checkAnswersAvailability(answer, newProxyId) async {
    try{
      if(inspectionData['children'] != null){
        var childData = inspectionData['children'];
        var inspectionId = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ID);

        var vesselId = widget.inspectionData.containsKey('vesselid') ? widget.inspectionData['vesselid']?? null : null;
        var equipmentId = widget.inspectionData.containsKey('equipmentid') ? widget.inspectionData['equipmentid']?? null : null;

        for(int i=0; i<childData.length; i++) {
          await dbHelper.deleteBooleanChildrenData(
            vesselId: vesselId,
            equipmentId: equipmentId,
            questionid: childData[i]['questionid'],
            inspectiondefid: childData[i]['inspectiondefid'],
            inspectionid: inspectionId,
          );
        }
      }

      var previousAnswersListData = await PreferenceHelper.getPreferenceData(PreferenceHelper.ANSWER_LIST);
      List prevAnswersList = previousAnswersListData != null
          ? json.decode(previousAnswersListData)
          : [];

      int count = 0;
      // log("All Answer List Before Answer Added====>>>>${encoder.convert(prevAnswersList)}");
      for(int i=0; i<prevAnswersList.length; i++) {
        if("${prevAnswersList[i]['proxyid']}" == "$newProxyId") {
          prevAnswersList[i]['simplelistid'] = isSelected == 0 ? 316 : 317;
          count++;
        }
      }

      if(count == 0) {
        prevAnswersList.add(answer);
      }
      // log("All Answer List After Answer Added====>>>>${encoder.convert(prevAnswersList)}");

      /*** Set the answer list to shared preferences ***/
      PreferenceHelper.clearPreferenceData(PreferenceHelper.ANSWER_LIST);
      PreferenceHelper.setPreferenceData(PreferenceHelper.ANSWER_LIST, json.encode(prevAnswersList));

      saveEvent(prevAnswersList);
    }catch (e) {
      log("AnswerCheckStackTrace====>>>>$e");
    }
  }

  void saveEvent(prevAnswersList) async {
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
      // print("All WaterBodies List====>>>>$waterBodiesTemplateData");

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
      // var previousAnswersListData = await PreferenceHelper.getPreferenceData(PreferenceHelper.ANSWER_LIST);
      // List prevAnswersList = previousAnswersListData != null
      //     ? json.decode(previousAnswersListData)
      //     : [];
      //
      // if(answer != null) {
      //   prevAnswersList.add(answer);
      // }
      // print("All Answer List====>>>>$prevAnswersList");

      ///Start unroll
      var transformedData = HelperClass.unroll(int.parse(inspectionLocalId), childrenTemplateData, waterBodiesTemplateData, prevSelectedEquipmentList, prevAnswersList);
      // const JsonEncoder encoder = JsonEncoder.withIndent('  ');
      // log("TransformedData====>>>>${encoder.convert(transformedData)}");

      ///Save inspection data
      InspectionPreferences.clearPreferenceData(InspectionPreferences.INSPECTION_DATA);
      InspectionPreferences.setPreferenceData(
          InspectionPreferences.INSPECTION_DATA,
          json.encode(transformedData['flow'])
      );

      openNextScreen();
    } catch (e) {
      print("saveEvent Error ====$e");
    }
  }

  void updateNewAnswer() async {
    try{
      Map allPreviousData = await InspectionUtils.getPreviousData();

      var inspectionLocalId = allPreviousData['inspectionid'] ?? 0;
      var prevAnswersList = allPreviousData['answerlist'] ?? [];

      var pendingAnswer;
      if(answerDataList.length>0) {
        prevAnswersList.removeWhere((item) => item['answerid'] == answerDataList[0]['answerid']);
        setState(() {
          prevAnswer = -1;
        });

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

      answerDataList.clear();

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

      localPostBooleanQuestion();
    } catch (e) {
      print("saveEvent Error ====$e");
    }
  }

  Future<void> postBooleanQuestion() async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var requestJson;
    var simplelistid = isSelected == 0 ? "316" : "317";
    var endPoint;

    if(widget.inspectionData['endpoint'].toString().contains("maint")){
      requestJson = {};
      endPoint = "${widget.inspectionData['endpoint']}";
    } else {
      simplelistid = isSelected == 0 ? "316" : "317";
      requestJson = {
        "include": simplelistid
      };

      endPoint = "${widget.inspectionData['endpoint'].toString().replaceAll("{simplelistid}", "${simplelistid}")}";
    }

    var requestParam = json.encode(requestJson);
    var response = await request.postHazardRequest(
        endPoint,
        requestParam
    );
    _progressHUD.state.dismiss();

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage('${response['reason']}');
      } else {
        saveEvent(response);
      }
    } else {
      CustomToast.showToastMessage('Something went wrong!!!');
    }
  }

  Future<void> updateBooleanQuestion(answerData) async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var simplelistid = isSelected == 0 ? "316" : "317";
    var requestJson = {"simplelistid": "$simplelistid"};
    var inspectionId = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ID);

    var requestParam = json.encode(requestJson);
    var response = await request.postHazardRequest(
        "auth/inspection/$inspectionId/answer/${answerData['answerid']}",
        requestParam
    );
    _progressHUD.state.dismiss();

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage('${response['reason']}');
      } else {
        ///Answer List
        var previousAnswersListData = await PreferenceHelper.getPreferenceData(PreferenceHelper.ANSWER_LIST);
        List prevAnswersList = previousAnswersListData != null
            ? json.decode(previousAnswersListData)
            : [];
        for(int i=0; i<prevAnswersList.length; i++){
          if(answerData['answerid'] == prevAnswersList[i]['answerid']){
            prevAnswersList.removeAt(i);

            /*** Set the answer list to shared preferences ***/
            PreferenceHelper.clearPreferenceData(PreferenceHelper.ANSWER_LIST);
            PreferenceHelper.setPreferenceData(PreferenceHelper.ANSWER_LIST, json.encode(prevAnswersList));
            break;
          }
        }
        saveEvent(response);
      }
    } else {
      CustomToast.showToastMessage('Something went wrong!!!');
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
          var data = await InspectionUtils.getInspectionBlockTypeData(transformedData[++i], 0);
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
              vesselWaterList,
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
        var data = await InspectionUtils.getInspectionBlockTypeData(transformedData[i], 0);
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

  void openNextScreen() async {
    var listItemData = await InspectionPreferences.getPreferenceData(InspectionPreferences.INSPECTION_DATA);
    var transformedData = json.decode(listItemData);
    int inspectionIndex = await InspectionPreferences.getInspectionId(InspectionPreferences.INSPECTION_INDEX);

    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    // log("TransformedData====>>>>${encoder.convert(transformedData)}");


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
      // for(int i=0; i<transformedData.length; i++) {
      //   if(transformedData[i]['inspectiondefid'] == index) {
      //     index = i;
      //     break;
      //   }
      // }

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
  }
}
