import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dottie_inspector/database/database_helper.dart';
import 'package:dottie_inspector/inspectionPreferences/inspection_preferences.dart';
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

import 'dynamic_complete_inspection_screen.dart';
import 'dynamic_general_page.dart';

class DynamicMultiListPage extends StatefulWidget {
  final inspectionData;
  final lastIndex;
  const DynamicMultiListPage({Key key, this.inspectionData, this.lastIndex}) : super(key: key);

  @override
  _DynamicMultiListPageState createState() => _DynamicMultiListPageState();
}

class _DynamicMultiListPageState extends State<DynamicMultiListPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final dbHelper = DatabaseHelper.instance;
  
  int selectedIndex = -1;
  int selectedSubIndex = -1;
  int selectedIndexId = 0;
  String selectedItemName = "";
  bool isAttachedPool = false;

  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;
  var inspectionItem;
  String equipmentName = "Automation System";
  var elevation = 0.0;
  final _scrollController = ScrollController();
  var jsonResult;
  List automationTypeList;
  var answerId = "";
  List<dynamic> optionList = [];
  List<dynamic> optionMainList = [];
  var selectedValue;
  List<dynamic> optionSubList = [];
  List<dynamic> optionSelectedList = [];

  // var equipmentId;
  // var equipmentname;
  var dynamicData;
  var dynamicMainData;
  var inspectionData;
  var sectionName;
  var completeButtonName = "Next";
  String lang = "en";
  // final MyConnectivity _connectivity = MyConnectivity.instance;
  bool _isInternetAvailable = true;
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  var answerDataList = [];
  var localAnswerResult = [];
  var selectedData;

  var prevAnswer = -1;

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
      dynamicMainData = widget.inspectionData;
      dynamicData = dynamicMainData['txt'][lang] ?? dynamicMainData['txt']['en'];
      sectionName = HelperClass.getSectionText(inspectionData);

      answerDataList = inspectionData['answers'] ?? [];

      if(answerDataList.length > 0) {
        selectedIndex = answerDataList[0]['simplelistid'];
        prevAnswer = answerDataList[0]['simplelistid'];
      } else if(localAnswerResult.length > 0) {
        selectedIndex = localAnswerResult[0]['simplelistid'];
        prevAnswer = localAnswerResult[0]['simplelistid'];
      } else {
        selectedIndex = -1;
        prevAnswer = -1;
      }

      log("SelectedIndex==$selectedIndex");
      if(widget.lastIndex != null){
        if(widget.lastIndex == inspectionIndex) {
          completeButtonName = "Complete";
        }
      }
    });



    // _connectivity.initialise();
    // _connectivity.myStream.listen((source) {
    //   setState(() {
    //     if(source.keys.toList()[0] == ConnectivityResult.none) {
    //       print("No Internet found");
    //       _isInternetAvailable = false;
    //     } else if(source.keys.toList()[0] == ConnectivityResult.mobile) {
    //       print("Mobile");
    //       _isInternetAvailable = true;
    //       getOptionList();
    //     } else if(source.keys.toList()[0] == ConnectivityResult.wifi) {
    //       print("WIFI");
    //       _isInternetAvailable = true;
    //       getOptionList();
    //     }
    //   });
    // });

    // Timer(Duration(microseconds: 100), getOptionList);

    initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

  }

  // void getJsonFile() async {
  //   String data = await DefaultAssetBundle.of(context).loadString("assets/optionList.json");
  //
  //   setState(() {
  //     jsonResult = json.decode(data);
  //     optionMainList = jsonResult['children'];
  //   });
  //   print("JsonResult $jsonResult");
  // }

  @override
  void dispose() {
    // TODO: implement dispose
    _connectivitySubscription.cancel();
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
        if(_connectivityResult == ConnectivityResult.none) {
          print("No Internet found");
          _isInternetAvailable = false;
          getLocalOptionList();
        } else if(_connectivityResult == ConnectivityResult.mobile) {
          print("Mobile");
          _isInternetAvailable = true;
          getLocalOptionList();
        } else if(_connectivityResult == ConnectivityResult.wifi) {
          print("WIFI");
          _isInternetAvailable = true;
          getLocalOptionList();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode ? AppColor.BLACK_COLOR : AppColor.PAGE_COLOR,
      appBar: EmptyAppBar(isDarkMode: isDarkMode),
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
                        // HelperClass.printDatabaseResult();

                        var result = await dbHelper.allAnswerRecord();
                        const JsonEncoder encoder = JsonEncoder.withIndent('  ');
                        log("AllAnswerRecord====>>>>${encoder.convert(result)}");

                        var inspectionId = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ID);
                        var vesselId1 = inspectionData.containsKey('vesselid') ? inspectionData['vesselid']?? null : null;
                        var equipmentId = inspectionData.containsKey('equipmentid') ? inspectionData['equipmentid']?? null : null;
                        var bodyOfWaterId = inspectionData.containsKey('bodyofwaterid') ? inspectionData['bodyofwaterid']?? null : null;
                        var inspectionDefId = inspectionData['inspectiondefid'];
                        var questionId1 = inspectionData['questionid'];

                        log("inspectionDefId===$inspectionDefId, "
                            "InspectionId===$inspectionId, questionId===$questionId1, "
                            "bodyOfWaterId===$bodyOfWaterId, vesselId===$vesselId1, "
                            "equipmentId===$equipmentId");

                        var localAnswerResult = await dbHelper.fetchAnswerRecord(
                            inspectionDefId: inspectionDefId,
                            inspectionId: inspectionId,
                            questionId: questionId1,
                            bodyOfWaterId: bodyOfWaterId,
                            vesselId: vesselId1,
                            equipmentId: equipmentId);

                        log("Result===$localAnswerResult");
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
                      SizedBox(
                        height: 10.0,
                      ),

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

                      SizedBox(
                        height: 16.0,
                      ),
                      //Title
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          dynamicData != null
                              ? dynamicData['helpertext'] ?? ""
                              : "",
                          style: TextStyle(
                              fontSize: TextSize.subjectTitle,
                              color: themeColor,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.normal,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 16.0,
                      ),

                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
                        decoration: BoxDecoration(
                          color: AppColor.GREY_COLOR.withOpacity(0.48),
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: AppColor.TRANSPARENT,
                            width: 3.0,
                          ),
                        ),
                        padding: EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0, bottom: 8.0),

                        child: DropdownButton<dynamic>(
                          value: selectedValue,
                          isExpanded: true,
                          icon: Icon(
                              Icons.arrow_drop_down,
                            color: themeColor,
                          ),
                          iconSize: 32.0,
                          elevation: 0,
                          isDense: true,
                          dropdownColor: Color(0xff1f1f1f),
                          borderRadius: BorderRadius.circular(32),
                          style: TextStyle(
                              color: themeColor,
                              fontSize: TextSize.subjectTitle,
                              fontWeight: FontWeight.w600,
                          ),
                          underline: Container(
                            height: 0,
                            color: Colors.transparent,
                          ),
                          onChanged: (newValue) {
                            setState(() {
                              selectedValue = newValue;

                              if(selectedValue['children'].length>0){
                                optionSubList.clear();
                                var mapData = {
                                  "value": selectedValue['children'],
                                  "selectedValue": null
                                };
                                optionSubList.add(mapData);
                                selectedIndex = -1;
                              } else {
                                selectedIndex = newValue['simplelistid'];
                              }
                            });
                          },
                          items: optionMainList.map((data){
                            return DropdownMenuItem<dynamic>(
                              value: data,
                              child: Container(
                                width: double.infinity,
                                child: Text(
                                  '${data['label'][lang] ?? data['label']['en']}',
                                  style: TextStyle(
                                      color: themeColor,
                                      fontSize: TextSize.subjectTitle,
                                      fontStyle: FontStyle.normal,
                                      fontWeight: FontWeight.w600,

                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      // Container(
                      //   width: double.infinity,
                      //   margin: EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
                      //   decoration: BoxDecoration(
                      //     color: AppColor.GREY_COLOR.withOpacity(0.48),
                      //     borderRadius: BorderRadius.circular(16.0),
                      //     border: Border.all(
                      //       color: AppColor.TRANSPARENT,
                      //       width: 3.0,
                      //     ),
                      //   ),
                      //   padding: EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0, bottom: 8.0),
                      //
                      //   child: DropdownButton<dynamic>(
                      //     value: selectedValue,
                      //     isExpanded: true,
                      //     icon: Icon(Icons.arrow_drop_down),
                      //     iconSize: 32.0,
                      //     elevation: 0,
                      //     isDense: true,
                      //     style: TextStyle(
                      //         color: themeColor,
                      //         fontSize: TextSize.subjectTitle,
                      //         fontStyle: FontStyle.normal,
                      //         fontWeight: FontWeight.w600,
                      //
                      //     ),
                      //     underline: Container(
                      //       height: 0,
                      //       color: Colors.transparent,
                      //     ),
                      //     onChanged: (newValue) {
                      //       setState(() {
                      //         selectedValue = newValue;
                      //         // log("selectedValue====${optionSubList[index]['selectedValue']}");
                      //         // if(optionSubList[index]['selectedValue']['children'].length>0){
                      //         //   optionSubList.clear();
                      //         //   optionSubList.addAll(optionSubList[index]['selectedValue']['children']);
                      //         //   for(int i=0; i<optionSubList.length; i++){
                      //         //     optionSubList[i]['selectedValue'] = null;
                      //         //   }
                      //         // }
                      //       });
                      //     },
                      //     items: optionSubList.map((data){
                      //       return DropdownMenuItem<dynamic>(
                      //         value: data,
                      //         child: Container(
                      //           width: double.infinity,
                      //           child: Text(
                      //             '${data['label']['en']}',
                      //             style: TextStyle(
                      //                 color: themeColor,
                      //                 fontSize: TextSize.subjectTitle,
                      //                 fontStyle: FontStyle.normal,
                      //                 fontWeight: FontWeight.w600,
                      //
                      //             ),
                      //           ),
                      //         ),
                      //       );
                      //     }).toList(),
                      //   ),
                      // ),

                      Container(
                        child: ListView.builder(
                          itemCount: optionSubList.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            List<dynamic> optionData = optionSubList[index]['value'] != null
                                        ? optionSubList[index]['value']
                                        : [];
                            return Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
                              decoration: BoxDecoration(
                                color: AppColor.GREY_COLOR.withOpacity(0.48),
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(
                                  color: AppColor.TRANSPARENT,
                                  width: 3.0,
                                ),
                              ),
                              padding: EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0, bottom: 8.0),

                              child: DropdownButton<dynamic>(
                                value: optionSubList[index]['selectedValue'],
                                isExpanded: true,
                                dropdownColor: Color(0xff1f1f1f),
                                borderRadius: BorderRadius.circular(32),
                                icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: themeColor
                                ),
                                iconSize: 32.0,
                                elevation: 0,
                                isDense: true,
                                style: TextStyle(
                                    color: themeColor,
                                    fontSize: TextSize.subjectTitle,
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.w600,

                                ),
                                underline: Container(
                                  height: 0,
                                  color: Colors.transparent,
                                ),
                                onChanged: (newValue) {
                                  setState(() {
                                    optionSubList[index]['selectedValue'] = newValue;

                                    if(optionSubList[index]['selectedValue']['children'].length>0){
                                      var mapData = {
                                        "value": optionSubList[index]['selectedValue']['children'],
                                        "selectedValue": null
                                      };
                                      optionSubList.add(mapData);
                                      selectedIndex = -1;
                                    } else {
                                      selectedIndex = newValue['simplelistid'];
                                    }
                                  });
                                },
                                items: optionData.map((data){
                                  return DropdownMenuItem<dynamic>(
                                    value: data,
                                    child: Container(
                                      width: double.infinity,
                                      child: Text(
                                        '${data['label'][lang] ?? data['label']['en']}',
                                        style: TextStyle(
                                            color: themeColor,
                                            fontSize: TextSize.subjectTitle,
                                            fontStyle: FontStyle.normal,
                                            fontWeight: FontWeight.w600,

                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 120.0,)
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
                isActive: selectedIndex != -1,
                onNextButton: () async {
                  if(prevAnswer != -1 && selectedIndex != -1) {
                    if(selectedIndex != prevAnswer) {
                      updateNewAnswer();
                    } else {
                      var result = await updatePendingQuestionDB();
                      if (result != null) {
                        openNextScreen();
                      } else {
                        CustomToast.showToastMessage('Something Went Wrong!!');
                      }
                    }
                  } else {
                    var result = await updatePendingQuestionDB();
                    if (result != null) {
                      openNextScreen();
                    } else {
                      CustomToast.showToastMessage('Something Went Wrong!!');
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

  void checkQuestion() async {
    var listItemData = await InspectionPreferences.getPreferenceData(InspectionPreferences.INSPECTION_DATA);
    var transformedData = json.decode(listItemData);
    int inspectionIndex = await InspectionPreferences.getInspectionId(InspectionPreferences.INSPECTION_INDEX);

    if(transformedData.length > inspectionIndex) {
      inspectionData = transformedData[inspectionIndex-1];
      log("InspectionUpdatedData ==== ${inspectionData['answers']}");

      if(inspectionData['answers'].length == 0){
        postMultiListQuestion();
      } else {
        var isAnswered = false;
        var answerData;
        for(int i=0; i<inspectionData['answers'].length; i++){
          var simpleListId = "$selectedIndex";
          if("${inspectionData['answers'][i]['simplelistid']}" != "$simpleListId"){
            isAnswered = true;
            answerData = inspectionData['answers'][i];
            break;
          }
        }

        if(isAnswered) {
          updateMultiListQuestion(answerData);
        } else {
          openNextScreen();
        }
      }
    }
  }

  Future updatePendingQuestionDB() async {
    var result;
    try {
      var simplelistid = "$selectedIndex";

      log("updatePendingQuestionDBsimplelistid====$simplelistid");

      var requestParam = {};
      var endPoint =  "${widget.inspectionData['endpoint'].toString().replaceAll("{simplelistid}", "${simplelistid}")}";
      var inspectionId = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ID);
      var vesselId = widget.inspectionData.containsKey('vesselid') ? widget.inspectionData['vesselid']?? null : null;
      var equipmentId = widget.inspectionData.containsKey('equipmentid') ? widget.inspectionData['equipmentid']?? null : null;
      var bodyOfWaterId = widget.inspectionData.containsKey('bodyofwaterid') ? widget.inspectionData['bodyofwaterid']?? null : null;

      result = await dbHelper.insertPendingUrl({
        "url": "$endPoint",
        "verb": "POST",
        "inspectionid": inspectionId,
        "simplelistid": simplelistid,
        "image_id": null,
        "equipmentid": equipmentId,
        "vesselid": vesselId,
        "bodyofwaterid": bodyOfWaterId,
        "inspectiondefid": widget.inspectionData['inspectiondefid'],
        "questionid": widget.inspectionData['questionid'],
        "payload": json.encode(requestParam),
        "imagepath": "",
        "notaimagepath": ""
      });
      print("ResultInsertPending==== $result");

      log("inspectionDefId1111===${widget.inspectionData['inspectiondefid']}, "
          "InspectionId===$inspectionId, questionId===${widget.inspectionData['questionid']}, "
          "bodyOfWaterId===$bodyOfWaterId, vesselId===$vesselId, "
          "equipmentId===$equipmentId, SimpleListId===$simplelistid");

      var answerData = {
        "proxyid": result,
        "inspectionid": inspectionId,
        "simplelistid": simplelistid,
        "image_id": "",
        "equipmentid": equipmentId,
        "vesselid": vesselId,
        "bodyofwaterid": bodyOfWaterId,
        "inspectiondefid": widget.inspectionData['inspectiondefid'],
        "questionid": widget.inspectionData['questionid'],
        "payload": "",
        "answer": "",
        "imageurl": '',
        "imagefileurl": ''
      };
      print("answerData ==== $answerData");

      var answerResult = await dbHelper.insertUpdateAnswerRecord(answerData);
      print("answerResult ==== $answerResult");
    } catch (e){
      log("StackTrace====$e");
    }
    return result;
  }

  Future getLocalOptionList() async {
    var optionId = inspectionData['answerscope']['simplelist'] ?? "";
    if(optionId != "") {
      var response = await dbHelper.getSelectedSimpleList(optionId);
      if (response != null) {

        var result = await dbHelper.getMultiListData(selectedIndex);

        result = result.map((element) => Map<String, dynamic>.of(element)).toList();
        var prevAnswerData = adjacencyTransform1(result);
        JsonEncoder encoder = JsonEncoder.withIndent('  ');
        log("Result === ${encoder.convert(prevAnswerData)}");

        setState(() {
          optionMainList.clear();
          response = response.map((element) => Map<String, dynamic>.of(element)).toList();

          var transformedData = adjacencyTransform1(response);
          log("transformedData===$transformedData");
           optionMainList = transformedData['children'];

           if(selectedIndex != -1) {
             for (int i = 0; i < optionMainList.length; i++) {
               for(int j=0; j<prevAnswerData['children'].length; j++) {
                 if(optionMainList[i]['simplelistid'] == prevAnswerData['children'][j]['simplelistid']) {
                    selectedValue = optionMainList[i];

                    for(int k=0; k<optionMainList[i]['children'].length; k++) {
                      if(optionMainList[i]['children'][k]['simplelistid'] == prevAnswerData['children'][j]['children'][0]['simplelistid']) {
                        optionSubList.clear();
                        var mapData = {
                          "value": optionMainList[i]['children'],
                          "selectedValue": optionMainList[i]['children'][k]
                        };
                        optionSubList.add(mapData);
                      }
                    }
                 }
               }
             }
           } else {
             for (int i = 0; i < optionMainList.length; i++) {
               if (optionMainList[i]['simplelistid'] == selectedIndex) {
                 if (optionMainList[i]['children'].length > 0) {
                   optionSubList.clear();
                   var mapData = {
                     "value": optionMainList[i]['children'],
                     "selectedValue": null
                   };
                   optionSubList.add(mapData);
                   selectedIndex = -1;
                 }
               }
             }
           }
        });
      }
    }
  }

  void updateNewAnswer() async {
    try{
      log("UpdateNewAnswer");
      Map allPreviousData = await InspectionUtils.getPreviousData();

      var inspectionLocalId = allPreviousData['inspectionid'];
      var prevAnswersList = allPreviousData['answerlist'] ?? [];

      var prevSelectedEquipmentList = allPreviousData['equipmentlist'] ?? [];
      var waterBodiesTemplateData = allPreviousData['bodyofwaterlist'] ?? [];
      var childrenTemplateData = allPreviousData['inspectionDef'] ?? [];

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
      var result = await updatePendingQuestionDB();
      if (result != null) {
        openNextScreen();
      } else {
        CustomToast.showToastMessage('Something Went Wrong!!');
      }

    } catch (e) {
      print("saveEvent Error ====$e");
    }
  }

  Future getOptionList() async {
    var optionId = dynamicMainData['answerscope']['simplelist'] ?? "";
    if(optionId != "") {
      _progressHUD.state.show();
      FocusScope.of(context).requestFocus(FocusNode());
      var response = await request.getAuthRequest("auth/simplelist/list/$optionId");

      _progressHUD.state.dismiss();
      if (response != null) {
        var transformedData = adjacencyTransform1(response);

        const JsonEncoder encoder = JsonEncoder.withIndent('  ');
        log("ChildrenData====>>>>${encoder.convert(transformedData)}");
        setState(() {
          optionMainList = transformedData['children'];
        });
      }
    }

    // _progressHUD.state.show();
    // FocusScope.of(context).requestFocus(FocusNode());
    // var response = await request.getAuthRequest("auth/simplelist/list/40");
    //
    // _progressHUD.state.dismiss();
    // if (response != null) {
    //   var transformedData = adjacencyTransform(response);
    //
    //   // const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    //   // log("ChildrenData====>>>>${encoder.convert(transformedData)}");
    //   setState(() {
    //     optionList = transformedData['children'];
    //     optionMainList = transformedData['children'];
    //
    //     for(int i=0; i<optionList.length; i++) {
    //       optionList[i]['selectedValue'] = null;
    //       optionMainList[i]['selectedValue'] = null;
    //     }
    //   });
    // }
  }

  void postMultiListQuestion() async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var simplelistid = "$selectedIndex";

    var requestParam = json.encode({});
    var response = await request.postRequest(
        "${widget.inspectionData['endpoint'].toString().replaceAll("{simplelistid}", "${simplelistid}")}",
        requestParam
    );
    _progressHUD.state.dismiss();

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage('${response['reason']}');
      } else {
        var result = await HelperClass.openUnroll(response);
        if(result)
          openNextScreen();
        else
          CustomToast.showToastMessage('Something went wrong!!!');
      }
    } else {
      CustomToast.showToastMessage('Something went wrong!!!');
    }
  }

  void updateMultiListQuestion(answerData) async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var simplelistid = "$selectedIndex";
    var inspectionId = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ID);

    var requestParam = json.encode({"simplelistid": "$simplelistid"});
    var response = await request.postRequest(
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
        var result = await HelperClass.openUnroll(response);
        if(result)
          openNextScreen();
        else
          CustomToast.showToastMessage('Something went wrong!!!');
      }
    } else {
      CustomToast.showToastMessage('Something went wrong!!!');
    }
  }

  Map<String, dynamic> adjacencyTransform1(List<dynamic> nsResult) {
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
            nsResult[ix]['label'] = newData;
          } catch(e) {
            log("StackTraceMapEntryMultiple====$e");
          }
          container["children"].add(nsResult[ix]);
          build(nsResult[ix]);
        }

        if (ix < nsResult.length) {
          ix--;
        }
      };

      if (nsResult.length > 0) {
        build(nsResult[0]);
        return nsResult[0];
      }
    } catch(e) {
      log("StackTrace====$e");
    }

    return {"children":[]};
  }

  Map adjacencyTransform(nsResult) {
    // try{
      int ix=0;
      void build (Map<String, dynamic> container) {

        container["children"]=[];
        log("TYPE===${nsResult[ix]["lft"].runtimeType}");
        if(container["rgt"] - container["lft"] < 2) {
          return;
        }
        while((++ix < nsResult.length) && (nsResult[ix]["lft"] > container["lft"]) && (nsResult[ix]["rgt"] < container["rgt"])) {
          container["children"].add(nsResult[ix]);

          Map<String, dynamic> newResult = Map<String, dynamic>.from(nsResult[ix]);
          build(newResult);
        }

        if(ix<nsResult.length) {
          ix--;
        }
      }

      if(nsResult.length > 0) {
        Map<String, dynamic> newResult = Map<String, dynamic>.from(nsResult[0]);
        build(newResult);
        return newResult;
      }
    // }catch(e) {
    //   log("StackTraceAdjacencyMultiple====$e");
    // }

    return {"children":[]};
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
}
