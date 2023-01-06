import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:dottie_inspector/pages/dynamicInspection/signature_screen.dart';
import 'package:dottie_inspector/pages/dynamicInspection/dynamic_complete_inspection_screen.dart';
import 'package:dottie_inspector/pages/menu/drawer_page.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/SlideRightRoute.dart';
import 'package:dottie_inspector/utils/custom_toast.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:progress_hud/progress_hud.dart';

class AddUploadSignaturePage extends StatefulWidget {
  @override
  _AddUploadSignaturePageState createState() => _AddUploadSignaturePageState();
}

class _AddUploadSignaturePageState extends State<AddUploadSignaturePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSignatureAvail = false;
  var imagePath = '';
  ValueNotifier<ByteData> rawImage = ValueNotifier<ByteData>(null);
  ByteData imgData;

  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;
  var inspectionItem;

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
  }

  Future getImageFromCamera() async {
    // var image1 = await ImagePicker.pickImage(source: ImageSource.camera, imageQuality: 60);
    // if (image1 != null) {
    //   setState(() {
    //     isSignatureAvail = true;
    //     imagePath = image1.path;
    //   });
    // }
  }

  Future getImageFromGallery() async {
    // var image1 = await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 60 );
    // if (image1 != null) {
    //   setState(() {
    //     isSignatureAvail = true;
    //     imagePath = image1.path;
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColor.PAGE_COLOR,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: AppColor.PAGE_COLOR,
        leading: InkWell(
          onTap: (){
            _scaffoldKey.currentState.openDrawer();
//            HelperClass.launchDetail(context, AddUploadSignaturePage());
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
        actions: [
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(horizontal: 3.0, vertical: 12.0),
            padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 20.0, right: 20.0),
            decoration: BoxDecoration(
                color: AppColor.THEME_PRIMARY.withOpacity(0.2),
                borderRadius: BorderRadius.all(Radius.circular(16.0))),
            child: Text(
              'Help',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: TextSize.bodyText,
                  color: AppColor.THEME_PRIMARY,
                  fontStyle: FontStyle.normal),
            ),
          ),
          InkWell(
            onTap: (){
//              HelperClass.launchChapter(context);
              setState(() {
                isSignatureAvail = true;
              });
            },
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 6.0, vertical: 12.0),
              padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 8.0, right: 16.0),
              decoration: BoxDecoration(
                  color: AppColor.THEME_PRIMARY.withOpacity(0.2),
                  borderRadius: BorderRadius.all(Radius.circular(16.0))),
              child: Text(
                'CHAPTERS',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: TextSize.bodyText,
                    color: AppColor.THEME_PRIMARY,
                    fontStyle: FontStyle.normal),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: DrawerPage(),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 10.0,),
                  Text(
                    'Start: 2 of 4',
                    style: TextStyle(
                      color: AppColor.TYPE_PRIMARY.withOpacity(0.6),
                      fontSize: TextSize.subjectTitle,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: 60.0,vertical: 8.0),
                    child: LinearPercentIndicator(
                      animationDuration: 200,
                      backgroundColor: AppColor.DIVIDER,
                      percent: 0.5,
                      lineHeight: 8.0,
                      progressColor: AppColor.HEADER_COLOR,
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 50.0,vertical: 8.0),
                    alignment: Alignment.center,
                    child: Text(
                      'Time to put the finishing touches',
                      style: TextStyle(
                          fontSize: TextSize.pageTitleText,
                          color: AppColor.TYPE_PRIMARY,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                          fontFamily: "WorkSans"),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 56.0,vertical: 8.0),
                    alignment: Alignment.center,
                    child: Text(
                      'Give your client’s proposal the stamp of approval!',
                      style: TextStyle(
                          fontSize: TextSize.headerText,
                          color: AppColor.TYPE_PRIMARY,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                          fontFamily: "WorkSans"),
                      textAlign: TextAlign.center,
                    ),
                  ),

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
                              padding: EdgeInsets.all(1.5),
                              decoration: BoxDecoration(
                                  color: AppColor.WHITE_COLOR,
                                  borderRadius: BorderRadius.circular(16.0)
                              ),
                              margin: EdgeInsets.all(16.0),
                              child: DottedBorder(
                                  radius: Radius.circular(16.0),
                                  borderType: BorderType.RRect,
                                  strokeWidth: 3.0,
                                  color: AppColor.DIVIDER,
                                  strokeCap: StrokeCap.square,
                                  dashPattern: [5,8],
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
                              child: InkWell(
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
                          child: InkWell(
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
                                    setState(() async {
                                      isSignatureAvail = true;
                                      imgData = result['image'];
                                      File imageFile = await HelperClass.getFile(imgData, "Signature.jpg");
                                      imagePath = imageFile.path;
                                    });
                                  }
                                }
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 8.0),
                              padding: EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: AppColor.WHITE_COLOR,
                                borderRadius: BorderRadius.circular(16.0),
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
                                          color: AppColor.TYPE_PRIMARY,
                                          fontSize: TextSize.headerText,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'WorkSans'
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16.0,),
                                  Icon(Icons.keyboard_arrow_right, size: 24.0, color: AppColor.TYPE_PRIMARY.withOpacity(0.6),)
                                ],
                              ),
                            ),
                          ),
                        ),

                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(horizontal:24.0, vertical: 0.0),
                          child:  Text(
                            'Or',
                            style: TextStyle(
                                color: AppColor.TYPE_PRIMARY.withOpacity(0.6),
                                fontSize: TextSize.subjectTitle,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Work Sans'
                            ),
                          ),
                        ),

                        //Search Address
                        Theme(
                          data: ThemeData(
                              splashColor: AppColor.TRANSPARENT,
                              highlightColor: AppColor.TRANSPARENT
                          ),
                          child: InkWell(
                            onTap: (){
                              bottomNavigation(context);
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 8.0, top: 8.0),
                              padding: EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: AppColor.WHITE_COLOR,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12.0),
                                    child: Icon(
                                      Icons.cloud_upload,
                                      size: 24.0,
                                      color: AppColor.THEME_PRIMARY,
                                    )
                                  ),
                                  SizedBox(width: 16.0,),
                                  Expanded(
                                    child: Text(
                                      'Upload existing',
                                      style: TextStyle(
                                          color: AppColor.TYPE_PRIMARY,
                                          fontSize: TextSize.headerText,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'WorkSans'
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16.0,),
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

          //Submit
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              height: 64.0,
              margin: EdgeInsets.only(left: 48.0, right: 48.0, bottom: 34.0, top: 12.0),
              decoration: BoxDecoration(
                  color: isSignatureAvail ? AppColor.TYPE_PRIMARY : AppColor.TYPE_PRIMARY,
                  borderRadius: BorderRadius.all(Radius.circular(32.0))
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 24.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'BACK',
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
                    child: InkWell(
                      onTap: (){
                        if(imagePath != '') {
                          uploadSignatureImage();
                        }
                      },
                      child: Container(
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(right: 24.0),
                        child: Text(
                          'COMPLETE',
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
        barrierColor: AppColor.BARRIER_COLOR.withOpacity(0.9),
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
                      InkWell(
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
                                color: AppColor.TYPE_PRIMARY,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'WorkSans'
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
                                color: AppColor.TYPE_PRIMARY,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'WorkSans'
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
                                color: AppColor.TYPE_PRIMARY.withOpacity(0.8),
                                fontWeight: FontWeight.w600,
                                fontFamily: 'WorkSans'
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

  Future<void> uploadSignatureImage() async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());

    var questionId = "724";
    var inspectionId = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ID);

    var response = await request.uploadOnlyResource(
        "auth/inspection/$inspectionId/$questionId",
        imagePath,
    );
    print("Response====$response");
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
    print("requestParameter ====>>>$requestParam");
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
        Navigator.push(
            context,
            SlideRightRoute(
              page: CompleteInspectionScreen()
            )
        );
        /*Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
//            builder: (context) => SafetyEquipmentInspectionPage(),
            builder: (context) => WelcomeNewScreenPage(),
          ),
          ModalRoute.withName(WelcomeNewScreenPage.tag),
        );*/
      }
    }
  }
}
