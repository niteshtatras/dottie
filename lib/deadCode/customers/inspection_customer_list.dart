import 'dart:async';
import 'dart:convert';

import 'package:dottie_inspector/pages/menu/drawer_page.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/custom_toast.dart';
import 'package:dottie_inspector/widget/custom_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:progress_hud/progress_hud.dart';

import '../models/customer_detail.dart';
import '../models/customer_list_detail.dart';
import 'add_new_customer.dart';
import '../../utils/helper_class.dart';
import '../../webServices/AllRequest.dart';

class InspectionCustomerListPage extends StatefulWidget {
  static String tag = 'inspection-customer-list-page';
  final type;

  const InspectionCustomerListPage({Key key, this.type}) : super(key: key);

  @override
  _InspectionCustomerListPageState createState() => _InspectionCustomerListPageState();
}

class _InspectionCustomerListPageState extends State<InspectionCustomerListPage> {
  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading  = false;
  bool isSlideOpen = false;

  Timer timer;

  TextEditingController controller = new TextEditingController();
  FocusNode _searchFocus = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  SlidableController _slideController;
  Key _slideControllerKey = Key("slide");
  bool deleteEnable = false;
  bool deactivateEnable = false;
  int activateValue = 0;
  bool _searchClear = false;
  bool focusEnable = false;
  bool _inactivateCustomers = false;
  var jsonResult;
  List customerList;
  List customerMainList;
  List _searchResult = List();
  List selectCustomer = List();
  int alphaIndex = 64;

  String inspectionType = "Active";
  bool isDialogOpen = false;
  bool hasFocus = false;

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

//    getJsonFile();
    timer = Timer(Duration(milliseconds: 1000), getCustomerList);

    _searchFocus.addListener(() {
      setState(() {
        hasFocus = _searchFocus.hasFocus;
      });
    });

    _slideController = SlidableController(
      onSlideIsOpenChanged:  (result) {
        print("HELLO===>>>$result");
      }
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    timer.cancel();
  }

  void getJsonFile() async {
    String data = await DefaultAssetBundle.of(context).loadString("assets/customer_list.json");

    setState(() {
      jsonResult = json.decode(data);
      customerList = List();
      customerList = jsonResult['data'];
    });
    print("JsonResult $jsonResult");
  }

  onSearchTextChanged1(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {
        _searchClear = false;
      });
      return;
    }
    _searchClear = true;
    var count = 0;
    List<CustomerDetail> searchUserData;
    for(int i=0; i<customerList.length ; i++){
      count = 0;
      searchUserData = List();
      for(int j=0; j<customerList[i]['values'].length; j++){
        if(customerList[i]['values'][j]['name'].toLowerCase().contains(text)){
          searchUserData.add(
              CustomerDetail(
                customerList[i]['values'][j]['id'],
                customerList[i]['values'][j]['name'],
                customerList[i]['values'][j]['email'],
                0
              )
          );
          count++;
        }
      }
      if(count>0){
        setState(() {
          _searchResult.add(
              CustomerListDetail(
                customerList[i]['key'],
                searchUserData
              )
          );
        });
      }
    }

    setState(() {
      _searchResult = _searchResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.PAGE_COLOR,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: AppColor.PAGE_COLOR,
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
        /*actions: [
          GestureDetector(
            onTap: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddNewCustomerPage()
                  )
              ).then((result) {
                if(result!=null){
                  getCustomerList();
                }
              });
            },
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 6.0, vertical: 12.0),
              padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 20.0, right: 20.0),
              decoration: BoxDecoration(
                  color: AppColor.THEME_PRIMARY.withOpacity(0.2),
                  borderRadius: BorderRadius.all(Radius.circular(16.0))),
              child: Text(
                'NEW CUSTOMER',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: TextSize.bodyText,
                    color: AppColor.THEME_PRIMARY,
                    fontStyle: FontStyle.normal),
              ),
            ),
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
            _scaffoldKey.currentState.openDrawer();
          },
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Image.asset(
              'assets/ic_menu.png',
              fit: BoxFit.cover,
              color: AppColor.TYPE_PRIMARY,
              height: 28.0,
              width: 28.0,
            ),
          ),
        ),
      /*  title: Text(
          'Customers',
          style: TextStyle(
              color: AppColor.TYPE_PRIMARY,
              fontSize: TextSize.headerText,
              fontWeight: FontWeight.w600
          ),
        ),*/
      ),
      key: _scaffoldKey,
      drawer: Drawer(
        child: DrawerPage(),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 80.0,bottom: 70.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
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
                                     /* if(widget.type == 1){
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (
                                                    context) =>
                                                    CustomerDetailPage(
                                                      customerData: _searchResult[index],
                                                    )
                                            )
                                        ).then((result){
                                          if(result!=null){
                                            setState(() {
                                              _searchResult[index] = result['data'];
                                            });
                                          }
                                        });
                                      } else {
                                        getCustomerDetail(_searchResult[index]['clientid']);
                                      }*/
                                    },
                                    child: Container(
                                      padding: EdgeInsets.only(right: 16.0),
                                      margin: EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
                                      decoration: BoxDecoration(
                                        color: AppColor.WHITE_COLOR,
                                        borderRadius: BorderRadius.circular(16.0),
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
                                              borderRadius: BorderRadius.circular(16.0),
                                            ),
//                                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                                            height: 72.0,
                                            width: 72.0,
                                            alignment: Alignment.center,
                                            child: Text(
                                              '${_searchResult[index]['firstname'][0]}',
                                              style: TextStyle(
                                                  color: AppColor.WHITE_COLOR,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 24.0
                                              ),
                                            ),
                                          )
                                          : _searchResult[index]['status'] == 0
                                          ? GestureDetector(
                                            onTap: (){
                                              setState(() {
                                                _searchResult[index]['status'] = 1;
                                                selectCustomer.add(_searchResult[index]['clientid']);
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
                                                _searchResult[index]['status'] = 0;
                                                selectCustomer.remove(_searchResult[index]['clientid']);
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
                                                  Text(
                                                    '${ _searchResult[index]['firstname']}',
                                                    style: TextStyle(
                                                        color: _searchResult[index]['clientdisabled'] ? AppColor.DEACTIVATE : AppColor.TYPE_PRIMARY,

                                                        fontWeight: FontWeight.w700,
                                                        fontSize: TextSize.headerText
                                                    ),
                                                  ),
                                                  SizedBox(height: 3.0,),
                                                  Text(
                                                    _searchResult[index]['email'] == null ? '---' : '${ _searchResult[index]['email']}',
                                                    style: TextStyle(
                                                        color: _searchResult[index]['clientdisabled'] ? AppColor.DEACTIVATE :  AppColor.TYPE_SECONDARY,

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
                                  Divider(
                                    height: 1.0,
                                    color: AppColor.SEC_DIVIDER,
                                  ),
                                ],
                              ),
                              secondaryActions: <Widget>[
                                GestureDetector(
                                  onTap: (){
                                    showCustomDialog(
                                      context,
                                      _searchResult[index]
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
                                          _searchResult[index]['clientdisabled'] ? 'assets/activate_user.png' : 'assets/deactivate_user.png',
                                          fit: BoxFit.contain,
                                          height: 24.0,
                                          width: 24.0,
                                          color: AppColor.WHITE_COLOR,
                                        ),
                                        SizedBox(width: 6.0,),
                                        Flexible(
                                          child: Text(
                                            _searchResult[index]['clientdisabled'] ? 'Activate' : 'Inactivate',
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
                          itemCount: customerList != null ? customerList.length : 0,
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index){
                            return GestureDetector(
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
//                            Navigator.of(context).pop({"data": customerList[index]});

                              // Main Detail
                               /* if(widget.type == 1){
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
                                  getCustomerDetail(customerList[index]['clientid']);
                                }*/
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
                                child: Slidable(
                                  controller: _slideController,
                                  closeOnScroll: true,
                                  actionPane: SlidableScrollActionPane(),
                                  actionExtentRatio: 0.45,
                                  child: Container(
                                    padding: EdgeInsets.only(right: 16.0),
                                   decoration: BoxDecoration(
                                      color: AppColor.WHITE_COLOR,
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(isSlideOpen ? 0.0 : 16.0),
                                        bottomRight: Radius.circular(isSlideOpen ? 0.0 : 16.0),
                                        topLeft: Radius.circular(16.0),
                                        bottomLeft: Radius.circular(16.0),
                                      ),
                                    ),
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
                                            borderRadius: BorderRadius.circular(16.0),
                                          ),
//                                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                                          height: 72.0,
                                          width: 72.0,
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${customerList[index]['firstname'][0]}',
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
                                          child: GestureDetector(
                                            onTap: (){
                                            },
                                            child: Container(
                                              margin: EdgeInsets.only(left: 16.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    '${customerList[index]['firstname'] ?? ''} ${customerList[index]['lastname'] ?? ''}',
                                                    style: TextStyle(
                                                        color: customerList[index]['clientdisabled'] ? AppColor.DEACTIVATE : AppColor.TYPE_PRIMARY,

                                                        fontWeight: FontWeight.w700,
                                                        fontSize: TextSize.headerText
                                                    ),
                                                  ),
                                                  SizedBox(height: 3.0,),
                                                  Text(
                                                    customerList[index]['email'] == null ? '---' : '${customerList[index]['email']}',
                                                    style: TextStyle(
                                                        color: customerList[index]['clientdisabled'] ? AppColor.DEACTIVATE : AppColor.TYPE_PRIMARY.withOpacity(0.8),

                                                        fontWeight: FontWeight.w600,
                                                        fontSize: TextSize.subjectTitle
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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
                                        height: 72.0,
                                        decoration: BoxDecoration(
                                          color: AppColor.TYPE_PRIMARY,
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(16.0),
                                            bottomRight: Radius.circular(16.0),
                                          ),
                                        ),
                                        padding: EdgeInsets.only(left: 10.0,right: 10.0),
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
                                ),
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                ),

                // Search Widget
                Container(
                  height: 72.0,
                  margin: EdgeInsets.symmetric(horizontal: 16.0),
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      color: AppColor.WHITE_COLOR
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
                                    fillColor: AppColor.WHITE_COLOR,
                                    filled: true,
                                    border: InputBorder.none,
                                    hintText: "Search",
                                    hintStyle: TextStyle(
                                        fontSize: TextSize.subjectTitle,
                                        color: AppColor.TYPE_PRIMARY.withOpacity(0.6)
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
                        visible: controller.text == '' && !hasFocus,
                        child: GestureDetector(
                          onTap: (){
                            setState(() {
                              isDialogOpen = !isDialogOpen;
                            });
                          },
                          child: Container(
                            width: 160.0,
                            height: 56.0,
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            decoration: BoxDecoration(
                                color: AppColor.THEME_PRIMARY ,
                                borderRadius: BorderRadius.all(Radius.circular(16.0))
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    '$inspectionType',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: AppColor.WHITE_COLOR,
                                      fontSize: TextSize.headerText,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.normal,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 24.0,
                                  color: AppColor.WHITE_COLOR,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),

                      Visibility(
                        visible: controller.text != '' || hasFocus,
                        child: GestureDetector(
                          onTap: (){
                            setState(() {
                              _searchResult.clear();
                              controller.text = '';
                            });
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
              ],
            ),
          ),

          Positioned(
            top:0,
            bottom:0,
            left:0,
            right:0,
            child: Visibility(
              visible: isDialogOpen,
              child: Container(
                color: AppColor.PAGE_COLOR.withOpacity(0.8),
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),

          Positioned(
          top: 72.0,
          right: 32.0,
            child: Visibility(
              visible: isDialogOpen,
              child: Container(
                width: 160.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: AppColor.WHITE_COLOR
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          inspectionType = "All";
                          if(_searchResult.length > 0) {
                            filterCustomer(customerMainList, 'all');
                          } else {
                            filterCustomer(customerMainList, 'all');
                          }
                          isDialogOpen = false;
                        });
                      },
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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
                          isDialogOpen = false;
                        });
                      },
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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
                          isDialogOpen = false;
                        });
                      },
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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
            ),
          ),

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

  bottomNavigation(context){
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
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddNewCustomerPage()
                              )
                          ).then((result) {
                            if(result!=null){
                              getCustomerList();
                            }
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                          child: Text(
                            'Create New Customer',
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
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Show Inactivated Customers',
                                  style: TextStyle(
                                      fontSize: TextSize.headerText,
                                      color: AppColor.TYPE_PRIMARY,
                                      fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 5.0),
                                child: CustomSwitch(
                                  value: _inactivateCustomers,
                                  onChanged: (val){
                                    myState((){
                                      setState(() {
                                        _inactivateCustomers = val;
                                        if(_inactivateCustomers){
                                          filterCustomerList1(customerMainList, 'normal');
                                        } else {
                                          filterCustomerList1(customerMainList, 'inactive');
                                        }
                                      });
                                    });
                                    Navigator.pop(context);
                                  },
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
                      GestureDetector(
                        onTap: (){
                          myState(() {
                            setState(() {
                              deleteEnable = true;
                              filterCustomerList1(customerMainList, 'inactive');
                              selectCustomer.clear();
                              activateValue = 1;
                            });
                          });

                          print("Enabled=====$deleteEnable");
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                          child: Text(
                            'Inactivate Customers',
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
                          myState(() {
                            deleteEnable = true;
                            filterCustomerList1(customerMainList, 'active');
                            selectCustomer.clear();
                            activateValue = 0;
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                          child: Text(
                            'Activate Customers',
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
    /*_searchResult.clear();
    if (text.isEmpty) {
      setState(() {
        _searchClear = false;
      });
      return;
    }
    _searchClear = true;
    for(int i=0; i<customerList.length ; i++) {
      if(customerList[i]['firstname'].toString().toLowerCase().contains(text.toLowerCase()) ||
          customerList[i]['lastname'].toString().toLowerCase().contains(text.toLowerCase())){
        setState(() {
          _searchResult.add(customerList[i]);
        });
      }
    }*/
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
    for(int i=0; i<customerMainList.length ; i++) {
      if(customerMainList[i]['firstname'].toString().toLowerCase().startsWith(text.toLowerCase()) /*||
          customerList[i]['lastname'].toString().toLowerCase().contains(text.toLowerCase())*/){
        setState(() {
          _searchResult.add(customerMainList[i]);
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
      setState(() {
        customerList = List();
        customerMainList = List();
      });

//      if(response['success']){
      setState(() {
//          customerList = response;
        customerMainList = response;
//        countryHeaderList = response;

        customerMainList.sort((a, b){
          return a['firstname'].toString().toLowerCase().compareTo(
              b['firstname'].toString().toLowerCase()
          );
        });

        for(int i=0; i<customerMainList.length; i++) {
          if(!customerMainList[i]['clientdisabled'])
            customerList.add(customerMainList[i]);
        }
      });
//      setState(() {
//        customerList = List();
//        customerMainList = List();
//      });
//
////      if(response['success']){
//        setState(() {
//          customerList = response;
//          customerMainList = response;
////        countryHeaderList = response;
//
//          for(int i=0; i<customerMainList.length; i++){
//            customerMainList[i]['status'] = 0;
//          }
//
//          customerMainList.sort((a, b){
//            return a['firstname'].toString().toLowerCase().compareTo(b['firstname'].toString().toLowerCase());
//          });
//          print("CustomerList======$customerMainList");
//          filterCustomer(customerMainList, 'active');
////          filterCustomerList1(customerList, 'inactive');
//        });
//      } else {
//        _scaffoldKey.currentState.showSnackBar(HelperClass.showSnackBar(context, '${response['reason']}'));
//      }
    } else {

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
      List customerDataList = List();
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
      customerList = List();
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

  Future<void> getCustomerDetail(id) async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var response = await request.getAuthRequest("auth/myclient/$id");
//    print("Country list response get back: $response");
    _progressHUD.state.dismiss();

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage('${response['reason']}');
      } else {
        Navigator.of(context).pop({
          "data": response
        });
      }
    }
  }
}
