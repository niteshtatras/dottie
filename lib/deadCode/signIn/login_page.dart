//import 'package:dottie_inspector/pages/inspectionMain/welcome_screen.dart';
import 'package:dottie_inspector/deadCode/signIn/privacy_policy_page.dart';
import 'package:dottie_inspector/pages/inspectionMain/inspection_adding_customer.dart';
import 'package:dottie_inspector/deadCode/safety_equipment_screen.dart';
import 'package:dottie_inspector/deadCode/welcome_new_screen.dart';
import 'package:dottie_inspector/deadCode/signIn/forgot_password.dart';
import 'package:dottie_inspector/deadCode/signIn/register_user.dart';
import 'package:dottie_inspector/deadCode/signIn/reset_password.dart';
import 'package:dottie_inspector/pages/welcome/welcome_navigation_screen.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/custom_toast.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../pages/welcome/welcome_template_screen.dart';

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _autoValidate = false;
  ScrollController _pageScrollController = new ScrollController();

  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  bool _obscureText = true;
  bool _obscureTextVisible = false;

  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_loadLink);
    _progressHUD = ProgressHUD(
      backgroundColor: Colors.transparent,
      color: Colors.white,
      containerColor: AppColor.LOADER_COLOR,
      borderRadius: 5.0,
      loading: _loading,
      text: 'Loading...',
    );

//    KeyboardVisibilityNotification().addNewListener(
//      onChange: (visible) {
//
//        if(visible==true) {
//          _pageScrollController.animateTo(_pageScrollController.position.maxScrollExtent,
//              duration: Duration(milliseconds: 700), curve: Curves.easeOut);
//        }
//        else {
//          _pageScrollController.animateTo(_pageScrollController.position.minScrollExtent,
//              duration: Duration(milliseconds: 700), curve: Curves.easeOut);
//        }
//      },
//    );
  }

  void _loadLink(_){
    fetchLinkData();
  }

  void fetchLinkData() async {
    // FirebaseDynamicLinks.getInitialLInk does a call to firebase to get us the real link because we have shortened it.
    // var link = await FirebaseDynamicLinks.instance.getInitialLink();
//    CustomToast.showToastMessage("Normal Intent == $link");

    // This link may exist if the app was opened fresh so we'll want to handle it the same way onLink will.
    // handleLinkData(link);
    // print("Link=====$link");

    // This will handle incoming links if the application is already opened
    // FirebaseDynamicLinks.instance.onLink(onSuccess: (PendingDynamicLinkData dynamicLink) async {
    //   print("DynamicLink=====$dynamicLink");
    //   handleLinkData(dynamicLink);
    // });
  }

  /*void handleLinkData(PendingDynamicLinkData data) {
    final Uri deepLink = data?.link;
    if(deepLink != null) {
      final queryParams = deepLink.queryParameters;
      if(queryParams.length > 0) {
        String verify = queryParams["verifyString"];
        // verify the username is parsed correctly
        print("Verify String is:{$verify}");
//        CustomToast.showToastMessage("Verify String is:{$verify}");
        verifyEmailAddress(verify);
      }
    }

    if(deepLink != null) {

//      CustomToast.showToastMessage("path is:{${deepLink.path}}");

//      if(deepLink.path == "/resetpassword"){
//
//      } else {
//        print("No link path available");
//      }
    }
  }*/

  Future<Uri> createDynamicLink({@required String userName}) async {
    /*final DynamicLinkParameters parameters = DynamicLinkParameters(
      // This should match firebase but without the username query param
      uriPrefix: 'https://inspectordottie.page.link',
      // This can be whatever you want for the uri, https://yourapp.com/groupinvite?username=$userName
      link: Uri.parse('https://inspectordottie.page.link/restpassword?username='),
      androidParameters: AndroidParameters(
        packageName: 'com.dottie_inspector',
        minimumVersion: 1,
      ),
      iosParameters: IOSParameters(
        bundleId: 'com.dottie_inspector',
        minimumVersion: '1',
        appStoreId: '',
      ),
    );*/
    // final link = await parameters.buildUrl();
    // final ShortDynamicLink shortenedLink = await DynamicLinkParameters.shortenUrl(
    //   link,
    //   DynamicLinkParametersOptions(shortDynamicLinkPathLength: ShortDynamicLinkPathLength.unguessable),
    // );
    // print("${shortenedLink.shortUrl}");
    // return shortenedLink.shortUrl;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColor.BG_PRIMARY_ALT,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: AppColor.BG_PRIMARY_ALT,
        title: Container(
          child: Image.asset(
            'assets/welcome/welcome_title.png',
            height: 25.0,
            width: 100.0,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _pageScrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                //App Bar
//            Container(
//              alignment: Alignment.centerLeft,
//              padding: EdgeInsets.only(left: 16.0),
//              height: 64.0,
//              child: InkWell(
//                onTap: () {
//                  Navigator.pop(context);
//                },
//                splashColor: Colors.transparent,
//                highlightColor: Colors.transparent,
//                child: Icon(
//                  Icons.keyboard_backspace,
//                  color: AppColor.BLACK_COLOR,
//                  size: 32.0,
//                ),
//              ),
//            ),
//            Container(
//              margin: EdgeInsets.only(top: 32.0),
//              width: MediaQuery.of(context).size.width,
//              alignment: Alignment.center,
//              child: Image.asset(
//                'assets/welcome/welcome_title.png',
//                height: 25.0,
//                width: 100.0,
//              ),
//            ),
                Container(
                  margin: EdgeInsets.only(top: 50.0),
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  alignment: Alignment.center,
                  child: Text(
                    'Dottie will fundamentally\nchange the way you run your\npool business.',
                    style: TextStyle(
                        color: AppColor.TYPE_PRIMARY,
                        fontSize: TextSize.planeHeaderText,
                        fontWeight: FontWeight.w600,
                      height: 1.4
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(top: 70.0),
                  color: AppColor.WHITE_COLOR,
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: formUI(),
                  ),
                ),

                //Forgot Password
                InkWell(
                  onTap: (){
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ForgotPasswordPage()
                        )
                    );
//                    createDynamicLink(userName: "Nitesh");
                  },
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Container(
                    alignment: Alignment.topRight,
                    padding: EdgeInsets.only(right: 24.0,top: 16.0, bottom: 32.0),
                    child: Text(
                      'Forgot Password',
                      style: TextStyle(
                          color: AppColor.THEME_PRIMARY,
                          fontSize: TextSize.subjectTitle,
                          fontWeight: FontWeight.w500
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),

                //Submit Button
                InkWell(
                  onTap: (){
                    if (_formKey.currentState.validate()) {
                      //    If all data are correct then save data to out variables
                      _formKey.currentState.save();
                      login();
                    }
                    else {
                      //    If all data are not valid then start auto validation.
                      setState(() {
                        _autoValidate = true;
                      });
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.0),
                    alignment: Alignment.bottomCenter,
                    height: 56.0,
                    decoration: BoxDecoration(
                        color: AppColor.THEME_PRIMARY,
                        borderRadius: BorderRadius.all(Radius.circular(4.0))
                    ),
                    child: Center(
                      child: Text(
                        'Sign In',
                        textAlign: TextAlign.center,
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
                SizedBox(height: 16.0,),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have a Dottie account?  ",
                        style: TextStyle(
                          color: AppColor.TYPE_PRIMARY,
                          fontSize: TextSize.subjectTitle,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                          fontFamily: 'WorkSans'
                        ),
                      ),

                      InkWell(
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterUserPage()
                              )
                          );
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                              color: AppColor.THEME_PRIMARY,
                              fontSize: TextSize.subjectTitle,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.normal,
                              fontFamily: 'WorkSans'
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 10.0,),
                Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: (){
                          _launchURL(
                              "helpme@dottie.com",
                              "Help request for Inspector Dottie",
                              "Thank you for helping us make Inspector Dottie an incredible experience. Our support team will reach out to you soon.\n\nPlease describe the issue here:"
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal:10.0, vertical: 20.0),
                          child: Text(
                            'Help',
                            style: TextStyle(
                                color: AppColor.THEME_PRIMARY,
                                fontSize: TextSize.subjectTitle,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'WorkSans',
                                fontStyle: FontStyle.normal
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PrivacyPolicyPage()
                              )
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal:10.0, vertical: 20.0),
                          child: Text(
                            'Privacy Policy',
                            style: TextStyle(
                                color: AppColor.THEME_PRIMARY,
                                fontSize: TextSize.subjectTitle,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'WorkSans',
                                fontStyle: FontStyle.normal
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50.0,),
              ],
            ),
          ),
          _progressHUD
        ],
      ),
    );
  }

  Widget formUI(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        //Email Address
        Container(
          margin: EdgeInsets.only(top: 16.0,left: 20.0, right: 20.0),
          child:TextFormField(
            controller: emailController,
            focusNode: emailFocus,
            onFieldSubmitted: (term) {
              emailFocus.unfocus();
              FocusScope.of(context).requestFocus(passwordFocus);
            },
            validator: validateEmail,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            textAlign: TextAlign.start,
            decoration: InputDecoration(
                fillColor: AppColor.WHITE_COLOR,
                hintText: "Your Email Address",
                contentPadding: EdgeInsets.symmetric(horizontal: 0,),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  borderSide: BorderSide(width: 1,color: AppColor.TRANSPARENT),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  borderSide: BorderSide(width: 1,color: AppColor.TRANSPARENT),
                ),
                labelText: 'Your Email Address',
                hintStyle: TextStyle(
                    fontSize: TextSize.bodyText,
                    fontWeight: FontWeight.w500,
                    color: AppColor.TYPE_SECONDARY
                ),
                labelStyle: TextStyle(
                    fontSize: TextSize.bodyText,
                    fontWeight: FontWeight.w500,
                    color: AppColor.TYPE_SECONDARY
                ),
            ),
            style: TextStyle(
                color: AppColor.TYPE_PRIMARY,
                fontWeight: FontWeight.w600,
                fontSize: TextSize.subjectTitle
            ),
            inputFormatters: [LengthLimitingTextInputFormatter(40)],
            onChanged: (value){

            },
          ),
        ),
        SizedBox(height: 16.0,),
        Divider(
          height: 1.0,
          color: AppColor.SEC_DIVIDER,
        ),
        //Password
        Container(
          margin: EdgeInsets.only(top: 16.0,left: 20.0, right: 20.0),
          child:TextFormField(
            controller: passwordController,
            focusNode: passwordFocus,
            validator: validatePassword,
            textInputAction: TextInputAction.done,
            textAlign: TextAlign.start,
            decoration: InputDecoration(
              fillColor: AppColor.BG_PRIMARY_ALT,
              hintText: "Your Password",
              contentPadding: EdgeInsets.symmetric(horizontal: 0,),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                borderSide: BorderSide(width: 1,color: AppColor.TRANSPARENT),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                borderSide: BorderSide(width: 1,color: AppColor.TRANSPARENT),
              ),
              labelText: 'Your Password',
              hintStyle: TextStyle(
                  fontSize: TextSize.bodyText,
                  fontWeight: FontWeight.w500,
                  color: AppColor.TYPE_SECONDARY
              ),
              labelStyle: TextStyle(
                  fontSize: TextSize.bodyText,
                  fontWeight: FontWeight.w500,
                  color: AppColor.TYPE_SECONDARY
              ),
              suffixIcon: Visibility(
                visible: _obscureTextVisible,
                child: IconButton(
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColor.TYPE_SECONDARY,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
            ),
            obscureText: _obscureText,
            onChanged: (value){
              setState(() {
                _obscureTextVisible = value.isNotEmpty;
              });
            },
            style: TextStyle(
                color: AppColor.TYPE_PRIMARY,
                fontWeight: FontWeight.w600,
                fontSize: TextSize.subjectTitle
            ),
            inputFormatters: [LengthLimitingTextInputFormatter(40)],
          ),
        ),
        SizedBox(height: 16.0,),
      ],
    );
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if(value != '') {
      if (!regex.hasMatch(value))
        return 'Enter your valid email address';
      else
        return null;
    } else {
      return 'Enter your email address';
    }
  }

  String validatePassword(String value) {
    if(value!='' && value!=null) {
      if(!value.startsWith(' '))
        return null;
      else
        return 'Enter your valid password';
    }
    else {
      return 'Enter your password';
    }

  }

  _launchURL(String toMailId, String subject, String body) async {
    var url = 'mailto:$toMailId?subject=$subject&body=$body';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  ///////////////////////////API INTEGRATION////////////////////////
  Future<void> verifyEmailAddress(verifyString) async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var str1 = Uri.encodeQueryComponent(verifyString);
    print("Original String    $verifyString");
    print("Encoded String     $str1");
    var str = str1.replaceAll("/","%252f").replaceAll("+", "%252b");
    print("Final String $str");

    var  response = await request.getUnAuthRequest("unauth/verify/$str");
    _progressHUD.state.dismiss();

    if (response != null) {
      print(response);
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage('${response['reason']}');
//        _scaffoldKey.currentState.showSnackBar(HelperClass.showSnackBar(context, '${response['reason']}'));
      } else {
        PreferenceHelper.setToken("${response['token']}");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ResetPasswordPage(
                  type: "register",
                )
            )
        );
      }
    }
  }

  Future<void> login() async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var requestParam = {
      "email":"${emailController.text.toString().trim()}",
      "password":"${passwordController.text.toString().trim()}"
    };
    var response = await request.login("unauth/login", requestParam);
    _progressHUD.state.dismiss();
    print("Login response get back: $response");

    if (response != null) {
      if (response['success']) {
        var userData = {
          "token": "${response['token']}",
          "refresh_token": "${response['refresh_token']}",
          "user_name": "${emailController.text}"
        };
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt(PreferenceHelper.LAST_REFRESH, DateTime.now().millisecondsSinceEpoch);

        PreferenceHelper.saveUserPreferenceData(userData);
        PreferenceHelper.setPreferenceData("drawerMenu", drawerMenu.home.toString());
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
//            builder: (context) => SafetyEquipmentInspectionPage(),
            builder: (context) => WelcomeNavigationScreen(),
          ),
          ModalRoute.withName(WelcomeNavigationScreen.tag),
        );
      } else {
        HelperClass.showSnackBar(context, '${response['reason']}');
      }
    } else {
      HelperClass.displayDialog(context, "${response['reason']}");
    }
  }
}
