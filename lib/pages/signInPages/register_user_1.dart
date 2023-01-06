
import 'package:dottie_inspector/main/welcome_intro_page.dart';
import 'package:dottie_inspector/pages/signInPages/login_page_1.dart';
import 'package:dottie_inspector/pages/signInPages/register_email_page_1.dart';
import 'package:dottie_inspector/deadCode/signIn/login_page.dart';
import 'package:dottie_inspector/deadCode/signIn/register_email.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/SlideRightRoute.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:dottie_inspector/widget/gradient/grediant_box_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterUser1Page extends StatefulWidget {

  @override
  _RegisterUser1PageState createState() => _RegisterUser1PageState();
}

class _RegisterUser1PageState extends State<RegisterUser1Page> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  final FocusNode firstNameFocus = FocusNode();
  final FocusNode lastNameFocus = FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isFirstNameFocus = false;
  bool isLastNameFocus = false;
  bool isFocusOn = true;
  bool _allFieldValidate = false;

  ScrollController _pageScrollController = new ScrollController();
//  KeyboardVisibilityNotification _keyboardVisibility = new KeyboardVisibilityNotification();
//  int _keyboardVisibilitySubscriberId;
  bool _keyboardState;

  bool isDarkMode = false;
  Color themeColor = AppColor.BLACK_COLOR;

  @override
  void initState() {
    super.initState();
   /* _keyboardState = _keyboardVisibility.isKeyboardVisible;
    _keyboardVisibilitySubscriberId = _keyboardVisibility.addNewListener(
      onChange: (bool visible) {
        setState(() {
          _keyboardState = visible;
          if(visible) {
            _pageScrollController.animateTo(_pageScrollController.position.maxScrollExtent,
                duration: Duration(milliseconds: 700), curve: Curves.easeOut);
          }
          else {
            _pageScrollController.animateTo(_pageScrollController.position.minScrollExtent,
                duration: Duration(milliseconds: 700), curve: Curves.easeOut);
          }
        });
      },
    );*/

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
  void dispose() {
//    _keyboardVisibility.removeListener(_keyboardVisibilitySubscriberId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? AppColor.BLACK_COLOR : AppColor.PAGE_COLOR,
      appBar: EmptyAppBar(isDarkMode: isDarkMode),
      // appBar: AppBar(
      //   centerTitle: true,
      //   elevation: 0.0,
      //   backgroundColor: AppColor.PAGE_COLOR,
      // /*  leading: IconButton(
      //     padding: EdgeInsets.only(left: 16.0, right: 16.0),
      //     icon: Icon(Icons.arrow_back_ios,color: AppColor.TYPE_PRIMARY,size: 32.0,),
      //     onPressed: (){
      //       Navigator.pop(context);
      //     },
      //   ),*/
      // leading: IconButton(
      //   onPressed: (){
      //     Navigator.pop(context);
      //   },
      //   icon:  Image.asset(
      //     'assets/ic_back_button.png',
      //     height: 24.0,
      //     width: 24.0,
      //   ),
      // ),
      //   /*leading: Container(
      //     margin: EdgeInsets.only(left: 18.0),
      //     alignment: Alignment.centerLeft,
      //     child: Image.asset(
      //       'assets/ic_back_button.png',
      //       height: 24.0,
      //       width: 24.0,
      //       fit: BoxFit.cover,
      //     ),
      //   ),*/
      //   title: Text(
      //     '',
      //     style: TextStyle(
      //         color: AppColor.TYPE_PRIMARY,
      //         fontSize: TextSize.headerText,
      //         fontWeight: FontWeight.w600
      //     ),
      //   ),
      // ),
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
                    controller: _pageScrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 10.0, left: 24.0, right: 24.0),
                          child: Text(
                            'Nice to meet you!',
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
                            'How should we greet you?',
                            style: TextStyle(
                                color: themeColor,
                                fontSize: TextSize.subjectTitle,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                //First Name
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                  padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isFirstNameFocus && isDarkMode
                                            ? AppColor.gradientColor(0.32)
                                            : isFirstNameFocus
                                            ? AppColor.gradientColor(0.16)
                                            : isDarkMode
                                            ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                                            : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
                                      ),
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
                                            color: themeColor,
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FontStyle.normal
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      TextFormField(
                                        controller: _firstNameController,
                                        focusNode: firstNameFocus,
                                        keyboardType: TextInputType.text,
                                        textCapitalization: TextCapitalization.sentences,
                                        textAlign: TextAlign.start,
                                        autofocus: false,
                                        validator: (value){
                                          return validateString(value, "Given Name");
                                        },
                                        onFieldSubmitted: (term) {
                                          firstNameFocus.unfocus();
                                          FocusScope.of(context).requestFocus(lastNameFocus);
                                        },
                                        textInputAction: TextInputAction.next,
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

                                //Last Name
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
                                            color: themeColor,
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FontStyle.normal
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      TextFormField(
                                        controller: _lastNameController,
                                        focusNode: lastNameFocus,
                                        keyboardType: TextInputType.text,
                                        textCapitalization: TextCapitalization.sentences,
                                        textAlign: TextAlign.start,
                                        autofocus: false,
                                        onFieldSubmitted: (term) {
                                          lastNameFocus.unfocus();
                                        },
                                        textInputAction: TextInputAction.done,
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

                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0,),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Visibility(
                visible: isFocusOn,
                child: Container(
                  child: GestureDetector(
                    onTap: (){
                      if(_formKey.currentState.validate() && _allFieldValidate){
                        Map nameData = {
                          "first_name": "${_firstNameController.text.toString().trim()}",
                          "last_name": "${_lastNameController.text.toString().trim()}"
                        };
                        Navigator.pushReplacement(
                            context,
                            SlideRightRoute(
                                page: RegisterEmailPage1(
                                    nameData : nameData
                                )
                            )
                        );
                      }
                    },
                    child: Container(
                      height: 64.0,
                      margin: EdgeInsets.only(left: 48.0, right: 48.0, bottom: 64.0, top: 12.0),
                      decoration: BoxDecoration(
                          color: _allFieldValidate
                          ? themeColor
                          : AppColor.DIVIDER,
                          borderRadius: BorderRadius.all(Radius.circular(32.0))
                      ),
                      child: Center(
                        child: Text(
                          'Continue',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: (_allFieldValidate)
                                ? isDarkMode
                                  ?  AppColor.BLACK_COLOR
                                  : AppColor.WHITE_COLOR
                                : Color(0xff808080),
                            fontSize: TextSize.subjectTitle,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 40.0,
              left: 0,
              right: 0,
              child:  Visibility(
                visible: isFocusOn,
                child: GestureDetector(
                  onTap: (){
                    Navigator.pushReplacement(
                        context,
                        SlideRightRoute(
                            page: LoginPage1()
                        )
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                    alignment: Alignment.center,
                    child: Text(
                      "I already have a Dottie account",
                      style: TextStyle(
                          color: themeColor,
                          fontSize: TextSize.subjectTitle,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.normal,
                      ),
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
}
