import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dottie_inspector/database/database_helper.dart';
import 'package:dottie_inspector/inspectionPreferences/inspection_preferences.dart';
import 'package:dottie_inspector/pages/dynamicInspection/dynamic_general_page.dart';
import 'package:dottie_inspector/pages/menu/drawer_page.dart';
import 'package:dottie_inspector/pages/menu/index_menu.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/SlideRightRoute.dart';
import 'package:dottie_inspector/utils/custom_toast.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:dottie_inspector/utils/globalInstance.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/utils/inspection_utils.dart';
import 'package:dottie_inspector/utils/language.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:dottie_inspector/widget/bottom_button_widget.dart';
import 'package:dottie_inspector/widget/image_network_view_screen_page.dart';
import 'package:dottie_inspector/widget/image_view_screen_page.dart';
import 'package:dottie_inspector/widget/open_camera_widget.dart';
import 'package:dottie_inspector/widget/open_network_camera_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_hud/progress_hud.dart';

import 'dynamic_complete_inspection_screen.dart';

class DynamicPhotoPage extends StatefulWidget {
  final inspectionData;
  final lastIndex;

  const DynamicPhotoPage({Key key, this.inspectionData, this.lastIndex}) : super(key: key);

  @override
  _DynamicPhotoPageState createState() => _DynamicPhotoPageState();
}

class _DynamicPhotoPageState extends State<DynamicPhotoPage> {
  double progress = 0.05;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final dbHelper = DatabaseHelper.instance;

  var isPhotoTaken = false;
  var imagePath = '';
  var isAnswerChanged = false;
  File noteImagePath;
  File image;
  var photoDescription = "";
  var imageId;
  var elevation = 0.0;
  final _scrollController = ScrollController();
  bool isScrollBottom = false;

  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;
  var answerId = "";
  var dynamicData;
  var questionId = "0";
  var inspectionItem;
  var vesselId;
  var vesselname;
  var inspectionData;
  var sectionName;
  var completeButtonName = "Next";
  final ImagePicker _picker = ImagePicker();
  String lang = 'en';
  var answerDataList = [];
  var networkImage = "";

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
    lang = await PreferenceHelper.getPreferenceData(PreferenceHelper.LANGUAGE) ?? 'en';
    inspectionData = widget.inspectionData;

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

    setState(() {
      inspectionData = inspectionData;
      dynamicData = inspectionData['txt'][lang] ?? inspectionData['txt']['en'];
      vesselId = inspectionData['vesselid'] ?? '';
      vesselname = inspectionData['vesselname'] ?? '';

      sectionName = HelperClass.getSectionText(inspectionData);
      if(widget.lastIndex != null){
        if(widget.lastIndex == inspectionIndex) {
          completeButtonName = "Complete";
        }
      }

      log("AnswerRecord====${inspectionData['answers']}");
      answerDataList = inspectionData['answers'] ?? [];

      if(answerDataList.length>0) {
        if (answerDataList[0]['image']['path'] != null) {
          isPhotoTaken = true;
          networkImage =
          "${GlobalInstance.apiBaseUrl}${answerDataList[0]['image']['path']
              .toString()
              .substring(1)}";
        }
      } else if(localAnswerResult != null){
        if(localAnswerResult.length > 0) {
          if (localAnswerResult[0]['imageurl'] != null) {
            isPhotoTaken = true;
            imagePath = localAnswerResult[0]['imageurl'];
            networkImage = "";
          }
          if (localAnswerResult[0]['imagefileurl'] != null) {
            if(localAnswerResult[0]['imagefileurl'] != "null") {
              isPhotoTaken = true;
              noteImagePath = localAnswerResult[0]['imagefileurl'];
              networkImage = "";
            }
          }
        }
      }

      // log("ImagePath=====${localAnswerResult[0]['']}");
      
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

  Future getImageFromCamera() async {
    var image1 = await _picker.pickImage(source: ImageSource.camera);
    if (image1 != null) {
      openCropImageOption(image1.path);
    }
  }

  void openCropImageOption(imagePath1) async {
    File croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath1,
        aspectRatioPresets: [
          CropAspectRatioPreset.square
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: lang == 'en' ? imageCropperEn : imageCropperEs,
            toolbarColor: isDarkMode ? Colors.black : AppColor.THEME_PRIMARY,
            toolbarWidgetColor: Colors.white,
            cropFrameColor: isDarkMode ? Colors.white : AppColor.BLACK_COLOR,
            cropFrameStrokeWidth: 2,
            hideBottomControls: true,
            statusBarColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.square,
            cropGridColor: isDarkMode ? Colors.black : AppColor.THEME_PRIMARY,
            backgroundColor: isDarkMode ? Colors.black : AppColor.PAGE_COLOR,
            showCropGrid: true,
            activeControlsWidgetColor: AppColor.THEME_PRIMARY,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        )
    );

    if(croppedFile != null) {
      File compressedFile = await HelperClass.getCompressedImageFile(croppedFile);
      setState(() {
        isPhotoTaken = true;
        imagePath = compressedFile.path;
        image = compressedFile;

        compressedFile = null;
      });
    }
  }

  Future getImageFromGallery() async {
    var image1 = await _picker.pickImage(source: ImageSource.gallery);
    if (image1 != null) {
      openCropImageOption(image1.path);
    }
    // var image1 = await _picker.pickImage(source: ImageSource.gallery);
    // if (image1 != null) {
    //   File compressedFile = await HelperClass.getCompressedImageFile(File(image1.path));
    //   setState(() {
    //     isPhotoTaken = true;
    //     imagePath = compressedFile.path;
    //     image = null;
    //     compressedFile = null;
    //   });
    // }
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
        brightness: Brightness.light,
        leading: GestureDetector(
          onTap: () {
            displayDrawerDialog(context);
          },
          child: Container(
            padding: EdgeInsets.all(0.0),
            child: Image.asset(
              'assets/ic_menu.png',
              fit: BoxFit.cover,
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
                        // HelperClass.printDatabaseResult();

                        var result = await dbHelper.getAllPendingEquipmentData();
                        log("Result====$result");

                        // var result = await dbHelper.allAnswerRecord();
                        // const JsonEncoder encoder = JsonEncoder.withIndent('  ');
                        // log("AllAnswerRecord====>>>>${encoder.convert(result)}");
                        //
                        // var inspectionId = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ID);
                        // var vesselId1 = inspectionData.containsKey('vesselid') ? inspectionData['vesselid']?? null : null;
                        // var equipmentId = inspectionData.containsKey('equipmentid') ? inspectionData['equipmentid']?? null : null;
                        // var bodyOfWaterId = inspectionData.containsKey('bodyofwaterid') ? inspectionData['bodyofwaterid']?? null : null;
                        // var inspectionDefId = inspectionData['inspectiondefid'];
                        // var questionId1 = inspectionData['questionid'];
                        //
                        // log("inspectionDefId===$inspectionDefId, "
                        //     "InspectionId===$inspectionId, questionId===$questionId1, "
                        //     "bodyOfWaterId===$bodyOfWaterId, vesselId===$vesselId1, "
                        //     "equipmentId===$equipmentId");
                        //
                        // var localAnswerResult = await dbHelper.fetchAnswerRecord(
                        //     inspectionDefId: inspectionDefId,
                        //     inspectionId: inspectionId,
                        //     questionId: questionId1,
                        //     bodyOfWaterId: bodyOfWaterId,
                        //     vesselId: vesselId1,
                        //     equipmentId: equipmentId);
                        //
                        // log("Result===$localAnswerResult");
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
                    margin: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 10.0,),
                        sectionName != null && sectionName != ""
                            ? Container(
                          margin: EdgeInsets.only(left: 8.0,right: 8.0, bottom: 8),
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
                          margin: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            dynamicData != null
                                ? dynamicData['title'] ?? ""
                                : "",
                            style: TextStyle(
                                color: themeColor,
                                fontSize: TextSize.pageTitleText,
                                fontWeight: FontWeight.w700
                            ),
                          ),
                        ),

                        SizedBox(height: 16,),

                        networkImage != ""
                        ? GestureDetector(
                          onTap: (){
                            if(networkImage != "") {
                              Navigator.push(
                                  context,
                                  SlideRightRoute(
                                      page: ImageNetworkViewScreen(
                                        imageFile: networkImage,
                                        noteImagePath: noteImagePath,
                                      )
                                  )
                              ).then((result) async {
                                if (result != null) {
                                  setState(() {
                                    noteImagePath = result;
                                  });
                                }
                              });
                            }
                          },
                          child: OpenNetworkCameraWidget(
                            networkImagePath: networkImage,
                            noteImagePath: noteImagePath != null ? noteImagePath : null,
                            isPhotoScreen: true,
                            photoDescription: photoDescription,
                            imageHeight: 32,
                            onDeleteClick: (){
                              // checkQuestion();
                              // updatePendingQuestionDB();
                              deleteNetworkPhotoRecord();
                            },
                            onCameraClick: () {
                              getImageFromCamera();
                            },
                            onGalleryClick: (){
                              getImageFromGallery();
                            },
                            onDescriptionCallback: (description) {
                              setState(() {
                                if(description != null){
                                  photoDescription = description;
                                  print("PhotoDescription=====>>>>>$description");
                                }
                              });
                            },
                          ),
                        )
                        : GestureDetector(
                          onTap: (){
                            if(imagePath != "") {
                              Navigator.push(
                                  context,
                                  SlideRightRoute(
                                      page: ImageViewScreenPage(
                                        imageFile: imagePath,
                                        noteImagePath: noteImagePath,
                                      )
                                  )
                              ).then((result) async {
                                if (result != null) {
                                  setState(() {
                                    noteImagePath = result;
                                  });
                                }
                              });
                            }
                          },
                          child: OpenCameraWidget(
                            imagePath: imagePath,
                            noteImagePath: noteImagePath != null ? noteImagePath : null,
                            isPhotoScreen: true,
                            photoDescription: photoDescription,
                            imageHeight: 32,
                            onDeleteClick: (){
                              deletePhotoRecord();
                            },
                            onCameraClick: () {
                              getImageFromCamera();
                            },
                            onGalleryClick: (){
                              getImageFromGallery();
                            },
                            onDescriptionCallback: (description) {
                              bool isKeyboardShowing = MediaQuery.of(context).viewInsets.vertical > 0;
                              log("KeyboardVisibility====$isKeyboardShowing");
                              setState(() {
                                if(description != null){
                                  photoDescription = description;
                                  print("PhotoDescription=====>>>>>$description");
                                }
                              });
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
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: BottomButtonWidget(
              buttonName: "$completeButtonName",
              isActive: imagePath != "" || networkImage != "",
              onBackButton: () async {
                int inspectionIndex = await InspectionPreferences.getInspectionId(InspectionPreferences.INSPECTION_INDEX);
                InspectionUtils.decrementIndex(inspectionIndex);
                Navigator.pop(context);
              },
              onNextButton: () async {
                if(networkImage != "") {
                  openNextScreen();
                } else if(imagePath != "") {
                   var result = await updatePendingQuestionDB();
                   if(result != null) {
                     openNextScreen();
                   } else {
                     CustomToast.showToastMessage('Something Went Wrong!!');
                   }
                }
               /* var result = await updatePendingQuestionDB();
                if(result != null) {
                  openNextScreen();
                } else {
                  CustomToast.showToastMessage('Something Went Wrong!!');
                }*/
                // openNextScreen();
              },
            )
          ),

          _progressHUD
        ],
      ),
    );
  }

  void displayDrawerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        content: Text(
          "Do you want to left your inspection",
          style: TextStyle(
            color: themeColor,
            fontSize: 16.0,
          ),
        ),
        actions: <Widget>[
          CupertinoDialogAction(
              child: const Text('Cancel'),
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context, 'Cancel');
              }),
          CupertinoDialogAction(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.pop(context, 'Yes');
                _scaffoldKey.currentState.openDrawer();
              }),
        ],
      ),
      barrierDismissible: true,
    );
  }

  Future updatePendingQuestionDB() async {
    var result;
    try {
      var inspectionId = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ID);
      var vesselId = widget.inspectionData.containsKey('vesselid') ? widget.inspectionData['vesselid']?? null : null;
      var equipmentId = widget.inspectionData.containsKey('equipmentid') ? widget.inspectionData['equipmentid']?? null : null;
      var bodyOfWaterId = widget.inspectionData.containsKey('bodyofwaterid') ? widget.inspectionData['bodyofwaterid']?? null : null;

      var endPoint =  "${widget.inspectionData['endpoint']}";
      var answer = photoDescription == '' ? '' : photoDescription;

      result = await dbHelper.insertPendingUrl({
        "url": '$endPoint',
        "verb":'MULTIPART',
        "inspectionid": inspectionId,
        "inspectiondefid": widget.inspectionData['inspectiondefid'],
        "questionid": widget.inspectionData['questionid'],
        "payload": '$answer',
        "equipmentid": equipmentId,
        "vesselid": vesselId,
        "bodyofwaterid": bodyOfWaterId,
        "simplelistid": null,
        "image_id": null,
        "imagepath": '$imagePath',
        "notaimagepath": noteImagePath != null ? '${noteImagePath.path}' : 'null'
      });
      print("Result ==== $result");
      setState(() {
        imageId = result ?? 0;
      });

      var answerData = {
        "proxyid": result,
        "inspectionid": inspectionId,
        "simplelistid": null,
        "image_id": imageId,
        "equipmentid": equipmentId,
        "vesselid": vesselId,
        "bodyofwaterid": bodyOfWaterId,
        "inspectiondefid": widget.inspectionData['inspectiondefid'],
        "questionid": widget.inspectionData['questionid'],
        "payload": "",
        "answer": "$answer",
        "imageurl": '$imagePath',
        "imagefileurl": '$noteImagePath'
      };

      var answerResult = await dbHelper.insertUpdateAnswerRecord(answerData);
      print("answerResult ==== $answerResult");

    } catch (e){
      log("StackTrace====$e");
    }
    return result;
  }

  Future deleteNetworkPhotoRecord() async {
    try{
      Map allPreviousData = await InspectionUtils.getPreviousData();

      var inspectionLocalId = allPreviousData['inspectionid'];

      var prevSelectedEquipmentList = allPreviousData['equipmentlist'] ?? [];
      var waterBodiesTemplateData = allPreviousData['bodyofwaterlist'] ?? [];
      var childrenTemplateData = allPreviousData['inspectionDef'] ?? [];
      var prevAnswersList = allPreviousData['answerlist'] ?? [];

      var pendingAnswer;
      if(answerDataList.length>0) {
        prevAnswersList.removeWhere((item) => item['answerid'] == answerDataList[0]['answerid']);
        setState(() {
          networkImage = "";
          isPhotoTaken = false;
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

      ///Start unroll
      var transformedData = HelperClass.unroll(int.parse(inspectionLocalId), childrenTemplateData, waterBodiesTemplateData, prevSelectedEquipmentList, prevAnswersList);

      ///Save inspection data
      InspectionPreferences.clearPreferenceData(InspectionPreferences.INSPECTION_DATA);
      InspectionPreferences.setPreferenceData(
          InspectionPreferences.INSPECTION_DATA,
          json.encode(transformedData['flow'])
      );

      answerDataList.clear();
    } catch (e) {
      print("saveEvent Error ====$e");
    }
  }

  Future deletePhotoRecord() async {
    try{
       var result = await dbHelper.deletePendingRequest("$imageId");

       if(result != null) {
         setState(() {
           noteImagePath = null;
           photoDescription = "";
           imagePath = "";
           isAnswerChanged = true;
           imageId = 0;
         });
       }
    }catch(e) {
      log("StackTrace====$e");
    }
  }

  Future<void> postPhotoQuestion() async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var answer = photoDescription == '' ? '' : photoDescription;

    var response = await request.uploadMultipartImage(
        "${widget.inspectionData['endpoint']}",
        imagePath,
        noteImagePath,
        answer
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

  void openNextScreen() async {
    var listItemData = await InspectionPreferences.getPreferenceData(InspectionPreferences.INSPECTION_DATA);
    var transformedData = json.decode(listItemData);
    int inspectionIndex = await InspectionPreferences.getInspectionId(InspectionPreferences.INSPECTION_INDEX);

    // const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    // log("TransformedData====>>>>${encoder.convert(transformedData)}");
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
