import 'dart:async';
import 'dart:convert';

import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:flutter/material.dart';
import 'package:progress_hud/progress_hud.dart';

class StateListPage extends StatefulWidget {
  final countryCode;

  const StateListPage({Key key, this.countryCode}) : super(key: key);

  @override
  _StateListPageState createState() => _StateListPageState();
}

class _StateListPageState extends State<StateListPage> {

  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;
  var countryCode = 'US';

  Timer timer;

  Map stateData;
  TextEditingController controller = new TextEditingController();
  bool focusEnable = false;
  var jsonResult;
  List stateList;
  int selectedIndex = -1;

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
    countryCode = widget.countryCode ?? 'US';
    timer = Timer(Duration(milliseconds: 100), getStateList);
//    getJsonFile();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    timer.cancel();
  }

  void getJsonFile() async {
    String data = await DefaultAssetBundle.of(context).loadString("assets/state_list.json");

    setState(() {
      jsonResult = json.decode(data);
      stateList = List();
      stateList = jsonResult['data'];
    });
    print("JsonResult $jsonResult");
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
            size: 32.0,
          ),
          onPressed: () {
            Navigator.of(context).pop({"stateData": stateData});
          },
        ),
//        actions: <Widget>[
//          InkWell(
//            onTap: (){
//              setState(() {
//                selectedIndex = -1;
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
          'Select State',
          style: TextStyle(
              color: AppColor.TYPE_PRIMARY,
              fontSize: TextSize.headerText,
              fontWeight: FontWeight.w600),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(top: 25.0,bottom: 70.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: stateList != null ? stateList.length : 0,
                      itemBuilder: (context, index){
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${stateList[index]['label']}',
                                    style: TextStyle(
                                        color: AppColor.TYPE_PRIMARY,
                                        fontSize: TextSize.headerText,
                                        fontStyle: FontStyle.normal,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'WorkSans'
                                    ),
                                  ),

                                  //
                                  selectedIndex == index
                                  ? InkWell(
                                    onTap: (){

                                    },
                                    child: Container(
                                      height: 45.0,
                                      width: 45.0,
                                      decoration: BoxDecoration(
                                        color: AppColor.THEME_PRIMARY,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.done,
                                        size: 24.0,
                                        color: AppColor.WHITE_COLOR,
                                      ),
                                    ),
                                  )
                                      : InkWell(
                                    onTap: (){
                                      setState(() {
                                        selectedIndex = index;
                                        stateData = stateList[index];
                                        FocusScope.of(context).requestFocus(FocusNode());
                                      });
                                    },
                                    child: Container(
                                      height: 45.0,
                                      width: 45.0,
                                      decoration: BoxDecoration(
                                          color: AppColor.WHITE_COLOR,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: AppColor.TYPE_SECONDARY, width: 1.0)
                                      ),
                                      child: Icon(
                                        Icons.done,
                                        size: 24.0,
                                        color: AppColor.WHITE_COLOR,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(height: 1.0, color: AppColor.SEC_DIVIDER,),
                          ],
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
          _progressHUD
        ],
      ),
    );
  }

  ///////////API Integration/////////////////
  Future<void> getStateList() async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var response = await request.getUnAuthRequest("unauth/states/$countryCode");
    print("Country list response get back: $response");
    _progressHUD.state.dismiss();

    if (response != null) {
      stateList = List();
      setState(() {
        stateList = response;
      });
    } else {

    }
  }
}
