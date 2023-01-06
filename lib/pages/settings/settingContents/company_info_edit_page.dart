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
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_hud/progress_hud.dart';

class CompanyInfoEditPage extends StatefulWidget {
  final title;
  final value;
  final companyData;

  const CompanyInfoEditPage({Key key, this.title, this.value, this.companyData}) : super(key: key);

  @override
  _CompanyInfoEditPageState createState() => _CompanyInfoEditPageState();
}

class _CompanyInfoEditPageState extends State<CompanyInfoEditPage> {
  FToast fToast;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _companyNameController = TextEditingController();
  final _legalNameController = TextEditingController();


  FocusNode companyNameFocus = FocusNode();
  FocusNode legalNameFocus = FocusNode();

  bool isCompanyNameFocus = false;
  bool isLegalNameFocus = false;
  bool isFocusOn = true;

  var imagePath = '';
  bool isPhotoTaken = false;
  bool _autoValidate = false;
  bool _allFieldValidate = false;
  Map companyData;
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

    companyNameFocus.addListener(() {
      setState(() {
        isCompanyNameFocus = companyNameFocus.hasFocus;
        isFocusOn = !companyNameFocus.hasFocus;
      });
    });

    legalNameFocus.addListener(() {
      setState(() {
        isLegalNameFocus = legalNameFocus.hasFocus;
        isFocusOn = !legalNameFocus.hasFocus;
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

    companyData = widget.companyData;
    if(companyData != null) {
      _companyNameController.text = companyData['companyname'];
      _legalNameController.text = companyData['legalname'];
    }

    fToast = FToast();
    fToast.init(context);

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
                        Navigator.of(context).pop({
                          "companyname":"${companyData['companyname']}",
                          "legalname":"${companyData['legalname']}"
                        });
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
                            'Company Info',
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
                          'Company Info',
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
                                 * Company Name
                                 */
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                  padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isCompanyNameFocus && isDarkMode
                                            ? AppColor.gradientColor(0.32)
                                            : isCompanyNameFocus
                                            ? AppColor.gradientColor(0.16)
                                            : isDarkMode
                                            ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                                            : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
                                      ),
                                      borderRadius: BorderRadius.circular(32.0),
                                      border: GradientBoxBorder(
                                          gradient: LinearGradient(
                                            colors: isCompanyNameFocus
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
                                        'Company Name',
                                        style: TextStyle(
                                            fontSize: TextSize.subjectTitle,
                                            color: themeColor.withOpacity(1.0),
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FontStyle.normal
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      TextFormField(
                                        controller: _companyNameController,
                                        focusNode: companyNameFocus,
                                        onFieldSubmitted: (term) {
                                          companyNameFocus.unfocus();
                                          FocusScope.of(context).requestFocus(legalNameFocus);
                                        },
                                        textCapitalization: TextCapitalization.sentences,
                                        textInputAction: TextInputAction.next,
                                        keyboardType: TextInputType.name,
                                        textAlign: TextAlign.start,
                                        validator: (value){
                                          return validateString(value, "company name");
                                        },
                                        decoration: InputDecoration(
                                          fillColor: AppColor.WHITE_COLOR,
                                          hintText: "Add",
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
                                 * Legal Name
                                 */
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                  padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isLegalNameFocus && isDarkMode
                                            ? AppColor.gradientColor(0.32)
                                            : isLegalNameFocus
                                            ? AppColor.gradientColor(0.16)
                                            : isDarkMode
                                            ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                                            : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
                                      ),
                                      borderRadius: BorderRadius.circular(32.0),
                                      border: GradientBoxBorder(
                                          gradient: LinearGradient(
                                            colors: isLegalNameFocus
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
                                        'Legal Name',
                                        style: TextStyle(
                                            fontSize: TextSize.subjectTitle,
                                            color: themeColor.withOpacity(1.0),
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FontStyle.normal
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      TextFormField(
                                        controller: _legalNameController,
                                        focusNode: legalNameFocus,
                                        validator: (value) {
                                          return validateString(value, "legal name");
                                        },
                                        textCapitalization: TextCapitalization.sentences,
                                        textInputAction: TextInputAction.done,
                                        keyboardType: TextInputType.text,
                                        textAlign: TextAlign.start,
                                        decoration: InputDecoration(
                                          fillColor: AppColor.WHITE_COLOR,
                                          hintText: "Add",
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
              buttonName: "UPDATE",
              onStartButton: () async {
                if(_formKey.currentState.validate() && _allFieldValidate){
                  updateCompanyDetail();
                  // if(await HelperClass.internetConnectivity()) {
                  //   updateCompanyDetail();
                  // } else {
                  //   HelperClass.openSnackBar(context);
                  // }
                } else {
                  setState(() {
                    companyNameFocus.requestFocus(FocusNode());
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

  void updateCompanyDetail() async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var requestJson;
    if(_companyNameController.text == ''){
      requestJson = {"legalname": "${_legalNameController.text.toString().trim()}"};
    } else if(_legalNameController.text == ''){
      requestJson = {"company": "${_companyNameController.text.toString().trim()}"};
    } else {
      requestJson = {
        "company": "${_companyNameController.text.toString().trim()}",
        "legalname": "${_legalNameController.text.toString().trim()}"
      };
    }
    var requestParam = json.encode(requestJson);
    log("RequestParam:===$requestParam");
    var response = await request.postRequest("auth/admin/setCompany", requestParam);
    _progressHUD.state.dismiss();

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage('${response['reason']}');
      } else {
        setState(() {
          companyData['companyname'] = "${_companyNameController.text.trim()}";
          companyData['legalname'] = "${_legalNameController.text.trim()}";
        });
        _showToast("Success");
      }
    }
  }

  _showToast(message) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.black,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              "$message",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 16
            ),
          ),
        ],
      ),
    );


    fToast.showToast(
      child: toast,
      toastDuration: Duration(seconds: 3),
      positionedToastBuilder: (context, child) {
        return Positioned(
          child: child,
          top: 64,
          left: 0,
          right: 0,
        );
      }
    );

    // // Custom Toast Position
    // fToast.showToast(
    //     child: toast,
    //     toastDuration: Duration(seconds: 2),
    //     positionedToastBuilder: (context, child) {
    //       return Positioned(
    //         child: child,
    //         top: 16.0,
    //         left: 16.0,
    //       );
    //     });
  }
}
