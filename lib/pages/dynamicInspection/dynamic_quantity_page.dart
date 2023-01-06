import 'dart:convert';
import 'dart:developer';

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

class DynamicQuantityPage extends StatefulWidget {
  final inspectionData;
  final lastIndex;

  const DynamicQuantityPage({Key key, this.inspectionData, this.lastIndex}) : super(key: key);

  @override
  _DynamicQuantityPageState createState() => _DynamicQuantityPageState();
}

class _DynamicQuantityPageState extends State<DynamicQuantityPage> {
  int quantityValue = 0;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final dbHelper = DatabaseHelper.instance;

  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;
  var inspectionItem;
  var elevation = 0.0;
  bool isScrollBottom = false;
  final _scrollController = ScrollController();
  String equipmentName = "Pool";
  var answerId = "";
  int previousAnswer = -1;
  bool isAnswerChange = false;
  var dynamicData;
  var vesselId;
  var vesselname;
  int maxValue = 0;
  var inspectionData;
  var sectionName;
  var completeButtonName = "Next";
  String lang = "en";

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
    getInspectionData();

    _scrollController.addListener(() {
      setState(() {
        if(_scrollController.position.pixels > _scrollController.position.minScrollExtent){
          elevation = HelperClass.ELEVATION_1;
        } else {
          elevation = HelperClass.ELEVATION;
        }

        isScrollBottom = _scrollController.position.pixels < _scrollController.position.maxScrollExtent;
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

  void getInspectionData() async {
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
      inspectionData = inspectionData;
      dynamicData = inspectionData['txt'][lang] ?? inspectionData['txt']['en'];

      vesselId = inspectionData['vesselid'] ?? '';
      vesselname = inspectionData['vesselname'] ?? '';
      maxValue = inspectionData['answerscope']['max'] != null
                  ? int.parse(inspectionData['answerscope']['max'])
                  : 0;

      sectionName = HelperClass.getSectionText(inspectionData);
      if(widget.lastIndex != null){
        if(widget.lastIndex == inspectionIndex) {
          completeButtonName = "Complete";
        }
      }

      log("AnswerRecord====${inspectionData['answers']}");
      answerDataList = inspectionData['answers'] ?? [];

      for(var answer in answerDataList) {
        quantityValue = answer['answer'] ?? 0;
        prevAnswer = answer['answer'] ?? -1;
      }

      for(var localAnswer in localAnswerResult) {
        quantityValue = localAnswer['answer'] ?? 0;
        prevAnswer = localAnswer['answer'] ?? -1;
      }
    });
  }

  void getPreferenceData() async {
    var preferenceData = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ITEM);
    var inspectionData = json.decode(preferenceData);

    setState(() {
      inspectionItem = inspectionData;
      equipmentName = inspectionItem['name'] ?? 'Pool';

      print(inspectionItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode ? AppColor.BLACK_COLOR : AppColor.PAGE_COLOR,
     appBar: EmptyAppBar(isDarkMode: isDarkMode),
     /* appBar: AppBar(
        elevation: elevation,
        backgroundColor: AppColor.PAGE_COLOR,
        leading: GestureDetector(
          onTap: (){
//            getProfileDetail();
            _scaffoldKey.currentState.openDrawer();
//              HelperClass.launchDetail(context, DynamicQuantityPage());
//          Navigator.push(context, MaterialPageRoute(builder: (context) => Chapter1Page()));
          },
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Image.asset(
              'assets/ic_menu.png',
//              'assets/ic_close.png',
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
                        getThemeData();
                        // HelperClass.printDatabaseResult();
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
                  child: Column(
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
                     /* Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.symmetric(horizontal: 60.0,vertical: 8.0),
                        child: LinearPercentIndicator(
                          animationDuration: 200,
                          backgroundColor: Color(0xffE5E5E5),
                          percent: 0.1,
                          lineHeight: 8.0,
                          progressColor: AppColor.HEADER_COLOR,
                        ),
                      ),*/

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
                      SizedBox(height: 32.0,),

                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.0),
                        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 16.0),
                        decoration: BoxDecoration(
                            color: isDarkMode
                                ? Color(0xff1F1F1F)
                                : AppColor.WHITE_COLOR,
                          borderRadius: BorderRadius.all(Radius.circular(16.0))
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 6.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: (){
                                      setState(() {
                                        if(quantityValue != 0){
                                          quantityValue--;
                                        }
                                      });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(right: 24.0),
                                      padding: EdgeInsets.all(12.0),
                                      decoration: BoxDecoration(
                                          color: AppColor.THEME_PRIMARY.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(24)
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(
                                          Icons.remove,
                                          color: quantityValue == 0 ? AppColor.TYPE_SECONDARY : themeColor,
                                          size: 24.0
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 56.0,
                                    width: 56.0,
                                    alignment: Alignment.center,
                                    child: Text(
                                      '$quantityValue',
                                      style: TextStyle(
                                          fontSize: 28.0,
                                          color: themeColor,
                                          fontWeight: FontWeight.w700,
                                          fontStyle: FontStyle.normal
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: (){
                                      setState(() {
                                        if(quantityValue != maxValue){
                                          quantityValue++;
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(12.0),
                                      decoration: BoxDecoration(
                                          color: AppColor.THEME_PRIMARY.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(24)
                                      ),
                                      margin: EdgeInsets.only(left: 24.0),
                                      alignment: Alignment.center,
                                      child: Icon(
                                          Icons.add,
                                          color: quantityValue == maxValue ? AppColor.TYPE_SECONDARY : themeColor,
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
                                dynamicData != null
                                    ? dynamicData['reporttag'] ?? ""
                                    : "",
                                style: TextStyle(
                                    fontSize: 16.0,
                                    color: themeColor,
                                    fontWeight: FontWeight.w700,
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
                      ),

                    ],
                  ),
                ),
              ),
            ],
          ),

          Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: BottomButtonWidget(
                buttonName: "$completeButtonName",
                isActive: true,
                onBackButton: () async {
                  int inspectionIndex = await InspectionPreferences.getInspectionId(InspectionPreferences.INSPECTION_INDEX);
                  InspectionUtils.decrementIndex(inspectionIndex);
                  Navigator.pop(context);
                },
                onNextButton: () async {
                  // postQuantityQuestion();
                  // checkQuestion();
                  if(prevAnswer != -1 && quantityValue != -1) {
                    if(quantityValue != prevAnswer) {
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
              )
          ),
          _progressHUD
        ],
      ),
    );
  }

  void updateNewAnswer() async {
    try{
      var answer = quantityValue;
      Map allPreviousData = await InspectionUtils.getPreviousData();

      var inspectionLocalId = allPreviousData['inspectionid'] ?? 0;
      var prevAnswersList = allPreviousData['answerlist'] ?? [];

      prevAnswersList.removeWhere((item) => item['answer'] == answer);
      setState(() {
        prevAnswer = -1;
      });

      var pendingAnswer;
      if(answerDataList.length>0) {
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

      var result = await updatePendingQuestionDB();
      if(result != null) {
        openNextScreen();
      } else {
        CustomToast.showToastMessage('Something Went Wrong!!');
      }

    } catch (e) {
      print("saveEvent Error ====$e");
    }
  }

  Future updatePendingQuestionDB() async {
    var result;
    try {
      var requestJson = {"answer": quantityValue};
      var simplelistid = "$quantityValue";
      var endPoint =  "${widget.inspectionData['endpoint'].toString().replaceAll("{simplelistid}", "${simplelistid}")}";
      var inspectionId = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ID);

      var vesselId = widget.inspectionData.containsKey('vesselid') ? widget.inspectionData['vesselid']?? null : null;
      var equipmentId = widget.inspectionData.containsKey('equipmentid') ? widget.inspectionData['equipmentid']?? null : null;
      var bodyOfWaterId = widget.inspectionData.containsKey('bodyofwaterid') ? widget.inspectionData['bodyofwaterid']?? null : null;

      result = await dbHelper.insertPendingUrl({
        "url": "$endPoint",
        "verb": "POST",
        "inspectionid": inspectionId,
        "simplelistid": null,
        "image_id": null,
        "equipmentid": equipmentId,
        "vesselid": vesselId,
        "bodyofwaterid": bodyOfWaterId,
        "inspectiondefid": widget.inspectionData['inspectiondefid'],
        "questionid": widget.inspectionData['questionid'],
        "payload": json.encode(requestJson),
        "imagepath": "",
        "notaimagepath": ""
      });
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
        "answer": quantityValue,
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

  void postQuantityQuestion() async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var requestJson = {"answer": quantityValue};
    var simplelistid = "$quantityValue";

    var requestParam = json.encode(requestJson);
    var response = await request.postRequest(
        "${widget.inspectionData['endpoint'].toString().replaceAll("{simplelistid}", "${simplelistid}")}",
        requestParam
    );
    _progressHUD.state.dismiss();

    if (response != null) {
      if (response['success']!=null && !response['success']) {
          CustomToast.showToastMessage('${response['reason']}');
      } else {
        setState(() {
          answerId = "${response['answerid']}";
          previousAnswer = quantityValue;
          isAnswerChange = false;
        });
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

  void updateQuantityQuestion(answerData) async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var requestJson = {"answer": quantityValue};
    var inspectionId = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ID);

    var requestParam = json.encode(requestJson);
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
