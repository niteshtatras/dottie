import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dottie_inspector/database/database_helper.dart';
import 'package:dottie_inspector/inspectionPreferences/inspection_preferences.dart';
import 'package:dottie_inspector/pages/dynamicInspection/dynamic_complete_inspection_screen.dart';
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
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_hud/progress_hud.dart';

import 'dynamic_general_page.dart';

class DynamicSingleSelectionPage extends StatefulWidget {
  final inspectionData;
  final lastIndex;

  const DynamicSingleSelectionPage({Key key, this.inspectionData, this.lastIndex}) : super(key: key);
  @override
  _DynamicSingleSelectionPageState createState() => _DynamicSingleSelectionPageState();
}

class _DynamicSingleSelectionPageState extends State<DynamicSingleSelectionPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final dbHelper = DatabaseHelper.instance;

  int selectedIndex = -1;
  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;
  var elevation = 0.0;
  final _scrollController = ScrollController();
  var answerId = "";
  int previousAnswer = 0;
  bool isAnswerChange = false;
  bool isAnsweredChanged = false;
  bool isSelectedNone = false;
  var dynamicData;
  var imagePath;
  var dynamicMainData;
  var questionId = "0";
  List optionList = [];
  List imageList = [];
  // List<Map> itemSelected = [];
  var inspectionItem;
  var inspectionData;
  var optionId;
  bool isOptionIconPresent = false;
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
      dynamicMainData = widget.inspectionData;
      dynamicData = dynamicMainData['txt'][lang] ?? dynamicMainData['txt']['en'];
      questionId = "${dynamicMainData['questionid']}";
      optionId = dynamicMainData['answerscope']['simplelist'] ?? "";

      answerDataList = inspectionData['answers'] ?? [];

      sectionName = HelperClass.getSectionText(inspectionData);
      if(widget.lastIndex != null){
        if(widget.lastIndex == inspectionIndex) {
          completeButtonName = "Complete";
        }
      }
    });
    JsonEncoder encoder = JsonEncoder.withIndent('  ');
    log("InspectionData===>>>>${encoder.convert(inspectionData)}");
    print("Solve");

    // _connectivity.initialise();
    // print("Soleve123");
    // _connectivity.myStream.listen((source) {
    //   print("Soleve343");
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
    //
    // Timer(Duration(milliseconds: 100), getOptionList);
    initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

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

  void getPreferenceData() async {
    var preferenceData = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ITEM);
    var inspectionData = json.decode(preferenceData);

    setState(() {
      inspectionItem = inspectionData;

      print(inspectionItem);
    });
    getInspectionData();
  }

  ImagePicker _imagePicker = ImagePicker();
  Future getImageFromCamera(index, subIndex) async {
    var image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      openCropImageOption(image.path, index, subIndex);
    }
  }

  Future getImageFromGallery(index, subIndex) async {
    var image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      openCropImageOption(image.path, index, subIndex);
    }
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

        print("imagePath====>>>>$imagePath");
        Map itemData = {
          "image": "",
          "imageFile": null,
          "description": "",
          "imageid":0,
          "isNetwork": false
        };

        optionList[index]['selectedItem']['images'].add(json.decode(json.encode(itemData)));
        compressedFile = null;
      });

      // var imageData = await GallerySaver.saveImage(imagePath, albumName: "Dottie");
      // print("SaveImage=====$imageData");
    }
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
            _scaffoldKey.currentState.openDrawer();
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
                         onTap: () async {
                           _scaffoldKey.currentState.openDrawer();
                           // HelperClass.printDatabaseResult();
                          // _progressHUD.state.dismiss();
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
                        SizedBox(height: 10.0,),
                        sectionName != null && sectionName != ""
                            ? Container(
                          margin: EdgeInsets.only(left: 24.0,right: 24.0, bottom: 0),
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
                          margin: EdgeInsets.symmetric(horizontal: 24.0,vertical: 8),
                          child: Text(

                            dynamicData != null
                                ? dynamicData['title'] ?? ""
                                : "",
                            style: TextStyle(
                                fontSize: TextSize.pageTitleText,
                                color: themeColor,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,),
                          ),
                        ),
                        SizedBox(height: 24.0,),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16.0),
                          child: ListView.builder(
                            itemCount: optionList != null ? optionList.length : 0,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index){
                              var answerScope = dynamicMainData['answerscope']['photoif'] != null
                                                ? dynamicMainData['answerscope']['photoif']
                                                : [];

                              return GestureDetector(
                                onTap: () async {
                                  if(selectedIndex != -1) {
                                    if(optionList[index]['answers'].length > 0){
                                      displayDeleteOptionDialog(context, optionList[index]['simplelistid'], index);
                                    } else {
                                      var inspectionId = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ID);
                                      var questionId = widget.inspectionData['questionid'];
                                      var simplelistid = optionList[index]['simplelistid'];
                                      var vesselId = widget.inspectionData.containsKey('vesselid') ? widget.inspectionData['vesselid']?? null : null;
                                      var equipmentId = widget.inspectionData.containsKey('equipmentid') ? widget.inspectionData['equipmentid']?? null : null;

                                      var record = await dbHelper.getSinglePendingResult(inspectionId, questionId, vesselId, equipmentId);
                                      if(record != null && record.length > 0) {
                                        for(int i=0; i<record.length; i++) {
                                          await dbHelper.deletePendingRequest(record[i]['proxyid']);
                                        }
                                      }
                                    }
                                  }
                                  setState(() {
                                    selectedIndex = index;
                                    // isAnswerChange = previousAnswer != (optionList[index]['simplelistid']);
                                    for(int i=0; i<optionList.length; i++) {
                                      if(index == selectedIndex) {
                                        imageList.clear();
                                        imageList.add({
                                          "image": "",
                                          "imageFile": null,
                                          "description": "",
                                          "imageid":0,
                                          "isNetwork": true
                                        });
                                        optionList[index]['selectedItem']['images'] = json.decode(json.encode(imageList));
                                      } else {
                                        imageList.clear();
                                        optionList[index]['selectedItem'] = {};
                                      }
                                    }
                                    // selectedIndex = index;
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
                                          Visibility(
                                            visible: isOptionIconPresent,
                                            child: optionList[index]['svgicon'] == null
                                                ? Container(
                                              padding: EdgeInsets.all(12.0),
                                              decoration: BoxDecoration(
                                                  color: AppColor.BACKGROUND_COLOR.withOpacity(0.12),
                                                  borderRadius: BorderRadius.circular(24)
                                              ),
                                              child: Image.asset(
                                                "assets/ic_pool.png",
                                                width: 24.0,
                                                height: 24.0,
                                              ),
                                            )
                                                : Container(
                                              padding: EdgeInsets.all(12.0),
                                              decoration: BoxDecoration(
                                                  color: AppColor.BACKGROUND_COLOR.withOpacity(0.12),
                                                  borderRadius: BorderRadius.circular(24)
                                              ),
                                              child: SvgPicture.string('${optionList[index]['svgicon'].toString()}'),
                                              height: 48.0,
                                              width: 48.0,
                                            ),
                                          ),
                                          Visibility(
                                            visible: isOptionIconPresent,
                                            child: SizedBox(width: 16.0,)
                                          ),

                                          Expanded(
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                  minHeight: 40
                                              ),
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                padding: EdgeInsets.only(right: 8.0),
                                                child: Text(
                                                  optionList[index]['label'][lang] == null
                                                      ? optionList[index]['label']['en'].toString().replaceAll("@@", "\"").replaceAll("##", "\'")
                                                      : optionList[index]['label'][lang].toString().replaceAll("@@", "\"").replaceAll("##", "\'"),
                                                  style: TextStyle(
                                                      color: !isSelectedNone
                                                          ? themeColor
                                                          : selectedIndex == index && index == 0
                                                          ? themeColor
                                                          : AppColor.TYPE_PRIMARY.withOpacity(0.60),
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
                                              selectedIndex == index
                                                  ? 'assets/complete_inspection/ic_check_icon.png'
                                                  : 'assets/complete_inspection/ic_unchecked_icon.png',
                                              height: 150,
                                              width: 150,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                         /* Container(
                                            margin: EdgeInsets.only(left: 8.0),
                                            height: 48.0,
                                            width: 48.0,
                                            decoration: BoxDecoration(
                                                color: selectedIndex == index ? AppColor.THEME_PRIMARY.withOpacity(0.12) : AppColor.TYPE_PRIMARY.withOpacity(0.08),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: isSelectedNone
                                                      ? AppColor.TYPE_PRIMARY.withOpacity(0.12)
                                                      : selectedIndex == index
                                                      ? AppColor.TRANSPARENT
                                                      : AppColor.TYPE_PRIMARY.withOpacity(0.6),
                                                  width: 1.0,
                                                )
                                            ),
                                            child: Icon(
                                              Icons.done,
                                              size: 24.0,
                                              color: selectedIndex == index ? AppColor.THEME_PRIMARY : AppColor.TRANSPARENT,
                                            ),
                                          ),*/
                                        ],
                                      ),

                                      Visibility(
                                        visible: answerScope.contains(optionList[index]['simplelistid'])
                                                && selectedIndex == index,
                                        child: ListView.builder(
                                          itemCount: optionList[index]['selectedItem']['images'] != null
                                              ? optionList[index]['selectedItem']['images'].length
                                              : 0,
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, subIndex){
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
                                                        optionList[index]['selectedItem']['images'][subIndex]['imageFile'] = result;
                                                      });
                                                    }
                                                  });
                                                },
                                                child: OpenCameraWidget(
                                                  imagePath: optionList[index]['selectedItem']['images'][subIndex]['image'],
                                                  isPhotoScreen: false,
                                                  imageHeight: 48,
                                                  noteImagePath: optionList[index]['selectedItem']['images'][subIndex]['imageFile'] == null
                                                      ? null
                                                      : optionList[index]['selectedItem']['images'][subIndex]['imageFile'],
                                                  photoDescription: optionList[index]['selectedItem']['images'][subIndex]['description'],
                                                  onDeleteClick: () async {
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
            // Submit
            Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: BottomButtonWidget(
                  buttonName: "$completeButtonName",
                  isActive: selectedIndex != -1,
                  onNextButton: () async {
//                    openNextScreen();
                    if(selectedIndex != -1){
                      /*updatePoolMaterial();
                      if(answerId == '' && previousAnswer == 0) {
                        updatePoolMaterial();
                      } else if(isAnswerChange){
                        deletePreviousAnswer();
                      } else {
                        Navigator.push(
                            context,
                            SlideRightRoute(
                                page: PoolTripHazardPage()
                            )
                        );
                      }*/
                      // openNextScreen();
                      /*if(isAnsweredChanged) {
                        openNextScreen();
                      } else {
                        hazardList();
                      }*/
                      hazardList();
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

  Future getLocalOptionList() async {
    var optionId = inspectionData['answerscope']['simplelist'] ?? "";
    log("Hello===$optionId");
    if(optionId != "") {
      var response = await dbHelper.getSelectedSimpleList(optionId);
      if (response != null) {
        setState(() {
          optionList.clear();
          response = response.map((element) => Map<String, dynamic>.of(element)).toList();

          var transformedData = adjacencyTransform1(response);
          log("transformedData====$transformedData");
          optionList = transformedData['children'];
          // var answerData = answerDataList.length > 0 ? answerDataList[0] : null;


          for (int i = 0; i < optionList.length; i++) {
            imageList.clear();
            optionList[i]['selectedItem'] = {};
            optionList[i]['answers'] = [];
            for(var answerData in answerDataList) {
              List answeredList = [];
              if (answerData != null && answerData['simplelistid'] == optionList[i]['simplelistid']) {
                if(!answeredList.contains(optionList[i]['simplelistid'])) {
                  selectedIndex = i;
                }
                optionList[i]['answers'].add(answerData);

                var imagePath = "";
                var imageid = answerData['image']['imageid'] ?? "";

                if(answerData['image']['path'] != null) {
                  imagePath = "${GlobalInstance.apiBaseUrl}${answerData['image']['path'].toString().substring(1)}";
                }

                imageList.add({
                  "image": imagePath,
                  "imageFile": null,
                  "description": answerData['answer'] ?? "",
                  "imageid": imageid,
                  "isNetwork": true
                });

                optionList[selectedIndex]['selectedItem']['images'] = json.decode(json.encode(imageList));
                answeredList.add(optionList[i]['simplelistid']);
              }
            }

            try{
              for(var localAnswer in localAnswerResult) {
                List answeredList = [];
                if (localAnswer != null && localAnswer['simplelistid'] == optionList[i]['simplelistid']) {
                  if(!answeredList.contains(optionList[i]['simplelistid'])) {
                    selectedIndex = i;
                  }
                  optionList[i]['answers'].add(localAnswer);

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

                  optionList[selectedIndex]['selectedItem']['images'] = json.decode(json.encode(imageList));
                  answeredList.add(optionList[i]['simplelistid']);
                }
              }
            }catch(e) {
              log("StackTrace====$e");
            }

          }
        });
      }
    }
  }

  Future getOptionList() async {
    log("Hello");
    var optionId = dynamicMainData['answerscope']['simplelist'] ?? "";
    log("Hello ===$optionId");
    if(optionId != "") {
      _progressHUD.state.show();
      FocusScope.of(context).requestFocus(FocusNode());
      var response = await request.getAuthRequest("auth/simplelist/list/$optionId");

      print(response);
      _progressHUD.state.dismiss();
      if (response != null) {
        log("RESPONSE====$response");
        log("RESPONSE_TYPE====${response.runtimeType}");

        setState(() {
          var transformedData = adjacencyTransform(response);
          optionList = transformedData['children'];

          for (int i = 0; i < optionList.length; i++) {
            optionList[i]['selectedItem'] = {};

            if (optionList[i]['svgicon'] != null) {
              isOptionIconPresent = true;
            }
          }
        });
      }
    }
  }

  Future hazardList() async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    print("hazardList");
    var response;
    var simplelistid = "${optionList[selectedIndex]['simplelistid']}";
    var inspectionId = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ID);
    var vesselId = widget.inspectionData.containsKey('vesselid') ? widget.inspectionData['vesselid']?? null : null;
    var equipmentId = widget.inspectionData.containsKey('equipmentid') ? widget.inspectionData['equipmentid']?? null : null;

    log("EQUIPMENT_ID===$equipmentId, QuestionId===${widget.inspectionData['questionid']}, VesselId===$vesselId, SimpleListId====$simplelistid, InspectionId===$inspectionId");
    var fetchOneRecord = await dbHelper.getSinglePendingResult(
        inspectionId,
        widget.inspectionData['questionid'],
        vesselId,
        equipmentId
    );

    log("FetchRecord====$fetchOneRecord");
    for(int i=0; i<fetchOneRecord.length; i++) {
      await dbHelper.deletePendingRequest(fetchOneRecord[i]["proxyid"]);
    }

    if(optionList[selectedIndex]['images'] != null) {
      if(optionList[selectedIndex]['selectedItem']['images'].length == 1) {
        // response = await postSingleAnswerQuestions(optionList[selectedIndex]['selectedItem'], selectedIndex, 0);
        response = await updatePendingQuestionDB(optionList[selectedIndex]['selectedItem'], selectedIndex, 0);
      } else {
        for(int k=0; k<optionList[selectedIndex]['selectedItem']['images'].length; k++){
          if(optionList[selectedIndex]['selectedItem']['images'][k]['image'] != ""){
            // response = await postSingleAnswerQuestions(optionList[selectedIndex]['selectedItem'], selectedIndex, k);
            response = await updatePendingQuestionDB(optionList[selectedIndex]['selectedItem'], selectedIndex, k);
          }
        }
      }
    } else {
      // response = await postSingleAnswerQuestions(optionList[selectedIndex]['selectedItem'], selectedIndex, 0);
      response = await updatePendingQuestionDB(optionList[selectedIndex]['selectedItem'], selectedIndex, 0);
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

  Future updatePendingQuestionDB(hazardItem, index , subIndex) async {
    var result;
    try {
      var simplelistid = optionList[selectedIndex]['simplelistid'];
      var endPoint = "${widget.inspectionData['endpoint'].toString().replaceAll("{simplelistid}", "$simplelistid")}";
      var answer = hazardItem['images'] == null ? "" : hazardItem['images'][subIndex]['description'] == null ? '' : hazardItem['images'][subIndex]['description'] == '' ? '' : hazardItem['images'][subIndex]['description'];
      var requestJson = {"answer": "$answer"};
      var inspectionId = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ID);

      var vesselId = widget.inspectionData.containsKey('vesselid') ? widget.inspectionData['vesselid']?? null : null;
      var equipmentId = widget.inspectionData.containsKey('equipmentid') ? widget.inspectionData['equipmentid']?? null : null;
      var bodyOfWaterId = widget.inspectionData.containsKey('bodyofwaterid') ? widget.inspectionData['bodyofwaterid']?? null : null;

      var verb;
      var requestParamLocal;
      var imagePath;
      var noteImagePath;
      var imageId = 0;

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
        imageId = optionList[index]['selectedItem']['images'][subIndex]['imageid'] ?? 0;
      }

      result = await dbHelper.insertSingleMultiplePendingRecord({
        "url": '$endPoint',
        "verb": '$verb',
        "inspectionid": inspectionId,
        "simplelistid": simplelistid,
        "image_id": imageId,
        "equipmentid": equipmentId,
        "vesselid": vesselId,
        "bodyofwaterid": bodyOfWaterId,
        "inspectiondefid": widget.inspectionData['inspectiondefid'],
        "questionid": widget.inspectionData['questionid'],
        "payload": requestParamLocal,
        "imagepath": '$imagePath',
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

      setState(() {
        optionList[index]['answers'].add(answerData);
      });

    } catch (e){
      log("StackTraceUpdatePending====$e");
    }
    return result;
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

  Future postSingleAnswerQuestions(hazardItem, index , subIndex) async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var answer = hazardItem['images'] == null ? "" : hazardItem['images'][subIndex]['description'] == null ? '' : hazardItem['images'][subIndex]['description'] == '' ? '' : hazardItem['images'][subIndex]['description'];
    var requestJson = {"answer": "$answer"};

    var simplelistid = optionList[selectedIndex]['simplelistid'];
    var endPoint = "${widget.inspectionData['endpoint'].toString().replaceAll("{simplelistid}", "$simplelistid")}";
    var response;

    var requestParam = json.encode(requestJson);
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

    if (response != null) {
      if (response['success']!=null && !response['success']) {
          CustomToast.showToastMessage('${response['reason']}');
      } else {
        if(response['image'] != null){
          log("Response======>>>>$response");
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
    } else {
      CustomToast.showToastMessage('Something went wrong!!!');
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
          if (selectedIndex == index && optionList[selectedIndex]['simplelistid'] == inspectionData['answers'][i]['simplelistid']) {
            answerId = inspectionData['answers'][i]['answerid'];
            answerData = inspectionData['answers'][i];

            deletePreviousAnswer(selectedIndex, -1, answerId, answerData);
          }
        }
      }
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
      log("StackTraceAdjacency====$e");
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

  void displayDeleteOptionDialog(context, simplelistid, index) {
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
