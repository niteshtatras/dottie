import 'dart:developer';
import 'dart:io';

import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/widget/dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class OpenNetworkCameraWidget extends StatefulWidget {
  OpenNetworkCameraWidget(
    {
      this.onGalleryClick,
      this.onCameraClick,
      this.onDeleteClick,
      this.onDescriptionCallback,
      this.networkImagePath = '',
      this.noteImagePath,
      this.isPhotoScreen = false,
      this.photoDescription = '',
      this.imageHeight = 0
    }
  );

  final void Function() onCameraClick;
  final void Function() onGalleryClick;
  final void Function() onDeleteClick;
  final void Function(String photoDescription) onDescriptionCallback;
  bool isPhotoScreen;
  String networkImagePath;
  File noteImagePath;
  String photoDescription;
  int imageHeight;

  @override
  _OpenNetworkCameraWidgetState createState() => _OpenNetworkCameraWidgetState();
}

class _OpenNetworkCameraWidgetState extends State<OpenNetworkCameraWidget> {
  bool isPhotoTaken = false;
  String networkImagePath = '';
  String photoDescription = '';

  final controller = TextEditingController();
  final focusNode = FocusNode();
  bool isFocus = false;

  var imageHeight;

  bool isDarkMode = false;
  Color themeColor = AppColor.BLACK_COLOR;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    networkImagePath = widget.networkImagePath;

    focusNode.addListener((){
      setState((){
        isFocus = focusNode.hasFocus;
      });
    });
    setState(() {
      imageHeight = widget.imageHeight ?? 0;
    });

    getThemeData();
  }

  void getThemeData() async {
    log("Hello");
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
        log("DarkMode===$isDarkMode");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // print("Width====${MediaQuery.of(context).size.width}");
    // print("Height====${MediaQuery.of(context).size.height}");
    // print("Double Width====${double.infinity}");
    return Column(
      children: [
        Container(
          child: widget.networkImagePath != null && widget.networkImagePath != ''
          ? ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.width - imageHeight,
                maxWidth: MediaQuery.of(context).size.width,
            ),
            child: Stack(
              children: [
                Container(
                    margin: EdgeInsets.only(top: 16.0, left: 0.0, right: 0.0, bottom: 10.0),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width - imageHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.TYPE_PRIMARY.withOpacity(0.16),
                          blurRadius: 1.0
                        )
                      ]
                    ),
                    child: Stack(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width - imageHeight,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: Image.network(
                              networkImagePath,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 16.0,
                          right: 16.0,
                          child: GestureDetector(
                            onTap: (){
                              /*setState(() {
                                widget.imagePath = "";
                                widget.noteImagePath = null;
                                photoDescription = "";
                              });*/
                              widget.onDeleteClick();
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
                    )
                ),
                widget.noteImagePath == null
                ? Container()
                : Container(
                    margin: EdgeInsets.only(top: 16.0, left: 0.0, right: 0.0, bottom: 10.0),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width - imageHeight,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                              color: AppColor.TYPE_PRIMARY.withOpacity(0.16),
                              blurRadius: 1.0
                          )
                        ]
                    ),
                    child: Stack(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width - imageHeight,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: Image.file(
                              widget.noteImagePath,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 16.0,
                          right: 16.0,
                          child: GestureDetector(
                            onTap: (){
                             /* setState(() {
                                widget.imagePath = "";
                                widget.noteImagePath = null;
                                photoDescription = "";
                              });*/

                              widget.onDeleteClick();
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
                    )
                ),
              ],
            ),
          )
          : widget.isPhotoScreen
          ? GestureDetector(
            onTap: (){
              bottomNavigation(context);
              // widget.onCameraClick();
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 24.0),
              padding: EdgeInsets.symmetric(horizontal: 3.0),
              child: DottedBorder(
                  color: Color(0xFFE5E5E5),
                  radius: Radius.circular(16.0),
                  borderType: BorderType.RRect,
                  strokeWidth: 3.0,
                  strokeCap: StrokeCap.square,
                  dashPattern: [5,8],
                  child: Container(
                    height: 280.0,
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.all(0.0),
                    decoration: BoxDecoration(
                        color: isDarkMode
                            ? Color(0xff1f1f1f)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(24.0)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Image.asset(
                            'assets/ic_camera_image.png',
                            width: 72.0,
                            height: 72.0,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: 8.0,),
                        Text(
                          'Add Photo',
                          style:  TextStyle(
                              color: AppColor.BLACK_COLOR,
                              fontSize: TextSize.subjectTitle,
                              fontWeight: FontWeight.w700,
                              height: 1.3
                          ),
                        )
                      ],
                    ),
                  )
              ),
            ),
          )
          : Container(
            padding: EdgeInsets.all(1.5),
            decoration: BoxDecoration(
                color: isDarkMode
                    ? Color(0xff1f1f1f)
                    : Colors.white,
                borderRadius: BorderRadius.circular(24.0)
            ),
            margin: EdgeInsets.only(top: 16.0, bottom: 10.0),
            child: GestureDetector(
              onTap: (){
               bottomNavigation(context);
                // widget.onCameraClick();
              },
              child: DottedBorder(
                  radius: Radius.circular(16.0),
                  borderType: BorderType.RRect,
                  strokeWidth: 4.0,
                  color: AppColor.DIVIDER,
                  strokeCap: StrokeCap.square,
                  dashPattern: [5,8],
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: isDarkMode
                          ? Color(0xff1f1f1f)
                          : Colors.white,
                    ),
                    height: 70.0,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          child: Image.asset(
                            'assets/ic_camera_image.png',
                            width: 48.0,
                            height: 48.0,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(width: 8.0,),
                        Text(
                          'Take a photo',
                          style:  TextStyle(
                              color: themeColor,
                              fontSize: TextSize.headerText,
                              fontWeight: FontWeight.w700,
                              height: 1.3
                          ),
                        )
                      ],
                    ),
                  )
              ),
            ),
          ),
        ),

        //Photo Description
        /*Visibility(
          visible: widget.imagePath != null && widget.imagePath != '',
          child: Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
            padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
            decoration: BoxDecoration(
                color: isFocus
                    ? AppColor.THEME_PRIMARY.withOpacity(0.08)
                    : AppColor.TYPE_PRIMARY.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16.0)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Description',
                  style: TextStyle(
                      fontSize: TextSize.bodyText,
                      color: AppColor.TYPE_PRIMARY,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.0,),
                TextFormField(
                  controller: controller,
                  textAlign: TextAlign.start,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.done,
                  autofocus: false,
                  focusNode: focusNode,
                  onFieldSubmitted: (term) {
                    focusNode.unfocus();
                    photoDescription = controller.text;
                    widget.onDescriptionCallback(photoDescription);
                  },
                  decoration: InputDecoration(
                    fillColor: AppColor.TRANSPARENT,
                    contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
                    filled: false,
                    border: InputBorder.none,
                    hintText: "Write Something....",
                    hintStyle: TextStyle(
                        fontSize: TextSize.headerText,
                        fontWeight: FontWeight.w600,
                        color: AppColor.TYPE_PRIMARY.withOpacity(0.6)
                    ),
                  ),
                  style: TextStyle(
                      color: AppColor.TYPE_PRIMARY,
                      fontWeight: FontWeight.w600,
                      fontSize: TextSize.headerText
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(40)],
                ),
              ],
            ),
          ),
        ),*/
        //Photo Description
        Visibility(
          visible: widget.networkImagePath != null && widget.networkImagePath != '',
          child: GestureDetector(
            onTap: (){
              openAddCommentBottomSheet(context);
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              decoration: BoxDecoration(
                  color: widget.isPhotoScreen
                      ? isDarkMode ? Color(0xff1f1f1f) : AppColor.WHITE_COLOR
                      : isDarkMode ? Color(0xff1f1f1f) : AppColor.TYPE_PRIMARY.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16.0)
              ),
              child: Text(
                photoDescription.isEmpty ? "Add a description..." : '$photoDescription',
                style: TextStyle(
                    color: isDarkMode
                        ? photoDescription.isNotEmpty ? Colors.white : AppColor.WHITE_COLOR.withOpacity(0.6)
                        : AppColor.BLACK_COLOR,
                    fontWeight: photoDescription.isEmpty ? FontWeight.w500 : FontWeight.w700,
                    fontSize: TextSize.subjectTitle
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void bottomNavigation(context){
    showModalBottomSheet(
        context: context,
        barrierColor: themeColor.withOpacity(0.5),
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
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                          widget.onCameraClick();
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
                        color: isDarkMode ? AppColor.DIVIDER.withOpacity(0.4) : AppColor.DIVIDER,
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                          widget.onGalleryClick();
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
                        thickness: 1.0,
                        color: isDarkMode ? AppColor.DIVIDER.withOpacity(0.4) : AppColor.DIVIDER,
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

  void openAddCommentBottomSheet(context){
    TextEditingController _commentController = TextEditingController();
    final _commentFocus = FocusNode();

    setState(() {
      _commentController..value = TextEditingValue(
          text: photoDescription,
          selection: TextSelection(
              baseOffset: photoDescription.length,
              extentOffset: photoDescription.length
          )
      );
    });

    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        barrierColor: themeColor.withOpacity(0.5),
        isDismissible: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        builder: (context){
          return StatefulBuilder(
            builder: (context1, myState){
              return Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Container(
                  width: double.infinity,
                  child: Wrap(
                    children: <Widget>[
                      Container(
                        height: 72,
                        color: isDarkMode ? Color(0xff1f1f1f) : Colors.white,
                        alignment: Alignment.centerLeft,
                        child: TextFormField(
                          controller: _commentController,
                          focusNode: _commentFocus,
                          textAlign: TextAlign.start,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.done,
                          autofocus: true,
                          onFieldSubmitted: (term) {
                            _commentFocus.unfocus();
                          },
                          decoration: InputDecoration(
                            fillColor: isDarkMode ? Color(0xff1f1f1f) : Colors.white,
                            filled: true,
                            border: InputBorder.none,
                            hintText: "Type your description...",
                            hintStyle: TextStyle(
                                fontSize: TextSize.subjectTitle,
                                color: isDarkMode
                                    ? Color(0xff545454)
                                    : Color(0xff808080)
                            ),
                          ),
                          style: TextStyle(
                              color: themeColor,
                              fontWeight: FontWeight.w600,
                              fontSize: TextSize.subjectTitle
                          ),
                          inputFormatters: [LengthLimitingTextInputFormatter(100)],
                        ),
                      ),
                      Divider(
                        height: 1.0,
                        color: isDarkMode ? AppColor.DIVIDER.withOpacity(0.4) : AppColor.DIVIDER,
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                          myState((){
                            setState(() {
                              photoDescription = _commentController.text;
                              widget.onDescriptionCallback(photoDescription);
                            });
                          });
                        },
                        child: Container(
                          height: 56.0,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: AppColor.gradientColor(1.0)
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(0.0))
                          ),
                          child: Center(
                            child: Text(
                              'DONE',
                              style: TextStyle(
                                fontSize: TextSize.headerText,
                                color: AppColor.WHITE_COLOR,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
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
