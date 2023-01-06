import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:dottie_inspector/database/database_helper.dart';
import 'package:dottie_inspector/inspectionPreferences/inspection_preferences.dart';
import 'package:dottie_inspector/pages/dynamicInspection/dynamic_general_page.dart';
import 'package:dottie_inspector/pages/inspectionMain/reorderScreen/water_bodies_creating_page.dart';
import 'package:dottie_inspector/pages/menu/drawer_page.dart';
import 'package:dottie_inspector/pages/menu/index_menu.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/SlideRightRoute.dart';
import 'package:dottie_inspector/utils/custom_toast.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/utils/inspection_utils.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:dottie_inspector/widget/bottom_button_widget.dart';
import 'package:dottie_inspector/widget/gradient/grediant_box_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:progress_hud/progress_hud.dart';

class VesselEquipmentInventorySelectionPage extends StatefulWidget {
  final inspectionData;

  const VesselEquipmentInventorySelectionPage({Key key, this.inspectionData}) : super(key: key);

  @override
  _VesselEquipmentInventorySelectionPageState createState() => _VesselEquipmentInventorySelectionPageState();
}

class _VesselEquipmentInventorySelectionPageState extends State<VesselEquipmentInventorySelectionPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  var elevation = 0.0;
  final _scrollController = ScrollController();
  TextEditingController equipmentNameController = TextEditingController();

  final FocusNode equipmentFocus = FocusNode();
  bool isEquipmentFocus = false;

  List equipmentList = [];
  List equipmentSelectionList = [];
  List allSelectedEquipmentList = [];
  var dynamicData;
  var vesselId;
  var vesselname;
  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;
  var isVisible = false;
  var inspectionData;
  List onlyOneList = [];
  var sectionName;

  final _equipmentScrollController = ScrollController();
  var equipmentElevation = 0.0;
  var equipmentState;
  String lang = 'en';
  final dbHelper = DatabaseHelper.instance;
  List prevSelectedEquipmentList = [];

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

    equipmentFocus.addListener(() {
      setState(() {
        setState(() {
          isEquipmentFocus = equipmentFocus.hasFocus;
        });
      });
    });

    _equipmentScrollController.addListener(() {
      if(equipmentState != null) {
        equipmentState(() {
          setState(() {
            if(_equipmentScrollController.position.pixels > _equipmentScrollController.position.minScrollExtent){
              equipmentElevation = HelperClass.ELEVATION_1;
            } else {
              equipmentElevation = HelperClass.ELEVATION;
            }
          });
        });
      }
    });

//    setVesselList();
    getThemeData();
    getPreferenceData();
    Timer(Duration(milliseconds: 100), getEquipmentLocalList);
  }

  void getThemeData() async {
    await PreferenceHelper.getPreferenceData(PreferenceHelper.THEME_MODE).then((value){
      setState(() {
        var themeMode = value == null ? "" : value;
        log("ThemeData===$themeMode");
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

  void getPreferenceData() async {
    lang = await PreferenceHelper.getPreferenceData(PreferenceHelper.LANGUAGE) ?? "en";

    var previousSelectedEquipmentListData = await PreferenceHelper.getPreferenceData(PreferenceHelper.EQUIPMENT_ITEMS);
    List prevEquipmentList = previousSelectedEquipmentListData != null
        ? json.decode(previousSelectedEquipmentListData)
        : [];
    print("All Equipment List====>>>>$prevSelectedEquipmentList");

    setState(() {
      log("InspectionData=====>>>>>${widget.inspectionData}");
      var data = widget.inspectionData;
      dynamicData = data['txt'][lang] ?? data['txt']['en'];
      vesselId = data['vesselid'] ?? '';
      vesselname = data['vesselname'] ?? '';
      sectionName = HelperClass.getSectionText(widget.inspectionData);

      inspectionData = data;

      prevSelectedEquipmentList = prevEquipmentList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode ? AppColor.BLACK_COLOR : AppColor.PAGE_COLOR,
      appBar: EmptyAppBar(isDarkMode: isDarkMode),
      /*appBar: AppBar(
        elevation: 0.0,
        backgroundColor: AppColor.PAGE_COLOR,
        leading: GestureDetector(
          onTap: (){
            _scaffoldKey.currentState.openDrawer();
          _progressHUD.state.dismiss();
          },
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Image.asset(
              'assets/ic_menu.png',
              fit: BoxFit.cover,
              height: 28.0,
              width: 28.0,
            ),
          ),
        ),
      ),*/
      drawer: Drawer(
        child: DrawerIndexPage(),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: GestureDetector(
                      onTap: () async {
                        _scaffoldKey.currentState.openDrawer();
                        getThemeData();
                        // HelperClass.printDatabaseResult();
                        // await dbHelper.deleteEquipmentsData();
                      },
                      child: Container(
                        child: Image.asset(
                          'assets/ic_menu.png',
                          fit: BoxFit.cover,
                          width: 44,
                          height: 44,
                          color: isDarkMode ? AppColor.WHITE_COLOR : AppColor.BLACK_COLOR,
                        ),
                      ),
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: GestureDetector(
                      onTap: () {
                        HelperClass.cancelInspection(context);
                      },
                      child: Image.asset(
                        isDarkMode
                            ? 'assets/ic_dark_close.png'
                            : 'assets/ic_clear.png',
                        fit: BoxFit.cover,
                        width: 44,
                        height: 44,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 10.0,),
                        sectionName != null && sectionName != ""
                            ? Container(
                          margin: EdgeInsets.only(left: 24.0,right: 24.0),
                          child: Text(
                            sectionName,
                            style: TextStyle(
                              color: themeColor,
                              fontSize: TextSize.subjectTitle,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                            : Container(),

                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 24.0,vertical: 8.0),
                          child: Text(
                            dynamicData != null
                                ? dynamicData['title'] ?? ""
                                : "",
                            style: TextStyle(
                                fontSize: TextSize.pageTitleText,
                                color: themeColor,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                                height: 1.2
                            ),
                          ),
                        ),

                        dynamicData == null
                            ? Container()
                            : dynamicData['helpertext'] != null
                            ? Container(
                          margin: EdgeInsets.only(left: 24.0,right: 24.0, top: 8),
                          child: Text(
                            dynamicData != null
                                ? dynamicData['helpertext'] ?? ""
                                : '',
                            style: TextStyle(
                                fontSize: TextSize.headerText,
                                color: themeColor,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.normal,
                                height: 1.3
                            ),
                          ),
                        )
                            : Container(),
                        //////Equipment List//////
//                   GridView.builder(
//                       itemCount: equipmentList != null ? equipmentList.length + 1 : 1,
//                       physics: NeverScrollableScrollPhysics(),
//                       shrinkWrap: true,
//                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2,
//                         childAspectRatio: 0.95,
//                         mainAxisSpacing: 0.0,
//                         crossAxisSpacing: 16.0,
//                       ),
//                       itemBuilder: (context, index){
//                         // var svgIcon = index != equipmentList.length
//                         //     ? equipmentList[index]['svgicon'].toString().replaceAll("\\", "")
//                         //     : "";
//                         // log("Hello====$svgIcon");
//                         return index != equipmentList.length
//                         ? GestureDetector(
//                           onTap: (){
//                             openEditDeleteBottomSheet(context, equipmentList[index]);
//                           },
//                           onLongPress: (){
//                             print("Hello");
//                             setState(() {
//                               // isVisible = !isVisible;
//                             });
//                           },
//                           child: Container(
//                             margin: EdgeInsets.only(top: 16.0),
//                             padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
//                             decoration: BoxDecoration(
//                               color: themeColor.withOpacity(0.08),
//                               borderRadius: BorderRadius.all(Radius.circular(32.0)),
//                             ),
//                             child: Stack(
//                               clipBehavior: Clip.none,
//                               children: [
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: <Widget>[
//                                     equipmentList[index]['svgicon'] == "null"
//                                     ? Container(
//                                       child: Image.asset(
//                                         "assets/ic_pool.png",
//                                         width: 48.0,
//                                         height: 48.0,
//                                       ),
//                                     )
//                                     : Container(
// //                                      child: Image.asset('${vesselList[index]['icon']}'),
//                                       child: SvgPicture.string('${equipmentList[index]['svgicon'].toString()}'),
// //                                      child: SvgPicture.string('<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">\n<path d="M20.1422 21.0175C20.0007 21.0175 19.8591 21.0411 19.7176 21.1118C19.3402 21.2769 18.9392 21.3713 18.5382 21.3713C17.9249 21.3713 17.3352 21.1826 16.8398 20.8288C15.9199 20.1447 14.6461 20.1447 13.7261 20.8288C13.2308 21.1826 12.641 21.3713 12.0277 21.3713C11.4144 21.3713 10.8247 21.1826 10.3294 20.8288C9.88118 20.4985 9.33864 20.3098 8.77251 20.3098C8.20639 20.3098 7.66385 20.4749 7.21567 20.8288C6.72031 21.1826 6.13059 21.3713 5.51729 21.3713C5.11629 21.3713 4.71528 21.3005 4.33786 21.1118C4.21992 21.0411 4.07839 21.0175 3.91327 21.0175C3.39432 21.0175 2.96973 21.4421 2.96973 21.961C2.96973 22.0318 2.96973 22.1025 2.99332 22.1969C3.06408 22.48 3.25279 22.6923 3.51226 22.8102C4.12557 23.1169 4.80964 23.2584 5.4937 23.2348C6.48442 23.2584 7.42797 22.9517 8.22998 22.3856C8.53663 22.1969 8.53663 22.1733 8.74893 22.1733C8.96122 22.1733 8.98481 22.1733 9.29146 22.3856C10.0699 22.9517 11.037 23.2584 12.0041 23.2348C12.9713 23.2584 13.9384 22.9517 14.7168 22.3856C15.0235 22.1969 15.0235 22.1733 15.2358 22.1733C15.4481 22.1733 15.4717 22.1733 15.7783 22.3856C17.17 23.3527 18.9628 23.5179 20.496 22.8102C20.9678 22.5743 21.1565 22.0318 20.9442 21.56C20.9206 21.5128 20.897 21.4892 20.897 21.4657C20.7555 21.1826 20.4724 21.0175 20.1422 21.0175Z" fill="#509BCC"/>\n<path d="M20.9206 17.5736C20.7555 17.3141 20.4489 17.149 20.1422 17.149C20.0007 17.149 19.8591 17.1726 19.7176 17.2434C19.3402 17.4085 18.9392 17.5029 18.5382 17.5029C17.9249 17.5029 17.3352 17.3141 16.8398 16.9603C15.9199 16.2762 14.6461 16.2762 13.7261 16.9603C13.2308 17.3377 12.641 17.5264 12.0277 17.5264C11.4144 17.5264 10.8247 17.3377 10.3294 16.9839C9.88118 16.6301 9.33864 16.465 8.77251 16.465C8.20639 16.465 7.66385 16.6301 7.21567 16.9839C6.72031 17.3613 6.13059 17.55 5.51729 17.5264C5.11629 17.5264 4.71528 17.4557 4.33786 17.267C4.21992 17.1962 4.07839 17.1726 3.91327 17.1726C3.39432 17.1726 2.96973 17.5972 2.96973 18.1162C2.96973 18.1869 2.96973 18.2577 2.99332 18.352C3.06408 18.6115 3.25279 18.8474 3.48868 18.9653C4.10198 19.272 4.78605 19.4135 5.4937 19.3899C6.46084 19.4135 7.42797 19.1069 8.20639 18.5408C8.51304 18.352 8.51304 18.3285 8.72534 18.3285C8.93764 18.3285 8.96122 18.3285 9.26788 18.5408C10.0463 19.1069 11.0134 19.4135 11.9806 19.3899C12.9477 19.4135 13.9148 19.1069 14.6932 18.5172C14.9999 18.3285 14.9999 18.3049 15.2122 18.3049C15.4245 18.3049 15.4481 18.3049 15.7547 18.5172C17.1465 19.4843 18.9392 19.6494 20.4724 18.9418C20.9442 18.7059 21.1329 18.1397 20.9206 17.6916C20.9678 17.6444 20.9442 17.6208 20.9206 17.5736Z" fill="#509BCC"/>\n<path d="M16.4861 15.0967C17.005 15.0967 17.4296 14.6721 17.4296 14.1532V6.51049C17.4296 4.95365 18.0429 3.46757 19.128 2.38249C19.5054 2.00508 19.5054 1.41536 19.128 1.03795C18.7506 0.660529 18.1608 0.660529 17.7834 1.03795C16.9814 1.83996 16.3681 2.80709 15.9671 3.86857H9.5982C9.88126 3.32604 10.2351 2.80709 10.6833 2.38249C11.0607 2.00508 11.0607 1.41536 10.6833 1.03795C10.3059 0.660529 9.71614 0.660529 9.33872 1.03795C7.87623 2.47685 7.07422 4.45829 7.07422 6.51049V14.1532C7.07422 14.6721 7.49881 15.0967 8.01776 15.0967C8.53671 15.0967 8.9613 14.6721 8.9613 14.1532V12.9974H15.4953V14.1532C15.5425 14.6721 15.9671 15.0967 16.4861 15.0967ZM9.00848 6.51049C9.00848 6.20384 9.03207 5.8736 9.07925 5.56695H15.5897C15.5425 5.8736 15.5189 6.20384 15.5189 6.51049V7.59557H9.00848V6.51049ZM9.00848 11.3226V9.27036H15.5425V11.3226H9.00848Z" fill="#509BCC"/>\n</svg>'),
//                                       height: 48.0,
//                                       width: 48.0,
//                                     ),
//                                     SizedBox(height: 16.0,),
//                                     Expanded(
//                                       child: Text(
//                                         '${equipmentList[index]['label']}',
//                                         style: TextStyle(
//                                           color: themeColor,
//                                           fontSize: TextSize.headerText,
//                                           fontStyle: FontStyle.normal,
//                                           fontWeight: FontWeight.w700,
//                                         ),
//                                         maxLines: 2,
//                                       ),
//                                     ),
//                                     SizedBox(height: 8.0,),
//                                   ],
//                                 ),
//
//                                Visibility(
//                                  visible: isVisible,
//                                  child: Positioned(
//                                    bottom: -80,
//                                    child: Container(
//                                      decoration: BoxDecoration(
//                                        color: AppColor.WHITE_COLOR,
//                                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
//                                      ),
//                                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
//                                      child: Column(
//                                        children: [
//                                          Text('Edit'),
//                                          Text('Delete'),
//                                        ],
//                                      ),
//                                    ),
//                                  ),
//                                )
//                                /* Visibility(
//                                   visible: isVisible,
//                                   child: PopupMenuButton(
//                                       itemBuilder: (context) {
//                                         return [
//                                           PopupMenuItem(
//                                             value: 'edit',
//                                             child: Text(
//                                               'Edit'
//                                             ),
//                                           ),
//                                           PopupMenuItem(
//                                             value: 'delete',
//                                             child: Text(
//                                                 'Delete'
//                                             ),
//                                           ),
//                                         ];
//                                       },
//                                     onSelected: (value){
//                                       print('You Click on po up menu item $value');
//                                     },
//                                   ),
//                                 ),*/
//                               ],
//                             ),
//                           ),
//                         )
//                         : GestureDetector(
//                           onTap: (){
//                             openAddCommentBottomSheet(context);
//                           },
//                           child: Theme(
//                             data: Theme.of(context).copyWith(splashColor: Colors.transparent),
//                             child: Container(
//                               margin: EdgeInsets.only(top: 16.0),
//                               padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
//                               decoration: BoxDecoration(
//                                 color: AppColor.THEME_PRIMARY.withOpacity(0.08),
//                                 borderRadius: BorderRadius.all(Radius.circular(32.0)),
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: <Widget>[
//                                   Container(
//                                     width: double.infinity,
//                                     alignment: Alignment.topRight,
//                                     child: Container(
//                                       alignment: Alignment.center,
//                                       width: 32.0,
//                                       height: 32.0,
//                                       margin: EdgeInsets.only(right: 0.0),
//                                       padding: EdgeInsets.all(8.0),
//                                       decoration: BoxDecoration(
//                                           color: AppColor.THEME_PRIMARY,
//                                           borderRadius: BorderRadius.circular(24)
//                                       ),
//                                       child: Icon(
//                                           Icons.add,
//                                           color: AppColor.WHITE_COLOR,
//                                           size: 16.0
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(height: 16.0,),
//                                   Expanded(
//                                     child: Text(
//                                       'Add Equipment',
//                                       style: TextStyle(
//                                         color: themeColor,
//                                         fontSize: TextSize.headerText,
//                                         fontStyle: FontStyle.normal,
//                                         fontWeight: FontWeight.w700,
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(height: 8.0,),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         );
//                       }
//                   ),

                        ///List view new design
                        Container(
                          child: ListView.builder(
                            itemCount: equipmentList != null ? equipmentList.length + 1 : 1,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              // var svgIcon = index == equipmentList.length
                              //     ? null
                              //     : equipmentList[index]['svgicon'] == null
                              //     ? null
                              //     : equipmentList[index]['svgicon'].toString().replaceAll("\\", "");

                              return index != equipmentList.length
                                  ? GestureDetector(
                                onTap: (){
                                  openEditDeleteBottomSheet(context, equipmentList[index], "top");
                                },
                                onLongPress: (){
                                  setState(() {
                                    bottomSelectNavigation(context, equipmentList[index]);
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? Color(0xff1f1f1f)
                                        : AppColor.TYPE_PRIMARY.withOpacity(0.08),
                                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[

                                      equipmentList[index]['svgicon'] == "null" || equipmentList[index]['svgicon'] == null
                                          ? Container(
                                        child: Image.asset(
                                          "assets/ic_pool.png",
                                          width: 48.0,
                                          height: 48.0,
                                        ),
                                      )
                                          : Container(
//                                      child: Image.asset('${equipmentList[index]['icon']}'),
                                        child: SvgPicture.string('${equipmentList[index]['svgicon'].toString()}'),
//                                      child: SvgPicture.string('<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">\n<path d="M20.1422 21.0175C20.0007 21.0175 19.8591 21.0411 19.7176 21.1118C19.3402 21.2769 18.9392 21.3713 18.5382 21.3713C17.9249 21.3713 17.3352 21.1826 16.8398 20.8288C15.9199 20.1447 14.6461 20.1447 13.7261 20.8288C13.2308 21.1826 12.641 21.3713 12.0277 21.3713C11.4144 21.3713 10.8247 21.1826 10.3294 20.8288C9.88118 20.4985 9.33864 20.3098 8.77251 20.3098C8.20639 20.3098 7.66385 20.4749 7.21567 20.8288C6.72031 21.1826 6.13059 21.3713 5.51729 21.3713C5.11629 21.3713 4.71528 21.3005 4.33786 21.1118C4.21992 21.0411 4.07839 21.0175 3.91327 21.0175C3.39432 21.0175 2.96973 21.4421 2.96973 21.961C2.96973 22.0318 2.96973 22.1025 2.99332 22.1969C3.06408 22.48 3.25279 22.6923 3.51226 22.8102C4.12557 23.1169 4.80964 23.2584 5.4937 23.2348C6.48442 23.2584 7.42797 22.9517 8.22998 22.3856C8.53663 22.1969 8.53663 22.1733 8.74893 22.1733C8.96122 22.1733 8.98481 22.1733 9.29146 22.3856C10.0699 22.9517 11.037 23.2584 12.0041 23.2348C12.9713 23.2584 13.9384 22.9517 14.7168 22.3856C15.0235 22.1969 15.0235 22.1733 15.2358 22.1733C15.4481 22.1733 15.4717 22.1733 15.7783 22.3856C17.17 23.3527 18.9628 23.5179 20.496 22.8102C20.9678 22.5743 21.1565 22.0318 20.9442 21.56C20.9206 21.5128 20.897 21.4892 20.897 21.4657C20.7555 21.1826 20.4724 21.0175 20.1422 21.0175Z" fill="#509BCC"/>\n<path d="M20.9206 17.5736C20.7555 17.3141 20.4489 17.149 20.1422 17.149C20.0007 17.149 19.8591 17.1726 19.7176 17.2434C19.3402 17.4085 18.9392 17.5029 18.5382 17.5029C17.9249 17.5029 17.3352 17.3141 16.8398 16.9603C15.9199 16.2762 14.6461 16.2762 13.7261 16.9603C13.2308 17.3377 12.641 17.5264 12.0277 17.5264C11.4144 17.5264 10.8247 17.3377 10.3294 16.9839C9.88118 16.6301 9.33864 16.465 8.77251 16.465C8.20639 16.465 7.66385 16.6301 7.21567 16.9839C6.72031 17.3613 6.13059 17.55 5.51729 17.5264C5.11629 17.5264 4.71528 17.4557 4.33786 17.267C4.21992 17.1962 4.07839 17.1726 3.91327 17.1726C3.39432 17.1726 2.96973 17.5972 2.96973 18.1162C2.96973 18.1869 2.96973 18.2577 2.99332 18.352C3.06408 18.6115 3.25279 18.8474 3.48868 18.9653C4.10198 19.272 4.78605 19.4135 5.4937 19.3899C6.46084 19.4135 7.42797 19.1069 8.20639 18.5408C8.51304 18.352 8.51304 18.3285 8.72534 18.3285C8.93764 18.3285 8.96122 18.3285 9.26788 18.5408C10.0463 19.1069 11.0134 19.4135 11.9806 19.3899C12.9477 19.4135 13.9148 19.1069 14.6932 18.5172C14.9999 18.3285 14.9999 18.3049 15.2122 18.3049C15.4245 18.3049 15.4481 18.3049 15.7547 18.5172C17.1465 19.4843 18.9392 19.6494 20.4724 18.9418C20.9442 18.7059 21.1329 18.1397 20.9206 17.6916C20.9678 17.6444 20.9442 17.6208 20.9206 17.5736Z" fill="#509BCC"/>\n<path d="M16.4861 15.0967C17.005 15.0967 17.4296 14.6721 17.4296 14.1532V6.51049C17.4296 4.95365 18.0429 3.46757 19.128 2.38249C19.5054 2.00508 19.5054 1.41536 19.128 1.03795C18.7506 0.660529 18.1608 0.660529 17.7834 1.03795C16.9814 1.83996 16.3681 2.80709 15.9671 3.86857H9.5982C9.88126 3.32604 10.2351 2.80709 10.6833 2.38249C11.0607 2.00508 11.0607 1.41536 10.6833 1.03795C10.3059 0.660529 9.71614 0.660529 9.33872 1.03795C7.87623 2.47685 7.07422 4.45829 7.07422 6.51049V14.1532C7.07422 14.6721 7.49881 15.0967 8.01776 15.0967C8.53671 15.0967 8.9613 14.6721 8.9613 14.1532V12.9974H15.4953V14.1532C15.5425 14.6721 15.9671 15.0967 16.4861 15.0967ZM9.00848 6.51049C9.00848 6.20384 9.03207 5.8736 9.07925 5.56695H15.5897C15.5425 5.8736 15.5189 6.20384 15.5189 6.51049V7.59557H9.00848V6.51049ZM9.00848 11.3226V9.27036H15.5425V11.3226H9.00848Z" fill="#509BCC"/>\n</svg>'),
                                        height: 48.0,
                                        width: 48.0,
                                      ),
                                      SizedBox(width: 16.0,),
                                      Expanded(
                                        child: Text(
                                          '${equipmentList[index]['label']}',
                                          style: TextStyle(
                                            color: themeColor,
                                            fontSize: TextSize.headerText,
                                            fontStyle: FontStyle.normal,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          maxLines: 2,
                                        ),
                                      ),
                                      SizedBox(height: 8.0,),
                                    ],
                                  ),
                                ),
                              )
                                  : GestureDetector(
                                onTap: (){
                                  openEquipmentSelectionBottomSheet(context);
                                },
                                child: Theme(
                                  data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                                  child: Container(
                                    margin: EdgeInsets.only(top: 16.0, left: 16, right: 16),
                                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 22.0),
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? Color(0xff1f1f1f)
                                          : AppColor.TYPE_PRIMARY.withOpacity(0.08),
                                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[

                                        Expanded(
                                          child: Text(
                                            'Add',
                                            style: TextStyle(
                                              color: themeColor,
                                              fontSize: TextSize.headerText,
                                              fontStyle: FontStyle.normal,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 16.0,),
                                        Container(
                                          alignment: Alignment.center,
                                          width: 36.0,
                                          height: 36.0,
                                          padding: EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                              color: AppColor.THEME_PRIMARY,
                                              borderRadius: BorderRadius.circular(24)
                                          ),
                                          child: Icon(
                                              Icons.add,
                                              color: AppColor.WHITE_COLOR,
                                              size: 20.0
                                          ),
                                        ),


                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        SizedBox(height: 120.0,),

                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: BottomButtonWidget(
              isActive: equipmentList.length > 0,
              onBackButton: () async {
                int inspectionIndex = await InspectionPreferences.getInspectionId(InspectionPreferences.INSPECTION_INDEX);
                InspectionUtils.decrementIndex(inspectionIndex);
                Navigator.pop(context);
              },
              onNextButton: () async {
                // if(prevSelectedEquipmentList)
                onSaveEvent();

              },
            ),
          ),

          _progressHUD
        ],
      ),
    );
  }
  
  void onSaveEvent() async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var response;
    log("EquipmentList====$equipmentList");
    for(int i=0; i<equipmentList.length; i++) {
      if(equipmentList[i]['equipmentgeneralid'] == null) {
        if(equipmentList[i]['equipmentid'] == null && equipmentList[i]['vesselid'] == "") {
          response = await createLocalEquipmentItem(equipmentList[i]);
        } else if(equipmentList[i]['equipmentid'] == null && equipmentList[i]['vesselid'] != vesselId) {
          response = await createLocalEquipmentItem(equipmentList[i]);
        }
      }
    }

    _progressHUD.state.dismiss();

    if (response != null) {
      // if (response['success'] != null && !response['success']) {
      //   CustomToast.showToastMessage('${response['reason']}');
      // } else {
        log("Water List Data=====>>>>${allSelectedEquipmentList.toString()}");

        ///Children Inspection Data
        var localChildData = await InspectionPreferences.getPreferenceData(InspectionPreferences.INSPECTION_CHILD_DATA);
        var childrenTemplateData = localChildData != null
                                  ? json.decode(localChildData)
                                  : [];

        const JsonEncoder encoder = JsonEncoder.withIndent('  ');
        log("childrenTemplateData====>>>>${encoder.convert(childrenTemplateData)}");


        ///Selected Vessel List
        var localWaterBodiesListData = await PreferenceHelper.getPreferenceData(PreferenceHelper.WATER_SELECTED_BODIES);
        var waterBodiesTemplateData = localWaterBodiesListData != null
                                    ? json.decode(localWaterBodiesListData)
                                    : [];

        ///Previous selected equipments
        var previousSelectedEquipmentListData = await PreferenceHelper.getPreferenceData(PreferenceHelper.EQUIPMENT_ITEMS);
        List prevSelectedEquipmentList = previousSelectedEquipmentListData != null
                                    ? json.decode(previousSelectedEquipmentListData)
                                    : [];

        if(allSelectedEquipmentList != null && allSelectedEquipmentList.length>0) {
          prevSelectedEquipmentList.addAll(allSelectedEquipmentList);
        }
        print("All Equipment List====>>>>$prevSelectedEquipmentList");

        ///Answer List
        var previousAnswersListData = await PreferenceHelper.getPreferenceData(PreferenceHelper.ANSWER_LIST);
        List prevAnswersList = previousAnswersListData != null
            ? json.decode(previousAnswersListData)
            : [];
        print("All Answer List====>>>>$prevAnswersList");

        /*** Set the answer list to shared preferences ***/
        PreferenceHelper.clearPreferenceData(PreferenceHelper.ANSWER_LIST);
        PreferenceHelper.setPreferenceData(PreferenceHelper.ANSWER_LIST, json.encode(prevAnswersList));

        ///Inspection Id
        var inspectionLocalId = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ID);

        ///Start unroll
        var transformedData = HelperClass.unroll(int.parse(inspectionLocalId), childrenTemplateData, waterBodiesTemplateData, prevSelectedEquipmentList, prevAnswersList);
        log("TransformedData====>>>>${encoder.convert(transformedData)}");

        ///Save inspection data
        InspectionPreferences.clearPreferenceData(InspectionPreferences.INSPECTION_DATA);
        InspectionPreferences.setPreferenceData(
            InspectionPreferences.INSPECTION_DATA,
            json.encode(transformedData['flow'])
        );
        PreferenceHelper.clearPreferenceData(PreferenceHelper.EQUIPMENT_ITEMS);
        PreferenceHelper.setPreferenceData(
            PreferenceHelper.EQUIPMENT_ITEMS,
            json.encode(prevSelectedEquipmentList)
        );
        print("EquipmentList====>>>>$prevSelectedEquipmentList");

         openNextScreen();
      // }
    } else {
      log("No Equipment available");
      openNextScreen();
    }
  }

  Future createEquipmentItem(equipmentItem) async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var addressId = await PreferenceHelper.getPreferenceData(PreferenceHelper.LOCATION_ID);
    var clientId = await PreferenceHelper.getPreferenceData(PreferenceHelper.CLIENT_ID);

    var requestJson;
    if(equipmentItem['simplelistid'] == 28
        || equipmentItem['simplelistid'] == 29
        || equipmentItem['simplelistid'] == 31
        || equipmentItem['simplelistid'] == 150) {
      requestJson = {
        "equipmenttype": "${equipmentItem['simplelistid']}",
        "equipmentdescription":"${equipmentItem['label']}",
        "vessel": vesselId == "" ? [] : [vesselId],
        "meta": {
          "lighttypeid": "${equipmentItem['simplelistid']}",
          "count": "${equipmentItem['selectedCount']}"
        }
      };
    } else {
      requestJson = {
        "equipmenttype": "${equipmentItem['simplelistid']}",
        "equipmentdescription":"${equipmentItem['label']}",
        "vessel": vesselId == "" ? [] : [vesselId],
      };
    }

    print("REQUEST PARAM======>>>>>$requestJson");
    var requestParam = json.encode(requestJson);
    var response = await request.postRequest(
        "auth/myclient/$clientId/servicelocation/$addressId/equipment",
        requestParam
    );
    _progressHUD.state.dismiss();

    if(response != null){
      setState(() {
        allSelectedEquipmentList.add(response);
      });
    }

    return response;
  }

  Future createLocalEquipmentItem(equipmentItem) async {
    // _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var addressId = await PreferenceHelper.getPreferenceData(PreferenceHelper.LOCATION_ID);
    var clientId = await PreferenceHelper.getPreferenceData(PreferenceHelper.CLIENT_ID);

    var requestJson;
    if(equipmentItem['simplelistid'] == 28
        || equipmentItem['simplelistid'] == 29
        || equipmentItem['simplelistid'] == 31
        || equipmentItem['simplelistid'] == 150) {
      requestJson = {
        "equipmenttype": "${equipmentItem['simplelistid']}",
        "equipmentdescription":"${equipmentItem['label']}",
        "vessel": vesselId == "" ? [] : ["{{vesselid}}"],
        "meta": {
          "lighttypeid": equipmentItem['simplelistid'] != null ? int.parse("${equipmentItem['simplelistid']}") : 0,
          "count": "${equipmentItem['selectedCount']}"
        }
      };
    } else {
      requestJson = {
        "equipmenttype": equipmentItem['simplelistid'] != null ? int.parse("${equipmentItem['simplelistid']}") : 0,
        "equipmentdescription":"${equipmentItem['label']}",
        "vessel": vesselId == "" ? [] : ["{{vesselid}}"],
      };
    }

    // var endPoint =  "auth/myclient/$clientId/servicelocation/$addressId/equipment";
    var endPoint =  "auth/myclient/{{clientid}}/servicelocation/{{serviceid}}/equipment";

    var equipmentData = {
      "equipmentdescription": "${equipmentItem['label']}",
      "equipmentid": 0,
      "equipmentgroupid": 0,
      "equipmentgeneralid": 0,
      "customerlocalid": clientId,
      "servicelocalid": addressId,
      "vesselidlocal": vesselId,
      "vesselid": vesselId,
      "equipmenttypeid": equipmentItem['simplelistid'] != null ? int.parse("${equipmentItem['simplelistid']}") : 0,
      "equipmenttype": {
        "simplelistid": equipmentItem['simplelistid'] != null ? int.parse("${equipmentItem['simplelistid']}") : 0,
        "equipmenttype": "${equipmentItem['label']}"
      },
      "payload": json.encode(requestJson),
      "url": "$endPoint",
      "verb": "POST",
      "meta": [],
      "bodyofwater": [],
      "vessel": vesselId == "" ? [] : [vesselId]
    };
    //{
    //  "equipmentid": 5861,
    //  "equipmenttype": {
    //    "simplelistid": 790,
    //    "equipmenttype": "Automation System"
    //   },
    //  "equipmentgroupid": null,
    //  "isinstalled": true,
    //  "equipmentdescription": "Automation System",
    //  "comments": null,
    //  "image": null,
    //  "meta": [],
    //  "bodyofwater": [],
    //  "vessel": []
    // }

    var response = await dbHelper.insertEquipmentData(equipmentData);

    dbHelper.getAllPendingEquipmentData();
    setState(() {
      equipmentData['equipmentid'] = "$response";
    });
    allSelectedEquipmentList.add(equipmentData);
    log("allSelectedEquipmentList===$allSelectedEquipmentList");
    log("allSelectedEquipmentListRES===$response");
    return response;
  }

  void openEquipmentSelectionBottomSheet(context) {
    for(int k=0; k<equipmentSelectionList.length; k++) {
      print("Index===$k, Count====${equipmentSelectionList[k]['count']} SelectedCount===${equipmentSelectionList[k]['selectedCount']}");
      equipmentSelectionList[k]['isEquipmentCountChanged'] = 0;
    }
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        barrierColor: themeColor.withOpacity(0.5),
        isDismissible: false,
        clipBehavior: Clip.none,
        enableDrag: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        builder: (context){
          return StatefulBuilder(
            builder: (context1, myState){
              equipmentState = myState;
              return Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height - 50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: (){
                              for(int k=0; k<equipmentSelectionList.length; k++){
                                if(equipmentSelectionList[k]['isEquipmentCountChanged'] == 0
                                    && equipmentSelectionList[k]['equipmentCountClose'] == 0) {
                                  equipmentSelectionList[k]['isSelected'] = 0;
                                  equipmentSelectionList[k]['count'] = equipmentSelectionList[k]['selectedCount'];
                                  equipmentSelectionList[k]['selectedCount'] = equipmentSelectionList[k]['selectedCount'];
                                } else {
                                  equipmentSelectionList[k]['count'] = equipmentSelectionList[k]['selectedCount'];
                                  equipmentSelectionList[k]['isSelected'] = 1;
                                }
                              }

                              Navigator.pop(context);
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                              child: Image.asset(
                                isDarkMode
                                    ? 'assets/ic_dark_close.png'
                                    : 'assets/ic_back_close.png',
                                height: 44.0,
                                width: 44.0,
                              ),
                            ),
                          ),

                          Text(
                            'Select Equipment',
                            style: TextStyle(
                              color: themeColor,
                              fontSize: TextSize.headerText,
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          GestureDetector(
                            onTap: (){
                              setState(() {
                                myState((){
                                  equipmentList.clear();
                                  for(int k=0; k<equipmentSelectionList.length; k++) {
                                    if(equipmentSelectionList[k]['isSelected'] == 1) {
                                      equipmentSelectionList[k]['selectedCount'] = equipmentSelectionList[k]['count'];
                                      equipmentSelectionList[k]['isEquipmentCountChanged'] = equipmentSelectionList[k]['count'];
                                      equipmentSelectionList[k]['equipmentCountClose'] = equipmentSelectionList[k]['count'];

                                      for (int i = 0; i < equipmentSelectionList[k]['count']; i++) {
                                        equipmentList.add({
                                          "simplelistid": "${equipmentSelectionList[k]['simplelistid']}",
                                          "label": i == 0
                                              ? "${equipmentSelectionList[k]['label']}"
                                              : "${equipmentSelectionList[k]['label']} ${i + 1}",
                                          "svgicon": "${equipmentSelectionList[k]['svgicon']}"
                                        });
                                      }
                                    }
                                  }
                                  log("equipmentList====$equipmentList");
                                });
                              });

                              Navigator.pop(context);
                            },
                            child: Theme(
                              data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                              child: Container(
                                alignment: Alignment.bottomCenter,
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: AppColor.gradientColor(1.0)),
                                    borderRadius: BorderRadius.all(Radius.circular(32.0))
                                ),
                                margin: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                                padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 8.0),
                                child: Center(
                                  child: Text(
                                    'Save',
                                    style: TextStyle(
                                        fontSize: TextSize.headerText,
                                        color: AppColor.WHITE_COLOR,
                                        fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Visibility(
                        visible: equipmentElevation != 0.0,
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: AppColor.DIVIDER,
                        )
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        controller: _equipmentScrollController,
                        child: Padding(
                          padding: MediaQuery.of(context).viewInsets,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                                child: ListView.builder(
                                  itemCount: equipmentSelectionList != null ? equipmentSelectionList.length : 0,
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (context, index){
                                    return GestureDetector(
                                      onTap: (){

                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(top: 16.0),
                                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 22.0),
                                        decoration: BoxDecoration(
                                          color: isDarkMode
                                              ? Color(0xff1F1F1F)
                                              : AppColor.TYPE_PRIMARY.withOpacity(0.08),
                                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                equipmentSelectionList[index]['svgicon'] == "null"
                                                    ? Container(
                                                  child: Image.asset(
                                                    "assets/ic_pool.png",
                                                    width: 48.0,
                                                    height: 48.0,
                                                  ),
                                                )
                                                    : Container(
                                                  child: SvgPicture.string('${equipmentSelectionList[index]['svgicon'].toString()}'),
                                                  height: 48.0,
                                                  width: 48.0,
                                                ),
                                                SizedBox(width: 16.0,),
                                                Expanded(
                                                  child: Text(
                                                    '${equipmentSelectionList[index]['label']}',
                                                    style: TextStyle(
                                                      color: themeColor,
                                                      fontSize: TextSize.headerText,
                                                      fontStyle: FontStyle.normal,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 16.0,),

                                                GestureDetector(
                                                  onTap: (){
                                                    setState(() {
                                                      myState((){
                                                        equipmentSelectionList[index]['isSelected'] = equipmentSelectionList[index]['isSelected'] == 0 ? 1 : 0;
                                                      });
                                                    });
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.only(left: 8.0),
                                                    height: 48.0,
                                                    width: 48.0,
                                                    child: Image.asset(
                                                      equipmentSelectionList[index]['isSelected'] == 1
                                                          ? 'assets/complete_inspection/ic_check_icon.png'
                                                          : 'assets/complete_inspection/ic_unchecked_icon.png',
                                                      height: 150,
                                                      width: 150,
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ),

                                                /*onlyOneList.contains(equipmentSelectionList[index]['simplelistid'])
                                                    ? Container(
                                                  child: GestureDetector(
                                                    onTap: (){
                                                      setState(() {
                                                        myState(() {
                                                          equipmentSelectionList[index]['count'] = equipmentSelectionList[index]['count'] == 0 ? 1 : 0;
                                                        });
                                                      });
                                                    },
                                                    child: Container (
                                                      alignment: Alignment.center,
                                                      child: Image.asset(
                                                            equipmentSelectionList[index]['count'] == 0
                                                            ? "assets/complete_inspection/single_tap.png"
                                                            : "assets/complete_inspection/ic_check_icon.png",
                                                            height: 48,
                                                            width: 48,
                                                        )
                                                    ),
                                                  ),
                                                )
                                                    : Container (
                                                  child: Row (
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: (){
                                                          if(equipmentSelectionList[index]['count'] != equipmentSelectionList[index]['selectedCount']) {
                                                            setState(() {
                                                              myState(() {
                                                                equipmentSelectionList[index]['count']--;
                                                              });
                                                            });
                                                          }
                                                        },
                                                        child: Container (
                                                          padding: EdgeInsets.all(12.0),
                                                          decoration: BoxDecoration(
                                                              color: equipmentSelectionList[index]['count'] == equipmentSelectionList[index]['selectedCount']
                                                                  ? AppColor.THEME_PRIMARY.withOpacity(0.12)
                                                                  : equipmentSelectionList[index]['count'] == 0
                                                                  ? AppColor.THEME_PRIMARY.withOpacity(0.12)
                                                                  : AppColor.THEME_PRIMARY,
                                                              borderRadius: BorderRadius.circular(24)
                                                          ),
                                                          alignment: Alignment.center,
                                                          child: Icon(
                                                              Icons.remove,
                                                              color: equipmentSelectionList[index]['count'] == equipmentSelectionList[index]['selectedCount'] ? AppColor.PAGE_COLOR : AppColor.WHITE_COLOR,
                                                              size: 16.0
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        margin: EdgeInsets.symmetric(horizontal: 12.0),
                                                        alignment: Alignment.center,
                                                        child: Text(
                                                          "${equipmentSelectionList[index]['count']}",
                                                          style: TextStyle(
                                                              fontSize: 22.0,
                                                              color: themeColor,
                                                              fontWeight: FontWeight.w700,
                                                              fontStyle: FontStyle.normal
                                                          ),
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: (){
                                                          setState(() {
                                                            myState((){
                                                              equipmentSelectionList[index]['count']++;
                                                            });
                                                          });
                                                        },
                                                        child: Container(
                                                          padding: EdgeInsets.all(12.0),
                                                          decoration: BoxDecoration(
                                                              color: AppColor.THEME_PRIMARY,
                                                              borderRadius: BorderRadius.circular(24)
                                                          ),
                                                          alignment: Alignment.center,
                                                          child: Icon(
                                                              Icons.add,
                                                              color: AppColor.WHITE_COLOR,
                                                              size: 16.0
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),*/
                                              ],
                                            ),

                                            //Selection tab
                                            Visibility(
                                              visible: (equipmentSelectionList[index]['isSelected'] == 1) && (!onlyOneList.contains(equipmentSelectionList[index]['simplelistid'])),
                                              child: Container (
                                                child: Row (
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: (){
                                                        if(equipmentSelectionList[index]['count'] != equipmentSelectionList[index]['selectedCount']) {
                                                          setState(() {
                                                            myState(() {
                                                              equipmentSelectionList[index]['count']--;
                                                            });
                                                          });
                                                        }
                                                      },
                                                      child: Container (
                                                        // padding: EdgeInsets.all(8.0),
                                                        width: 48,
                                                        height: 48,
                                                        decoration: BoxDecoration(
                                                            color: equipmentSelectionList[index]['count'] == equipmentSelectionList[index]['selectedCount']
                                                                ? AppColor.THEME_PRIMARY.withOpacity(0.12)
                                                                : equipmentSelectionList[index]['count'] == 0
                                                                ? AppColor.THEME_PRIMARY.withOpacity(0.12)
                                                                : AppColor.THEME_PRIMARY,
                                                            borderRadius: BorderRadius.circular(24)
                                                        ),
                                                        alignment: Alignment.center,
                                                        child: Icon(
                                                            Icons.remove,
                                                            color: equipmentSelectionList[index]['count'] == equipmentSelectionList[index]['selectedCount'] ? AppColor.PAGE_COLOR : AppColor.WHITE_COLOR,
                                                            size: 18.0
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.symmetric(horizontal: 12.0),
                                                      alignment: Alignment.center,
                                                      child: Text(
                                                        "${equipmentSelectionList[index]['count']}",
                                                        style: TextStyle(
                                                            fontSize: 22.0,
                                                            color: themeColor,
                                                            fontWeight: FontWeight.w700,
                                                            fontStyle: FontStyle.normal
                                                        ),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: (){
                                                        setState(() {
                                                          myState((){
                                                            equipmentSelectionList[index]['count']++;
                                                          });
                                                        });
                                                      },
                                                      child: Container(
                                                        width: 48,
                                                        height: 48,
                                                        decoration: BoxDecoration(
                                                            color: AppColor.THEME_PRIMARY,
                                                            borderRadius: BorderRadius.circular(24)
                                                        ),
                                                        alignment: Alignment.center,
                                                        child: Icon(
                                                            Icons.add,
                                                            color: AppColor.WHITE_COLOR,
                                                            size: 18.0
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              SizedBox(height: 80,)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
    );
  }

  void openAddCommentBottomSheet(context){
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        barrierColor: themeColor.withOpacity(0.5),
        isDismissible: false,
        clipBehavior: Clip.none,
        enableDrag: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        builder: (context){
          return StatefulBuilder(
            builder: (context1, myState){
              return SingleChildScrollView(
                child: Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height - 50,
                    child: ListView(
//                      crossAxisAlignment: CrossAxisAlignment.center,
//                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: (){
                                  Navigator.pop(context);
                                },
                                icon:  Image.asset(
                                  isDarkMode
                                      ? 'assets/ic_dark_close.png'
                                      : 'assets/ic_back_close.png',
                                  height: 18.0,
                                  width: 18.0,
                                ),
                              ),

                              Text(
                                'Add Equipment',
                                style: TextStyle(
                                  color: themeColor,
                                  fontSize: TextSize.headerText,
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              GestureDetector(
                                onTap: (){
                                  setState(() {
                                    myState((){
                                      equipmentList.clear();
                                      for(int k=0; k<equipmentSelectionList.length; k++){
                                        equipmentSelectionList[k]['selectedCount'] = equipmentSelectionList[k]['count'];

                                        if(equipmentSelectionList[k]['simplelistid'] == 29
                                            || equipmentSelectionList[k]['simplelistid'] == 30
                                            || equipmentSelectionList[k]['simplelistid'] == 31
                                            || equipmentSelectionList[k]['simplelistid'] == 150) {

                                          if(equipmentSelectionList[k]['selectedCount'] > 0) {
                                            equipmentList.add({
                                              "simplelistid": "${equipmentSelectionList[k]['simplelistid']}",
                                              "label": "${equipmentSelectionList[k]['selectedCount']} X ${equipmentSelectionList[k]['label']}",
                                              "svgicon": "${equipmentSelectionList[k]['svgicon']}",
                                              "selectedCount": "${equipmentSelectionList[k]['selectedCount']}"
                                            });
                                          }
                                        } else {
                                          for (int i = 0; i < equipmentSelectionList[k]['count']; i++) {
                                            equipmentList.add({
                                              "simplelistid": "${equipmentSelectionList[k]['simplelistid']}",
                                              "label": "${equipmentSelectionList[k]['label']} ${i + 1}",
                                              "svgicon": "${equipmentSelectionList[k]['svgicon']}"
                                            });
                                          }
                                        }
                                      }
                                    });
                                  });

                                  Navigator.pop(context);
                                },
                                child: Theme(
                                  data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                                  child: Container(
                                    alignment: Alignment.bottomCenter,
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: AppColor.gradientColor(1.0)),
                                        borderRadius: BorderRadius.all(Radius.circular(32.0))
                                    ),
                                    margin: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                                    padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 8.0),
                                    child: Center(
                                      child: Text(
                                        'Save',
                                        style: TextStyle(
                                            fontSize: TextSize.headerText,
                                            color: AppColor.WHITE_COLOR,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: ''
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                          child: GridView.builder(
                            itemCount: equipmentSelectionList != null ? equipmentSelectionList.length : 0,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.88,
                              mainAxisSpacing: 0.0,
                              crossAxisSpacing: 16.0,
                            ),
                            itemBuilder: (context, index){
                              print("Index=====${equipmentSelectionList[index]['simplelistid']}");
                              return GestureDetector(
                                onTap: (){

                                },
                                child: Container(
                                  margin: EdgeInsets.only(top: 16.0),
                                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 16.0),
                                  decoration: BoxDecoration(
                                    color: themeColor.withOpacity(0.08),
                                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      equipmentSelectionList[index]['svgicon'] == null
                                      ? Container(
                                        child: Image.asset(
                                          "assets/ic_pool.png",
                                          width: 48.0,
                                          height: 48.0,
                                        ),
                                      )
                                      : Container(
                                        child: SvgPicture.string('${equipmentSelectionList[index]['svgicon'].toString()}'),
                                        height: 48.0,
                                        width: 48.0,
                                      ),
                                      SizedBox(height: 8.0,),
                                      Expanded(
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "${equipmentSelectionList[index]['label']}",
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 16.0,
                                              fontStyle: FontStyle.normal,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8.0,),

                                      equipmentSelectionList[index]['simplelistid'] == 29
                                      ? Container(
                                        child: GestureDetector(
                                          onTap: (){
                                              setState(() {
                                                myState(() {
                                                  equipmentSelectionList[index]['count'] = equipmentSelectionList[index]['count'] == 0 ? 1 : 0;
                                                });
                                              });
                                          },
                                          child: Container (
                                            margin: EdgeInsets.only(right: 16.0),
                                            padding: EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                                color: AppColor.THEME_PRIMARY,
                                                borderRadius: BorderRadius.circular(24)
                                            ),
                                            alignment: Alignment.center,
                                            child: Icon(
                                                equipmentSelectionList[index]['count'] == 0
                                                ? Icons.add
                                                : Icons.remove,
                                                color: AppColor.WHITE_COLOR,
                                                size: 14.0
                                            ),
                                          ),
                                        ),
                                      )
                                      : Container (
                                        margin: EdgeInsets.only(top: 6.0),
                                        child: Row (
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            GestureDetector(
                                              onTap: (){
                                                if(equipmentSelectionList[index]['count'] != equipmentSelectionList[index]['selectedCount']) {
                                                  setState(() {
                                                    myState(() {
                                                      equipmentSelectionList[index]['count']--;
                                                    });
                                                  });
                                                }
                                              },
                                              child: Container (
                                                margin: EdgeInsets.only(right: 16.0),
                                                padding: EdgeInsets.all(8.0),
                                                decoration: BoxDecoration(
                                                    color: equipmentSelectionList[index]['count'] == equipmentSelectionList[index]['selectedCount']
                                                          ? AppColor.THEME_PRIMARY.withOpacity(0.12)
                                                          : AppColor.THEME_PRIMARY,
                                                    borderRadius: BorderRadius.circular(24)
                                                ),
                                                alignment: Alignment.center,
                                                child: Icon(
                                                    Icons.remove,
                                                    color: equipmentSelectionList[index]['count'] == equipmentSelectionList[index]['selectedCount'] ? AppColor.PAGE_COLOR : AppColor.WHITE_COLOR,
                                                    size: 14.0
                                                ),
                                              ),
                                            ),
                                            Container(
                                              alignment: Alignment.center,
                                              child: Text(
                                                "${equipmentSelectionList[index]['count']}",
                                                style: TextStyle(
                                                    fontSize: 22.0,
                                                    color: themeColor,
                                                    fontWeight: FontWeight.w700,
                                                    fontStyle: FontStyle.normal
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: (){
                                                setState(() {
                                                  myState((){
                                                    equipmentSelectionList[index]['count']++;
                                                  });
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(8.0),
                                                decoration: BoxDecoration(
                                                    color: AppColor.THEME_PRIMARY,
                                                    borderRadius: BorderRadius.circular(24)
                                                ),
                                                margin: EdgeInsets.only(left: 16.0),
                                                alignment: Alignment.center,
                                                child: Icon(
                                                    Icons.add,
                                                    color: AppColor.WHITE_COLOR,
                                                    size: 14.0
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
    );
  }

  void openEditDeleteBottomSheet(context, equipmentMap, type){
    equipmentNameController.text = "${equipmentMap['label']}";
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        clipBehavior: Clip.none,
        barrierColor: themeColor.withOpacity(0.5),
        isDismissible: false,
        enableDrag: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        builder: (context){
          return StatefulBuilder(
            builder: (context1, myState){
              return Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height - 50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: (){
                              Navigator.pop(context);
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                              child: Image.asset(
                                isDarkMode
                                    ? 'assets/ic_dark_close.png'
                                    : 'assets/ic_back_close.png',
                                height: 44.0,
                                width: 44.0,
                              ),
                            ),
                          ),

                          Text(
                            "${equipmentMap['label']}",
                            style: TextStyle(
                              color: themeColor,
                              fontSize: TextSize.headerText,
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          GestureDetector(
                            onTap: (){
                              setState(() {
                                myState((){
                                  if(equipmentNameController.text != ''){
                                    equipmentMap['label'] = "${equipmentNameController.text}";
                                  }
                                });
                              });

                              Navigator.pop(context);
                              if(type == "bottom"){
                                Navigator.pop(context);
                              }
                            },
                            child: Theme(
                              data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                              child: Container(
                                alignment: Alignment.bottomCenter,
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: AppColor.gradientColor(1.0)),
                                    borderRadius: BorderRadius.all(Radius.circular(32.0))
                                ),
                                margin: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                                padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 8.0),
                                child: Center(
                                  child: Text(
                                    'Save',
                                    style: TextStyle(
                                        fontSize: TextSize.headerText,
                                        color: AppColor.WHITE_COLOR,
                                        fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // equipment Name
                              Container(
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isEquipmentFocus && isDarkMode
                                          ? AppColor.gradientColor(0.32)
                                          : isEquipmentFocus
                                          ? AppColor.gradientColor(0.16)
                                          : isDarkMode
                                          ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                                          : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
                                    ),
                                    borderRadius: BorderRadius.circular(32.0),
                                    border: GradientBoxBorder(
                                        gradient: LinearGradient(
                                          colors: isEquipmentFocus
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
                                      'Nick name (Optional)',
                                      style: TextStyle(
                                          fontSize: TextSize.bodyText,
                                          color: themeColor.withOpacity(1.0),
                                          fontWeight: FontWeight.w600,
                                          fontStyle: FontStyle.normal,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SingleChildScrollView(
                                      child: TextFormField(
                                        controller: equipmentNameController,
                                        focusNode: equipmentFocus,
                                        onFieldSubmitted: (term) {
                                          equipmentFocus.unfocus();
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
                                              fontWeight: FontWeight.w600,
                                              color: isDarkMode
                                                  ? Color(0xff545454)
                                                  : Color(0xff808080)
                                          ),
                                        ),
                                        style: TextStyle(
                                            color: themeColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: TextSize.headerText
                                        ),
                                        inputFormatters: [LengthLimitingTextInputFormatter(40)],
                                        onChanged: (value){

                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ), // equipment Name End

                              // Delete button
                              GestureDetector(
                                onTap: (){
                                  setState(() {
                                    myState((){
                                      for(int k=0; k<equipmentSelectionList.length; k++){
                                        if("${equipmentMap['simplelistid']}" == "${equipmentSelectionList[k]['simplelistid']}"){
                                          equipmentSelectionList[k]['count'] = equipmentSelectionList[k]['count'] > 0
                                              ? equipmentSelectionList[k]['count'] - 1
                                              : 0;
                                          equipmentSelectionList[k]['selectedCount'] = equipmentSelectionList[k]['selectedCount'] > 0
                                              ? equipmentSelectionList[k]['selectedCount'] - 1
                                              : 0;

                                          equipmentSelectionList[k]['isSelected'] = equipmentSelectionList[k]['count'] == 0 ? 0 : 1;
                                        }
                                      }
                                      equipmentList.remove(equipmentMap);

                                      if(prevSelectedEquipmentList.length>0) {
                                        onSaveDelete(equipmentMap['equipmentid']);
                                      }
                                    });
                                  });
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                  padding: EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                      color: AppColor.WHITE_COLOR,
                                      borderRadius: BorderRadius.circular(32.0)
                                  ),
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(
                                        color: AppColor.RED_COLOR,
                                        fontWeight: FontWeight.w600,
                                        fontSize: TextSize.headerText
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Delete Button End
                  ],
                ),
              );
            },
          );
        }
    );
  }

  void onSaveDelete(equipmentid) async {
    try{
      ///Children Inspection Data
      var localChildData = await InspectionPreferences.getPreferenceData(InspectionPreferences.INSPECTION_CHILD_DATA);
      var childrenTemplateData = localChildData != null
          ? json.decode(localChildData)
          : [];
      print("All Children List====>>>>$childrenTemplateData");

      ///Selected Vessel List
      var localWaterBodiesListData = await PreferenceHelper.getPreferenceData(PreferenceHelper.WATER_SELECTED_BODIES);
      var waterBodiesTemplateData = localWaterBodiesListData != null
          ? json.decode(localWaterBodiesListData)
          : [];


      ///Previous selected equipments
      var previousSelectedEquipmentListData = await PreferenceHelper.getPreferenceData(PreferenceHelper.EQUIPMENT_ITEMS);
      List prevSelectEquipmentList = previousSelectedEquipmentListData != null
          ? json.decode(previousSelectedEquipmentListData)
          : [];
      print("All Equipment List====>>>>$prevSelectEquipmentList");

      ///RemoveDataFromMainList
      var newEquipmentListData =  getEquipmentListData(prevSelectEquipmentList, equipmentid);
      log("NewWaterListData===$newEquipmentListData");

      PreferenceHelper.clearPreferenceData(PreferenceHelper.EQUIPMENT_ITEMS);
      PreferenceHelper.setPreferenceData(
          PreferenceHelper.EQUIPMENT_ITEMS,
          json.encode(newEquipmentListData)
      );

      setState(() {
        prevSelectedEquipmentList = newEquipmentListData;
      });


      ///Inspection Id
      var inspectionLocalId = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ID);
      // print("InspectionId=====>>>>$inspectionLocalId");

      // ///Answer List
      var previousAnswersListData = await PreferenceHelper.getPreferenceData(PreferenceHelper.ANSWER_LIST);
      List prevAnswersList = previousAnswersListData != null
          ? json.decode(previousAnswersListData)
          : [];

      print("All Answer List====>>>>$prevAnswersList");

      var pendingAnswer;
      for(int i=0; i<prevAnswersList.length; i++) {
        if(prevAnswersList[i]['equipmentid'] == equipmentid) {
          pendingAnswer = {
            "inspectionid": inspectionLocalId,
            "answerserverid": prevAnswersList[i]['answerid'] ?? 0,
            "questionid": prevAnswersList[i]['questionid'] ?? 0,
            "equipmentid": prevAnswersList[i]['equipmentid'] ?? 0,
            "vesselid": prevAnswersList[i]['vesselid'] ?? 0,
            "bodyofwaterid": prevAnswersList[i]['bodyofwaterid'] ?? 0,
            "simplelistid": prevAnswersList[i]['simplelistid'] ?? 0,
            "answer": prevAnswersList[i]['answer'] ?? "",
            "imageurl": prevAnswersList[i]['image'] == null
                ? ""
                : prevAnswersList[i]['image']['path'] ?? "",
          };

          await dbHelper.insertRecordIntoDeleteTable(
            json.decode(json.encode(pendingAnswer)),
          );
        }
      }
      prevAnswersList.removeWhere((element) => element['equipmentid'] == equipmentid);
      print("All Answer List====>>>>$prevAnswersList");

      PreferenceHelper.clearPreferenceData(PreferenceHelper.ANSWER_LIST);
      PreferenceHelper.setPreferenceData(PreferenceHelper.ANSWER_LIST, json.encode(prevAnswersList));

      ///Start unroll
      var transformedData = HelperClass.unroll(int.parse(inspectionLocalId), childrenTemplateData, waterBodiesTemplateData, newEquipmentListData, prevAnswersList);
      // const JsonEncoder encoder = JsonEncoder.withIndent('  ');
      // log("TransformedData====>>>>${encoder.convert(transformedData)}");

      ///Save inspection data
      InspectionPreferences.clearPreferenceData(InspectionPreferences.INSPECTION_DATA);
      InspectionPreferences.setPreferenceData(
          InspectionPreferences.INSPECTION_DATA,
          json.encode(transformedData['flow'])
      );
    } catch (e) {
      print("saveEvent Error ====$e");
    }
  }

  List getEquipmentListData(equipmentList, equipmentid) {
    for(int i=0; i<equipmentList.length; i++) {
      equipmentList.removeWhere((item) => item['equipmentid'] == equipmentid);
    }
    setState(() {
      prevSelectedEquipmentList.removeWhere((item) => item['equipmentid'] == equipmentid);
    });
    return equipmentList;
  }

  bottomSelectNavigation(context, equipmentMap){
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        barrierColor: themeColor.withOpacity(0.5),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        builder: (context){
          return StatefulBuilder(
            builder: (context1, myState){
              return SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                        child: Text(
                          "${equipmentMap['label']}",
                          style: TextStyle(
                              fontSize: TextSize.subjectTitle,
                              color: themeColor,
                              fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: (){
                          openEditDeleteBottomSheet(context, equipmentMap, "bottom");
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                          child: Text(
                            'Edit',
                            style: TextStyle(
                                fontSize: TextSize.planeHeaderText,
                                color: themeColor,
                                fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: (){
                          setState(() {
                            myState((){
                              for(int k=0; k<equipmentSelectionList.length; k++){
                                if("${equipmentMap['simplelistid']}" == "${equipmentSelectionList[k]['simplelistid']}"){
                                  equipmentSelectionList[k]['count'] = equipmentSelectionList[k]['count'] > 0
                                      ? equipmentSelectionList[k]['count'] - 1
                                      : 0;
                                  equipmentSelectionList[k]['selectedCount'] = equipmentSelectionList[k]['selectedCount'] > 0
                                      ? equipmentSelectionList[k]['selectedCount'] - 1
                                      : 0;

                                  equipmentSelectionList[k]['isSelected'] = equipmentSelectionList[k]['count'] == 0 ? 0 : 1;
                                }
                              }
                              equipmentList.remove(equipmentMap);

                              if(prevSelectedEquipmentList.length>0) {
                                onSaveDelete(equipmentMap['equipmentid']);
                              }
                            });
                          });
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                          child: Text(
                            'Remove',
                            style: TextStyle(
                                fontSize: TextSize.planeHeaderText,
                                color: AppColor.RED_COLOR,
                                fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      Container(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: (){
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            height: 64.0,
                            width: 120,
                            margin: EdgeInsets.only(bottom: 20.0, top: 8.0),
                            decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Color(0xffffffff)
                                    : AppColor.BLACK_COLOR,
                                borderRadius: BorderRadius.all(Radius.circular(32.0))
                            ),
                            child: Center(
                              child: Text(
                                'Close',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isDarkMode
                                      ? AppColor.BLACK_COLOR
                                      : AppColor.WHITE_COLOR,
                                  fontSize: TextSize.subjectTitle,
                                  fontWeight: FontWeight.w700,
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
            },
          );
        }
    );
  }

  Future getEquipmentLocalList() async {
    final dbHelper = DatabaseHelper.instance;
    var result = await dbHelper.getSelectedSimpleList("36");
    if (result != null) {

      log("Result===$result");
      setState(() {
        result = result.map((element) => Map<String, dynamic>.of(element)).toList();

        var transformedData = adjacencyTransform(result);
        var response = transformedData['children'];

        List equipmentDataList = [];
        for(int i=0; i<response.length; i++){
          if(response[i]['simplelistid'] == 30
              || response[i]['simplelistid'] == 31
              || response[i]['simplelistid'] == 150) {

          } else {
            for(int j=0; j<inspectionData['equipmenttype'].length; j++) {
              if("${inspectionData['equipmenttype'][j]['equipmenttypeid']}" == "${response[i]['simplelistid']}") {
                equipmentDataList.add(response[i]);
              }

              if(inspectionData['equipmenttype'][j]['onlyone']
                  && "${inspectionData['equipmenttype'][j]['equipmenttypeid']}" == "${response[i]['simplelistid']}") {
                onlyOneList.add(response[i]['simplelistid']);
              }
            }

            //New Code
            // equipmentDataList.add(response[i]);
            // if(response[i]['simplelistid'] == 29
            //     || response[i]['simplelistid'] == 42 ) {
            //   onlyOneList.add(response[i]['simplelistid']);
            // }

          }
        }

        log("InspectionType===${inspectionData['equipmenttype']}");
        log("OnyData===$onlyOneList");
        equipmentSelectionList.addAll(equipmentDataList);

        /*for(int i=0; i< response.length; i++) {
          if(response[i]['simplelistid'] == 28) {
            for(int j=0; j<response[i]['children'].length; j++) {
              equipmentSelectionList.add(response[i]['children'][j]);
            }
          } else {
            equipmentSelectionList.add(response[i]);
          }
        }*/

        List allIds = [];
        for(int i=0; i<equipmentSelectionList.length; i++){
          log("EquipmentList === ${equipmentSelectionList[i]['simplelistid']}");
          equipmentSelectionList[i]['count'] = 1;
          equipmentSelectionList[i]['selectedCount'] = 1;
          equipmentSelectionList[i]['isEquipmentCountChanged'] = 0;
          equipmentSelectionList[i]['isSelected'] = 0;
          equipmentSelectionList[i]['equipmentCountClose'] = 0;
          equipmentSelectionList[i]['vesselid'] = vesselId;

          for(int j=0; j<prevSelectedEquipmentList.length; j++){
            if(prevSelectedEquipmentList[j]['vesselid'] == "") {
              if(equipmentSelectionList[i]['simplelistid'] == prevSelectedEquipmentList[j]['equipmenttypeid']) {
                int count = 1;
                if(allIds.contains(equipmentSelectionList[i]['simplelistid'])) {
                  count++;
                }
                equipmentSelectionList[i]['count'] = count;
                equipmentSelectionList[i]['selectedCount'] = count;
                equipmentSelectionList[i]['isEquipmentCountChanged'] = count;
                equipmentSelectionList[i]['isSelected'] = 1;
                equipmentSelectionList[i]['equipmentCountClose'] = count;
                equipmentSelectionList[i]['vesselid'] = vesselId;
                equipmentSelectionList[i]['equipmentid'] = prevSelectedEquipmentList[j]['equipmentid'];

                equipmentList.add(equipmentSelectionList[i]);

                allIds.add(equipmentSelectionList[i]['simplelistid']);
              }
            } else if(prevSelectedEquipmentList[j]['vesselid'] == vesselId) {
              if(equipmentSelectionList[i]['simplelistid'] == prevSelectedEquipmentList[j]['equipmenttypeid']) {
                int count = 1;
                if(allIds.contains(equipmentSelectionList[i]['simplelistid'])) {
                  count++;
                }
                equipmentSelectionList[i]['count'] = count;
                equipmentSelectionList[i]['selectedCount'] = count;
                equipmentSelectionList[i]['isEquipmentCountChanged'] = count;
                equipmentSelectionList[i]['isSelected'] = 1;
                equipmentSelectionList[i]['equipmentCountClose'] = count;
                equipmentSelectionList[i]['vesselid'] = vesselId;
                equipmentSelectionList[i]['equipmentid'] = prevSelectedEquipmentList[j]['equipmentid'];

                equipmentList.add(equipmentSelectionList[i]);

                allIds.add(equipmentSelectionList[i]['simplelistid']);
              }
            }
          }
        }
      });
    }
  }

  Future getEquipmentList() async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var response = await request.getAuthRequest("auth/simplelist/$lang/equipment");

    _progressHUD.state.dismiss();
    if (response != null) {
      setState(() {
        List equipmentDataList = [];
        for(int i=0; i<response.length; i++){
          if(response[i]['simplelistid'] == 30
              || response[i]['simplelistid'] == 31
              || response[i]['simplelistid'] == 150) {

          } else {
            for(int j=0; j<inspectionData['equipmenttype'].length; j++) {
              if("${inspectionData['equipmenttype'][j]['equipmenttypeid']}" == "${response[i]['simplelistid']}") {
                equipmentDataList.add(response[i]);
              }

              if(inspectionData['equipmenttype'][j]['onlyone']
                && "${inspectionData['equipmenttype'][j]['equipmenttypeid']}" == "${response[i]['simplelistid']}") {
                onlyOneList.add(response[i]['simplelistid']);
              }
            }

            //New Code
            // equipmentDataList.add(response[i]);
            // if(response[i]['simplelistid'] == 29
            //     || response[i]['simplelistid'] == 42 ) {
            //   onlyOneList.add(response[i]['simplelistid']);
            // }

          }
        }

        log("${inspectionData['equipmenttype']}");
        log("$onlyOneList");
        equipmentSelectionList.addAll(equipmentDataList);

        /*for(int i=0; i< response.length; i++) {
          if(response[i]['simplelistid'] == 28) {
            for(int j=0; j<response[i]['children'].length; j++) {
              equipmentSelectionList.add(response[i]['children'][j]);
            }
          } else {
            equipmentSelectionList.add(response[i]);
          }
        }*/

        for(int i=0; i<equipmentSelectionList.length; i++){
          equipmentSelectionList[i]['count'] = 1;
          equipmentSelectionList[i]['selectedCount'] = 1;
          equipmentSelectionList[i]['isEquipmentCountChanged'] = 0;
          equipmentSelectionList[i]['isSelected'] = 0;
          equipmentSelectionList[i]['equipmentCountClose'] = 0;
        }
      });
    }
  }

  void openNextScreen() async {
    var listItemData = await InspectionPreferences.getPreferenceData(InspectionPreferences.INSPECTION_DATA);
    var transformedData = json.decode(listItemData);
    int inspectionIndex = await InspectionPreferences.getInspectionId(InspectionPreferences.INSPECTION_INDEX);

    print(transformedData);

    var pageName;
    var inspectionData;
    int index;

    print("Index====$inspectionIndex");
    print("Length====${transformedData.length}");
    for(int i=inspectionIndex??0; i<transformedData.length; i++) {
      var data = await InspectionUtils.getInspectionBlockTypeData(transformedData[i], transformedData.length);
      if(data != null){
        pageName = data;
        inspectionData = transformedData[i];
        index = i;
        break;
      }
    }

    if(pageName != null){
      InspectionPreferences.clearPreferenceData(InspectionPreferences.INSPECTION_INDEX);
      InspectionPreferences.setInspectionId(
          InspectionPreferences.INSPECTION_INDEX,
          ++index
      );
      if(pageName.runtimeType == DynamicGeneralPage) {
        Navigator.pushAndRemoveUntil(
          context,
          SlideRightRoute(
              page: DynamicGeneralPage(
                inspectionData: inspectionData,
              )
          ),
          ModalRoute.withName(DynamicGeneralPage.tag),
        );
      } else {
        Navigator.push(
            context,
            SlideRightRoute(
                page: pageName
            )
        );
      }
    }
  }

  Map<String, dynamic> adjacencyTransform(List<dynamic> nsResult) {
    try {
      int ix = 0;
      void build(Map<String, dynamic> container) {
        container["children"] = [];
        if (container["rgt"] - container["lft"] < 2) {
          return;
        }

        while ((++ix < nsResult.length) &&
            (nsResult[ix]["lft"] > container["lft"]) &&
            (nsResult[ix]["rgt"] < container["rgt"])) {

          try {
            var entries = nsResult[ix]['label'].toString()
                .substring(1,nsResult[ix]['label'].length-1)
                .split(RegExp(r',\s?'))
                .map((e) => e.split(RegExp(r':\s?')))
                .map((e) => MapEntry(e.first, e.last));
            var result = Map.fromEntries(entries);

            var newData = jsonDecode(json.encode(result));
            nsResult[ix]['label'] = newData[lang] == null
                ? newData['en'].toString().replaceAll("##", "\'").replaceAll("@@", "\"")
                : newData[lang].toString().replaceAll("##", "\'").replaceAll("@@", "\"");
          } catch(e) {
            log("StackTraceMapEntryMultiple====$e");
          }
          container["children"].add(nsResult[ix]);
          build(nsResult[ix]);
        }

        if (ix < nsResult.length) {
          ix--;
        }
      }

      if (nsResult.length > 0) {
        build(nsResult[0]);
        return nsResult[0];
      }
    } catch(e) {
      log("StackTrace====$e");
    }

    return {"children":[]};
  }
}
