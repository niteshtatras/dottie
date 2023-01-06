import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddCustomerZipCodePage extends StatefulWidget {
  final zipData;

  const AddCustomerZipCodePage({Key key, this.zipData}) : super(key: key);

  @override
  _AddCustomerZipCodePageState createState() => _AddCustomerZipCodePageState();
}

class _AddCustomerZipCodePageState extends State<AddCustomerZipCodePage> {
  bool _allFieldValidate = false;
  bool _autoValidate = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _zipCodeController = TextEditingController();
  FocusNode _zipCodeFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    _zipCodeController.text = widget.zipData != null ? widget.zipData['zipCode'] : "";
    _allFieldValidate = _zipCodeController.text.isNotEmpty;
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
          icon: Icon(
            Icons.keyboard_backspace,
            color: AppColor.TYPE_PRIMARY,
            size: 28.0,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
//        actions: <Widget>[
//          InkWell(
//            onTap: (){
//              setState(() {
//                _zipCodeController.text = "";
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
          'Add Zip Code',
          style: TextStyle(
              color: AppColor.TYPE_PRIMARY,
              fontSize: TextSize.headerText,
              fontWeight: FontWeight.w600),
        ),
      ),
      body: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Zip Code
                  Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Container(
                      margin: EdgeInsets.only(top: 28.0 ,left: 20.0, right: 20.0),
                      child:TextFormField(
                        controller: _zipCodeController,
                        focusNode: _zipCodeFocus,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.start,
                        validator: (value){
                          return validateString(value, "zip code");
                        },
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          fillColor: AppColor.WHITE_COLOR,
                          hintText: "Zip Code",
                          contentPadding: EdgeInsets.symmetric(horizontal: 0.0,),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            borderSide: BorderSide(width: 1, color: AppColor.TRANSPARENT),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            borderSide: BorderSide(width: 1, color: AppColor.TRANSPARENT),
                          ),
                          labelText: 'Zip Code',
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
                  Map zipData = {
                    "zipCode": "${_zipCodeController.text.toString().trim()}",
                  };
                  Navigator.of(context).pop({"data": zipData});
                }else{
                  setState(() {
                    _zipCodeFocus.requestFocus(FocusNode());
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
                    'SAVE ZIP CODE',
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
