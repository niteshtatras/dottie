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
import 'package:dottie_inspector/widget/gradient/grediant_box_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_hud/progress_hud.dart';

import 'dynamic_complete_inspection_screen.dart';
import 'dynamic_general_page.dart';

class DynamicSideNotePage extends StatefulWidget {
  final inspectionData;
  final lastIndex;

  const DynamicSideNotePage({Key key, this.inspectionData, this.lastIndex}) : super(key: key);
  @override
  _DynamicSideNotePageState createState() => _DynamicSideNotePageState();
}

class _DynamicSideNotePageState extends State<DynamicSideNotePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final dbHelper = DatabaseHelper.instance;

  String noteText = "";
  var noComment = false;
  var isCommentEntered = false;
  var isCommentFocus = false;
  final _commentTextEditingController = TextEditingController();
  FocusNode _commentFocus = FocusNode();

  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;
  var elevation = 0.0;
  final _scrollController = ScrollController();
  var dynamicData;
  var inspectionItem;
  var vesselId;
  var vesselname;
  var inspectionData;
  var sectionName;
  var completeButtonName = "Next";
  var answerDataList = [];
  var localAnswerResult = [];

  var prevAnswer = "";

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

    _scrollController.addListener(() {
      setState(() {
        if(_scrollController.position.pixels > _scrollController.position.minScrollExtent){
          elevation = HelperClass.ELEVATION_1;
        } else {
          elevation = HelperClass.ELEVATION;
        }
      });
    });

    _commentFocus.addListener(() {
      setState(() {
        isCommentFocus = _commentFocus.hasFocus;
        noComment = !_commentFocus.hasFocus && _commentTextEditingController.text == "";
      });
    });
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
    int inspectionIndex = await InspectionPreferences.getInspectionId(InspectionPreferences.INSPECTION_INDEX);
    print("Index===$inspectionIndex && lastIndex===${widget.lastIndex}");
    print("RunTYpe Index===${inspectionIndex.runtimeType} && lastIndex===${widget.lastIndex.runtimeType}");
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
      dynamicData = inspectionData['txt'][lang] ?? inspectionData['txt']['en'];

      log("AnswerRecord====${inspectionData['answers']}");
      answerDataList = inspectionData['answers'] ?? [];

      if(answerDataList.length>0) {
        _commentTextEditingController.text = answerDataList[0]['answer'];
        prevAnswer = answerDataList[0]['answer'];
        isCommentEntered = true;
      }

      if(localAnswerResult.length>0) {
        _commentTextEditingController.text = localAnswerResult[0]['answer'];
        prevAnswer = localAnswerResult[0]['answer'];
        isCommentEntered = true;
      }

      vesselId = inspectionData['vesselid'] ?? '';
      vesselname = inspectionData['vesselname'] ?? '';
      sectionName = HelperClass.getSectionText(inspectionData);
      if(widget.lastIndex != null){
        if(widget.lastIndex == inspectionIndex) {
          completeButtonName = "Complete";
        }
      }
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
                  child: SingleChildScrollView(
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
                                fontStyle: FontStyle.normal,),
                          ),
                        ),

                        SizedBox(
                          height: 8.0,
                        ),
                        // Description
                        dynamicData == null
                        ? Container()
                        : dynamicData['helpertext'] == null
                        ? Container()
                        : dynamicData['helpertext'] == ""
                        ? Container()
                        : Container(
                          margin: EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            dynamicData != null
                                ? dynamicData['helpertext'] ?? ""
                                : "",
                            style: TextStyle(
                                fontSize: TextSize.headerText,
                                color: themeColor,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),

                        // GestureDetector(
                        //   onTap: (){
                        //     /*Navigator.push(
                        //         context,
                        //         SlideRightRoute(
                        //             page: AddCommonCommentPage(
                        //               commentData: noteText,
                        //               progress: 1.0,
                        //             )
                        //         )
                        //     ).then((result) {
                        //       if (result != null) {
                        //         setState(() {
                        //           noteText = result['data'];
                        //           noComment = false;
                        //         });
                        //       }
                        //     });*/
                        //     openAddCommentBottomSheet(context);
                        //   },
                        //   child: Container(
                        //     margin: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8),
                        //     padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
                        //     decoration: BoxDecoration(
                        //       color: AppColor.WHITE_COLOR,
                        //       borderRadius: BorderRadius.circular(16.0),
                        //     ),
                        //     width: MediaQuery.of(context).size.width,
                        //     child: Text(
                        //       noteText == '' ? "Type something..." : '$noteText',
                        //       style: TextStyle(
                        //           color: noteText == '' ? AppColor.TYPE_SECONDARY : themeColor,
                        //           fontSize: noteText == '' ? TextSize.subjectTitle : TextSize.headerText,
                        //           fontWeight: FontWeight.w600,
                        //           fontFamily: 'WorkSans'
                        //       ),
                        //     ),
                        //   ),
                        // ),

                        //Comment TextField
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(top: 32.0, bottom: 0.0, left: 16.0,right: 16.0),
                          padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isCommentFocus && isDarkMode
                                    ? AppColor.gradientColor(0.32)
                                    : isCommentFocus
                                    ? AppColor.gradientColor(0.16)
                                    : isDarkMode
                                    ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                                    : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
                              ),
                              borderRadius: BorderRadius.circular(32.0),
                              border: GradientBoxBorder(
                                  gradient: LinearGradient(
                                    colors: isCommentFocus
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
                                'Comments',
                                style: TextStyle(
                                    fontSize: TextSize.bodyText,
                                    color: themeColor,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.normal,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              TextFormField(
                                controller: _commentTextEditingController,
                                focusNode: _commentFocus,
                                onFieldSubmitted: (term) {
                                  _commentFocus.unfocus();
                                  setState(() {
                                    noComment = false;
                                  });
                                },
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.text,
                                textCapitalization: TextCapitalization.sentences,
                                textAlign: TextAlign.start,
                                decoration: InputDecoration(
                                  fillColor: AppColor.WHITE_COLOR,
                                  hintText: "Write Something...",
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
                                onChanged: (text) {
                                  setState(() {
                                    isCommentEntered = _commentTextEditingController.text != "";
                                    noComment = false;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),


                        SizedBox(height: 8.0,),
                        GestureDetector(
                          onTap: (){
                            setState(() {
                              noComment = !noComment;
                              if(noComment){
                                isCommentEntered = false;
                                _commentTextEditingController.text = "";
                              }
                              FocusScope.of(context).requestFocus(FocusNode());
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                ? Color(0xff1f1f1f)
                                : AppColor.WHITE_COLOR,
                              borderRadius: BorderRadius.circular(32.0),
                                border: GradientBoxBorder(
                                    gradient: LinearGradient(
                                      colors: noComment
                                          ? AppColor.gradientColor(1.0)
                                          : [AppColor.TRANSPARENT, AppColor.TRANSPARENT],
                                    ),
                                    width: 3
                                )
                            ),

                            child:  Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isDarkMode
                                      ? [Color(0xff333333), Color(0xff333333)]
                                      : [Color(0xff013399).withOpacity(0.3), Color(0xffBC96E6).withOpacity(0.3)]
                                    ),
                                      borderRadius: BorderRadius.circular(24)
                                  ),
                                  child:  Image.asset(
                                    'assets/shape/ic_none.png',
                                    width: 24.0,
                                    height: 24.0,
                                    color: isDarkMode
                                      ? Colors.white
                                      : Color(0xff013399).withOpacity(0.6),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Text(
                                      'I have no comments',
                                      style: TextStyle(
                                          color: themeColor,
                                          fontSize: TextSize.headerText,
                                          fontStyle: FontStyle.normal,
                                          fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
            Visibility(
              visible: !isCommentFocus,
              child: Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: BottomButtonWidget(
                    buttonName: "$completeButtonName",
                    isActive: isCommentEntered || noComment,
                    onNextButton: () async {
                     /* if(isCommentEntered || noComment){
                        postComment();
                      }*/
                      if(isCommentEntered) {
                        if(_commentTextEditingController.text.trim() != prevAnswer) {
                          if(prevAnswer != "") {
                            updateNewAnswer();
                          } else {
                            var result = await updatePendingQuestionDB();
                            if(result != null) {
                              openNextScreen();
                            } else {
                              CustomToast.showToastMessage('Something Went Wrong!!');
                            }
                          }
                        } else {
                          openNextScreen();
                        }
                      } else if(noComment){
                        openNextScreen();
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
        postComment();
      } else {
        var isAnswered = false;
        var answerData;
        for(int i=0; i<inspectionData['answers'].length; i++){
          var newAnswer = noComment ? "" : "${_commentTextEditingController.text}";
          if("${inspectionData['answers'][i]['answer']}" != newAnswer){
            isAnswered = true;
            answerData = inspectionData['answers'][i];
            break;
          }
        }

        if(isAnswered) {
          updateComment(answerData);
        } else {
          openNextScreen();
        }
      }
    }
  }

  Future updatePendingQuestionDB() async {
    var result;
    try {
      var comment = !isCommentEntered ? "" : "${_commentTextEditingController.text}";
      var requestJson = {"answer": '$comment'};
      var endPoint =  "${widget.inspectionData['endpoint']}";
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
        "image_id": 0,
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

      var answerResult = await dbHelper.insertUpdateAnswerRecord(answerData);
      print("answerResult ==== $answerResult");
    } catch (e){
      log("StackTrace====$e");
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

  void postComment() async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var comment = noComment ? "" : "${_commentTextEditingController.text}";
    var requestJson = {"answer": '$comment'};

    var requestParam = json.encode(requestJson);
    var response = await request.postRequest(
        "${widget.inspectionData['endpoint']}",
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

  void updateComment(answerData) async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var comment = noComment ? "" : "${_commentTextEditingController.text}";
    var requestJson = {"answer": '$comment'};
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
