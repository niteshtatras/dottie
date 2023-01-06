import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/custom_toast.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:dottie_inspector/widget/bottom_general_button_widget.dart';
import 'package:dottie_inspector/widget/bottom_general_dark_button_widget.dart';
import 'package:dottie_inspector/widget/gradient/grediant_box_border.dart';
import 'package:dottie_inspector/widget/masked_phone_number.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_hud/progress_hud.dart';

class ProfileInfoEditPage extends StatefulWidget {
  final title;
  final value;
  final userData;

  const ProfileInfoEditPage({Key key, this.title, this.value, this.userData}) : super(key: key);

  @override
  _ProfileInfoEditPageState createState() => _ProfileInfoEditPageState();
}

class _ProfileInfoEditPageState extends State<ProfileInfoEditPage> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  TextEditingController email1Controller = TextEditingController();
  var phone1Controller = MaskedTextController(mask: '(000) 000-0000');


  FocusNode firstNameFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();
  FocusNode email1Focus = FocusNode();
  FocusNode phone1Focus = FocusNode();

  bool isFirstNameFocus = false;
  bool isLastNameFocus = false;
  bool isEmail1Focus = false;
  bool isPhone1Focus = false;
  bool isFocusOn = true;

  var imagePath = '';
  bool isPhotoTaken = false;
  bool _autoValidate = false;
  bool _allFieldValidate = false;
  Map userData;
  var elevation = 0.0;
  ScrollController _scrollController = ScrollController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;
  bool isDarkMode = false;
  Color themeColor = AppColor.BLACK_COLOR;

  @override
  void initState() {
    super.initState();
    _progressHUD = ProgressHUD(
      backgroundColor: Colors.transparent,
      color: Colors.white,
      containerColor: AppColor.LOADER_COLOR,
      borderRadius: 5.0,
      loading: _loading,
      text: 'Loading...',
    );

    firstNameFocus.addListener(() {
      setState(() {
        isFirstNameFocus = firstNameFocus.hasFocus;
        isFocusOn = !firstNameFocus.hasFocus;
      });
    });

    lastNameFocus.addListener(() {
      setState(() {
        isLastNameFocus = lastNameFocus.hasFocus;
        isFocusOn = !lastNameFocus.hasFocus;
      });
    });

    email1Focus.addListener((){
      setState(() {
        isEmail1Focus = email1Focus.hasFocus;
        isFocusOn = !email1Focus.hasFocus;
      });
    });
    phone1Focus.addListener((){
      setState(() {
        isPhone1Focus = phone1Focus.hasFocus;
        isFocusOn = !phone1Focus.hasFocus;
      });
    });

    _scrollController.addListener(() {
      setState(() {
        if(_scrollController.position.pixels > _scrollController.position.minScrollExtent){
          elevation = HelperClass.ELEVATION_1;
        } else {
          elevation = HelperClass.ELEVATION;
        }
      });
    });

    userData = widget.userData;
    if(userData != null) {
      _firstNameController.text = userData['firstname'];
      _lastNameController.text = userData['lastname'];
    }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode ? AppColor.BLACK_COLOR : AppColor.PAGE_COLOR,
      appBar: EmptyAppBar(isDarkMode: isDarkMode),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
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
                    Expanded(
                      flex: 8,
                      child: Visibility(
                        visible: elevation != 0,
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            'Profile Info',
                            style: TextStyle(
                                color: themeColor,
                                fontSize: TextSize.headerText,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Text(
                          'Profile Info',
                          style: TextStyle(
                              color: themeColor,
                              fontSize: TextSize.greetingTitleText,
                              fontWeight: FontWeight.w700
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 16.0, right: 16.0),
                        child: Form(
                          key: _formKey,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                /***
                                 * First Name
                                 */
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                  padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      //matillion
                                      //AWS- Cloud essentials
                                      //AWS
                                      //Snowflake
                                      //AWS- Cloud essentials
                                      //Datawarehouse basics
                                      //SQL
                                      colors: isFirstNameFocus && isDarkMode
                                          ? AppColor.gradientColor(0.32)
                                          : isFirstNameFocus
                                          ? AppColor.gradientColor(0.16)
                                          : isDarkMode
                                          ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                                          : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
                                    ),
                                      // color: isFirstNameFocus
                                      //     ? AppColor.THEME_PRIMARY.withOpacity(0.08)
                                      //     : AppColor.WHITE_COLOR,
                                      borderRadius: BorderRadius.circular(32.0),
                                      border: GradientBoxBorder(
                                          gradient: LinearGradient(
                                            colors: isFirstNameFocus
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
                                        'First Name',
                                        style: TextStyle(
                                            fontSize: TextSize.subjectTitle,
                                            color: themeColor.withOpacity(1.0),
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FontStyle.normal
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      TextFormField(
                                        controller: _firstNameController,
                                        focusNode: firstNameFocus,
                                        onFieldSubmitted: (term) {
                                          firstNameFocus.unfocus();
                                          FocusScope.of(context).requestFocus(lastNameFocus);
                                        },
                                        textCapitalization: TextCapitalization.sentences,
                                        textInputAction: TextInputAction.next,
                                        keyboardType: TextInputType.name,
                                        textAlign: TextAlign.start,
                                        validator: (value){
                                          return validateString(value, "given name");
                                        },
                                        decoration: InputDecoration(
                                          fillColor: AppColor.WHITE_COLOR,
                                          hintText: "Given Name",
                                          filled: false,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.only(top: 0,),
                                          hintStyle: TextStyle(
                                              fontSize: TextSize.headerText,
                                              fontWeight: FontWeight.w700,
                                              color: isDarkMode
                                                  ? Color(0xff545454)
                                                  : Color(0xff808080)
                                          ),
                                        ),
                                        style: TextStyle(
                                            color: themeColor,
                                            fontWeight: FontWeight.w700,
                                            fontSize: TextSize.headerText
                                        ),
                                        inputFormatters: [LengthLimitingTextInputFormatter(40)],
                                        onChanged: (value){
                                          setState(() {
                                            _allFieldValidate = _formKey.currentState.validate();
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                /***
                                 * Last Name
                                 */
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                  padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isLastNameFocus && isDarkMode
                                            ? AppColor.gradientColor(0.32)
                                            : isLastNameFocus
                                            ? AppColor.gradientColor(0.16)
                                            : isDarkMode
                                            ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                                            : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
                                      ),
                                      borderRadius: BorderRadius.circular(32.0),
                                      border: GradientBoxBorder(
                                          gradient: LinearGradient(
                                            colors: isLastNameFocus
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
                                        'Last Name',
                                        style: TextStyle(
                                            fontSize: TextSize.subjectTitle,
                                            color: themeColor.withOpacity(1.0),
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FontStyle.normal
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      TextFormField(
                                        controller: _lastNameController,
                                        focusNode: lastNameFocus,
                                        onFieldSubmitted: (term) {
                                          lastNameFocus.unfocus();
                                        },
                                        validator: (value) {
                                          return validateString(value, "family name");
                                        },
                                        textCapitalization: TextCapitalization.sentences,
                                        textInputAction: TextInputAction.done,
                                        keyboardType: TextInputType.text,
                                        textAlign: TextAlign.start,
                                        decoration: InputDecoration(
                                          fillColor: AppColor.WHITE_COLOR,
                                          hintText: "Family Name",
                                          filled: false,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.only(top: 0,),
                                          hintStyle: TextStyle(
                                              fontSize: TextSize.headerText,
                                              fontWeight: FontWeight.w700,
                                              color: isDarkMode
                                                  ? Color(0xff545454)
                                                  : Color(0xff808080)
                                          ),
                                        ),
                                        style: TextStyle(
                                            color: themeColor,
                                            fontWeight: FontWeight.w700,
                                            fontSize: TextSize.headerText
                                        ),
                                        inputFormatters: [LengthLimitingTextInputFormatter(40)],
                                        onChanged: (value){
                                          setState(() {
                                            _allFieldValidate = _formKey.currentState.validate();
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                /***
                                 * Email
                                 */
                                /***Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                  padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                  decoration: BoxDecoration(
                                      color: isEmail1Focus
                                          ? AppColor.THEME_PRIMARY.withOpacity(0.08)
                                          : AppColor.WHITE_COLOR,
                                      borderRadius: BorderRadius.circular(16.0)
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Email(Optional)',
                                        style: TextStyle(
                                            fontSize: TextSize.subjectTitle,
                                            color: themeColor.withOpacity(1.0),
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FontStyle.normal
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      TextFormField(
                                        controller: email1Controller,
                                        focusNode: email1Focus,
                                        onFieldSubmitted: (term) {
                                          email1Focus.unfocus();
                                          FocusScope.of(context).requestFocus(phone1Focus);
                                        },
                                        textInputAction: TextInputAction.next,
                                        keyboardType: TextInputType.text,
                                        textAlign: TextAlign.start,
                                        decoration: InputDecoration(
                                          fillColor: AppColor.WHITE_COLOR,
                                          hintText: "example@mail.com",
                                          filled: false,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.only(top: 0,),
                                          hintStyle: TextStyle(
                                              fontSize: TextSize.headerText,
                                              fontWeight: FontWeight.w700,
                                              color: AppColor.TYPE_PRIMARY.withOpacity(0.6)
                                          ),
                                        ),
                                        style: TextStyle(
                                            color: themeColor,
                                            fontWeight: FontWeight.w700,
                                            fontSize: TextSize.headerText
                                        ),
                                        inputFormatters: [LengthLimitingTextInputFormatter(40)],
                                        onChanged: (value){

                                        },
                                      ),
                                    ],
                                  ),
                                ),*/
                                /***
                                 * Phone
                                 */
                               /*** Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                  padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                  decoration: BoxDecoration(
                                      color: isPhone1Focus
                                          ? AppColor.THEME_PRIMARY.withOpacity(0.08)
                                          : AppColor.WHITE_COLOR,
                                      borderRadius: BorderRadius.circular(16.0)
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Phone(Optional)',
                                        style: TextStyle(
                                          fontSize: TextSize.subjectTitle,
                                          color: themeColor.withOpacity(1.0),
                                          fontWeight: FontWeight.w600,
                                          fontStyle: FontStyle.normal,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      TextFormField(
                                        controller: phone1Controller,
                                        focusNode: phone1Focus,
                                        onFieldSubmitted: (term) {
                                          phone1Focus.unfocus();
                                        },
                                        textInputAction: TextInputAction.done,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.start,
                                        decoration: InputDecoration(
                                          fillColor: AppColor.WHITE_COLOR,
                                          hintText: "(000) 000-0000",
                                          filled: false,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.only(top: 0,),
                                          hintStyle: TextStyle(
                                              fontSize: TextSize.headerText,
                                              fontWeight: FontWeight.w700,
                                              color: AppColor.TYPE_PRIMARY.withOpacity(0.6)
                                          ),
                                        ),
                                        style: TextStyle(
                                            color: themeColor,
                                            fontWeight: FontWeight.w700,
                                            fontSize: TextSize.headerText
                                        ),
                                        inputFormatters: [LengthLimitingTextInputFormatter(40)],
                                        onChanged: (value){

                                        },
                                      ),
                                    ],
                                  ),
                                ),*/
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 160.0,)
                    ],
                  ),
                ),
              ),
            ],
          ),

          Visibility(
            visible: isFocusOn,
            child: BottomGeneralButton(
              isActive: _allFieldValidate,
              buttonName: "Update Profile",
              onStartButton: () async {
                log("IsDarkMode===$isDarkMode");
                if(_formKey.currentState.validate() && _allFieldValidate){
                  updateProfileDetail();
                  // if(await HelperClass.internetConnectivity()) {
                  //   updateProfileDetail();
                  // } else {
                  //   HelperClass.openSnackBar(context);
                  // }
                } else {
                  setState(() {
                    firstNameFocus.requestFocus(FocusNode());
                    _autoValidate = true;
                  });
                }
              },
            )
          ),

          _progressHUD
        ],
      ),
    );
  }

  String validateString(String value, String type) {
    if(value!='' && value!=null) {
      if(!value.startsWith(' '))
        return null;
      else
        return 'Enter your $type';
    }
    else {
      return 'Enter your $type';
    }

  }

  void updateProfileDetail() async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var requestJson;
    if(_firstNameController.text == '') {
      requestJson = {"lastname": "${_lastNameController.text.toString().trim()}"};
    } else if(_lastNameController.text == '') {
      requestJson = {"firstname": "${_firstNameController.text.toString().trim()}"};
    } else {
      requestJson = {
        "firstname": "${_firstNameController.text.toString().trim()}",
        "lastname": "${_lastNameController.text.toString().trim()}"
      };
    }
    var requestParam = json.encode(requestJson);
    var response = await request.patchRequest("auth/me", requestParam);
    _progressHUD.state.dismiss();

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage('${response['reason']}');
      } else {
        Navigator.of(context).pop({"userData": {
          "firstname": "${_firstNameController.text.toString().trim()}",
          "lastname": "${_lastNameController.text.toString().trim()}"
        }});
      }
    }
  }
}
