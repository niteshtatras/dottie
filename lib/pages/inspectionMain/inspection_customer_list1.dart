import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dottie_inspector/connection_mixin.dart';
import 'package:dottie_inspector/database/database_helper.dart';
import 'package:dottie_inspector/pages/menu/drawer_page.dart';
import 'package:dottie_inspector/pages/signInPages/login_page_1.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/SlideRightRoute.dart';
import 'package:dottie_inspector/utils/custom_toast.dart';
import 'package:dottie_inspector/utils/language.dart';
import 'package:dottie_inspector/widget/gradient/grediant_box_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:progress_hud/progress_hud.dart';

import '../../utils/helper_class.dart';
import '../../webServices/AllRequest.dart';

class InspectionCustomerList1Page extends StatefulWidget {
  static String tag = 'inspection-customer-list1-page';
  final type;

  const InspectionCustomerList1Page({Key key, this.type}) : super(key: key);

  @override
  _InspectionCustomerList1PageState createState() => _InspectionCustomerList1PageState();
}

class _InspectionCustomerList1PageState extends State<InspectionCustomerList1Page> with MyConnection{
  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;

  Timer timer;

  TextEditingController controller = new TextEditingController();
  FocusNode _searchFocus = FocusNode();
  bool isSearchFocus = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool deleteEnable = false;
  bool deactivateEnable = false;
  int activateValue = 0;
  bool _searchClear = false;
  bool focusEnable = false;
  bool _inactivateCustomers = false;
  var jsonResult;
  List customerList;
  List customerMainList;
  List _searchResult = [];
  List selectCustomer = [];
  int alphaIndex = 64;

  String inspectionType = "Active";
  String lang = "en";

  bool isDarkMode = false;
  Color themeColor = AppColor.BLACK_COLOR;

  final dbHelper = DatabaseHelper.instance;

  bool _isInternetAvailable = true;
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

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

    _searchFocus.addListener(() {
      setState(() {
        isSearchFocus = _searchFocus.hasFocus;
      });
    });

   getPreferencesData();
  }

  void getPreferencesData() async {
    var language = await PreferenceHelper.getPreferenceData(PreferenceHelper.LANGUAGE) ?? "en";

    setState(() {
      lang = language;
    });

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

    ///Offline mode
   initConnectivity();
    ///End

    ///Online Mode
    // timer = Timer(Duration(milliseconds: 1000), getCustomerList);
  }

  @override
  void initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      log('Couldn\'t check connectivity status', error: e);
      return;
    }

    connectionSubscription();

    if (!mounted) {
      return Future.value(null);
    }

    return updateConnectionStatus(result);
  }

  @override
  void connectionSubscription() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      updateConnectionStatus(result);
    });
  }

  @override
  void updateConnectionStatus(result) {
    setState(() {
      _connectivityResult = result;
      if (_connectivityResult == ConnectivityResult.none) {
        _isInternetAvailable = false;
        customerListFromLocalDB();
      } else if ((_connectivityResult == ConnectivityResult.mobile) || (_connectivityResult == ConnectivityResult.wifi)) {
        _isInternetAvailable = true;
        getCustomerList();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
    timer.cancel();
  }

  void getJsonFile() async {
    String data = await DefaultAssetBundle.of(context).loadString("assets/customer_list.json");

    setState(() {
      jsonResult = json.decode(data);
      customerList = [];
      customerList = jsonResult['data'];
    });
    print("JsonResult $jsonResult");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? AppColor.BLACK_COLOR : AppColor.PAGE_COLOR,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: isDarkMode ? AppColor.BLACK_COLOR : AppColor.PAGE_COLOR,
        /*actions: <Widget>[
          IconButton(
            padding: EdgeInsets.all(16.0),
            icon: Icon(
              Icons.more_horiz,
              color: AppColor.TYPE_PRIMARY,
            ),
            onPressed: (){
              focusEnable = false;
              if(deleteEnable){
                bottomSelectNavigation(context);
              } else{
                bottomNavigation(context);
              }
            },
          ),
        ],*/

        /*leading: widget.type == 0
          ? IconButton(
              padding: EdgeInsets.only(left: 16.0, right: 16.0),
              icon: Icon(Icons.clear,color: AppColor.TYPE_PRIMARY,size: 32.0,),
              onPressed: (){
                setState(() {
                  Navigator.pop(context);
//                  deleteEnable = false;
//                  selectCustomer.clear();
//                  filterCustomerList1(customerMainList, 'inactive');
                });
              },
            )
          : IconButton(
              padding: EdgeInsets.only(left: 16.0, right: 16.0),
              icon: Icon(Icons.menu,color: AppColor.TYPE_PRIMARY,size: 32.0,),
              onPressed: (){
                _scaffoldKey.currentState.openDrawer();
              },
            ),*/
        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: Container(
            padding: EdgeInsets.all(6),
            child: Image.asset(
              isDarkMode
              ? 'assets/ic_dark_close.png'
              : 'assets/ic_back_close.png',
              fit: BoxFit.cover,
              width: 44,
              height: 44,
            ),
          ),
        ),
        title: Text(
          lang == "en" ? selectCustomerTitleEn : selectCustomerTitleEs,
          style: TextStyle(
              color: themeColor,
              fontSize: TextSize.headerText,
              fontWeight: FontWeight.w700
          ),
        ),
      ),
      key: _scaffoldKey,
      drawer: Drawer(
        child: DrawerPage(),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(top: 8.0,bottom: 70.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 72.0,
                    margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 16.0),
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isSearchFocus && isDarkMode
                              ? AppColor.gradientColor(0.32)
                              : isSearchFocus
                              ? AppColor.gradientColor(0.16)
                              : isDarkMode
                              ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                              : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
                        ),
                        borderRadius: BorderRadius.circular(32.0),
                        border: GradientBoxBorder(
                            gradient: LinearGradient(
                              colors: isSearchFocus
                                  ? AppColor.gradientColor(1.0)
                                  : [AppColor.TRANSPARENT, AppColor.TRANSPARENT],
                            ),
                            width: 3
                        )
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'assets/welcome/ic_search.png',
                                  fit: BoxFit.contain,
                                  height: 20.0,
                                  width: 20.0,
                                  color: AppColor.TYPE_PRIMARY,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: controller,
                                    textAlign: TextAlign.start,
                                    keyboardType: TextInputType.name,
                                    textInputAction: TextInputAction.done,
                                    autofocus: false,
                                    focusNode: _searchFocus,
                                    onFieldSubmitted: (term) {
                                      _searchFocus.unfocus();
                                    },
                                    decoration: InputDecoration(
                                      fillColor: AppColor.TRANSPARENT,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                                      filled: false,
                                      border: InputBorder.none,
                                      hintText: lang == 'en' ? customerSearchEn : customerSearchEs,
                                      hintStyle: TextStyle(
                                          fontSize: TextSize.subjectTitle,
                                          color: isDarkMode
                                              ? Color(0xff545454)
                                              : Color(0xff808080)
                                      ),
                                    ),
                                    style: TextStyle(
                                        color: AppColor.TYPE_PRIMARY,
                                        fontWeight: FontWeight.w600,
                                        fontSize: TextSize.subjectTitle
                                    ),
                                    onChanged: onSearchTextChanged,
                                    inputFormatters: [LengthLimitingTextInputFormatter(40)],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Visibility(
                          visible: controller.text != '',
                          child: GestureDetector(
                            onTap: (){
//                            showActiveDialog(context);
                              setState(() {
                                controller.text = '';
                                _searchResult.clear();
                                _searchClear = false;
                                // filterCustomerList1(customerMainList, 'inactive');
                              });
                              // onSearchTextChanged("");
                            },
                            child: Container(
                              padding: EdgeInsets.all(6),
                              child: Image.asset(
                                'assets/ic_back_close.png',
                                fit: BoxFit.cover,
                                width: 44,
                                height: 44,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  customerList == null
                  ? Container()
                  : customerList.length == 0
                  ? HelperClass.getNoDataFountText("No Customer Available yet!")
                  : _searchResult.length == 0 && controller.text.isNotEmpty
                  ? HelperClass.getNoDataFountText("No Record Match!")
                  : _searchResult.length != 0 || controller.text.isNotEmpty
                  ? ListView.builder(
                      itemCount:  _searchResult != null ? _searchResult.length : 0,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index){
                        return Slidable(
                          actionExtentRatio: 0.35,
                          actionPane: SlidableScrollActionPane(),
                          child: Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: (){
                                 /* Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              CustomerDetailPage(
                                                customerData: _searchResult[index],
                                              )
                                      )
                                  );*/
                                  if(widget.type == 0) {
                                    if(_isInternetAvailable) {
                                      getCustomerDetail(_searchResult[index]['customerData']['clientid'], _searchResult[index]['customerData']['lastUpdated']);
                                    } else {
                                      loadCustomerDetailFromLocalDb(_searchResult[index]['customerData']['clientid']);
                                    }
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16),
                                  margin: EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? Color(0xff1f1f1f)
                                        : AppColor.TYPE_PRIMARY.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(32.0),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      !deleteEnable
                                      ? Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                              colors: [
                                                Color(0xff013399),
                                                Color(0xffBC96E6),
                                              ]
                                          ),
                                          borderRadius: BorderRadius.circular(32.0),
                                        ),
//                                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                                        height: 48.0,
                                        width: 48.0,
                                        alignment: Alignment.center,
                                        child: Text(
                                          _searchResult[index]['customerData']['firstname'] != null
                                              ? '${_searchResult[index]['customerData']['firstname'][0]}'
                                              : "-",
                                          style: TextStyle(
                                              color: AppColor.WHITE_COLOR,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 24.0
                                          ),
                                        ),
                                      )
                                      : _searchResult[index]['customerData']['status'] == 0
                                      ? GestureDetector(
                                        onTap: (){
                                          setState(() {
                                            _searchResult[index]['customerData']['status'] = 1;
                                            selectCustomer.add(_searchResult[index]['customerData']['clientid']);
                                          });
                                          print("CustomerIds===${selectCustomer.toString()}");
                                          setState(() {
                                            deactivateEnable = selectCustomer.length > 0;
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
                                      )
                                      : GestureDetector(
                                        onTap: (){
                                          setState(() {
                                            _searchResult[index]['customerData']['status'] = 0;
                                            selectCustomer.remove(_searchResult[index]['customerData']['clientid']);
                                          });
                                          print("CustomerIds===${selectCustomer.toString()}");
                                          setState(() {
                                            deactivateEnable = selectCustomer.length > 0;
                                          });
                                        },
                                        child: Container(
                                          height: 45.0,
                                          width: 45.0,
                                          decoration: BoxDecoration(
                                            color: AppColor.SUCCESS_COLOR,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.done,
                                            size: 24.0,
                                            color: AppColor.WHITE_COLOR,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          margin: EdgeInsets.only(left: 16.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              _searchResult[index]['type'] == "firstName"
                                              ? Text.rich(
                                                  TextSpan(
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                            text: '${ _searchResult[index]['customerData']['firstname'].toString().substring(0, controller.text.length)}',
                                                            style: TextStyle(
                                                                color: themeColor,
                                                                fontWeight: FontWeight.w700,
                                                                fontSize: TextSize.headerText
                                                            )
                                                        ),
                                                        TextSpan(
                                                            text: '${ _searchResult[index]['customerData']['firstname'].toString().substring(controller.text.length)}',
                                                            style: TextStyle(
                                                                color: themeColor,
                                                                fontWeight: FontWeight.w700,
                                                                fontSize: TextSize.headerText
                                                            )
                                                        ),
                                                        TextSpan(
                                                            text: ' ${ _searchResult[index]['customerData']['lastname']}',
                                                            style: TextStyle(
                                                                color: themeColor,
                                                                fontWeight: FontWeight.w400,
                                                                fontSize: TextSize.headerText
                                                            )
                                                        ),
                                                      ]
                                                  )
                                              )
                                              : _searchResult[index]['type'] == "lastName"
                                              ? Text.rich(
                                                TextSpan(
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                        text: '${ _searchResult[index]['customerData']['firstname']} ',
                                                        style: TextStyle(
                                                            color: themeColor,
                                                            fontWeight: FontWeight.w400,
                                                            fontSize: TextSize.headerText
                                                        )
                                                    ),
                                                    TextSpan(
                                                      text: '${ _searchResult[index]['customerData']['lastname'].toString().substring(0, controller.text.length)}',
                                                      style: TextStyle(
                                                          color: themeColor,
                                                          fontWeight: FontWeight.w700,
                                                          fontSize: TextSize.headerText
                                                      )
                                                    ),
                                                    TextSpan(
                                                        text: '${ _searchResult[index]['customerData']['lastname'].toString().substring(controller.text.length)}',
                                                        style: TextStyle(
                                                            color: themeColor,
                                                            fontWeight: FontWeight.w400,
                                                            fontSize: TextSize.headerText
                                                        )
                                                    ),
                                                  ]
                                                )
                                              )
                                              : Container(),
                                             /* Text(
                                                '${ _searchResult[index]['firstname']} ${ _searchResult[index]['lastname']}',
                                                style: TextStyle(
                                                    color: AppColor.TYPE_PRIMARY.withOpacity(0.6),
                                                    ,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: TextSize.headerText
                                                ),
                                              ),*/
                                              SizedBox(height: 3.0,),
                                              Text(
                                                _searchResult[index]['customerData']['email'] == null ? '---' : '${ _searchResult[index]['customerData']['email']}',
                                                style: TextStyle(
                                                    color: AppColor.TYPE_PRIMARY.withOpacity(0.6),
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: TextSize.subjectTitle
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          secondaryActions: <Widget>[
                            GestureDetector(
                              onTap: (){
                                showCustomDialog(
                                  context,
                                  _searchResult[index]['customerData']
                                );
                              },
                              child: Container(
                                alignment: Alignment.center,
                                height: 60.0,
                                padding: EdgeInsets.only(left: 10.0,right: 10.0),
                                color:  AppColor.TYPE_PRIMARY,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Image.asset(
                                      _searchResult[index]['customerData']['clientdisabled'] ? 'assets/activate_user.png' : 'assets/deactivate_user.png',
                                      fit: BoxFit.contain,
                                      height: 24.0,
                                      width: 24.0,
                                      color: AppColor.WHITE_COLOR,
                                    ),
                                    SizedBox(width: 6.0,),
                                    Flexible(
                                      child: Text(
                                        _searchResult[index]['customerData']['clientdisabled'] ? 'Activate' : 'Inactivate',
                                        style: TextStyle(
                                            fontSize: TextSize.subjectTitle,
                                            color: AppColor.WHITE_COLOR,
                                            fontWeight: FontWeight.w600
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                  )
                  : ListView.builder(
                      itemCount: customerList.length,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index){
                        return Slidable(
                          actionPane: SlidableScrollActionPane(),
                          actionExtentRatio: 0.35,
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: (){
                                  /*if(type == 0) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (
                                                context) =>
                                                CustomerDetailPage(
                                                  customerData: customerList[index],
                                                )
                                        )
                                    ).then((result){
                                      if(result!=null){
                                        setState(() {
                                          customerList[index] = result['data'];
                                        });
                                      }
                                    });
                                  } else {
                                    Navigator.of(context).pop({"data": customerList[index]});
                                  }*/
                                  print("Icon");
//                                Navigator.of(context).pop({"data": customerList[index]});
                                  if(widget.type == 1){
                                    //
                                  } else {
                                    if(_isInternetAvailable) {
                                      getCustomerDetail(customerList[index]['clientid'], customerList[index]['lastUpdated']);
                                    } else {
                                      loadCustomerDetailFromLocalDb(customerList[index]['clientid']);
                                    }
                                  }
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 8.0, left: 16.0, right: 16.0),
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                          ? Color(0xff1f1f1f)
                                          : AppColor.TYPE_PRIMARY.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(32.0),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      ! deleteEnable
                                      ? Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                              colors: [
                                                Color(0xff013399),
                                                Color(0xffBC96E6),
                                              ]
                                          ),
                                          borderRadius: BorderRadius.circular(32.0),
                                        ),
//                                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                                        height: 48.0,
                                        width: 48.0,
                                        alignment: Alignment.center,
                                        child: Text(
                                          customerList[index]['firstname'] != null
                                          ? '${customerList[index]['firstname'][0]}'
                                          : "-",
                                          style: TextStyle(
                                            color: AppColor.WHITE_COLOR,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 24.0
                                          ),
                                        ),
                                      )
                                      : GestureDetector(
                                        onTap: (){
                                          setState(() {
                                            if(customerList[index]['status'] == 0) {
                                              customerList[index]['status'] = 1;
                                              selectCustomer.add("${customerList[index]}");
                                            } else {
                                              customerList[index]['status'] = 0;
                                              selectCustomer.removeWhere((element){
                                                var jsonCode = json.decode(element);
                                                var map = Map.castFrom(json.decode(element.toString()));
                                                print("MAP ==== $map");
                                                return false;
//                                          return jsonCode['clientid'] == customerList[index]['clientid'];
                                              });
                                            }
                                            print("SelectedCustomerList======$selectCustomer");
                                            deleteEnable = true;
                                            deactivateEnable = selectCustomer.length > 0;
                                            FocusScope.of(context).requestFocus(FocusNode());
                                          });
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(left: 8.0),
                                          height: 48.0,
                                          width: 48.0,
                                          decoration: BoxDecoration(
                                              color: customerList[index]['status'] == 1 ? AppColor.THEME_PRIMARY : AppColor.WHITE_COLOR,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: customerList[index]['status'] == 1 ? AppColor.TRANSPARENT : AppColor.TYPE_SECONDARY,
                                                width: 1.0,
                                              )
                                          ),
                                          child: Icon(
                                            Icons.done,
                                            size: 24.0,
                                            color: AppColor.WHITE_COLOR,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          margin: EdgeInsets.only(left: 16.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                '${customerList[index]['firstname'] ?? ''} ${customerList[index]['lastname'] ?? ''}',
                                                style: TextStyle(
                                                    color: customerList[index]['clientdisabled'] ? AppColor.DEACTIVATE : themeColor,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: TextSize.headerText
                                                ),
                                              ),
                                              SizedBox(height: 3.0,),
                                              Text(
                                                customerList[index]['email'] == null ? '---' : '${customerList[index]['email']}',
                                                style: TextStyle(
                                                    color: customerList[index]['clientdisabled'] ? AppColor.DEACTIVATE : themeColor,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: TextSize.subjectTitle
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          /*actions: <Widget>[
                            GestureDetector(
                              onTap:(){
                                setState(() {
                                  if(customerList[index]['status'] == 0) {
                                    customerList[index]['status'] = 1;
                                    selectCustomer.add("${customerList[index]}");
                                  } else {
                                    customerList[index]['status'] = 0;
                                    selectCustomer.removeWhere((element){
                                      return element['clientid'] == customerList[index]['clientid'];
                                    });
                                  }
                                  print("SelectedCustomerList======$selectCustomer");
                                  deleteEnable = true;
                                  deactivateEnable = selectCustomer.length > 0;
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                height: 60.0,
                                padding: EdgeInsets.only(right: 12.0),
                                color:  Color(0xff37D4BC),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Flexible(
                                      child: Text(
                                        'Select',
                                        style: TextStyle(
                                            fontSize: TextSize.subjectTitle,
                                            color: AppColor.WHITE_COLOR,
                                            fontWeight: FontWeight.w600
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.0,),
                                    Icon(Icons.done, size: 24.0, color: AppColor.WHITE_COLOR),
                                  ],
                                ),
                              ),
                            ),
                          ],*/
                          secondaryActions: <Widget>[
                            GestureDetector(
                              onTap: (){
                                selectCustomer.clear();
                                selectCustomer.add(customerList[index]);
                                showCustomDialog(
                                    context,
                                    customerList[index]['clientdisabled']
                                );
                              },
                              child: Container(
                                alignment: Alignment.center,
                                height: 60.0,
                                padding: EdgeInsets.only(left: 10.0,right: 10.0),
                                color:  AppColor.TYPE_PRIMARY,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Image.asset(
                                      customerList[index]['clientdisabled'] ? 'assets/activate_user.png' : 'assets/deactivate_user.png',
                                      fit: BoxFit.contain,
                                      height: 24.0,
                                      width: 24.0,
                                      color: AppColor.WHITE_COLOR,
                                    ),
                                    SizedBox(width: 6.0,),
                                    Flexible(
                                      child: Text(
                                        customerList[index]['clientdisabled'] ? 'Activate' : 'Inactivate',
                                        style: TextStyle(
                                            fontSize: TextSize.subjectTitle,
                                            color: AppColor.WHITE_COLOR,
                                            fontWeight: FontWeight.w600
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                  ),
                ],
              ),
            ),
          ),

          /*Positioned(
            child: Container(
              height: 72.0,
              margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: AppColor.LOADER_COLOR.withOpacity(0.08)
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/welcome/ic_search.png',
                            fit: BoxFit.contain,
                            height: 20.0,
                            width: 20.0,
                            color: AppColor.TYPE_PRIMARY,
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: controller,
                              textAlign: TextAlign.start,
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.done,
                              autofocus: false,
                              focusNode: _searchFocus,
                              onFieldSubmitted: (term) {
                                _searchFocus.unfocus();
                              },
                              decoration: InputDecoration(
                                fillColor: AppColor.TRANSPARENT,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                                filled: false,
                                border: InputBorder.none,
                                hintText: "Search",
                                hintStyle: TextStyle(
                                    fontSize: TextSize.subjectTitle,
                                    color: isDarkMode
                            ? Color(0xff545454)
                            : Color(0xff808080)
                                ),
                              ),
                              style: TextStyle(
                                  color: AppColor.TYPE_PRIMARY,
                                  fontWeight: FontWeight.w600,
                                  fontSize: TextSize.subjectTitle
                              ),
                              onChanged: onSearchTextChanged,
                              inputFormatters: [LengthLimitingTextInputFormatter(40)],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Visibility(
                    visible: controller.text != '',
                    child: GestureDetector(
                      onTap: (){
//                        showActiveDialog(context);
                      },
                      child: Container(
                        height: 56.0,
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                            color: AppColor.TYPE_PRIMARY ,
                            borderRadius: BorderRadius.all(Radius.circular(16.0))
                        ),
                        child: Text(
                          'CLEAR',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: AppColor.WHITE_COLOR,
                            fontSize: TextSize.headerText,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),*/
          //Submit Button
          Positioned(
            bottom: 0.0,
            left: 20.0,
            right: 20.0,
            child: Visibility(
              visible: deleteEnable,
              child: Container(
                color: AppColor.BG_PRIMARY,
                padding: EdgeInsets.only(bottom: 16.0),
                child: GestureDetector(
                  onTap: (){
                    if(selectCustomer.length>0){
                      showLoading(context, activateValue==0);
                    }
                  },
                  child: Container(
                    height: 56.0,
                    decoration: BoxDecoration(
                        color: deactivateEnable ? AppColor.THEME_PRIMARY : AppColor.DEACTIVATE,
                        borderRadius: BorderRadius.all(Radius.circular(4.0))
                    ),
                    child: Center(
                      child: Text(
                        activateValue == 1 ? 'INACTIVATE CUSTOMERS' : 'ACTIVATE CUSTOMERS',
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
            ),
          ),
          _progressHUD
        ],
      ),
    );
  }

  removeCustomerFromList(clientId){
    var jsonCode = json.decode(selectCustomer.toString());
    print("Selected Customer List===$jsonCode");
    for(int i=0; i<selectCustomer.length; i++){
      if(selectCustomer[i]['clientid'] == clientId){
        selectCustomer.removeAt(i);
      }
    }
  }

  bottomSelectNavigation(context){
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
        ),
        backgroundColor: Colors.white,
        builder: (context){
          return StatefulBuilder(
            builder: (context1, myState){
              return SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 12.0,),
                      GestureDetector(
                        onTap: (){
                          for(int i=0; i<customerList.length; i++){
                            for(int j=0; j<customerList[i]['values'].length; j++)
                            myState(() {
                              setState(() {
                                customerList[i]['values'][j]['status'] = 1;
                                selectCustomer.add(customerList[i]['values'][j]);
                              });
                            });
                          }
                          myState((){
                            setState(() {
                              deactivateEnable = selectCustomer.length > 0;
                            });
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                          child: Text(
                            'Select All',
                            style: TextStyle(
                                fontSize: TextSize.headerText,
                                color: AppColor.TYPE_PRIMARY,
                                fontWeight: FontWeight.w600,
                                
                            ),
                          ),
                        ),
                      ),
                      Divider(
                        height: 1.0,
                        color: AppColor.SEC_DIVIDER,
                      ),
                      GestureDetector(
                        onTap: (){
                          for(int i=0; i<customerList.length; i++){
                            for(int j=0; j<customerList[i]['values'].length; j++)
                              myState(() {
                                setState(() {
                                  customerList[i]['values'][j]['status'] = 0;
                                });
                              });
                          }

                          myState((){
                            setState(() {
                              selectCustomer.clear();
                              deactivateEnable = selectCustomer.length > 0;
                            });
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                          child: Text(
                            'Deselect All',
                            style: TextStyle(
                                fontSize: TextSize.headerText,
                                color: AppColor.TYPE_PRIMARY,
                                fontWeight: FontWeight.w600,
                                
                            ),
                          ),
                        ),
                      ),
                      Divider(
                        height: 1.0,
                        color: AppColor.SEC_DIVIDER,
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                                fontSize: TextSize.headerText,
                                color: AppColor.TYPE_SECONDARY,
                                fontWeight: FontWeight.w600,
                                
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0,),
                    ],
                  ),
                ),
              );
            },
          );
        }
    );
  }

  void showLoading(context, customerDisabled) {
    var sLoadingContext;
    print("show loading call");
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext loadingContext) {
        sLoadingContext = loadingContext;
        return Container(
          height: 500,
          margin: EdgeInsets.only(top: 50, bottom: 30),
          child: Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Text(
                    'Are you sure?',
                    style: TextStyle(
                        fontSize: TextSize.headerText,
                        color: AppColor.TYPE_PRIMARY,
                        fontWeight: FontWeight.w600,
                        
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 36.0, vertical: 10.0),
                  child: Text(
                    customerDisabled
                    ? 'You are about to activate ${selectCustomer.length == 1 ? 'a customer.' : '${selectCustomer.length} customers.' }'
                    : 'You are about to inactivate ${selectCustomer.length == 1 ? 'a customer.' : '${selectCustomer.length} customers.' }',
                    style: TextStyle(
                        fontSize: TextSize.subjectTitle,
                        color: AppColor.TYPE_SECONDARY,
                        fontWeight: FontWeight.w500,
                        height: 1.3
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 56.0,
                            alignment: Alignment.center,
                            child: Text(
                              'CANCEL',
                              style: TextStyle(
                                fontSize: TextSize.subjectTitle,
                                color: AppColor.TYPE_SECONDARY,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: (){
                            Navigator.pop(context);
                            customerActivation(customerDisabled);
                          },
                          child: Container(
                            height: 56.0,
                            alignment: Alignment.center,
                            child: Text(
                              customerDisabled ? 'ACTIVATE' : 'INACTIVATE',
                              style: TextStyle(
                                fontSize: TextSize.subjectTitle,
                                color: AppColor.TYPE_PRIMARY,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void showCustomDialog(context, customerDisabled) {
    print("show loading call");
    showDialog(
      context: _scaffoldKey.currentContext,
      barrierDismissible: false,
      builder: (BuildContext loadingContext) {
        return Container(
          height: 500,
          margin: EdgeInsets.only(top: 50, bottom: 30),
          child: Dialog(
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Text(
                    'Are you sure?',
                    style: TextStyle(
                        fontSize: TextSize.headerText,
                        color: AppColor.TYPE_PRIMARY,
                        fontWeight: FontWeight.w600,
                        
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 28.0, vertical: 10.0),
                  child: Text(
                    customerDisabled ? 'You are about to activate a customer.' : 'You are about to inactivate a customer.',
                    style: TextStyle(
                        fontSize: TextSize.subjectTitle,
                        color: AppColor.TYPE_SECONDARY,
                        fontWeight: FontWeight.w500,
                        height: 1.3
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: (){
                            Navigator.pop(_scaffoldKey.currentContext);
                          },
                          child: Container(
                            height: 56.0,
                            alignment: Alignment.center,
                            child: Text(
                              'CANCEL',
                              style: TextStyle(
                                fontSize: TextSize.subjectTitle,
                                color: AppColor.TYPE_SECONDARY,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: (){
//                            activateCustomer(customerData);
                            customerActivation(customerDisabled);
                            Navigator.pop(_scaffoldKey.currentContext);
                          },
                          child: Container(
                            height: 56.0,
                            alignment: Alignment.center,
                            child: Text(
                              customerDisabled ? 'ACTIVATE' : 'INACTIVATE',
                              style: TextStyle(
                                fontSize: TextSize.subjectTitle,
                                color: AppColor.TYPE_PRIMARY,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  onSearchTextChanged(String text) async {
    setState(() {
      _searchResult.clear();
    });

    if (text.isEmpty) {
      setState(() {
        _searchClear = false;
      });
      return;
    }
    _searchClear = true;
    for(int i=0; i<customerList.length ; i++) {
      if(customerList[i]['firstname'].toString().toLowerCase().startsWith(text.toLowerCase())){
        setState(() {
          _searchResult.add({
            "customerData": customerList[i],
            "type": "firstName"
          });
        });
      } else if(customerList[i]['lastname'].toString().toLowerCase().startsWith(text.toLowerCase())) {
        setState(() {
          _searchResult.add({
            "customerData": customerList[i],
            "type": "lastName"
          });
        });
      }
    }
  }

  void showActiveDialog(context) {
    var sLoadingContext;
    print("show loading call");
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (loadingContext) {
          sLoadingContext = loadingContext;
          return SingleChildScrollView(
            child: Container(
                margin: EdgeInsets.only(top: 110, left: 140),
                child: Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16.0))),
                  child: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: (){
                            setState(() {
                              inspectionType = "All";
                              filterCustomer(customerMainList, 'all');
                              Navigator.pop(context);
                            });
                          },
                          child: Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                            child: Text(
                              'All',
                              style: TextStyle(
                                  fontSize: TextSize.headerText,
                                  color: AppColor.TYPE_PRIMARY,
                                  fontWeight: FontWeight.w600,
                                  
                              ),
                            ),
                          ),
                        ),
                        Divider(height: 1, color: AppColor.SEC_DIVIDER,),
                        GestureDetector(
                          onTap: (){
                            setState(() {
                              inspectionType = "Active";
                              filterCustomer(customerMainList, 'active');
                              Navigator.pop(context);
                            });
                          },
                          child: Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                            child: Text(
                              'Active',
                              style: TextStyle(
                                  fontSize: TextSize.headerText,
                                  color: AppColor.TYPE_PRIMARY,
                                  fontWeight: FontWeight.w600,
                                  
                              ),
                            ),
                          ),
                        ),
                        Divider(height: 1, color: AppColor.SEC_DIVIDER,),
                        GestureDetector(
                          onTap: (){
                            setState(() {
                              inspectionType = "Inactive";
                              filterCustomer(customerMainList, 'inactive');
                              Navigator.pop(context);
                            });
                          },
                          child: Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                            child: Text(
                              'Inactive',
                              style: TextStyle(
                                  fontSize: TextSize.headerText,
                                  color: AppColor.TYPE_PRIMARY,
                                  fontWeight: FontWeight.w600,
                                  
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
            ),
          );
        }
    );
  }

  Future<void> getCustomerList() async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var response = await request.getAuthRequest("auth/myclient");
//    print("Country list response get back: $response");
    _progressHUD.state.dismiss();

    if (response != null) {
      if (response is List<dynamic>) {
        setState(() {
          customerList = [];
          customerMainList = [];
        });

//      if(response['success']){
        setState(() {
//          customerList = response;
          customerMainList = response;
//        countryHeaderList = response;

          try {
              var customerListData = {
                "payload": json.encode(response)
              };
            dbHelper.insertCustomerListData(customerListData);
          } catch(e) {
            log("InsertCustomerListStackTrace===$e");
          }
          customerMainList.sort((a, b){
            return a['firstname'].toString().toLowerCase().compareTo(
                b['firstname'].toString().toLowerCase()
            );
          });

          for(int i=0; i<customerMainList.length; i++) {
            if(!customerMainList[i]['clientdisabled'])
              customerList.add(customerMainList[i]);
          }

          /* for(int i=0; i<customerMainList.length; i++){
            customerMainList[i]['status'] = 0;
          }

          customerMainList.sort((a, b){
            return a['firstname'].toString().toLowerCase().compareTo(b['firstname'].toString().toLowerCase());
          });
          print("CustomerList======$customerMainList");
          filterCustomer(customerMainList, 'active');*/
//          filterCustomerList1(customerList, 'inactive');
        });
//      } else {
//        _scaffoldKey.currentState.showSnackBar(HelperClass.showSnackBar(context, '${response['reason']}'));
//      }
      }
    } else {
      if(response['reason'] == "Invalid JWT Token" || response['reason'] == "Expired JWT Token"){
        PreferenceHelper.clearUserPreferenceData(context);

        // PreferenceHelper.clearPreferenceData(PreferenceHelper.LANGUAGE);
        // PreferenceHelper.clearPreferenceData(PreferenceHelper.DATE_FORMAT);
        // PreferenceHelper.clearPreferenceData(PreferenceHelper.TIME_FORMAT);
        // PreferenceHelper.clearPreferenceData(PreferenceHelper.BUSINESS_HOUR);
        // PreferenceHelper.clearPreferenceData(PreferenceHelper.ROLES);

        Navigator.pop(context);
        Navigator.pushAndRemoveUntil(
            context,
            SlideRightRoute(
                page: LoginPage1()
            ),
            ModalRoute.withName(LoginPage1.tag)
        );
      } else {
        CustomToast.showToastMessage('${response['reason']}');
      }
    }
  }

  Future customerListFromLocalDB() async {
    try{
      var response = await dbHelper.getAllCustomerListData();
      var resultList = response.toList();

      log("responseType===${resultList.runtimeType}");

      if(resultList.length > 0) {
        customerMainList = [];
        customerList = [];

        setState(() {
          customerMainList.addAll(json.decode(resultList[0]['payload']));
        });
        log("localData===$customerMainList");

        customerMainList.sort((a, b){
          return a['firstname'].toString().toLowerCase().compareTo(
              b['firstname'].toString().toLowerCase()
          );
        });

        for(int i=0; i<customerMainList.length; i++) {
          if(!customerMainList[i]['clientdisabled'])
            customerList.add(customerMainList[i]);
        }
      } else {
        customerList = [];
      }
    }catch(e) {
      log("customerListFromLocalDBStackTrace====$e");
    }
  }

  void filterCustomer(customersList, type){
    List customerDataList = List();
    for(int i=0; i<customersList.length; i++){
      if(type == 'all'){
        customerDataList.add(customersList[i]);
      } else if(type == 'active'){
        if(!customersList[i]['clientdisabled']){
          customerDataList.add(customersList[i]);
        }
      } else if(type == 'inactive') {
        if(customersList[i]['clientdisabled']){
          customerDataList.add(customersList[i]);
        }
      }
    }

    setState(() {
      customerList = List();
      customerList = customerDataList;
    });
  }

  void filterCustomerList1(customersList, type) {
    print("Country list response get back: $customersList");
    var customerList1 = List();

//    customersList.sort();

    for(int i=0; i<26; i++){
      List customerDataList = [];
      for(int j=0; j<customersList.length; j++){
        if(customersList[j]['firstname'].toString().toUpperCase().startsWith(String.fromCharCode(i+65))){
          customersList[j]['status'] = 0;

          if(type == 'normal'){
            customerDataList.add(customersList[j]);
          } else if(type == 'inactive'){
            if(!customersList[j]['clientdisabled']){
              customerDataList.add(customersList[j]);
            }
          } else if(type == 'active') {
            if(customersList[j]['clientdisabled']){
              customerDataList.add(customersList[j]);
            }
          }
        }
      }
      var customerMap = {
        "key": customerDataList.length > 0 ? String.fromCharCode(i+65) : '',
        "values": customerDataList
      };
      print("Customer Map $customerMap");
      customerList1.add(customerMap);
    }

    setState(() {
      customerList = [];
      customerList = customerList1;
    });
    print("List====$customerList");
  }

  Future firstAsync(customerData) async {
    var requestJson = {
      "clientdisabled": !customerData['clientdisabled']
    };

    var requestParam = json.encode(requestJson);
    var  response = await request.patchRequest("auth/myclient/${customerData['clientid']}", requestParam);

    return response;
  }

  Future customerActivation(type) async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    for(int i=0; i<selectCustomer.length; i++) {
      await activateCustomer(selectCustomer[i], type);
    }
    _progressHUD.state.dismiss();

    deleteEnable = false;
    selectCustomer.clear();
    filterCustomerList1(customerMainList, 'inactive');
  }
  
  Future<void> activateCustomer(customerData, type) async {
    var requestJson = {
      "clientdisabled": !type
    };

    var requestParam = json.encode(requestJson);
    print("Request Param === $requestParam");
    var  response = await request.patchRequest("auth/myclient/${customerData['clientid']}", requestParam);

    if (response != null) {
//      if (response['success']!=null && !response['success']) {
//        _scaffoldKey.currentState.showSnackBar(HelperClass.showSnackBar(context, '${response['reason']}'));
//      } else {
//
//      }
//      setState(() {
        customerData['clientdisabled'] = !type;
//      });
    } else {
      HelperClass.showSnackBar(context, 'Something Went Wrong!');
    }
  }

  Future<void> getCustomerDetail(id, lastUpdated) async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var response = await request.getAuthRequest("auth/myclient/$id");
//    print("Country list response get back: $response");
    _progressHUD.state.dismiss();

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage('${response['reason']}');
      } else {
        log("CustomerDetail====$response");

        try {
          var customerData = {
            "customerid": "$id",
            "lastUpdated": "$lastUpdated",
            "payload": json.encode(response)
          };
          await dbHelper.insertCustomerDetailData(customerData);
        } catch(e) {
          log("getCustomerDetailInsertCustomerDetailDataStackTrace====$e");
        }

        Navigator.of(context).pop({
          "data": response
        });
      }
    }
  }

  Future loadCustomerDetailFromLocalDb(id) async {
    try{
      var response = await dbHelper.getSingleCustomerData(id);
      var resultList = response.toList();

      log("responseType===${resultList.runtimeType}");

      if(resultList.length > 0) {
        var resultData = json.decode(resultList[0]['payload']);

        Navigator.of(context).pop({
          "data": resultData
        });
      } else {
        HelperClass.displayDialog(context, "Customer detail not found for this customer, please check internet connection or try different customer");
      }
    }catch(e) {
      log("loadTemplateDetailFromLocalDbStackTrace====$e");
    }
  }
}









