import 'dart:async';
import 'dart:convert';

import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:flutter/material.dart';
import 'package:progress_hud/progress_hud.dart';

class CountryListPage extends StatefulWidget {
  final type;

  const CountryListPage({Key key, this.type}) : super(key: key);

  @override
  _CountryListPageState createState() => _CountryListPageState();
}

class _CountryListPageState extends State<CountryListPage> {
  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;

  Timer timer;

  TextEditingController controller = new TextEditingController();
  bool _searchClear = false;
  bool focusEnable = false;
  var jsonResult;
  List countryList;
  Map countryMap;
  List countryHeaderList;
  int selectedIndex = -1;
  int selectedSubIndex = -1;
  Map countryData;
  int alphaIndex = 64;
  int countIndex = 0;
  bool visibleAlpha = false;
  List _searchResult = List();

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

    timer = Timer(Duration(milliseconds: 1000), getCountryList);
//    getJsonFile();
  }

  void getJsonFile() async {
    String data = await DefaultAssetBundle.of(context).loadString("assets/country_list.json");

    setState(() {
      jsonResult = json.decode(data);
      countryList = List();
      countryList = jsonResult['data'];
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
            Navigator.of(context).pop({"countryData": countryData});
          },
        ),
//        actions: <Widget>[
//          InkWell(
//            onTap: (){
//              setState(() {
//                selectedIndex = -1;
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
          'Select Country',
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
              margin: EdgeInsets.only(top: 75.0,bottom: 70.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _searchResult.length != 0 || controller.text.isNotEmpty
                  ? Container(
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _searchResult != null ? _searchResult.length : 0,
                        itemBuilder: (context, index){
                          var countryName = _searchResult[index]['mixedcase'] != null
                              ? _searchResult[index]['mixedcase']
                              : _searchResult[index]['countryname'];
                          var dialCode = _searchResult[index]['dialcode'] != null
                              ? "(+${_searchResult[index]['dialcode']})"
                              : '';
                          return Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            widget.type == 1
                                                  ? '$countryName'
                                                  : '$countryName$dialCode',
                                            style: TextStyle(
                                                color: AppColor.TYPE_PRIMARY,
                                                fontSize: TextSize.headerText,
                                                fontStyle: FontStyle.normal,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'WorkSans'
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),

                                        //
                                        selectedIndex == index
                                            ? Container(
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
                                        )
                                            : InkWell(
                                          onTap: (){
                                            setState(() {
                                              selectedIndex = index;
                                              countryData = _searchResult[index];
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
                                  Divider(height: 1.0, color: AppColor.SEC_DIVIDER,)
                                ],
                              )
                          );
                        },
                      ),
                  )
                  : Container(
                     child:  ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: countryHeaderList != null ? countryHeaderList.length : 0,
                      itemBuilder: (context, index){
                        return Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 22.0),
                                  child: Text(
                                    '${countryHeaderList[index]['key']}',
                                    style: TextStyle(
                                        color: AppColor.TYPE_SECONDARY,
                                        fontFamily: 'WorkSans',
                                        fontWeight: FontWeight.w600,
                                        fontSize: TextSize.bodyText
                                    ),
                                  ),
                                ),
                                ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: countryHeaderList[index]['values'] != null ? countryHeaderList[index]['values'].length : 0,
                                  itemBuilder: (context, subIndex){
                                    var countryName = countryHeaderList[index]['values'][subIndex]['mixedcase'] != null
                                                      ? countryHeaderList[index]['values'][subIndex]['mixedcase']
                                                      : countryHeaderList[index]['values'][subIndex]['countryname'];
                                    var dialCode = countryHeaderList[index]['values'][subIndex]['dialcode'] != null
                                                    ? "(+${countryHeaderList[index]['values'][subIndex]['dialcode']})"
                                                    : '';
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
                                              Expanded(
                                                child: Text(
                                                  widget.type == 1
                                                  ? '$countryName'
                                                  : '$countryName$dialCode',
                                                  style: TextStyle(
                                                      color: AppColor.TYPE_PRIMARY,
                                                      fontSize: TextSize.headerText,
                                                      fontStyle: FontStyle.normal,
                                                      fontWeight: FontWeight.w600,
                                                      fontFamily: 'WorkSans'
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),

                                              //
                                              selectedIndex == index && selectedSubIndex == subIndex
                                                  ? Container(
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
                                              )
                                                  : InkWell(
                                                onTap: (){
                                                  setState(() {
                                                    selectedIndex = index;
                                                    selectedSubIndex = subIndex;
                                                    countryData = countryHeaderList[index]['values'][subIndex];
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
                                        Divider(height: 1.0, color: AppColor.SEC_DIVIDER,)
                                      ],
                                    );
                                  },
                                ),
                              ],
                            )
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          _progressHUD,
          //Search bar
          Positioned(
            child: Visibility(
              visible: countryHeaderList != null,
              child: Container(
                color: AppColor.BG_PRIMARY,
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 22.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/ic_search.png',
                      fit: BoxFit.contain,
                      height: 24.0,
                      width: 24.0,
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 16.0,right: 16.0),
                        child:  TextField(
                          autofocus: focusEnable,
                          controller: controller,
                          decoration: new InputDecoration(
                              hintText: 'Search',
                              border: InputBorder.none
                          ),
                          onChanged: onSearchTextChanged,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: _searchClear,
                      child: IconButton(
                        onPressed: (){
                          controller.clear();
                          onSearchTextChanged('');
                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                        icon: Icon(
                          Icons.clear,
                          color: AppColor.TYPE_PRIMARY,
                          size: 24.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {
        _searchClear = false;
      });
      return;
    }
    _searchClear = true;
    for(int i=0; i<countryHeaderList.length ; i++) {
      for(int j=0; j<countryHeaderList[i]['values'].length ; j++) {
        if(countryHeaderList[i]['values'][j]['mixedcase'].toString().toLowerCase().contains(text.toLowerCase())){
          setState(() {
            _searchResult.add(countryHeaderList[i]['values'][j]);
          });
        }
      }
    }
  }

  ///////////API Integration/////////////////
  Future<void> getCountryList() async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var response = await request.getUnAuthRequest("unauth/countries");
//    print("Country list response get back: $response");
    _progressHUD.state.dismiss();

    if (response != null) {
      countryList = List();
      setState(() {
        countryList = response;
//        countryHeaderList = response;
        filterCountryList(countryList);
      });
    } else {

    }
  }

  void filterCountryList(countriesList) {
    print("Country list response get back: $countriesList");
    countryHeaderList = List();
    for(int i=0; i<26; i++){
      List countryDataList = List();
      for(int j=0; j<countriesList.length; j++){
        if(countriesList[j]['mixedcase'].toString().toUpperCase().startsWith(String.fromCharCode(i+65))){
          countryDataList.add(countriesList[j]);
        }
      }
      countryMap = {
        "key": String.fromCharCode(i+65),
        "values": countryDataList
      };
      countryHeaderList.add(countryMap);
    }
    print("List====$countryHeaderList");

//    int code = 65;
//    int countIndex = 0;

//    CountryListData countryData;
//    for(int i=0; i<countriesList.length; i++){
//      if(countryData != null){
//        countryData = CountryListData();
//      }
//      if(countIndex == 0)
//        countryData.key = "A";
//
//      if (countriesList[i].toString().toUpperCase().startsWith(String.fromCharCode(code))) {
//        CountryDetailData countryValue = CountryDetailData(
//          countriesList[i]['countrycode'],
//          countriesList[i]['countrycode3'],
//          countriesList[i]['mixedcase'],
//          countriesList[i]['mixedcase'],
//          countriesList[i]['flag'],
//          countriesList[i]['dialcode'],
//          countriesList[i]['postalcoderegex'],
//          0
//        );
//        countryData.values.add(countryValue);
//        countIndex++;
//      } else {
//        code++;
//        countIndex = 0;
//        countryList.add(countryData);
//        countryData = null;
//      }
//    }

//    print("List ${countryList.toString}");
  }
}
