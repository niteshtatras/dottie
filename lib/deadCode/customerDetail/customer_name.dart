import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddCustomerName extends StatefulWidget {
  final nameData;

  const AddCustomerName({Key key, this.nameData}) : super(key: key);

  @override
  _AddCustomerNameState createState() => _AddCustomerNameState();
}

class _AddCustomerNameState extends State<AddCustomerName> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  final FocusNode firstNameFocus = FocusNode();
  final FocusNode lastNameFocus = FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _allFieldValidate = false;
  var mainMargin = 20.0;

  @override
  void initState() {
    super.initState();

    _firstNameController.text = widget.nameData != null ? widget.nameData['first_name'] : "";
    _lastNameController.text = widget.nameData != null ? widget.nameData['last_name'] : "";

    setState(() {
      _allFieldValidate = _firstNameController.text.isNotEmpty && _lastNameController.text.isNotEmpty;
    });
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
//        actions: <Widget>[
//          InkWell(
//            onTap: (){
//              setState(() {
//                _firstNameController.text = '';
//                _lastNameController.text = '';
//                _allFieldValidate = false;
//                FocusScope.of(context).requestFocus(FocusNode());
//              });
//            },
//            child: Container(
//              padding: EdgeInsets.all(16.0),
//              child: Image.asset(
//                'assets/ic_delete.png',
//                fit: BoxFit.contain,
//                height: 28.0,
//                width: 28.0,
//                color: AppColor.RED_COLOR,
//              ),
//            ),
//          )
//        ],
        title: Text(
          'Name',
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
          children: <Widget>[
            SingleChildScrollView(
              child: Form(
                key: _formKey,
//                autovalidate: _autoValidate,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[

                    //First Name
                    Container(
                      margin: EdgeInsets.only(top: 28.0 ,left: 32.0, right: 32.0),
                      child:TextFormField(
                        controller: _firstNameController,
                        focusNode: firstNameFocus,
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
                          contentPadding: EdgeInsets.symmetric(horizontal: 0.0,),
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
                      margin: EdgeInsets.only(top: 28.0 ,left: 32.0, right: 32.0),
                      child:TextFormField(
                        controller: _lastNameController,
                        focusNode: lastNameFocus,
                        textAlign: TextAlign.start,
                        textInputAction: TextInputAction.done,
                        validator: (value){
                          return validateString(value, "last name");
                        },
                        decoration: InputDecoration(
                          fillColor: AppColor.WHITE_COLOR,
                          hintText: "Last Name",
                          contentPadding: EdgeInsets.symmetric(horizontal: 0.0,),
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
            ),

            //Submit Button
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
                    Navigator.of(context).pop({"data":nameData});
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
                  child: Center(
                    child: Text(
                      'SAVE NAME',
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
