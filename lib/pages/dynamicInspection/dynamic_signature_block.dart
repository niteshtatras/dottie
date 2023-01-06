import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dottie_inspector/database/database_helper.dart';
import 'package:dottie_inspector/inspectionPreferences/inspection_preferences.dart';
import 'package:dottie_inspector/pages/dynamicInspection/signature_screen.dart';
import 'package:dottie_inspector/pages/menu/drawer_page.dart';
import 'package:dottie_inspector/pages/menu/index_menu.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/SlideRightRoute.dart';
import 'package:dottie_inspector/utils/custom_toast.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:dottie_inspector/widget/dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_hud/progress_hud.dart';

import 'dynamic_complete_inspection_screen.dart';

class DynamicSignaturePage extends StatefulWidget {
  final inspectionData;
  final lastIndex;

  const DynamicSignaturePage({Key key, this.inspectionData, this.lastIndex}) : super(key: key);

  @override
  _DynamicSignaturePageState createState() => _DynamicSignaturePageState();
}

class _DynamicSignaturePageState extends State<DynamicSignaturePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSignatureAvail = false;
  var imagePath = '';
  ValueNotifier<ByteData> rawImage = ValueNotifier<ByteData>(null);
  ByteData imgData;
  var inspectionData;
  final dbHelper = DatabaseHelper.instance;

  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;
  var inspectionItem;
  var dynamicData;
  var sectionName;

  var completeButtonName = "Next";
  var answerDataList = [];

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

    setState(() {
      inspectionData = widget.inspectionData;
      dynamicData = inspectionData['txt'][lang] ?? inspectionData['txt']['en'];
      sectionName = HelperClass.getSectionText(inspectionData);

      if(widget.lastIndex != null){
        if(widget.lastIndex == inspectionIndex) {
          completeButtonName = "Complete";
        }
      }
    });
  }

  Future getImageFromCamera() async {
    var image1 = await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 60);
    if (image1 != null) {
      setState(() {
        isSignatureAvail = true;
        imagePath = image1.path;
      });
    }
  }

  ImagePicker _imagePicker = ImagePicker();
  Future getImageFromGallery() async {
    var image1 = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 60 );
    if (image1 != null) {
      setState(() {
        isSignatureAvail = true;
        imagePath = image1.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode ? AppColor.BLACK_COLOR : AppColor.PAGE_COLOR,
     appBar: EmptyAppBar(isDarkMode: isDarkMode),
     /* appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: AppColor.PAGE_COLOR,
        leading: GestureDetector(
          onTap: (){
            _scaffoldKey.currentState.openDrawer();
//            HelperClass.launchDetail(context, DynamicSignaturePage());
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
                          margin: EdgeInsets.symmetric(horizontal: 16.0,vertical: 8.0),
                          child: Text(
                            dynamicData != null
                                ? dynamicData['title'] ?? ""
                                : "",
                            style: TextStyle(
                                fontSize: TextSize.greetingTitleText,
                                color: themeColor,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                                height: 1.3
                            ),
                          ),
                        ),

                        dynamicData['helpertext'] != null
                            ? Container(
                          margin: EdgeInsets.symmetric(horizontal: 16.0,vertical: 8.0),
                          child: Text(
                            dynamicData != null
                                ? dynamicData['helpertext'] ?? ""
                                : "",
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

                        SizedBox(height: 24.0,),

                        isSignatureAvail
                        ? Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                        color: AppColor.WHITE_COLOR,
                                        borderRadius: BorderRadius.circular(16.0)
                                    ),
                                    margin: EdgeInsets.all(16.0),
                                    child: DottedBorder(
                                        radius: Radius.circular(16.0),
                                        borderType: BorderType.RRect,
                                        strokeWidth: 3.0,
                                        strokeCap: StrokeCap.square,
                                        dashPattern: [5,8],
                                        padding: EdgeInsets.all(16),
                                        child: Container(
                                          color: AppColor.WHITE_COLOR,
                                          height: 160.0,
                                          width: MediaQuery.of(context).size.width,
//                                    margin: EdgeInsets.symmetric(horizontal: 16.0),
                                          /*child: Icon(
                                            FontAwesomeIcons.signature
                                          )*/
                                          child: Container(
                                            padding: EdgeInsets.all(1),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(16.0),
                                              child: Image.file(
                                                File(imagePath),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        )
                                    ),
                                  ),
                                  Positioned(
                                    top: 32.0,
                                    right: 28.0,
                                    child: GestureDetector(
                                      onTap: (){
                                        setState(() {
                                          isSignatureAvail = false;
                                          imagePath = '';
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(12.0),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(40.0),
                                          color: AppColor.RED_COLOR,
                                        ),
                                        child: Image.asset(
                                          'assets/ic_delete.png',
                                          fit: BoxFit.contain,
                                          color: AppColor.WHITE_COLOR,
                                          height: 24.0,
                                          width: 24.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                        : Container(
                          margin: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              //Add Signature
                              Theme(
                                data: ThemeData(
                                    splashColor: AppColor.TRANSPARENT,
                                    highlightColor: AppColor.TRANSPARENT
                                ),
                                child: GestureDetector(
                                  onTap: (){
                                    Navigator.push(
                                      context,
                                      SlideRightRoute(
                                        page: SignatureScreen()
                                      )
                                    ).then((result) async {
                                      SystemChrome.setPreferredOrientations([
                                        DeviceOrientation.portraitDown,
                                        DeviceOrientation.portraitUp
                                      ]);
                                      if(result != null){
                                        if(result['image'] != null){
                                          var imgData1 = result['image'];
                                          File imageFile = await HelperClass.getFile(imgData1, "Signature.jpg");
                                          setState(() {
                                            isSignatureAvail = true;
                                            imgData = result['image'];
                                            imagePath = imageFile.path;
                                            imageFile = null;
                                          });
                                        }
                                      }
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 8.0),
                                    padding: EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? Color(0xff1F1F1F)
                                          : AppColor.WHITE_COLOR,
                                      borderRadius: BorderRadius.circular(32.0),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(12.0),
                                          child: Icon(
                                            Icons.done,
                                            size: 24.0,
                                            color: AppColor.THEME_PRIMARY
                                          )
                                        ),
                                        SizedBox(width: 16.0,),
                                        Expanded(
                                          child: Text(
                                            'Add your signature',
                                            style: TextStyle(
                                                color: themeColor,
                                                fontSize: TextSize.headerText,
                                                fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 16.0,),
                                        Icon(Icons.keyboard_arrow_right, size: 24.0, color: themeColor.withOpacity(0.6),)
                                      ],
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

          //Submit
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              height: 64.0,
              margin: EdgeInsets.only(left: 48.0, right: 48.0, bottom: 34.0, top: 12.0),
              decoration: BoxDecoration(
                  color: isDarkMode
                      ? Color(0xff333333)
                      : AppColor.BLACK_COLOR,
                  borderRadius: BorderRadius.all(Radius.circular(32.0))
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 24.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Back',
                          style: TextStyle(
                            color: AppColor.WHITE_COLOR,
                            fontSize: TextSize.subjectTitle,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: (){
                        if(imagePath != '') {
                          updatePendingQuestionDB();
                        }
                      },
                      child: Container(
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(right: 24.0),
                        child: Text(
                          '$completeButtonName',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSignatureAvail ? AppColor.WHITE_COLOR : AppColor.WHITE_COLOR.withOpacity(0.24),
                            fontSize: TextSize.subjectTitle,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          _progressHUD
        ],
      ),
    );
  }

  void bottomNavigation(context){
    showModalBottomSheet(
        context: context,
        barrierColor: isDarkMode ? Color(0xff000000).withOpacity(0.8) : Color(0xff000000).withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        backgroundColor: Colors.white,
        isDismissible: false,
        builder: (context){
          return StatefulBuilder(
            builder: (context1, myState){
              return SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                          getImageFromCamera();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(top: 24.0, bottom: 16.0),
                          child: Text(
                            'Take Photo',
                            style: TextStyle(
                                fontSize: TextSize.headerText,
                                color: themeColor,
                                fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Divider(
                        thickness: 1.0,
                        color: AppColor.DIVIDER,
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                          getImageFromGallery();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                          child: Text(
                            'Choose from library',
                            style: TextStyle(
                                fontSize: TextSize.headerText,
                                color: themeColor,
                                fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Divider(
                        color: AppColor.DIVIDER,
                        thickness: 1.0,
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                                fontSize: TextSize.headerText,
                                color: themeColor.withOpacity(0.8),
                                fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 12.0,
                      )
                    ],
                  ),
                ),
              );
            },
          );
        }
    );
  }

  Future updatePendingQuestionDB() async {
    var result;
    try {
      var inspectionId = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ID);
      var endPoint =  "auth/inspection/{{inspectionid}}/${widget.inspectionData["questionid"]}";
      var vesselId = widget.inspectionData.containsKey('vesselid') ? widget.inspectionData['vesselid']?? null : null;
      var equipmentId = widget.inspectionData.containsKey('equipmentid') ? widget.inspectionData['equipmentid']?? null : null;
      var bodyOfWaterId = widget.inspectionData.containsKey('bodyofwaterid') ? widget.inspectionData['bodyofwaterid']?? null : null;

      result = await dbHelper.insertPendingUrl({
        "url": '$endPoint',
        "verb":'SIGNATURE',
        "payload": '',
        "simplelistid": null,
        "image_id": null,
        "equipmentid": equipmentId,
        "vesselid": vesselId,
        "bodyofwaterid": bodyOfWaterId,
        "inspectionid": inspectionId,
        "inspectiondefid": widget.inspectionData['inspectiondefid'],
        "questionid": widget.inspectionData['questionid'],
        "imagepath": '$imagePath',
        "notaimagepath": null
      });
      print("Result ==== $result");

      if(result != null) {
        submitInspectionLocalDB();
      }
    } catch (e){
      log("StackTrace====$e");
    }
    return result;
  }

  Future submitInspectionLocalDB() async {
    var result;
    try {
      var vesselId = widget.inspectionData.containsKey('vesselid') ? widget.inspectionData['vesselid']?? null : null;
      var equipmentId = widget.inspectionData.containsKey('equipmentid') ? widget.inspectionData['equipmentid']?? null : null;
      var bodyOfWaterId = widget.inspectionData.containsKey('bodyofwaterid') ? widget.inspectionData['bodyofwaterid']?? null : null;

      var inspectionId = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ID);
      var requestJson = {
        "completed": HelperClass.getCompletedDateFormat()
      };

      var endPoint =  "auth/inspection/{{inspectionid}}";

      result = await dbHelper.insertPendingUrl({
        "url": '$endPoint',
        "verb":'PATCH',
        "inspectionid": inspectionId,
        "simplelistid": null,
        "image_id": null,
        "equipmentid": equipmentId,
        "vesselid": vesselId,
        "bodyofwaterid": bodyOfWaterId,
        "inspectiondefid": widget.inspectionData['inspectiondefid'],
        "questionid": widget.inspectionData['questionid'],
        "payload": json.encode(requestJson),
        "imagepath": '$imagePath',
        "notaimagepath": null
      });
      print("Result ==== $result");

      if(result != null) {
        Navigator.push(
            context,
            SlideRightRoute(
                page: CompleteInspectionScreen()
            )
        );
      }
    } catch (e){
      log("StackTrace====$e");
    }
    return result;
  }

  Future<void> uploadSignatureImage() async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var inspectionId = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ID);

    var response = await request.uploadOnlyResource(
        "auth/inspection/$inspectionId/${widget.inspectionData["questionid"]}",
        imagePath,
    );
    print("Response====$response");
    print("Error====$response");
    _progressHUD.state.dismiss();
    if (response != null) {
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage('${response['reason']}');
      } else {
        /*Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => WelcomeScreenPage(),
          ),
          ModalRoute.withName(WelcomeScreenPage.tag),
        );*/
        submitInspection();
      }
    }
  }

  Future<void> submitInspection() async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());

    var inspectionId = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ID) ?? 213;
    var requestJson = {
      "completed": HelperClass.getCompletedDateFormat()
    };
    var requestParam = json.encode(requestJson);
    var response = await request.patchRequest(
      "auth/inspection/$inspectionId",
        requestParam
    );
    print("Response====$response");
    _progressHUD.state.dismiss();
    if (response != null) {
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage('${response['reason']}');
      } else {
        print("Completed====>>>$response");
        /*Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
//            builder: (context) => SafetyEquipmentInspectionPage(),
            builder: (context) => WelcomeNewScreenPage(),
          ),
          ModalRoute.withName(WelcomeNewScreenPage.tag),
        );*/
        Navigator.push(
          context,
          SlideRightRoute(
            page: CompleteInspectionScreen()
          )
        );
      }
    }
  }
}
