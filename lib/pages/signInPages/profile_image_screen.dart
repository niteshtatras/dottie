import 'dart:developer';
import 'dart:io';

import 'package:dottie_inspector/main/welcome_intro_page.dart';
import 'package:dottie_inspector/pages/signInPages/privacy_policy_confirm_page.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/SlideRightRoute.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImageScreen extends StatefulWidget {
  final formData;
  const ProfileImageScreen({Key key, this.formData}) : super(key: key);

  @override
  _ProfileImageScreenState createState() => _ProfileImageScreenState();
}

class _ProfileImageScreenState extends State<ProfileImageScreen> {

  Map formData;
  var imagePath = "";
  final ImagePicker _picker = ImagePicker();

  bool isDarkMode = false;
  Color themeColor = AppColor.BLACK_COLOR;

  @override
  void initState() {
    super.initState();

    formData = widget.formData ?? {};
    getPreferenceData();
  }

  void getPreferenceData() async {
    await PreferenceHelper.getPreferenceData(PreferenceHelper.THEME_MODE).then((value){
      setState(() {
        var themeMode = value == null ? "" : value;
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

  Future getImageFromCamera() async {
    var image1 = await _picker.pickImage(source: ImageSource.camera);
    if (image1 != null) {
      openCropImageOption(image1.path);
    }
  }

  Future getImageFromGallery() async {
    var image1 = await _picker.pickImage(source: ImageSource.gallery);
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
            toolbarTitle: "Image Cropper",
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

        compressedFile = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? AppColor.BLACK_COLOR : AppColor.PAGE_COLOR,
      appBar: EmptyAppBar(isDarkMode: isDarkMode),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: GestureDetector(
                    onTap: () async  {
                      var result = await Navigator.of(context).maybePop();
                      print("BackResult====$result");
                      if(!result) {
                        Navigator.pushReplacement(
                            context,
                            SlideRightRoute(
                                page: WelcomeIntroPage()
                            )
                        );
                      }

                      getPreferenceData();
                    },
                    child: Container(
                      child: Image.asset(
                        isDarkMode
                            ? 'assets/ic_dark_back_button.png'
                            : 'assets/ic_close_button.png',
                        fit: BoxFit.cover,
                        width: 48,
                        height: 48,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 10.0, left: 24.0, right: 24.0),
                          child: Text(
                            'Add a profile image',
                            style: TextStyle(
                              color: themeColor,
                              fontSize: TextSize.greetingTitleText,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 8.0, left: 24.0, right: 24.0),
                          child: Text(
                            'Nice! Now let’s set a profile image so other Inspectors can recognize you',
                            style: TextStyle(
                              color: themeColor,
                              fontSize: TextSize.subjectTitle,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(top: 50),
                          alignment: Alignment.center,
                          child: Stack(
                            children: [
                              ClipRRect(
                                child: imagePath == ""
                                ? Image.asset(
                                  isDarkMode
                                    ? "assets/welcome/ic_profile_dark_avatar.png"
                                  : "assets/welcome/ic_profile_avatar.png",
                                  width: 200,
                                  height: 200,
                                )
                                : Image.file(
                                  File(imagePath),
                                  width: 200,
                                  height: 200,
                                ),
                                borderRadius: BorderRadius.circular(100),
                              ),

                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: (){
                                    bottomImagePicker(context);
                                  },
                                  child: ClipRRect(
                                    child: Image.asset(
                                      "assets/welcome/ic_camera_profile.png",
                                      width: 56,
                                      height: 56,
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),

            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Container(
                child: GestureDetector(
                  onTap: (){
                    if(imagePath != ""){
                      Map formDataLocal = {
                        "email": formData['email'],
                        "first_name": formData['first_name'],
                        "last_name": formData['last_name'],
                        "password": formData['password'],
                        "avatar": imagePath,
                      };
                      log("FormData====$formDataLocal");

                      Navigator.pushReplacement(
                          context,
                          SlideRightRoute(
                              page: PrivacyPolicyConfirmPage(
                                  formData : formDataLocal
                              )
                          )
                      );
                    }
                  },
                  child: Container(
                    height: 64.0,
                    margin: EdgeInsets.only(left: 48.0, right: 48.0, bottom: 72.0, top: 12.0),
                    decoration: BoxDecoration(
                        color: imagePath != ""
                            ? themeColor
                            : AppColor.DIVIDER,
                        borderRadius: BorderRadius.all(Radius.circular(32.0))
                    ),
                    child: Center(
                      child: Text(
                        'Continue',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: (imagePath != "")
                              ? isDarkMode
                              ?  AppColor.BLACK_COLOR
                              : AppColor.WHITE_COLOR
                              : Color(0xff808080),
                          fontSize: TextSize.subjectTitle,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 32.0,
              left: 0,
              right: 0,
              child:  GestureDetector(
                onTap: (){
                  Map formDataLocal = {
                    "email": formData['email'],
                    "first_name": formData['first_name'],
                    "last_name": formData['last_name'],
                    "password": formData['password'],
                    "avatar": "",
                  };
                  log("FormData====$formDataLocal");
                  Navigator.pushReplacement(
                      context,
                      SlideRightRoute(
                          page: PrivacyPolicyConfirmPage(
                              formData : formDataLocal
                          )
                      )
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  alignment: Alignment.center,
                  child: Text(
                    "Skip",
                    style: TextStyle(
                        color: themeColor,
                        fontSize: TextSize.subjectTitle,
                        fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void bottomImagePicker(context){
    showModalBottomSheet(
        context: context,
        barrierColor: isDarkMode ? Color(0xff000000).withOpacity(0.8) : Color(0xff000000).withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        isDismissible: false,
        builder: (context){
          return StatefulBuilder(
            builder: (context1, myState){
              return SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.only(top: 24.0),
                        child: Text(
                          'Update Profile Photo',
                          style: TextStyle(
                            fontSize: TextSize.subjectTitle,
                            color: themeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                          getImageFromCamera();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.only(top: 24.0),
                          child: Text(
                            'Take New Photo',
                            style: TextStyle(
                              fontSize: 20,
                              color: themeColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                          getImageFromGallery();
                        },
                        child: Container(
                          padding: EdgeInsets.only(top: 24.0),
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            'Choose New Photo',
                            style: TextStyle(
                              fontSize: 20,
                              color: themeColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      imagePath == ""
                      ? Container()
                      : GestureDetector(
                        onTap: (){
                          setState(() {
                            myState((){
                              imagePath = "";
                            });
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.only(top: 24.0),
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            'Remove Photo',
                            style: TextStyle(
                              fontSize: 20,
                              color: AppColor.RED_COLOR,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: 32, bottom: 16),
                          alignment: Alignment.center,
                          height: 64,
                          width: 110,
                          // padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                          decoration: BoxDecoration(
                              color: themeColor,
                              borderRadius: BorderRadius.circular(32)
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: TextSize.subjectTitle,
                              color: isDarkMode ? Colors.black : Colors.white,
                              fontWeight: FontWeight.w700,
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
}
