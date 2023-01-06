import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dottie_inspector/connection_mixin.dart';
import 'package:dottie_inspector/database/database_helper.dart';
import 'package:dottie_inspector/pages/signInPages/login_page_1.dart';
import 'package:dottie_inspector/pages/welcome/inspection_index.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/SlideRightRoute.dart';
import 'package:dottie_inspector/utils/custom_toast.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:dottie_inspector/utils/globalInstance.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/utils/language.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:dottie_inspector/widget/custome_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomeInspectionPage extends StatefulWidget {
  const WelcomeInspectionPage({Key key}) : super(key: key);

  @override
  _WelcomeInspectionPageState createState() => _WelcomeInspectionPageState();
}

class _WelcomeInspectionPageState extends State<WelcomeInspectionPage> with MyConnection{

  String dateTime = "Inspection";
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String lang = "en";
  int isStarted = 0;
  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  ProgressHUD _progressHUD1;
  var _loading = false;
  List inspectionList;
  List inspectionStatusList = [];
  List inspectionDoneList;

  TextEditingController controller = new TextEditingController();
  FocusNode _searchFocus = FocusNode();
  bool isSearchFocus = false;
  List _searchResult = [];
  var _searchClear = false;
  bool deleteEnable = false;
  SlidableController _slidableController;

  bool isIos = Platform.isIOS;
  bool isDarkMode = false;
  Color themeColor = AppColor.BLACK_COLOR;

  final dbHelper = DatabaseHelper.instance;

  // final MyConnectivity connectivity = MyConnectivity.instance;
  bool _isInternetAvailable = true;

  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _progressHUD = ProgressHUD(
      backgroundColor: Colors.transparent,
      color: Colors.white,
      containerColor: AppColor.LOADER_COLOR,
      borderRadius: 5.0,
      loading: _loading,
      text: 'Loading...',
    );

    _progressHUD1 = ProgressHUD(
      backgroundColor: Colors.transparent,
      color: Colors.white,
      containerColor: AppColor.LOADER_COLOR,
      borderRadius: 5.0,
      loading: _loading,
      text: 'Loading...',
    );
    //
    // _slidableController = SlidableController(
    //   onSlideAnimationChanged: slideAnimationChanged,
    //   onSlideIsOpenChanged: slideIsOpenChanged,
    // );
    _searchFocus.addListener(() {
      setState(() {
        isSearchFocus = _searchFocus.hasFocus;
      });
    });
    getPreferenceData();
  }

  void getPreferenceData() async {

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

   // connectivity.initialise();
   // connectivity.myStream.listen((source) {
   //   setState(() {
   //     _isInternetAvailable = connectivity.getConnectivityResult(source);
   //   });
   //   if(connectivity.getConnectivityResult(source)) {
   //     getInspectionList();
   //   } else {
   //     inspectionListFromLocalDb();
   //   }
   // });

    initConnectivity();
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
        inspectionListFromLocalDb();
      } else if ((_connectivityResult == ConnectivityResult.mobile) || (_connectivityResult == ConnectivityResult.wifi)) {
        _isInternetAvailable = true;
        getInspectionList();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    // connectivity.disposeStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: isDarkMode ? AppColor.BLACK_COLOR : AppColor.PAGE_COLOR,
        appBar: EmptyAppBar(isDarkMode: isDarkMode),
        body: Stack(
          fit: StackFit.loose,
          clipBehavior: Clip.none,
          children: [
            SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: (){
                        final dbHelper = DatabaseHelper.instance;
                        var result = dbHelper.getMultiListData();


                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 12),
                        child: Text(
                          lang == "en" ? inspectionTitleEn : inspectionTitleEs,
                          style: TextStyle(
                            fontSize: TextSize.greetingTitleText,
                            color: themeColor,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                isStarted = 0;
                                controller.text = "";
                                _searchResult.clear();
                              });
                              changeInspectionStatus();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isStarted == 0
                                    ? themeColor
                                    : AppColor.TRANSPARENT,
                                borderRadius: BorderRadius.circular(32.0),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child: Text(
                                lang == "en" ? inspectionStartedEn : inspectionStartedEn,
                                style: TextStyle(
                                  fontSize: TextSize.bodyText,
                                  color: isStarted == 1
                                        ? themeColor
                                        : isDarkMode
                                        ? AppColor.BLACK_COLOR
                                        : AppColor.WHITE_COLOR,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                controller.text = "";
                                isStarted = 1;
                              });
                              changeInspectionStatus();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isStarted == 1 ? themeColor : AppColor.TRANSPARENT,
                                borderRadius: BorderRadius.circular(32.0),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              margin: EdgeInsets.only(left: 8),
                              child: Text(
                                lang == "en" ? inspectionDoneEn : inspectionDoneEs,
                                style: TextStyle(
                                  fontSize: TextSize.bodyText,
                                  color: isStarted == 0
                                      ? themeColor
                                      : isDarkMode
                                      ? AppColor.BLACK_COLOR
                                      : AppColor.WHITE_COLOR,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    AnimatedOpacity(
                      curve: Curves.easeInOut,
                      duration: Duration(milliseconds: 800),
                      opacity: isStarted == 1 ? 1 : 0,
                      child: isStarted == 1
                          ? Container(
                        height: 72.0,
                        margin: EdgeInsets.only(left: 0.0, right: 0.0, top: 8.0, bottom: 8.0),
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32.0),
                            // color: controller.text != ''
                            //     ? AppColor.LOADER_COLOR.withOpacity(0.08)
                            //     : AppColor.WHITE_COLOR
                          gradient: LinearGradient(
                            colors: isSearchFocus && isDarkMode
                                ? AppColor.gradientColor(0.32)
                                : isSearchFocus
                                ? AppColor.gradientColor(0.16)
                                : isDarkMode
                                ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                                : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
                          ),
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
                                      color: isDarkMode ? AppColor.WHITE_COLOR : AppColor.BLACK_COLOR,
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
                                          hintText: lang == 'en' ? searchEn : searchEs,
                                          hintStyle: TextStyle(
                                            fontSize: TextSize.subjectTitle,
                                            color: isDarkMode ? AppColor.WHITE_COLOR.withOpacity(0.4) : AppColor.BLACK_COLOR.withOpacity(0.4),
                                          ),
                                        ),
                                        style: TextStyle(
                                            color: isDarkMode ? AppColor.WHITE_COLOR : AppColor.BLACK_COLOR,
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
                                    // filterCustomerList1(customerMainList, 'inactive');
                                  });
                                  // onSearchTextChanged("");
                                },
                                child: Container(
                                  height: 56.0,
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                                  decoration: BoxDecoration(
                                      color: themeColor ,
                                      borderRadius: BorderRadius.all(Radius.circular(16.0))
                                  ),
                                  child: Text(
                                    'CLEAR',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: isDarkMode ? AppColor.BLACK_COLOR : AppColor.WHITE_COLOR,
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
                      )
                      : Container(),
                    ),

                    inspectionList == null
                        ? Container()
                        : inspectionList.length == 0
                        ? HelperClass.getNoDataFountText("No Inspections Available yet!")
                        : _searchResult.length == 0 && controller.text.isNotEmpty
                        ? HelperClass.getNoDataFountText("No Record Match!")
                        : _searchResult.length != 0 || controller.text.isNotEmpty
                        ? ListView.builder(
                        itemCount:  _searchResult != null ? _searchResult.length : 0,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index){
                          var userImage;
                          var inspectionId = 0;
                          var customerName = "---";
                          var serviceAddress = "---";
                          var pdfToken = "";
                          var lastUpdated = null;
                          bool isCustomerNameSearched;
                          if(_searchResult[index]['inspectionData'] != null) {
                            isCustomerNameSearched = true;
                            inspectionId = _searchResult[index]['inspectionData']['inspectionid'];
                            lastUpdated = _searchResult[index]['inspectionData']['lastUpdated'];
                            userImage = _searchResult[index]['inspectionData']['photo'] != null ? _searchResult[index]['inspectionData']['photo']['path'] : null;

                            // var startedDate = _searchResult[index]['inspectionData']['started'] == null ? "" : HelperClass.getInspectionDateFormat(_searchResult[index]['inspectionData']['started']);
                            // var completedDate = _searchResult[index]['inspectionData']['completed'] == null ? "" : HelperClass.getInspectionDateFormat(_searchResult[index]['inspectionData']['completed']);
                            customerName = _searchResult[index]['inspectionData']['client'] == null ? "" : _searchResult[index]['inspectionData']['client']['name'] == null ? "" : _searchResult[index]['inspectionData']['client']['name'];
                            serviceAddress = _searchResult[index]['inspectionData']['serviceaddress'] != null ? "${_searchResult[index]['inspectionData']['serviceaddress']['street1']} ${_searchResult[index]['inspectionData']['serviceaddress']['city']}" : "---";

                            pdfToken = _searchResult[index]['inspectionData']['pdftoken'] ?? "";
                          } else {
                            isCustomerNameSearched = false;
                            inspectionId = _searchResult[index]['inspectionServiceData']['inspectionid'];
                            userImage = _searchResult[index]['inspectionServiceData']['photo'] != null ? _searchResult[index]['inspectionServiceData']['photo']['path'] : null;

                            customerName = _searchResult[index]['inspectionServiceData']['client'] == null ? "" : _searchResult[index]['inspectionServiceData']['client']['name'] == null ? "" : _searchResult[index]['inspectionServiceData']['client']['name'];
                            serviceAddress = _searchResult[index]['inspectionServiceData']['serviceaddress'] != null ? "${_searchResult[index]['inspectionServiceData']['serviceaddress']['street1']} ${_searchResult[index]['inspectionServiceData']['serviceaddress']['city']}" : "---";

                          }


                          return Slidable.builder(
                            key: Key("$inspectionId"),
                            actionExtentRatio: 0.25,
                            actionPane: SlidableScrollActionPane(),
                            child: Column(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: (){
                                    if(isStarted == 1) {
                                      if(pdfToken == "") {
                                        CustomToast.showToastMessage("The pdf file not available for this inspection");
                                      } else {
                                        displayOpenViewInspectionReport(context, pdfToken);
                                      }
                                    } else {
                                      if(_isInternetAvailable) {
                                        Navigator.push(
                                            context,
                                            SlideRightRoute(
                                                page: InspectionIndexScreen(
                                                  inspectionId: inspectionId ?? "0",
                                                  lastUpdated: lastUpdated,
                                                )
                                            )
                                        );
                                      } else {
                                        loadStartedInspectionDetailFromLocalDb(inspectionId ?? "0", "$lastUpdated");
                                      }
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.only(right: 16.0, left: 16, top: 16, bottom: 16),
                                    margin: EdgeInsets.only(bottom: 8.0, left: 0.0, right: 0.0),
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? Color(0xff1F1F1F)
                                          : AppColor.WHITE_COLOR,
                                      borderRadius: BorderRadius.circular(32.0),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        userImage != null && _isInternetAvailable
                                            ? ClipRRect(
                                          borderRadius: BorderRadius.circular(28.0),
                                          child: Image.network(
                                            "${GlobalInstance.apiBaseUrl}$userImage",
                                            fit: BoxFit.fill,
                                            width: 56,
                                            height: 56,
                                          ),
                                        )
                                            : Container(
                                          child: Image.asset(
                                            'assets/settings/ic_setting_logo.png',
                                            fit: BoxFit.cover,
                                            width: 56,
                                            height: 56,
                                          ),
                                        ),

                                        Expanded(
                                          child: Container(
                                            margin: EdgeInsets.only(left: 16.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: <Widget>[
                                                isCustomerNameSearched
                                                ? Text.rich(
                                                    TextSpan(
                                                        children: <TextSpan>[
                                                          TextSpan(
                                                              text: '${customerName.toString().substring(0, controller.text.length)}',
                                                              style: TextStyle(
                                                                  color: themeColor,
                                                                  fontWeight: FontWeight.w700,
                                                                  fontSize: TextSize.headerText
                                                              )
                                                          ),
                                                          TextSpan(
                                                              text: '${customerName.toString().substring(controller.text.length)}',
                                                              style: TextStyle(
                                                                  color: themeColor,
                                                                  fontWeight: FontWeight.w400,
                                                                  fontSize: TextSize.headerText
                                                              )
                                                          ),
                                                        ]
                                                    )
                                                )
                                                : Text(
                                                    "$customerName",
                                                    style: TextStyle(
                                                        color: themeColor,
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: TextSize.headerText
                                                    )
                                                ),
                                                SizedBox(height: 3.0,),
                                                !isCustomerNameSearched
                                                ? Text.rich(
                                                    TextSpan(
                                                        children: <TextSpan>[
                                                          TextSpan(
                                                              text: '${serviceAddress.toString().substring(0, controller.text.length)}',
                                                              style: TextStyle(
                                                                  color: themeColor,
                                                                  fontWeight: FontWeight.w700,
                                                                  fontSize: TextSize.headerText
                                                              )
                                                          ),
                                                          TextSpan(
                                                              text: '${serviceAddress.toString().substring(controller.text.length)}',
                                                              style: TextStyle(
                                                                  color: themeColor,
                                                                  fontWeight: FontWeight.w400,
                                                                  fontSize: TextSize.headerText
                                                              )
                                                          ),
                                                        ]
                                                    )
                                                )
                                                : Text(
                                                  "$serviceAddress",
                                                  style: TextStyle(
                                                      color: themeColor,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: TextSize.subjectTitle
                                                  ),
                                                ),

                                                SizedBox(height: 8.0,),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Divider(
                                  height: 1.0,
                                  color: AppColor.SEC_DIVIDER,
                                ),
                              ],
                            ),
                            closeOnScroll: true,
                            dismissal: SlidableDismissal(
                              closeOnCanceled: true,
                              child: SlidableDrawerDismissal(),
                              onDismissed: (actionType) {
                                log("Hello===$actionType");
                              },
                            ),
                            secondaryActionDelegate: SlideActionBuilderDelegate(
                                actionCount: 1,
                                builder: (context, index1, animation, renderingMode) {
                                  return  Container(
                                    alignment: Alignment.center,
                                    color: renderingMode == SlidableRenderingMode.slide
                                        ? Colors.transparent
                                        : (renderingMode == SlidableRenderingMode.dismiss
                                        ? AppColor.TRANSPARENT
                                        : AppColor.THEME_PRIMARY.withOpacity(0.4)),
                                    child: InkWell(
                                      onTap: () async {
                                        var state = Slidable.of(context);

                                        bool result = await displayDeleteInspection(context,index, _searchResult[index]['inspectionData']['inspectionid'], "search");

                                        if(result) {
                                          state.dismiss();
                                        } else {
                                          log("No Data remove");
                                        }
                                      },
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: AppColor.WHITE_COLOR,
                                                width: 10
                                            )
                                        ),
                                        child: Container(
                                          // width: 50.0,
                                          padding: EdgeInsets.all(12.0),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(40.0),

                                          ),
                                          child: Image.asset(
                                            'assets/ic_delete.png',
                                            fit: BoxFit.contain,
                                            color: AppColor.WHITE_COLOR,
                                            height: 24.0,
                                            width: 24.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            ),
                          );
                        }
                    )
                        : ListView.builder(
                        itemCount: inspectionList.length,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        reverse: true,
                        itemBuilder: (context, index) {
                          var userImage = inspectionList[index]['photo'] == null
                              ? null
                              : inspectionList[index]['photo']['path'] == null
                              ? null
                              : inspectionList[index]['photo']['path'];

                          var customerName = inspectionList[index]['client'] == null
                              ? ""
                              : inspectionList[index]['client']['name'] == null
                              ? ""
                              : inspectionList[index]['client']['name'];

                          var lastUpdated = inspectionList[index]['lastUpdated'];

                          var pdfToken = inspectionList[index]['pdftoken'];
                          return Slidable.builder(
                            key: Key("${inspectionList[index]['inspectionid']}"),
                            actionPane: SlidableScrollActionPane(),
                            closeOnScroll: true,
                            actionExtentRatio: 0.25,
                            dismissal: SlidableDismissal(
                              closeOnCanceled: true,
                              child: SlidableDrawerDismissal(),
                              onDismissed: (actionType) {
                                log("Hello===$actionType");
                              },
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: (){
                                    if(isStarted == 1) {
                                      if(pdfToken == "") {
                                        CustomToast.showToastMessage("The pdf file not available for this inspection");
                                      } else {
                                        displayOpenViewInspectionReport(context, pdfToken);
                                      }
                                    } else {
                                      if(_isInternetAvailable) {
                                        Navigator.push(
                                            context,
                                            SlideRightRoute(
                                                page: InspectionIndexScreen(
                                                  inspectionId: inspectionList[index]['inspectionid'] ?? "0",
                                                  lastUpdated: "$lastUpdated",
                                                )
                                            )
                                        );
                                      } else {
                                        loadStartedInspectionDetailFromLocalDb(inspectionList[index]['inspectionid'] ?? "0", "$lastUpdated");
                                      }
                                    }
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 8.0),
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? Color(0xff1F1F1F)
                                          : AppColor.WHITE_COLOR,
                                      borderRadius: BorderRadius.circular(32.0),
                                    ),
                                    padding: EdgeInsets.only(right: 16.0, top: 16, bottom: 16, left: 16),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        userImage != null  && _isInternetAvailable
                                            ? ClipRRect(
                                          borderRadius: BorderRadius.circular(28.0),
                                          child: Image.network(
                                            "${GlobalInstance.apiBaseUrl}$userImage",
                                            fit: BoxFit.fill,
                                            width: 56,
                                            height: 56,
                                            loadingBuilder: (context, child, loadingProgress){
                                              if(loadingProgress == null) {
                                                return child;
                                              } else {
                                                return Container(
                                                  height: 56,
                                                  width: 56,
                                                  color: AppColor.WHITE_COLOR,
                                                  child: Center(
                                                    child: CircularProgressIndicator(
                                                      value: loadingProgress.expectedTotalBytes != null ?
                                                      loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                                          : null,
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        )
                                            : Container(
                                          child: Image.asset(
                                            'assets/settings/ic_setting_logo.png',
                                            fit: BoxFit.cover,
                                            width: 56,
                                            height: 56,
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
                                                  '$customerName',
                                                  style: TextStyle(
                                                      color: themeColor,
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: TextSize.headerText
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 3.0,),
                                                Text(
                                                  inspectionList[index]['serviceaddress'] == null
                                                      ? '---'
                                                      : '${inspectionList[index]['serviceaddress']['street1'] ?? ''} ${inspectionList[index]['serviceaddress']['city'] ?? ''}',
                                                  style: TextStyle(
                                                    color:  themeColor,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: TextSize.subjectTitle,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),

                                                SizedBox(height: 8.0,),
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

                            secondaryActionDelegate: SlideActionBuilderDelegate(
                              actionCount: 1,
                              builder: (context, index1, animation, renderingMode) {
                                return  Container(
                                          alignment: Alignment.center,
                                          color: renderingMode == SlidableRenderingMode.slide
                                              ? Colors.transparent
                                              : (renderingMode == SlidableRenderingMode.dismiss
                                              ? AppColor.TRANSPARENT
                                              : AppColor.THEME_PRIMARY.withOpacity(0.4)),
                                          child: InkWell(
                                            onTap: () async {
                                              var state = Slidable.of(context);

                                              bool result = await displayDeleteInspection(context,index, inspectionList[index]['inspectionid'], "normal");

                                              log("DisplayResult===$result");
                                              if(result) {
                                                state.dismiss();
                                              } else {
                                                log("No Data remove");
                                              }
                                            },
                                            child: Container(
                                              child: Image.asset(
                                                'assets/ic_trash.png',
                                                fit: BoxFit.contain,
                                                // color: AppColor.WHITE_COLOR,
                                                height: 48.0,
                                                width: 48.0,
                                              ),
                                            ),
                                          ),
                                        );
                              }
                            ),
                          );
                        }
                    ),

                  ],
                ),
              ),
            ),

            _progressHUD
          ],
        ),
      ),
    );
  }

  void changeInspectionStatus() {
    setState(() {
      inspectionList = [];
      for(int i=0; i<inspectionStatusList.length; i++) {
       if(inspectionStatusList[i]['completed'] == null && isStarted == 0) {
          inspectionList.add(inspectionStatusList[i]);
        } else if(inspectionStatusList[i]['completed'] != null && isStarted == 1) {
          inspectionList.add(inspectionStatusList[i]);
        }
      }
    });
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
    for(int i=0; i<inspectionList.length ; i++) {
      if(inspectionList[i]['client'] != null) {
        if(inspectionList[i]['client']['name'].toString().toLowerCase()
            .startsWith(text.toLowerCase())
        ) {
          setState(() {
            _searchResult.add({
              "inspectionData": inspectionList[i]
            });
          });
        } else if(inspectionList[i]['serviceaddress']['street1'].toString().toLowerCase()
            .startsWith(text.toLowerCase())) {

          setState(() {
            _searchResult.add({
              "inspectionServiceData": inspectionList[i]
            });
          });
        }
      } else if(inspectionList[i]['serviceaddress']['street1'].toString().toLowerCase()
        .startsWith(text.toLowerCase())) {

        setState(() {
          _searchResult.add({
            "inspectionServiceData": inspectionList[i]
          });
        });
      }

    }
  }

  Future getInspectionList() async {
    _progressHUD.state.show();
    var response = await request.getAuthRequest("auth/inspection");

    _progressHUD.state.dismiss();

    if (response != null) {
      print(response.runtimeType);
      if (response is List<dynamic>) {
        setState(() {
          inspectionStatusList = response;
        });
        changeInspectionStatus();

        ///https://inspectordottie.com/report/pdf/134pts7c62qwAxFZE/en
        ///1BPq15HCi59QHTZeC
        var inspectionData = {
          "payload": json.encode(response)
        };
        dbHelper.insertInspectionListData(inspectionData);
      } else {
        if (response['success'] != null && !response['success']) {
          if(response['reason'] == "Invalid JWT Token" || response['reason'] == "Expired JWT Token") {
            PreferenceHelper.clearUserPreferenceData(context);
            PreferenceHelper.clearPreferenceData(PreferenceHelper.TEMPLATE_LIST);
            PreferenceHelper.clearPreferenceData(PreferenceHelper.LANGUAGE);
            PreferenceHelper.clearPreferenceData(PreferenceHelper.DATE_FORMAT);
            PreferenceHelper.clearPreferenceData(PreferenceHelper.TIME_FORMAT);
            PreferenceHelper.clearPreferenceData(PreferenceHelper.BUSINESS_HOUR);
            PreferenceHelper.clearPreferenceData(PreferenceHelper.ROLES);

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
    }
  }

  Future inspectionListFromLocalDb() async {
    try{
      var response = await dbHelper.getAllInspectionListData();
      var resultList = response.toList();

      log("responseType===${resultList.runtimeType}");

      if(resultList.length > 0) {
        inspectionStatusList.clear();
        setState(() {
          inspectionStatusList.addAll(json.decode(resultList[0]['payload']));
        });
        log("localData===$inspectionStatusList");
        changeInspectionStatus();
      } else {
        inspectionList = [];
      }
    }catch(e) {
      log("inspectionListFromLocalDbStackTrace====$e");
    }
  }

  Future displayDeleteInspection(BuildContext context,index, inspectionId, type) async  {
    var result =  await showDialog<bool>(
        context: context,
        builder: (BuildContext context){
          return StatefulBuilder(
            builder: (context, myState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                backgroundColor: isDarkMode ? Color(0xffF2F2F2).withOpacity(0.8) : Colors.white,
                child: Container(
                  height: 220,
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(left: 32, right: 32, top: 32),
                              child: Text(
                                "This will delete selected inspection's all questions and their answers\n\nDo you want to delete this inspection?",
                                style: TextStyle(
                                  color: AppColor.BLACK_COLOR,
                                  fontSize: 16.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),

                          Divider(
                            thickness: 1,
                            color: Color(0xC7252525),
                            height: 1,
                          ),
                          Container(
                            height: 60,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  child: GestureDetector(
                                    onTap: (){
                                      Navigator.of(context).pop(false);
                                    },
                                    child: Text(
                                      'Cancel',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppColor.RED_COLOR,
                                        fontSize: TextSize.subjectTitle,
                                        fontWeight: FontWeight.w700,
                                        fontStyle: FontStyle.normal,
                                      ),
                                    ),
                                  ),
                                ),
                                VerticalDivider(
                                  width: 1,
                                  color: Color(0xC7252525),
                                  thickness: 1,
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  child: GestureDetector(
                                    onTap: () async {
                                      var result = await deleteInspection(inspectionId,type, index);
                                      log("Result====$result");
                                      Navigator.of(context).pop(result);
                                    },
                                    child: Text(
                                      'Delete',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppColor.RED_COLOR,
                                        fontSize: TextSize.subjectTitle,
                                        fontWeight: FontWeight.w700,
                                        fontStyle: FontStyle.normal,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),

                      _progressHUD1
                    ],
                  ),
                ),
              );
            },
          );
        },
        barrierDismissible: true);

    return result ?? false;
  }

  void displayOpenViewInspectionReport(BuildContext context, String pdfToken) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          content: Text(
            "Open the inspection detail",
            style: TextStyle(
              color: AppColor.TYPE_PRIMARY,
              fontSize: 16.0,
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
                child: const Text('Cancel'),
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context, 'Cancel');
                }),
            CupertinoDialogAction(
                child: const Text('View'),
                onPressed: () async {
                  String lang = await PreferenceHelper.getPreferenceData(PreferenceHelper.LANGUAGE);
                  var pdfUrl = "${GlobalInstance.apiBaseUrl}report/pdf/$pdfToken/$lang";

                  print("PDF_URL===>>$pdfUrl");
                  _launchURL("$pdfUrl");
                  Navigator.pop(context);
                }),
          ],
        ),
        barrierDismissible: true);
  }

  Future deleteInspection(inspectionId, type, index) async {
    _progressHUD1.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    // Future.delayed(Duration(milliseconds: 2000), () {
    //   _progressHUD.state.dismiss();
    //   return false;
    // });
    var response = await request.deleteAuthRequest("auth/inspection/$inspectionId");

    _progressHUD1.state.dismiss();
    if (response != null) {
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage('${response['reason']}');
      } else {
        if(type == "normal") {
          inspectionList.removeAt(index);
        } else {
          _searchResult.removeAt(index);
        }
        return true;
      }
    }

    return false;
  }

  void _launchURL(_url) async {
    if (!await launch(_url)) throw 'Could not launch $_url';
  }

  Future loadStartedInspectionDetailFromLocalDb(inspectionId, lastUpdated) async {
    try{
      var response = await dbHelper.getSingleStartedInspectionData(inspectionId);
      var resultList = response.toList();

      log("responseType===${resultList.runtimeType}");
      log("resultList===$resultList");

      if(resultList.length > 0) {
        Navigator.push(
            context,
            SlideRightRoute(
                page: InspectionIndexScreen(
                  inspectionId: inspectionId,
                  lastUpdated: "$lastUpdated"
                )
            )
        );
      } else {
        HelperClass.displayDialog(context, "Inspection detail not found for this inspection, please check internet connection or try different inspection");
      }
    } catch(e) {
      log("loadStartedInspectionDetailFromLocalDbStackTrace===$e");
    }
  }

}
