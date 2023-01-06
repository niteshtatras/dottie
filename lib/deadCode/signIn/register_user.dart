
import 'package:dottie_inspector/pages/signInPages/login_page_1.dart';
import 'package:dottie_inspector/deadCode/signIn/login_page.dart';
import 'package:dottie_inspector/deadCode/signIn/register_email.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterUserPage extends StatefulWidget {

  @override
  _RegisterUserPageState createState() => _RegisterUserPageState();
}

class _RegisterUserPageState extends State<RegisterUserPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  final FocusNode firstNameFocus = FocusNode();
  final FocusNode lastNameFocus = FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _allFieldValidate = false;
  PageController _pageController;
  ScrollController _pageScrollController = new ScrollController();
//  KeyboardVisibilityNotification _keyboardVisibility = new KeyboardVisibilityNotification();
//  int _keyboardVisibilitySubscriberId;
  bool _keyboardState;

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
  }

  @override
  void dispose() {
//    _keyboardVisibility.removeListener(_keyboardVisibilitySubscriberId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.WHITE_COLOR,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: AppColor.WHITE_COLOR,
        leading: IconButton(
          padding: EdgeInsets.only(left: 16.0, right: 16.0),
          icon: Icon(Icons.keyboard_backspace,color: AppColor.TYPE_PRIMARY,size: 32.0,),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text(
          '',
          style: TextStyle(
              color: AppColor.TYPE_PRIMARY,
              fontSize: TextSize.headerText,
              fontWeight: FontWeight.w600
          ),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _pageScrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 10.0,),
                  Image(
                    image: AssetImage('assets/splash_main.png'),
                    fit: BoxFit.cover,
                    height: 150.0,
                    width: 150.0,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 12.0),
                    child: Text(
                      'Welcome!',
                      style: TextStyle(
                          color: AppColor.TYPE_PRIMARY,
                          fontSize: TextSize.greetingTitleText,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                          fontFamily: "WorkSans"
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16.0),
                    child: Text(
                      'First things first. What’s your name?',
                      style: TextStyle(
                          color: AppColor.TYPE_SECONDARY,
                          fontSize: TextSize.subjectTitle,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                          fontFamily: "WorkSans"
                      ),
                    ),
                  ),
                  Form(
                    key: _formKey,
//                autovalidate: _autoValidate,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[

                        Table(
                          children: [

                          ],
                        ),
                        //First Name
                        Container(
                          margin: EdgeInsets.only(top: 40.0 ,left: 20.0, right: 20.0),
                          width: MediaQuery.of(context).size.width,
                          child:TextFormField(
                            controller: _firstNameController,
                            focusNode: firstNameFocus,
                            keyboardType: TextInputType.text,
                            textAlign: TextAlign.start,
                            autofocus: false,
                            validator: (value){
                              return validateString(value, "first name");
                            },
                            onFieldSubmitted: (term) {
                              firstNameFocus.unfocus();
                              FocusScope.of(context).requestFocus(lastNameFocus);
                            },
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              fillColor: AppColor.WHITE_COLOR,
                              hintText: "First Name",
                              contentPadding: EdgeInsets.symmetric(horizontal: 0,),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(width: 1,color: AppColor.TRANSPARENT),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(width: 1,color: AppColor.TRANSPARENT),
                              ),
                              labelText: 'First Name',
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
                              setState(() {
                                _allFieldValidate = _formKey.currentState.validate();
                              });
                            },
                          ),
                        ),
                        Divider(
                          height: 1.0,
                          color: AppColor.SEC_DIVIDER,
                        ),

                        //Last Name
                        Container(
                          margin: EdgeInsets.only(top: 28.0 ,left: 20.0, right: 20.0),
                          width: MediaQuery.of(context).size.width,
                          child:TextFormField(
                            controller: _lastNameController,
                            focusNode: lastNameFocus,
                            textAlign: TextAlign.start,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.done,
                            validator: (value){
                              return validateString(value, "last name");
                            },
                            decoration: InputDecoration(
                              fillColor: AppColor.WHITE_COLOR,
                              hintText: "Last Name",
                              contentPadding: EdgeInsets.symmetric(horizontal: 0,),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(width: 1,color: AppColor.TRANSPARENT),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(width: 1,color: AppColor.TRANSPARENT),
                              ),
                              labelText: 'Last Name',
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
                              setState(() {
                                _allFieldValidate = _formKey.currentState.validate();
                              });
                            },
                          ),
                        ),
                        Divider(
                          height: 1.0,
                          color: AppColor.SEC_DIVIDER,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.0,),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "I already have a Dottie account?  ",
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
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPage1(),
                              ),
                              ModalRoute.withName(LoginPage1.tag));
                          },
                          child: Text(
                            "Sign In",
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
                  SizedBox(height: 200.0,)
                ],
              ),
            ),
           // Submit Button
            Positioned(
              bottom: 16.0,
              left: 20.0,
              right: 20.0,
              child: InkWell(
                onTap: (){
                  if(_formKey.currentState.validate() && _allFieldValidate){
                    Map nameData = {
                      "first_name": "${_firstNameController.text.toString().trim()}",
                      "last_name": "${_lastNameController.text.toString().trim()}"
                    };
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterEmailPage(
                          nameData : nameData
                        )
                      )
                    );
//                    Navigator.of(context).pop({"data":nameData});
                  } else {
                    setState(() {
                      firstNameFocus.requestFocus(FocusNode());
                      _autoValidate = true;
                    });
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(top: 24.0),
                  height: 56.0,
                  decoration: BoxDecoration(
                      color: _allFieldValidate ? AppColor.THEME_PRIMARY : AppColor.DEACTIVATE,
                      borderRadius: BorderRadius.all(Radius.circular(4.0))
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          '         CONTINUE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColor.WHITE_COLOR,
                            fontSize: TextSize.subjectTitle,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 16.0),
                        padding: EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                          color: _allFieldValidate ? AppColor.DARK_BLUE_COLOR : AppColor.TYPE_SECONDARY_ALT
                        ),
                        child: Icon(Icons.arrow_forward, color: AppColor.WHITE_COLOR,)
                      )
                    ],
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
