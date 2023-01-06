import 'dart:convert';

import 'package:dottie_inspector/pages/inspectionMain/inspection_adding_customer.dart';
import 'package:dottie_inspector/deadCode/inspection_client_information.dart';
import 'package:dottie_inspector/pages/menu/drawer_page.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/SlideRightRoute.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/widget/bottom_general_button_widget.dart';
import 'package:flutter/material.dart';

class SafetyEquipmentInspectionPage extends StatefulWidget {
  static String tag = 'safety-equipment-inspection-screen';
  @override
  _SafetyEquipmentInspectionPageState createState() => _SafetyEquipmentInspectionPageState();
}

class _SafetyEquipmentInspectionPageState extends State<SafetyEquipmentInspectionPage>
  with SingleTickerProviderStateMixin{
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedTab = 0;
  var elevation = 0.0;
  final bodyGlobalKey = GlobalKey();
  ScrollController _scrollController;
  bool fixedScroll = false;
  var jsonResult;
  List equipmentItemList;

  TabController _tabController;
  final List<Tab> tabList = <Tab>[
    Tab(text: 'Overview',),
    Tab(text: 'Tips',),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
//    _scrollController.addListener(_scrollListener);
    _tabController = new TabController(vsync: this, length: tabList.length);

    _tabController.addListener(_handleTabSelection);

    _scrollController.addListener(() {
      setState(() {
        if(_scrollController.position.pixels > _scrollController.position.minScrollExtent){
          elevation = HelperClass.ELEVATION_1;
        } else {
          elevation = HelperClass.ELEVATION;
        }
      });
    });
    getJsonFile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void getJsonFile() async {
    String data = await DefaultAssetBundle.of(context).loadString("assets/inspection_list.json");

    setState(() {
      jsonResult = json.decode(data);
      equipmentItemList = List();
      equipmentItemList = jsonResult['data'];
    });
    print("JsonResult $jsonResult");
  }

  _scrollListener() {
    if (fixedScroll) {
      _scrollController.jumpTo(0);
    }
  }

  void _handleTabSelection() {
    print("Index====${_tabController.index.toString()}");
      setState(() {
        switch (_tabController.index) {
          case 0:
            selectedTab = 0;
            break;

          case 1:
            selectedTab = 1;
            break;
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColor.PAGE_COLOR,
      appBar: AppBar(
        centerTitle: true,
        elevation: elevation,
        backgroundColor: AppColor.PAGE_COLOR,
        /*leading: IconButton(
          padding: EdgeInsets.only(left: 16.0, right: 16.0),
          icon: Icon(Icons.arrow_back_ios,color: AppColor.TYPE_PRIMARY,size: 30.0,),
          onPressed: (){
            Navigator.pop(context);
          },
        ),*/
        leading: InkWell(
          onTap: (){
            _scaffoldKey.currentState.openDrawer();
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
      ),
      drawer: Drawer(
        child: DrawerPage(),
      ),

      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, value) {
              return [
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    alignment: Alignment.center,
                    child: Text(
                      'Safety & Equipment Inspection',
                      style: TextStyle(
                          fontSize: 30.0,
                          color: AppColor.TYPE_PRIMARY,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                          fontFamily: "WorkSans"),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.only(top: 4.0, bottom: 32.0),
//                    alignment: Alignment.center,
//                    child: Text(
//                      '14 Steps',
//                      style: TextStyle(
//                          fontSize: TextSize.subjectTitle,
//                          color: Color(0xff344356).withOpacity(0.6),
//                          fontWeight: FontWeight.w600,
//                          fontStyle: FontStyle.normal,
//                          fontFamily: "WorkSans"),
//                      textAlign: TextAlign.center,
//                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: getTabBar()
                ),
              ];
            },
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 16.0),
                Expanded(
                  child: Container(
                    height: MediaQuery.of(context).size.height - 170.0,
                    child: TabBarView(
                      controller: _tabController,
                      children: tabList.map((Tab tab) {
                        return _getPage(tab);
                      }).toList(),
                      physics: ScrollPhysics(),
                    ),
                  ),
                ),

              ],
            ),
          ),

          BottomGeneralButton(
            buttonName: "START INSPECTION",
            onStartButton: (){
              Navigator.pushReplacement(
                  context,
                  SlideRightRoute(
                      page: InspectionAddCustomer()
                  )
              );
            },
          ),
        ],
      ),
    );
  }

  // ignore: missing_return
  Widget _getPage(Tab tab){

//    print("page text: ${tab.text}");

    switch(tab.text){
      case 'Overview': return overView();
      case 'Tips': return tips();
    }
  }

  Widget getTabBar(){
    return Container(
      alignment: Alignment.center,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: AppColor.TYPE_PRIMARY,
        indicatorColor: AppColor.TRANSPARENT,
        indicatorWeight: 0.1,
        unselectedLabelStyle: TextStyle(
            fontStyle: FontStyle.normal,
            fontSize: TextSize.bodyText,
            color: Color(0xFF344356),
            fontWeight: FontWeight.w500
        ),
        tabs: <Widget>[
          Tab(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10.0),
              decoration: BoxDecoration(
                  color: selectedTab == 0 ? AppColor.THEME_PRIMARY : AppColor.THEME_PRIMARY.withOpacity(0.12),
                  borderRadius: BorderRadius.all(Radius.circular(16.0))
              ),
              alignment: Alignment.center,
              child: Text(
                'Overview',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontStyle: FontStyle.normal,
                    fontSize: TextSize.subjectTitle,
                    color: selectedTab == 0 ? AppColor.WHITE_COLOR : AppColor.THEME_PRIMARY,
                    fontWeight: FontWeight.w600
                ),
              ),
            ),
          ),
          Tab(
            child: Container(
//            height: 44.0,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10.0),
              decoration: BoxDecoration(
                  color: selectedTab == 1 ? AppColor.THEME_PRIMARY : AppColor.THEME_PRIMARY.withOpacity(0.12),
                  borderRadius: BorderRadius.all(Radius.circular(16.0))
              ),
              alignment: Alignment.center,
              child: Text(
                'Tips',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontStyle: FontStyle.normal,
                    fontSize: TextSize.subjectTitle,
                    color: selectedTab == 1 ? AppColor.WHITE_COLOR : AppColor.THEME_PRIMARY,
                    fontWeight: FontWeight.w600
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget overView() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 12.0,),
//            Container(
//              height: 180.0,
//              width: MediaQuery.of(context).size.width,
//              child: Stack(
//                children: [
//                  Positioned(
//                    right: 0.0,
//                    left: 0.0,
//                    child: ClipRRect(
//                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
//                      child: Image.asset(
//                        "assets/ic_safety_bg.png",
//                        height: 180.0,
//                        width: MediaQuery.of(context).size.width,
//                        fit: BoxFit.cover,
//                      ),
//                    ),
//                  ),
//                  Center(
//                    child: Image.asset(
//                      "assets/ic_life_jacket.png",
//                      height: 80.0,
//                      width: 80.0,
//                      fit: BoxFit.cover,
//                    ),
//                  ),
//                ],
//              ),
//            ),

            Container(
              height: 180.0,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16.0), bottomRight: Radius.circular(16.0))
              ),
              child: Stack(
                children: [
                  Positioned(
                      bottom: 0.0,
                      right: 0.0,
                      left: 0.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(16.0),),
                        child: Container(
                          height: 180.0,
                          color: AppColor.SKY_COLOR,
                        ),
                      )
                    /*ClipRRect(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0),topRight: Radius.circular(16.0),),
                                child: Image.asset(
                                  "assets/ic_safety_bg.png",
                                  height: 180.0,
                                  width: MediaQuery.of(context).size.width,
                                  fit: BoxFit.cover,
                                ),
                              ),*/
                  ),
                  Center(
                    child: Image.asset(
                      "assets/ic__welcome_pool.png",
                      height: 80.0,
                      width: 80.0,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              margin: EdgeInsets.only(top: 40.0),
              alignment: Alignment.centerLeft,
              child: Text(
                'Introduction',
                style: TextStyle(
                    fontSize: 24.0,
                    color: AppColor.TYPE_PRIMARY,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                    fontFamily: "WorkSans"),
                textAlign: TextAlign.center,
              ),
            ),

            Container(
              margin: EdgeInsets.only(top: 16.0),
              child: Text(
                'Designed to compile a complete inventory of pool, spa and water features including all the supporting equipment. It also provides an review, documentation and recommendations of potential safety hazards.',
                style: TextStyle(
                  fontSize: 16.0,
                  color: AppColor.TYPE_PRIMARY.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal,
                  fontFamily: "WorkSans",
                  height: 1.3
                ),
              ),
            ),

            Container(
              margin: EdgeInsets.only(top: 40.0),
              alignment: Alignment.centerLeft,
              child: Text(
                'Steps',
                style: TextStyle(
                    fontSize: 24.0,
                    color: AppColor.TYPE_PRIMARY,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                    fontFamily: "WorkSans"),
                textAlign: TextAlign.center,
              ),
            ),

            Container(
              margin: EdgeInsets.only(top: 16.0),
              child: Text(
                'Inspector Dottie will take you step by step through a Safety & Equipment inspection and then prepare a comprehensive inspection report. That you can emailed to your client.\n\n All the inspection verbiage and descriptive detail is baked in. All you need to do is inspect, evaluate, take a picture and add a comment or annotation. The system does the rest.',
                style: TextStyle(
                    fontSize: 16.0,
                    color: AppColor.TYPE_PRIMARY.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    fontFamily: "WorkSans",
                    height: 1.3
                ),
              ),
            ),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              margin: EdgeInsets.only(top:32.0, bottom: 8.0),
              decoration: BoxDecoration(
                  color: AppColor.WHITE_COLOR,
                  borderRadius: BorderRadius.circular(16)
              ),
              child: ListView.builder(
                itemCount: equipmentItemList != null ? equipmentItemList.length : 0,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index){
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                  color: AppColor.BACKGROUND_COLOR.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(24)
                              ),
                              child: Image.asset(
                                '${equipmentItemList[index]['image']}',
                                width: 24.0,
                                height: 24.0,
                                color: AppColor.THEME_PRIMARY,
                              ),
                            ),
                            SizedBox(width: 16.0,),
                           Expanded(
                             child: Text(
                               '${equipmentItemList[index]['name']}',
                               style: TextStyle(
                                   color: AppColor.TYPE_PRIMARY,
                                   fontSize: TextSize.headerText,
                                   fontWeight: FontWeight.w600,
                                   fontFamily: 'WorkSans'
                               ),
                             ),
                           )
                           /* Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  *//*Text(
                                    'Step ${equipmentItemList[index]['id']}',
                                    style: TextStyle(
                                        color: AppColor.TYPE_PRIMARY.withOpacity(0.6),
                                        fontSize: TextSize.subjectTitle,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'WorkSans'
                                    ),
                                  ),*//*
                                  SizedBox(height: 4.0,),
                                  Text(
                                    '${equipmentItemList[index]['name']}',
                                    style: TextStyle(
                                        color: AppColor.TYPE_PRIMARY,
                                        fontSize: TextSize.headerText,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'WorkSans'
                                    ),
                                  )
                                ],
                              ),
                            )*/
                          ],
                        ),
                      ),
                      Container(

                        child: Divider(
                          height: 1.0,
                          color: AppColor.SEC_DIVIDER,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),


            SizedBox(height: 120.0),
          ],
        ),
      ),
    );
  }

  Widget tips() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 12.0,),
//            Container(
//              height: 180.0,
//              width: MediaQuery.of(context).size.width,
//              child: Stack(
//                children: [
//                  Positioned(
//                    right: 0.0,
//                    left: 0.0,
//                    child: ClipRRect(
//                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
//                      child: Image.asset(
//                        "assets/ic_safety_bg.png",
//                        height: 180.0,
//                        width: MediaQuery.of(context).size.width,
//                        fit: BoxFit.cover,
//                      ),
//                    ),
//                  ),
//                  Center(
//                    child: Image.asset(
//                      "assets/ic_life_jacket.png",
//                      height: 80.0,
//                      width: 80.0,
//                      fit: BoxFit.cover,
//                    ),
//                  ),
//                ],
//              ),
//            ),

            Container(
              height: 180.0,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16.0), bottomRight: Radius.circular(16.0))
              ),
              child: Stack(
                children: [
                  Positioned(
                      bottom: 0.0,
                      right: 0.0,
                      left: 0.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(16.0),),
                        child: Container(
                          height: 180.0,
                          color: AppColor.SKY_COLOR,
                        ),
                      )
                    /*ClipRRect(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0),topRight: Radius.circular(16.0),),
                                child: Image.asset(
                                  "assets/ic_safety_bg.png",
                                  height: 180.0,
                                  width: MediaQuery.of(context).size.width,
                                  fit: BoxFit.cover,
                                ),
                              ),*/
                  ),
                  Center(
                    child: Image.asset(
                      "assets/ic_bulb.png",
                      height: 80.0,
                      width: 80.0,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              margin: EdgeInsets.only(top: 40.0),
              alignment: Alignment.centerLeft,
              child: Text(
                'Dottie Tips',
                style: TextStyle(
                    fontSize: 24.0,
                    color: AppColor.TYPE_PRIMARY,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                    fontFamily: "WorkSans"),
                textAlign: TextAlign.center,
              ),
            ),

            Container(
              margin: EdgeInsets.only(top: 16.0),
              child: Text(
                'Far far away, behind the word mountains, far from the countries Vokalia and Consonantia, there live the blind texts. Separated they live in Bookmarksgrove right at the coast of the Semantics, a large language ocean. A small river named Duden flows by their place and supplies it with the necessary regelialia. ',
                style: TextStyle(
                    fontSize: 16.0,
                    color: AppColor.TYPE_PRIMARY.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    fontFamily: "WorkSans",
                    height: 1.3
                ),
              ),
            ),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              margin: EdgeInsets.only(top:32.0, bottom: 8.0),
              decoration: BoxDecoration(
                  color: AppColor.WHITE_COLOR,
                  borderRadius: BorderRadius.circular(16)
              ),
              child: ListView.builder(
                itemCount: 5,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index){
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                  color: AppColor.BACKGROUND_COLOR.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(24)
                              ),
                              child: Image.asset(
                                '${equipmentItemList[index]['image']}',
                                width: 24.0,
                                height: 24.0,
                                color: AppColor.THEME_PRIMARY,
                              ),
                            ),
                            SizedBox(width: 16.0,),
                            Expanded(
                              child: Text(
                                '${equipmentItemList[index]['name']}',
                                style: TextStyle(
                                    color: AppColor.TYPE_PRIMARY,
                                    fontSize: TextSize.headerText,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'WorkSans'
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        child: Divider(
                          height: 1.0,
                          color: AppColor.SEC_DIVIDER,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            /*Container(
              child: ListView.builder(
                itemCount: 10,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index){
                  return Container(
                    margin: EdgeInsets.only(top: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.0),
                          child: Image.asset(
                            'assets/pool/ic_wheel.png',
                            width: 24.0,
                            height: 24.0,
                            color: AppColor.THEME_PRIMARY,
                          ),
                        ),
                        SizedBox(width: 16.0,),
                        Expanded(
                          child: Text(
                            'Far far away, behind the word mountains',
                            style: TextStyle(
                              color: AppColor.TYPE_PRIMARY,
                              fontSize: TextSize.headerText,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'WorkSans',
                              height: 1.3
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),*/

            SizedBox(height: 120.0),
          ],
        ),
      ),
    );
  }
}
