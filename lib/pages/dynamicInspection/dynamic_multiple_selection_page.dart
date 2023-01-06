import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dottie_inspector/connection_mixin.dart';
import 'package:dottie_inspector/database/database_helper.dart';
import 'package:dottie_inspector/inspectionPreferences/inspection_preferences.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_hud/progress_hud.dart';

import 'dynamic_complete_inspection_screen.dart';
import 'dynamic_general_page.dart';

class DynamicMultipleSelectionPage extends StatefulWidget {
  final inspectionData;
  final lastIndex;

  const DynamicMultipleSelectionPage({Key key, this.inspectionData, this.lastIndex}) : super(key: key);
  @override
  _DynamicMultipleSelectionPageState createState() => _DynamicMultipleSelectionPageState();
}

class _DynamicMultipleSelectionPageState extends State<DynamicMultipleSelectionPage> with MyConnection{
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final dbHelper = DatabaseHelper.instance;

  bool isLandscapeHazard = true;
  bool isItemSelected = false;
  String imagePath = "";
  String noteText = "";
  var photoDescription = "";
  // List selectedList = [];
  // List<Map> itemSelected = [];
  List imageList = [];
  bool isSelectedNone = false;
  var elevation = 0.0;
  final _scrollController = ScrollController();

  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;
  var dynamicData;
  var inspectionData;
  List optionList = [];
  var questionId = "0";
  var inspectionItem;
  var vesselId;
  var vesselname;
  var optionId;
  bool isAnsweredChanged = false;
  var sectionName;
  var completeButtonName = "Next";
  String lang = "en";

  bool _isInternetAvailable = true;
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

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
      questionId = "${inspectionData['questionid']}";
      optionId = inspectionData['answerscope']['simplelist'] ?? "";
      isItemSelected = optionId == "";

      vesselId = inspectionData['vesselid'] ?? '';
      vesselname = inspectionData['vesselname'] ?? '';

      answerDataList = inspectionData['answers'] ?? [];

      sectionName = HelperClass.getSectionText(inspectionData);
      if(widget.lastIndex != null){
        if(widget.lastIndex == inspectionIndex) {
          completeButtonName = "Complete";
        }
      }
    });

    // JsonEncoder encoder = JsonEncoder.withIndent('  ');
    // log("InspectionData===>>>>${encoder.convert(inspectionData)}");

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

    // Timer(Duration(milliseconds: 100), getOptionList);
    initConnectivity();
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
  void dispose() {
    // TODO: implement dispose
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  void initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      log('Couldn\'t check connectivity status', error: e);
      return;
    }

    connectionSubscription();

    if (!mounted) {
      return Future.value(null);
    }

    return updateConnectionStatus(result);
  }

  @override
  void connectionSubscription() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      updateConnectionStatus(result);
    });
  }

  @override
  void updateConnectionStatus(result) {
    setState(() {
      _connectivityResult = result;
      if (_connectivityResult == ConnectivityResult.none) {
        _isInternetAvailable = false;
        getLocalOptionList();
      } else if ((_connectivityResult == ConnectivityResult.mobile) || (_connectivityResult == ConnectivityResult.wifi)) {
        _isInternetAvailable = true;
        getLocalOptionList();
      }
    });
  }

  ImagePicker _imagePicker = ImagePicker();
  Future getImageFromCamera(index, subIndex) async {
    var image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      openCropImageOption(image.path, index , subIndex);
    }
  }

  Future getImageFromGallery(index, subIndex) async {
    var image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      openCropImageOption(image.path, index , subIndex);
    }
    /*var image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File compressedFile = await HelperClass.getCompressedImageFile(File(image.path));
      setState(() {
        imagePath = compressedFile.path;
        optionList[index]['selectedItem']['images'][subIndex]['image'] = imagePath;
        //itemSelected[index]['images'][subIndex]['imageFile'] = compressedFile;

        Map itemData = {
          "image": "",
          "imageFile": null,
          "description": "",
          "imageid": 0
        };

        optionList[index]['selectedItem']['images'].add(json.decode(json.encode(itemData)));
        image = null;
        compressedFile = null;
      });
    }*/
  }

  void openCropImageOption(imageFilePath, index, subIndex) async {
    File croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFilePath,
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
        imagePath = compressedFile.path;
        optionList[index]['selectedItem']['images'][subIndex]['image'] = imagePath;
        optionList[index]['selectedItem']['images'][subIndex]['isNetwork'] = false;

        Map itemData = {
          "image": "",
          "imageFile": null,
          "description": "",
          "imageid": 0,
          "isNetwork": false
        };

        optionList[index]['selectedItem']['images'].add(json.decode(json.encode(itemData)));

        // var imageData = await GallerySaver.saveImage(imagePath, albumName: "Dottie");
        // print("SaveImage=====$imageData");
        compressedFile = null;
      });
    }
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
//            Timer(Duration(milliseconds: 100), getOptionList);
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
                       child: Image.asset(
                         'assets/ic_menu.png',
                         fit: BoxFit.cover,
                         width: 44,
                         height: 44,
                         color: isDarkMode ? AppColor.WHITE_COLOR : AppColor.BLACK_COLOR,
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

                      //Title
                      Container(
                        margin: EdgeInsets.only(left: 24.0,right: 24.0, top: 8, bottom: 16),
                        child: Text(
                          dynamicData != null
                              ? dynamicData['title'] ?? ""
                              : '',
                          style: TextStyle(
                              fontSize: TextSize.pageTitleText,
                              color: themeColor,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.normal,
                              height: 1.2
                          ),
                        ),
                      ),

                      //List of hazards
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
                        child: ListView.builder(
                          itemCount: optionList != null ? optionList.length : 0,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index){
                            var answerScope = inspectionData['answerscope']['photoif'] != null
                                ? inspectionData['answerscope']['photoif']
                                : [];
                            var isDisabled = inspectionData['answerscope']['disableif'] != null
                                ? inspectionData['answerscope']['disableif']
                                : [];
                            return IgnorePointer(
                              ignoring: isSelectedNone && !isDisabled.contains(optionList[index]['simplelistid']),
                              child: GestureDetector(
                                onTap: () async {
                                  if(isItemSelected){
                                    if(optionList[index]['answers'].length > 0){
                                      displayOptionDeleteDialog(context, optionList[index]['simplelistid'], index);
                                    } else {
                                      var inspectionId = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ID);
                                      var questionId = widget.inspectionData['questionid'];
                                      var simplelistid = optionList[index]['simplelistid'];

                                      var vesselId = widget.inspectionData.containsKey('vesselid') ? widget.inspectionData['vesselid']?? null : null;
                                      var equipmentId = widget.inspectionData.containsKey('equipmentid') ? widget.inspectionData['equipmentid']?? null : null;

                                      var record = await dbHelper.getMultiplePendingResult(inspectionId, questionId, simplelistid, vesselId, equipmentId);
                                      if(record != null && record.length > 0) {
                                        for(int i=0; i<record.length; i++) {
                                          await dbHelper.deletePendingRequest(record[i]['proxyid']);
                                        }
                                      }
                                    }
                                  }

                                  setState(() {
                                    if(optionList[index]['isSelected'] == 0){
                                      optionList[index]['selectedItem'] = {
                                        "id": optionList[index]['simplelistid'],
                                      };

                                      imageList.clear();
                                      imageList.add({
                                        "image": "",
                                        "imageFile": null,
                                        "description": "",
                                        "imageid":0,
                                        "isNetwork": false
                                      });
                                      optionList[index]['selectedItem']['images'] = json.decode(json.encode(imageList));
                                    } else {
                                      imageList.clear();
                                      optionList[index]['selectedItem'] = {};
                                    }
                                    optionList[index]['isSelected'] = optionList[index]['isSelected'] == 0 ? 1 : 0;
                                    print("ItemList====>>>>${optionList[index]['selectedItem']}");
                                    FocusScope.of(context).requestFocus(FocusNode());

                                    isSelectedNone = (isDisabled.contains(optionList[index]['simplelistid']) && optionList[index]['isSelected'] == 1);

                                    print(isSelectedNone);
                                    print(optionList[index]['isSelected']);
                                    print(optionList[index]['simplelistid']);
                                    print(isDisabled);
                                    print(isDisabled.contains(optionList[index]['simplelistid']));
                                    for(int i=0; i<optionList.length; i++){
                                      if(optionList[i]['isSelected'] == 1){
                                        isItemSelected = true;
                                        return;
                                      } else {
                                        isItemSelected = false;
                                      }
                                    }
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 8.0),
                                  padding: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 16.0),
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? Color(0xff1F1F1F)
                                        : AppColor.WHITE_COLOR,
                                    borderRadius: BorderRadius.circular(32.0),
                                    border: Border.all(
                                      color: AppColor.TRANSPARENT,
                                      width: 3.0,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                  minHeight: 40
                                              ),
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                padding: EdgeInsets.only(right: 8.0),
                                                child: Text(
//                                            getHazardTitle(index),
                                                  optionList[index]['label'][lang] == null
                                                      ? optionList[index]['label']['en'].toString().replaceAll("@@", "\"").replaceAll("##", "\'")
                                                      : optionList[index]['label'][lang].toString().replaceAll("@@", "\"").replaceAll("##", "\'"),
                                                  style: TextStyle(
                                                      color: !isSelectedNone
                                                          ? themeColor
                                                          : optionList[index]['isSelected'] == 1 && index == 0
                                                          ? themeColor
                                                          : themeColor.withOpacity(0.60),
                                                      fontSize: TextSize.subjectTitle,
                                                      fontStyle: FontStyle.normal,
                                                      fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(left: 8.0),
                                            height: 48.0,
                                            width: 48.0,
                                            child: Image.asset(
                                              optionList[index]['isSelected'] == 1
                                                  ? 'assets/complete_inspection/ic_check_icon.png'
                                                  : 'assets/complete_inspection/ic_unchecked_icon.png',
                                              height: 150,
                                              width: 150,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ],
                                      ),

                                      Visibility(
                                        visible: answerScope.contains(optionList[index]['simplelistid']),
                                        child: ListView.builder(
                                          itemCount: optionList[index]['selectedItem']['images'] != null
                                              ? optionList[index]['selectedItem']['images'].length
                                              : 0,
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, subIndex){
                                            // print("Index==$index, SubIndex===$subIndex & Value===${optionList[index]['selectedItem']['images'][subIndex]['isNetwork']}");
                                            return optionList[index]['selectedItem']['images'][subIndex]['isNetwork']
                                              ? Container(
                                              child: GestureDetector(
                                                onTap: (){
                                                  Navigator.push(
                                                      context,
                                                      SlideRightRoute(
                                                          page: ImageNetworkViewScreen(
                                                            imageFile: optionList[index]['selectedItem']['images'][subIndex]['image'],
                                                            noteImagePath: optionList[index]['selectedItem']['images'][subIndex]['imageFile'],
                                                          )
                                                      )
                                                  ).then((result) async {
                                                    if(result != null){
                                                      setState(() {
                                                        print(optionList[index]['selectedItem']);

                                                        optionList[index]['selectedItem']['images'][subIndex]['imageFile'] = result;
                                                      });
                                                    }
                                                  });
                                                },
                                                child: OpenNetworkCameraWidget(
                                                  networkImagePath: optionList[index]['selectedItem']['images'][subIndex]['image'],
                                                  isPhotoScreen: false,
                                                  noteImagePath: optionList[index]['selectedItem']['images'][subIndex]['imageFile'] == null
                                                      ? null
                                                      : optionList[index]['selectedItem']['images'][subIndex]['imageFile'],
                                                  photoDescription: optionList[index]['selectedItem']['images'][subIndex]['description'],
                                                  imageHeight: 48,
                                                  onDeleteClick: () async {
                                                    updateNewAnswer(optionList[index]['answers'][subIndex], index, subIndex);
                                                  },
                                                  onCameraClick: () async {
                                                    getImageFromCamera(index, subIndex);
                                                  },
                                                  onGalleryClick: (){
                                                    getImageFromGallery(index, subIndex);
                                                  },
                                                  onDescriptionCallback: (description){
                                                    setState(() {
                                                      if(description != null){
                                                        optionList[index]['selectedItem']['images'][subIndex]['description'] = description;
                                                      }
                                                    });
                                                  },
                                                ),
                                              ),
                                            )
                                              : Container(
                                              child: GestureDetector(
                                                onTap: (){
                                                  Navigator.push(
                                                      context,
                                                      SlideRightRoute(
                                                          page: ImageViewScreenPage(
                                                            imageFile: optionList[index]['selectedItem']['images'][subIndex]['image'],
                                                            noteImagePath: optionList[index]['selectedItem']['images'][subIndex]['imageFile'],
                                                          )
                                                      )
                                                  ).then((result) async {
                                                    if(result != null){
                                                      setState(() {
                                                        print(optionList[index]['selectedItem']);

                                                        optionList[index]['selectedItem']['images'][subIndex]['imageFile'] = result;
                                                      });
                                                    }
                                                  });
                                                },
                                                child: OpenCameraWidget(
                                                  imagePath: optionList[index]['selectedItem']['images'][subIndex]['image'],
                                                  isPhotoScreen: false,
                                                  noteImagePath: optionList[index]['selectedItem']['images'][subIndex]['imageFile'] == null
                                                      ? null
                                                      : optionList[index]['selectedItem']['images'][subIndex]['imageFile'],
                                                  photoDescription: optionList[index]['selectedItem']['images'][subIndex]['description'],
                                                  imageHeight: 48,
                                                  onDeleteClick: () async {
                                                    // checkQuestion(index, subIndex);
                                                    await dbHelper.deletePendingRequest(optionList[index]['selectedItem']['images'][subIndex]['imageid']);

                                                    setState(() {
                                                      optionList[index]['selectedItem']['images'].removeAt(subIndex);
                                                    });
                                                  },
                                                  onCameraClick: () async {
                                                    getImageFromCamera(index, subIndex);
                                                  },
                                                  onGalleryClick: (){
                                                    getImageFromGallery(index, subIndex);
                                                  },
                                                  onDescriptionCallback: (description){
                                                    setState(() {
                                                      if(description != null){
                                                        optionList[index]['selectedItem']['images'][subIndex]['description'] = description;
                                                      }
                                                    });
                                                  },
                                                ),
                                              ),
                                            );
                                          },
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
                isActive: isItemSelected,
                onNextButton: () async {

                  if(isItemSelected){
                    hazardList();
                  }
                },
                onBackButton: () async {
                  int inspectionIndex = await InspectionPreferences.getInspectionId(InspectionPreferences.INSPECTION_INDEX);
                  InspectionUtils.decrementIndex(inspectionIndex);
                  Navigator.pop(context);

                  // var db = DatabaseHelper.instance;
                  // await db.getCheckSingleSimpleList();
                },
              )
          ),

          _progressHUD
        ],
      ),
    );
  }

  Future getLocalOptionList() async {
    try {
      print("Opened");
      var optionId = inspectionData['answerscope']['simplelist'] ?? "";
      log("optionId===$optionId");
      if (optionId != "") {
        var response = await dbHelper.getSelectedSimpleList(optionId);

        if (response != null) {
          setState(() {
            optionList.clear();
            response = response.map((element) => Map<String, dynamic>.of(element)).toList();

            var transformedData = adjacencyTransform1(response);
            log("transformedData===$transformedData");
            // var localOptionList = transformedData['children'];

            optionList = transformedData['children'];
            List answeredList = [];
            for (int index = 0; index < optionList.length; index++) {
              optionList[index]['selectedItem'] = {};
              optionList[index]['answers'] = [];
              optionList[index]['isSelected'] = 0;
              imageList.clear();

              for(int i=0; i<answerDataList.length; i++) {
                if(answerDataList[i]['simplelistid'] == optionList[index]['simplelistid']) {

                  if(!answeredList.contains(optionList[index]['simplelistid'])) {
                    optionList[index]['selectedItem'] = {
                      "id": optionList[index]['simplelistid'],
                    };
                    optionList[index]['isSelected'] = optionList[index]['isSelected'] == 0 ? 1 : 0;
                  }

                  optionList[i]['answers'].add(answerDataList[i]);

                  var imagePath = "";
                  var imageid = answerDataList[i]['image']['imageid'] ?? "";

                  if(answerDataList[i]['image']['path'] != null) {
                    imagePath = "${GlobalInstance.apiBaseUrl}${answerDataList[i]['image']['path'].toString().substring(1)}";
                  }

                  imageList.add({
                    "image": imagePath,
                    "imageFile": null,
                    "description": answerDataList[i]['answer'] ?? "",
                    "imageid":imageid,
                    "isNetwork": true
                  });

                  optionList[index]['selectedItem']['images'] = json.decode(json.encode(imageList));

                  answeredList.add(optionList[index]['simplelistid']);
                  FocusScope.of(context).requestFocus(FocusNode());

                  // isSelectedNone =  optionList[index]['isSelected'] == 1;

                  isItemSelected = true;
                }
              }

              try{
                for(var localAnswer in localAnswerResult) {
                  if(localAnswer['simplelistid'] == optionList[index]['simplelistid']) {
                    if (!answeredList.contains(optionList[index]['simplelistid'])) {
                      optionList[index]['selectedItem'] = {
                        "id": optionList[index]['simplelistid'],
                      };
                      optionList[index]['isSelected'] =
                      optionList[index]['isSelected'] == 0 ? 1 : 0;
                    }

                    optionList[index]['answers'].add(localAnswer);

                    var imagePath = localAnswer['imagepath'];
                    var noteImagePath = localAnswer['imagefileurl'];
                    var imageid = localAnswer['imageid'] ?? 0;

                    imageList.add({
                      "image": imagePath,
                      "imageFile": noteImagePath == "null" ? null : File(noteImagePath),
                      "description": localAnswer['answer'] ?? "",
                      "imageid": imageid,
                      "isNetwork": false
                    });

                    optionList[index]['selectedItem']['images'] =
                        json.decode(json.encode(imageList));

                    answeredList.add(optionList[index]['simplelistid']);
                    FocusScope.of(context).requestFocus(FocusNode());

                    isItemSelected = true;
                  }
                }
              }catch(e) {
                log("StackTraceActual====$e");
              }
            }
          });
        }
      }
    } catch(e){
      log("StackTraceMap===$e");
    }
  }

  Future getOptionList() async {
    var optionId = inspectionData['answerscope']['simplelist'] ?? "";
    if(optionId != "") {
      _progressHUD.state.show();
      FocusScope.of(context).requestFocus(FocusNode());
      var response = await request.getAuthRequest("auth/simplelist/list/$optionId");

      _progressHUD.state.dismiss();
      if (response != null) {
        setState(() {
          var transformedData = adjacencyTransform(response);
          optionList = transformedData['children'];

          for(int i=0; i<optionList.length; i++){
            optionList[i]['selectedItem'] = {};
            optionList[i]['isSelected'] = 0;
          }
        });
      }
    }

    // _progressHUD.state.show();
    // FocusScope.of(context).requestFocus(FocusNode());
    // var response = await request.getAuthRequest("auth/simplelist/list/298");
    //
    // _progressHUD.state.dismiss();
    // if (response != null) {
    //   setState(() {
    //     optionList = response;
    //
    //     for(int i=0; i<optionList.length; i++){
    //       optionList[i]['selectedItem'] = {};
    //       optionList[i]['isSelected'] = 0;
    //     }
    //   });
    // }
  }

  Future hazardList() async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    print("hazardList");
    var response;
    for(int i=0; i<optionList.length; i++) {
      if(optionList[i]['isSelected'] == 1) {
        var simplelistid = "${optionList[i]['selectedItem']['id']}";
        var inspectionId = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ID);
        var vesselId = widget.inspectionData.containsKey('vesselid') ? widget.inspectionData['vesselid']?? null : null;
        var equipmentId = widget.inspectionData.containsKey('equipmentid') ? widget.inspectionData['equipmentid']?? null : null;

        var fetchOneRecord = await dbHelper.getMultiplePendingResult(inspectionId, widget.inspectionData['questionid'], simplelistid, vesselId, equipmentId);
        for(int i=0; i<fetchOneRecord.length; i++) {
          await dbHelper.deletePendingRequest(fetchOneRecord[i]["proxyid"]);
        }

        if(optionList[i]['selectedItem']['images'] != null) {
          // for(int k=0; k<optionList[i]['selectedItem']['images'].length; k++){
          //   response = await updateHazards(optionList[i]['selectedItem'], k);
          // }

          if(optionList[i]['selectedItem']['images'].length == 1) {
            response = await updatePendingQuestionDB(optionList[i]['selectedItem'], i, 0, 0);
            // response = await postHazards(optionList[i]['selectedItem'], i, 0);
          } else {
            for(int k=0; k<optionList[i]['selectedItem']['images'].length; k++){
              if(optionList[i]['selectedItem']['images'][k]['image'] != ""){
                response = await updatePendingQuestionDB(optionList[i]['selectedItem'], i, k, optionList[i]['selectedItem']['images'].length);
                // response = await postHazards(optionList[i]['selectedItem'], i, k);
              }
            }
          }
        } else {
          // response = await postHazards(optionList[i]['selectedItem'], i, 0);
          response = await updatePendingQuestionDB(optionList[i]['selectedItem'], i, 0, 0);
        }
      }
    }
    _progressHUD.state.dismiss();
    /*if (response != null) {
      if (response['success']!=null && !response['success']) {
          CustomToast.showToastMessage('${response['reason']}');
      } else {
        openNextScreen();
      }
    } else {
      CustomToast.showToastMessage('Something Went Wrong!!');
    }*/
    if (response != null) {
      openNextScreen();
    } else {
      CustomToast.showToastMessage('Something Went Wrong!!');
    }
  }

  Future updatePendingQuestionDB(hazardItem, index, subIndex, imageCount) async {
    var result;
    try {
      var answer = hazardItem['images'] == null ? "" : hazardItem['images'][subIndex]['description'] == null ? '' : hazardItem['images'][subIndex]['description'] == '' ? '' : hazardItem['images'][subIndex]['description'];
      var requestJson = {"answer": "$answer"};
      var simplelistid = "${hazardItem['id']}";
      var endPoint = "${widget.inspectionData['endpoint'].toString().replaceAll("{simplelistid}", "$simplelistid")}";
      var inspectionId = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ID);

      var vesselId = widget.inspectionData.containsKey('vesselid') ? widget.inspectionData['vesselid']?? null : null;
      var equipmentId = widget.inspectionData.containsKey('equipmentid') ? widget.inspectionData['equipmentid']?? null : null;
      var bodyOfWaterId = widget.inspectionData.containsKey('bodyofwaterid') ? widget.inspectionData['bodyofwaterid']?? null : null;

      var verb;
      var requestParamLocal;
      var imagePath;
      var noteImagePath;
      var imageId;

      if(hazardItem['images'] == null){
        verb = "POST";
        requestParamLocal = json.encode(requestJson);
      } else if(hazardItem['images'][subIndex]['image'] == ''){
        verb = "POST";
        requestParamLocal = json.encode(requestJson);
      } else {
        print("IMAGE_ID_DATA=====>>>>>${optionList[index]['selectedItem']['images'][subIndex]['imageid']}");
        verb = "MULTIPART";
        requestParamLocal = "$answer";
        imagePath = hazardItem['images'][subIndex]['image'];
        noteImagePath = hazardItem['images'][subIndex]['imageFile'];

        imageId = "${hazardItem['id']}_${index}_$subIndex";
      }

      result = await dbHelper.insertSingleMultiplePendingRecord({
        "url": "$endPoint",
        "verb": "$verb",
        "inspectionid": inspectionId,
        "simplelistid": simplelistid,
        "image_id": imageId,
        "equipmentid": equipmentId,
        "vesselid": vesselId,
        "bodyofwaterid": bodyOfWaterId,
        "inspectiondefid": widget.inspectionData['inspectiondefid'],
        "questionid": widget.inspectionData['questionid'],
        "payload": requestParamLocal,
        "imagepath": "$imagePath",
        "notaimagepath": noteImagePath != null ? '${noteImagePath.path}' : 'null'
      });
      print("Result ==== $result");

      if(hazardItem['images'] != null && hazardItem['images'][subIndex]['image'] != ''){
        setState(() {
          optionList[index]['selectedItem']['images'][subIndex]['imageid'] = result ?? 0;
        });
      }

      var answerData = {
        "proxyid": result,
        "inspectionid": inspectionId,
        "simplelistid": simplelistid,
        "image_id": 0,
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
      log("StackTraceUpdatemultiple====$e");
    }
    return result ?? 0;
  }

  void updateNewAnswer(answerData, index, subIndex) async {
    try{
      Map allPreviousData = await InspectionUtils.getPreviousData();

      var inspectionLocalId = allPreviousData['inspectionid'];
      var prevAnswersList = allPreviousData['answerlist'] ?? [];

      var prevSelectedEquipmentList = allPreviousData['equipmentlist'] ?? [];
      var waterBodiesTemplateData = allPreviousData['bodyofwaterlist'] ?? [];
      var childrenTemplateData = allPreviousData['inspectionDef'] ?? [];

      var pendingAnswer;
      if(answerData != null) {
        prevAnswersList.removeWhere((item) => item['answerid'] == answerData['answerid']);

        pendingAnswer = {
          "inspectionid": inspectionLocalId,
          "answerserverid": answerData['answerid'] ?? 0,
          "questionid": answerData['questionid'] ?? 0,
          "equipmentid": answerData['equipmentid'] ?? 0,
          "vesselid": answerData['vesselid'] ?? 0,
          "bodyofwaterid": answerData['bodyofwaterid'] ?? 0,
          "simplelistid": answerData['simplelistid'] ?? 0,
          "answer": answerData['answer'] ?? "",
          "imageurl": answerData['image'] == null ? "" : answerData['image']['path'] ?? "",
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

      setState(() {
        optionList[index]['answers'].removeAt(subIndex);
        optionList[index]['selectedItem']['images'].removeAt(subIndex);
        answerDataList.removeWhere((item) => item['answerid'] == answerData['answerid']);
      });

    } catch (e) {
      print("saveEvent Error ====$e");
    }
  }

  void deleteAllAnswers(simplelistid, index) async {
    try{
      Map allPreviousData = await InspectionUtils.getPreviousData();

      var inspectionLocalId = allPreviousData['inspectionid'];
      var prevAnswersList = allPreviousData['answerlist'] ?? [];

      var prevSelectedEquipmentList = allPreviousData['equipmentlist'] ?? [];
      var waterBodiesTemplateData = allPreviousData['bodyofwaterlist'] ?? [];
      var childrenTemplateData = allPreviousData['inspectionDef'] ?? [];

      for(var answerData in answerDataList) {
        if(answerData['simplelistid'] == simplelistid){
          prevAnswersList.removeWhere((item) => item['answerid'] == answerData['answerid']);

          var pendingAnswer = {
            "inspectionid": inspectionLocalId,
            "answerserverid": answerData['answerid'] ?? 0,
            "questionid": answerData['questionid'] ?? 0,
            "equipmentid": answerData['equipmentid'] ?? 0,
            "vesselid": answerData['vesselid'] ?? 0,
            "bodyofwaterid": answerData['bodyofwaterid'] ?? 0,
            "simplelistid": answerData['simplelistid'] ?? 0,
            "answer": answerData['answer'] ?? "",
            "imageurl": answerData['image'] == null ? "" : answerData['image']['path'] ?? "",
          };

          await dbHelper.insertRecordIntoDeleteTable(
            json.decode(json.encode(pendingAnswer)),
          );

          setState(() {
            answerDataList.removeWhere((item) => item['answerid'] == answerData['answerid']);
          });
        }
      }

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

      setState(() {
        optionList[index]['answers'].clear();
        optionList[index]['selectedItem']['images'].clear();
      });

    } catch (e) {
      print("saveEvent Error ====$e");
    }
  }

  void checkUpdateQuestion() async {
    var listItemData = await InspectionPreferences.getPreferenceData(InspectionPreferences.INSPECTION_DATA);
    var transformedData = json.decode(listItemData);
    int inspectionIndex = await InspectionPreferences.getInspectionId(InspectionPreferences.INSPECTION_INDEX);

    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var response;

    if(transformedData.length > inspectionIndex) {
      inspectionData = transformedData[inspectionIndex - 1];
      log("InspectionUpdatedData ==== ${inspectionData['answers']}");
      print("CheckUpdateQuestions");

      if (inspectionData['answers'].length > 0) {
        for (int j=0; j < optionList.length; j++) {
          for (int i = 0; i < inspectionData['answers'].length; i++) {
            if (optionList[j]['isSelected'] == 1
                && optionList[j]['selectedItem']['id'] != null
                && optionList[j]['selectedItem']['id'] != inspectionData['answers'][i]['simplelistid']) {

              print(optionList[j]['selectedItem']['id']);
              print(inspectionData['answers'][i]['simplelistid']);
              print("=======================");

              /*if(optionList[j]['selectedItem']['images'] != null) {
                if(optionList[j]['selectedItem']['images'].length == 1) {
                  response = await postHazards(optionList[j]['selectedItem'], i, 0);
                } else {
                  for(int k=0; k<optionList[i]['selectedItem']['images'].length; k++){
                    if(optionList[j]['selectedItem']['images'][k]['image'] != ""){
                      response = await postHazards(optionList[j]['selectedItem'], i, k);
                    }
                  }
                }
              } else {
                response = await postHazards(optionList[j]['selectedItem'], i, 0);
              }*/
              // break;
            }
          }
        }

        _progressHUD.state.dismiss();
        if (response != null) {
          if (response['success']!=null && !response['success']) {
            CustomToast.showToastMessage('${response['reason']}');
          } else {
            openNextScreen();
          }
        } else {
          CustomToast.showToastMessage('Something Went Wrong!!');
        }
      } else {
        openNextScreen();
      }
    }
  }

  void deleteSelectedSingleImageAnswer(index) async {
    var listItemData = await InspectionPreferences.getPreferenceData(InspectionPreferences.INSPECTION_DATA);
    var transformedData = json.decode(listItemData);
    int inspectionIndex = await InspectionPreferences.getInspectionId(InspectionPreferences.INSPECTION_INDEX);

    if(transformedData.length > inspectionIndex) {
      inspectionData = transformedData[inspectionIndex - 1];
      log("InspectionUpdatedData ==== ${inspectionData['answers']}");

      var answerId;
      var answerData;

      if(inspectionData['answers'].length > 0){
        for(int i=0; i<inspectionData['answers'].length; i++){
            if (optionList[index]['isSelected'] == 1 && optionList[index]['simplelistid'] == inspectionData['answers'][i]['simplelistid']) {
              answerId = inspectionData['answers'][i]['answerid'];
              answerData = inspectionData['answers'][i];

              deletePreviousAnswer(index, -1, answerId, answerData);
            }
        }
      }
    }
  }

  void deleteSelectedAnswer(index) async {
    var listItemData = await InspectionPreferences.getPreferenceData(InspectionPreferences.INSPECTION_DATA);
    var transformedData = json.decode(listItemData);
    int inspectionIndex = await InspectionPreferences.getInspectionId(InspectionPreferences.INSPECTION_INDEX);

    if(transformedData.length > inspectionIndex) {
      inspectionData = transformedData[inspectionIndex - 1];
      log("InspectionUpdatedData ==== ${inspectionData['answers']}");

      var answerId;
      var answerData;

      if(inspectionData['answers'].length > 0){
        for(int i=0; i<inspectionData['answers'].length; i++){
          for(int j=0; j<optionList.length; j++) {
            if (optionList[j]['isSelected'] == 1 && optionList[j]['simplelistid'] == inspectionData['answers'][i]['simplelistid']) {
              answerId = inspectionData['answers'][i]['answerid'];
              answerData = inspectionData['answers'][i];

              deletePreviousAnswer(index, -1, answerId, answerData);
            }
          }
        }
      }
    }
  }

  void checkQuestion(index, subIndex) async {
    var listItemData = await InspectionPreferences.getPreferenceData(InspectionPreferences.INSPECTION_DATA);
    var transformedData = json.decode(listItemData);
    int inspectionIndex = await InspectionPreferences.getInspectionId(InspectionPreferences.INSPECTION_INDEX);
    print("checkQuestion");

    if(transformedData.length > inspectionIndex) {
      inspectionData = transformedData[inspectionIndex-1];
      log("InspectionUpdatedData ==== ${inspectionData['answers']}");

      if(inspectionData['answers'].length > 0){
        bool isAnswer;
        var answerId;
        var answerData;
        for(int i=0; i<inspectionData['answers'].length; i++){
          for(int j=0; j<optionList.length; j++) {
            if (optionList[j]['isSelected'] == 1
                && optionList[j]['simplelistid'] == inspectionData['answers'][i]['simplelistid']) {
              isAnswer = true;
              answerId = inspectionData['answers'][i]['answerid'];
              answerData = inspectionData['answers'][i];
              break;
            }
          }
          if(isAnswer)
            break;
        }

        if(isAnswer) {
          deletePreviousAnswer(index, subIndex, answerId, answerData);
        }
      } else {
        setState(() {
          optionList[index]['selectedItem']['images'].removeAt(subIndex);
        });
      }
    }
  }

  Future postHazards(hazardItem, index, subIndex) async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var answer = hazardItem['images'] == null ? "" : hazardItem['images'][subIndex]['description'] == null ? '' : hazardItem['images'][subIndex]['description'] == '' ? '' : hazardItem['images'][subIndex]['description'];
    var requestJson = {"answer": "$answer"};
    var simplelistid = "${hazardItem['id']}";

    var requestParam = json.encode(requestJson);
    var response;
    if(hazardItem['images'] == null){
      response = await request.postRequest(
          "${widget.inspectionData['endpoint'].toString().replaceAll("{simplelistid}", "$simplelistid")}",
          requestParam
      );
    } else if(hazardItem['images'][subIndex]['image'] == ''){
      response = await request.postRequest(
          "${widget.inspectionData['endpoint'].toString().replaceAll("{simplelistid}", "$simplelistid")}",
          requestParam
      );
    } else {
      response = await request.uploadMultipartImage(
          "${widget.inspectionData['endpoint'].toString().replaceAll("{simplelistid}", "$simplelistid")}",
          hazardItem['images'][subIndex]['image'],
          hazardItem['images'][subIndex]['imageFile'],
          "$answer"
      );
    }
    _progressHUD.state.dismiss();

    log("Response==Index==$subIndex==$response");
    if(response != null){
      if(response['image'] != null){
        setState(() {
          optionList[index]['selectedItem']['images'][subIndex]['imageid'] = response['image']['imageid'] ?? 0;
        });
      }
      var result = await HelperClass.openUnroll(response);
      if(result) {
        return response;
      } else {
        return null;
      }
    }
    return null;
  }

  Future updateHazards(answerId, hazardItem, index, subIndex) async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var answer = hazardItem['images'] == null ? "" : hazardItem['images'][subIndex]['description'] == null ? '' : hazardItem['images'][subIndex]['description'] == '' ? '' : hazardItem['images'][subIndex]['description'];
    var requestJson = {"answer": "$answer"};
    var simplelistid = "${hazardItem['id']}";

    var requestParam = json.encode(requestJson);
    var response;
    var endPoint = "${widget.inspectionData['endpoint'].toString().replaceAll("{simplelistid}", "$simplelistid")}";
    if(hazardItem['images'] == null){
      response = await request.postRequest(
          endPoint,
          requestParam
      );
    } else if(hazardItem['images'][subIndex]['image'] == ''){
      response = await request.postRequest(
          endPoint,
          requestParam
      );
    } else {
      response = await request.uploadMultipartImage(
          endPoint,
          hazardItem['images'][subIndex]['image'],
          hazardItem['images'][subIndex]['imageFile'],
          "$answer"
      );
    }
    _progressHUD.state.dismiss();

    log("Response==Index==$subIndex==$response");
    if(response != null){
      if(response['image'] != null){
        setState(() {
          optionList[index]['selectedItem']['images'][subIndex]['imageid'] = response['image']['imageid'] ?? 0;
        });
      }
    }
    var result = await HelperClass.openUnroll(response);
    if(result) {
      return response;
    } else {
      return null;
    }
  }

  void deletePreviousAnswer(index, subIndex, answerId, answerData) async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var inspectionId = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ID);

    var response = await request.deleteAnswerRequest(
      "auth/inspection/$inspectionId/answer/$answerId",
    );

    _progressHUD.state.dismiss();
    if(response != null){
        setState(() {
          if(subIndex != -1) {
            optionList[index]['selectedItem']['images'].removeAt(subIndex);
          }
        });

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
        HelperClass.openUnroll(response);
    } else {
      CustomToast.showDottieToast('${response['reason']}');
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
    try{
      int ix=0;
      void build (Map<String, dynamic> container) {

        container["children"]=[];
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
    }catch(e) {
      log("StackTraceAdjacencyMultiple====$e");
    }

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
          ).then((result) {
            setState(() {
              isAnsweredChanged = true;
            });
          });
        }
      }
    }
  }

  void displayOptionDeleteDialog(context, simplelistid, index) {
    print("show loading call");
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: isDarkMode ? Color(0xff000000).withOpacity(0.8) : Color(0xff000000).withOpacity(0.5),
      builder: (BuildContext loadingContext) {
        return Container(
          height: 500,
          margin: EdgeInsets.only(top: 50, bottom: 30),
          child: Dialog(
            backgroundColor: isDarkMode ? Color(0xffF2F2F2).withOpacity(0.8) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32)),
            ),
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Text(
                    'Are you sure?',
                    style: TextStyle(
                      fontSize: TextSize.headerText,
                      color: AppColor.BLACK_COLOR,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                  child: Text(
                    'Do you want to change the option, it will remove your previous selection',
                    style: TextStyle(
                        fontSize: 15,
                        color: AppColor.BLACK_COLOR,
                        fontWeight: FontWeight.w400,
                        height: 1.5
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 16,),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xC7252525),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 44.0,
                            alignment: Alignment.center,
                            child: Text(
                              'NO',
                              style: TextStyle(
                                fontSize: 17,
                                color: AppColor.BLACK_COLOR,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 44,
                        child: VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: Color(0xC7252525),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: (){
                            Navigator.pop(context);
                            deleteAllAnswers(simplelistid, index);
                          },
                          child: Container(
                            height: 44.0,
                            alignment: Alignment.center,
                            child: Text(
                              'YES',
                              style: TextStyle(
                                fontSize: 17,
                                color: AppColor.BLACK_COLOR,
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
        );
      },
    );
  }
}
