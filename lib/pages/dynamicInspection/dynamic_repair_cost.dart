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
import 'package:dottie_inspector/widget/gradient/grediant_box_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_hud/progress_hud.dart';

class DynamicRepairCostPage extends StatefulWidget {
  final inspectionData;
  final lastIndex;

  const DynamicRepairCostPage({Key key, this.inspectionData, this.lastIndex}) : super(key: key);

  @override
  _DynamicRepairCostPageState createState() => _DynamicRepairCostPageState();
}

class _DynamicRepairCostPageState extends State<DynamicRepairCostPage> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final dbHelper = DatabaseHelper.instance;

  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;
  var inspectionItem;
  String equipmentName = "Skimmer";
  var elevation = 0.0;
  final _scrollController = ScrollController();
  var answerId = "";
  bool isAnswerChange = false;
  var dynamicData;
  var inspectionData;
  List repairCostList = [];
  var vesselId;
  var equipmentId;
  var vesselname;
  var equipmentname;
  bool isDimensionSelected;
  var sectionName;
  var completeButtonName = "Next";
  String lang = "en";

  Map dollarAmount = {};
  Map textWidget = {};

  var isFocusOn = true;
  var isRepairCostFocus = false;
  var isDollarAmountFocus = false;
  var isTextFocus = false;
  var _allFieldValidate = false;
  final _dollarAmountTextEditingController = TextEditingController();
  final _textTextEditingController = TextEditingController();
  FocusNode _dollarAmountFocus = FocusNode();
  FocusNode _textFocus = FocusNode();

  var answerDataList = [];
  var localAnswerResult = [];
  var prevDollarAmountAnswer = "";
  var prevTextAnswer = "";

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

    _dollarAmountFocus.addListener(() {
      setState(() {
        isDollarAmountFocus = _dollarAmountFocus.hasFocus;
        isRepairCostFocus = isDollarAmountFocus;
        isFocusOn = !_dollarAmountFocus.hasFocus;
      });
    });

    _textFocus.addListener(() {
      setState(() {
        isTextFocus = _textFocus.hasFocus;
        isRepairCostFocus = isTextFocus;
        isFocusOn = !_textFocus.hasFocus;
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
      repairCostList = inspectionData['children'] ?? [];
      vesselId = inspectionData['vesselid'] ?? '';
      equipmentId = inspectionData['equipmentid'] ?? '';
      vesselname = inspectionData['vesselname'] ?? '';
      equipmentname = inspectionData['equipmentname'] ?? '';

      log("AnswerRecord====${inspectionData['answers']}");
      answerDataList = inspectionData['answers'] ?? [];

      log("inspectionData===$inspectionData");
      log("List===$repairCostList");
      sectionName = HelperClass.getSectionText(inspectionData);
      if(widget.lastIndex != null){
        if(widget.lastIndex == inspectionIndex) {
          completeButtonName = "Complete";
        }
      }

      for(int i=0; i<repairCostList.length; i++) {
        if(repairCostList[i]['questiontype'] == "dollar amount") {
          dollarAmount = repairCostList[i];
        } else if(repairCostList[i]['questiontype'] == "text") {
          textWidget = repairCostList[i];
        }

        for(var answer in answerDataList) {
          if(answer['answer']['values'].containsKey('${repairCostList[i]['questionid']}') && repairCostList[i]['questiontype'] == "dollar amount") {
            prevDollarAmountAnswer = answer['answer']['values']['${repairCostList[i]['questionid']}'];
            _dollarAmountTextEditingController.text = answer['answer']['values']['${repairCostList[i]['questionid']}'];
          } else if(answer['answer']['values'].containsKey('${repairCostList[i]['questionid']}') && repairCostList[i]['questiontype'] == "text") {
            prevTextAnswer = answer['answer']['values']['${repairCostList[i]['questionid']}'];
            _textTextEditingController.text = answer['answer']['values']['${repairCostList[i]['questionid']}'];
          }
        }

        for(var answer1 in localAnswerResult) {
          var answer = answer1['answer'] != null ? json.decode(answer1) : {};
          if(answer['answer']['values'].containsKey('${repairCostList[i]['questionid']}') && repairCostList[i]['questiontype'] == "dollar amount") {
            prevDollarAmountAnswer = answer['answer']['values']['${repairCostList[i]['questionid']}'];
            _dollarAmountTextEditingController.text = answer['answer']['values']['${repairCostList[i]['questionid']}'];
          } else if(answer['answer']['values'].containsKey('${repairCostList[i]['questionid']}') && repairCostList[i]['questiontype'] == "text") {
            prevTextAnswer = answer['answer']['values']['${repairCostList[i]['questionid']}'];
            _textTextEditingController.text = answer['answer']['values']['${repairCostList[i]['questionid']}'];
          }
        }

        _allFieldValidate = _textTextEditingController.text.trim() != "" && _dollarAmountTextEditingController.text.trim() != "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
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
//            HelperClass.launchDetail(context, DynamicRepairCostPage());
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
                 Flexible(
                   fit: FlexFit.tight,
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


                            textWidget != null
                                ? Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.only(top: 32.0, bottom: 0.0, left: 16.0,right: 16.0),
                              padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isTextFocus && isDarkMode
                                        ? AppColor.gradientColor(0.32)
                                        : isTextFocus
                                        ? AppColor.gradientColor(0.16)
                                        : isDarkMode
                                        ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                                        : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
                                  ),
                                  borderRadius: BorderRadius.circular(24.0),
                                  border: GradientBoxBorder(
                                      gradient: LinearGradient(
                                        colors: isTextFocus
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
                                    'Repair Recommendations',
                                    style: TextStyle(
                                      fontSize: TextSize.subjectTitle,
                                      color: themeColor.withOpacity(1.0),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  TextFormField(
                                    controller: _textTextEditingController,
                                    focusNode: _textFocus,
                                    onFieldSubmitted: (term) {
                                      _textFocus.unfocus();
                                      FocusScope.of(context).requestFocus(_dollarAmountFocus);
                                    },
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.text,
                                    textCapitalization: TextCapitalization.sentences,
                                    textAlign: TextAlign.start,
                                    decoration: InputDecoration(
                                      fillColor: AppColor.WHITE_COLOR,
                                      hintText: "Write something...",
                                      filled: false,
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.only(top: 0,),
                                      hintStyle: TextStyle(
                                          fontSize: TextSize.headerText,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xff808080)
                                      ),
                                    ),
                                    style: TextStyle(
                                        color: themeColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: TextSize.headerText
                                    ),
                                    inputFormatters: [LengthLimitingTextInputFormatter(40)],
                                    onChanged: (text) {
                                      setState(() {
                                        _allFieldValidate = _textTextEditingController.text != "" && _dollarAmountTextEditingController.text != "" ;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            )
                                : Container(),
                            //
                            dollarAmount != null
                                ? Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.only(top: 8.0, bottom: 0.0, left: 16.0,right: 16.0),
                              padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isDollarAmountFocus && isDarkMode
                                        ? AppColor.gradientColor(0.32)
                                        : isDollarAmountFocus
                                        ? AppColor.gradientColor(0.16)
                                        : isDarkMode
                                        ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                                        : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
                                  ),
                                  borderRadius: BorderRadius.circular(24.0),
                                  border: GradientBoxBorder(
                                      gradient: LinearGradient(
                                        colors: isDollarAmountFocus
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
                                    'Estimated Repair Costs',
                                    style: TextStyle(
                                        fontSize: TextSize.subjectTitle,
                                        color: themeColor.withOpacity(1.0),
                                        fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '\$',
                                        style: TextStyle(
                                          fontSize: TextSize.headerText,
                                          color: themeColor.withOpacity(1.0),
                                          fontWeight: FontWeight.w700,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(width: 6,),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _dollarAmountTextEditingController,
                                          focusNode: _dollarAmountFocus,
                                          onFieldSubmitted: (term) {
                                            _dollarAmountFocus.unfocus();
                                          },
                                          textInputAction: TextInputAction.done,
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.start,
                                          decoration: InputDecoration(
                                            fillColor: AppColor.WHITE_COLOR,
                                            hintText: "0.0",
                                            filled: false,
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.only(top: 0,),
                                            hintStyle: TextStyle(
                                                fontSize: TextSize.headerText,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xff808080)
                                            ),
                                          ),
                                          style: TextStyle(
                                              color: themeColor,
                                              fontWeight: FontWeight.w700,
                                              fontSize: TextSize.headerText
                                          ),
                                          inputFormatters: [LengthLimitingTextInputFormatter(40)],
                                          onChanged: (text) {
                                            setState(() {
                                              _allFieldValidate = _textTextEditingController.text != "" && _dollarAmountTextEditingController.text != "" ;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                                : Container(),
                          ],
                        ),

                        SizedBox(height: 140.0,)
                      ],
                    ),
                   ),
                 ),
               ],
             ),

            // Submit
            Visibility(
              visible: isFocusOn,
              child: Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: BottomButtonWidget(
                    buttonName: "$completeButtonName",
                    isActive: _allFieldValidate,
                    onNextButton: () async {
                      // checkQuestion();
                     /* print("Length==$previousLength, Width==$previousWidth, Depth==$previousDepth");
                      if(answerId == '' && previousLength == 0 && previousWidth == 0 && previousDepth == 0) {
                        openNextScreen();
                      } else if(isAnswerChange){
                        deletePreviousAnswer();
                      } else {

                      }*/
                      print("Hello====$_allFieldValidate");

                      if(_allFieldValidate) {
                        if((prevDollarAmountAnswer != _dollarAmountTextEditingController.text.toString().trim())
                          && (prevTextAnswer != _textTextEditingController.text.trim())) {
                          if(prevDollarAmountAnswer != "" && prevTextAnswer != "") {
                            log("11111");
                            updateNewAnswer();
                          } else {
                            var result = await insertRepairCostRequestDB();
                            log("insertRepairCostRequestDB Result====>>>$result");
                            if (result != null) {
                              openNextScreen();
                            } else {
                              CustomToast.showToastMessage('Something Went Wrong!!');
                            }
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
            ),

            _progressHUD
          ],
        ),
      ),
    );
  }

  Future insertRepairCostRequestDB() async {
    FocusScope.of(context).unfocus();
    var result;
    try {
      var inspectionId = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ID);

      var vesselId = widget.inspectionData.containsKey('vesselid') ? widget.inspectionData['vesselid']?? null : null;
      var equipmentId = widget.inspectionData.containsKey('equipmentid') ? widget.inspectionData['equipmentid']?? null : null;
      var bodyOfWaterId = widget.inspectionData.containsKey('bodyofwaterid') ? widget.inspectionData['bodyofwaterid']?? null : null;

      var requestJson = "";
      for(int i=0; i<repairCostList.length; i++){
        if(requestJson == ""){
          if(repairCostList[i]['questiontype'] == "text") {
            requestJson =  "\"${repairCostList[i]['questionid']}\":\"${_textTextEditingController.text.toString()}\"";
          } else if(repairCostList[i]['questiontype'] == "dollar amount"){
            requestJson =  "\"${repairCostList[i]['questionid']}\":\"${_dollarAmountTextEditingController.text.toString()}\"";
          }
        } else {
          if(repairCostList[i]['questiontype'] == "text") {
            requestJson = requestJson + ", \"${repairCostList[i]['questionid']}\":\"${_textTextEditingController.text.toString()}\"" ;
          } else if(repairCostList[i]['questiontype'] == "dollar amount"){
            requestJson = requestJson + ", \"${repairCostList[i]['questionid']}\":\"${_dollarAmountTextEditingController.text.toString()}\"" ;
          }
        }
      }

      requestJson = "{\"answer\":{\"values\":{$requestJson}}}";
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
      log("StackTraceRepair====$e");
    }
    return result;
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
      var result = await insertRepairCostRequestDB();
      log("Result====>>>$result");
      if (result != null) {
        openNextScreen();
      } else {
        CustomToast.showToastMessage('Something Went Wrong!!');
      }
    } catch (e) {
      print("saveEvent Error ====$e");
    }
  }

  void openNextScreen() async {
    var listItemData = await InspectionPreferences.getPreferenceData(InspectionPreferences.INSPECTION_DATA);
    var transformedData = json.decode(listItemData);
    int inspectionIndex = await InspectionPreferences.getInspectionId(InspectionPreferences.INSPECTION_INDEX);

    // print(transformedData);
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    log("TransformedData====>>>>${encoder.convert(transformedData)}");

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
}
