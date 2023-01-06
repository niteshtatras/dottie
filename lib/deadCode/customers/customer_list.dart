import 'dart:async';
import 'dart:convert';

import 'package:dottie_inspector/pages/menu/drawer_page.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/widget/custom_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:progress_hud/progress_hud.dart';

import '../../utils/helper_class.dart';
import '../../webServices/AllRequest.dart';
import '../models/customer_detail.dart';
import '../models/customer_list_detail.dart';
import 'add_new_customer.dart';
import 'customer_detail.dart';

class CustomerListPage extends StatefulWidget {
  final type;
  static String tag = 'customer-list-page';

  const CustomerListPage({Key key, this.type}) : super(key: key);

  @override
  _CustomerListPageState createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;

  Timer timer;

  TextEditingController controller = new TextEditingController();
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
  List _searchResult = List();
  List selectCustomer = List();
  int alphaIndex = 64;

  var type = 0;

  @override
  void initState() {
    super.initState();
//    WidgetsBinding.instance.addPostFrameCallback(getCustomerList);
    _progressHUD = ProgressHUD(
      backgroundColor: Colors.transparent,
      color: Colors.white,
      containerColor: AppColor.LOADER_COLOR,
      borderRadius: 5.0,
      loading: _loading,
      text: 'Loading...',
    );

    type = widget.type ?? 0;
//    getJsonFile();
    timer = Timer(Duration(milliseconds: 1000), getCustomerList);
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
      backgroundColor: AppColor.WHITE_COLOR,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: AppColor.WHITE_COLOR,
        actions: <Widget>[
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
        ],
        leading: deleteEnable
          ? IconButton(
              padding: EdgeInsets.only(left: 16.0, right: 16.0),
              icon: Icon(Icons.clear,color: AppColor.TYPE_PRIMARY,size: 32.0,),
              onPressed: (){
                setState(() {
                  deleteEnable = false;
                  selectCustomer.clear();
                  filterCustomerList1(customerMainList, 'inactive');
                });
              },
            )
          : IconButton(
              padding: EdgeInsets.only(left: 16.0, right: 16.0),
              icon: Icon(Icons.menu,color: AppColor.TYPE_PRIMARY,size: 32.0,),
              onPressed: (){
                _scaffoldKey.currentState.openDrawer();
              },
            ),
        title: Text(
          'Customers',
          style: TextStyle(
              color: AppColor.TYPE_PRIMARY,
              fontSize: TextSize.headerText,
              fontWeight: FontWeight.w600
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
              margin: EdgeInsets.only(top: 70.0,bottom: 70.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  customerList == null
                  ? Container()
                  : customerMainList.length == 0
                  ? HelperClass.getNoDataFountText("No Customer Available yet!")
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
                              InkWell(
                                onTap: (){
                                  if(type == 0) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CustomerDetailPage(
                                                  customerData: _searchResult[index],
                                                )
                                        )
                                    );
                                  } else {
                                    Navigator.pop(context);
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 22.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      !deleteEnable
                                      ? CircleAvatar(
                                        backgroundColor: AppColor.BG_SECONDARY_ALT,
                                        child: Container(
                                          child: ClipOval(
                                            child: Image.asset(
                                              'assets/profile_avatar.png',
                                              fit: BoxFit.contain,
                                              height: 48.0,
                                              width: 48.0,
                                            ),
                                          ),
                                        ),
                                        radius: 24.0,
                                      )
                                      : _searchResult[index]['status'] == 0
                                      ? InkWell(
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
                                      : InkWell(
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
                                                    fontFamily: 'WorkSans',
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: TextSize.headerText
                                                ),
                                              ),
                                              SizedBox(height: 3.0,),
                                              Text(
                                                _searchResult[index]['email'] == null ? '---' : '${ _searchResult[index]['email']}',
                                                style: TextStyle(
                                                    color: _searchResult[index]['clientdisabled'] ? AppColor.DEACTIVATE :  AppColor.TYPE_SECONDARY,
                                                    fontFamily: 'WorkSans',
                                                    fontWeight: FontWeight.w500,
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
                          actions: <Widget>[
                            Container(
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
                          ],
                          secondaryActions: <Widget>[
                            InkWell(
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
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          customerList[index]['key'] == ''
                          ? Container()
                          : Container(
                            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 22.0),
                            child: Text(
//                              '${String.fromCharCode(index + 65)}',
                              '${customerList[index]['key']}',
                              style: TextStyle(
                                color: AppColor.TYPE_SECONDARY,
                                fontFamily: 'WorkSans',
                                fontWeight: FontWeight.w600,
                                fontSize: TextSize.bodyText
                              ),
                            ),
                          ),
                          Container(
                            child: ListView.builder(
                              itemCount:  customerList[index]['values'] != null ? customerList[index]['values'].length : 0,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, subIndex){
                                var customerDetailList = customerList[index]['values'];
                                return Slidable(
                                  actionPane: SlidableScrollActionPane(),
                                  actionExtentRatio: 0.35,
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 22.0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            ! deleteEnable
                                            ? CircleAvatar(
                                                backgroundColor: AppColor.BG_SECONDARY_ALT,
                                                child: Container(
                                                  child: ClipOval(
                                                    child: Image.asset(
                                                      'assets/profile_avatar.png',
                                                      fit: BoxFit.contain,
                                                      height: 48.0,
                                                      width: 48.0,
                                                    ),
                                                  ),
                                                ),
                                                radius: 24.0,
                                              )
                                            : customerList[index]['values'][subIndex]['status'] == 0
                                            ? InkWell(
                                                onTap: (){
                                                  setState(() {
                                                    customerList[index]['values'][subIndex]['status'] = 1;
                                                    selectCustomer.add(customerList[index]['values'][subIndex]);
                                                  });
                                                  print("CustomerIdsWith===${selectCustomer.toString()}");
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
                                            : InkWell(
                                                onTap: (){
                                                  setState(() {
                                                    customerList[index]['values'][subIndex]['status'] = 0;
//                                                    removeCustomerFromList("${customerList[index]['values'][subIndex]['clientid']}");
                                                    selectCustomer.removeWhere((element){
                                                      return element['clientid'] == customerList[index]['values'][subIndex]['clientid'];
                                                    });
                                                  });
                                                  print("CustomerIdsWith===${selectCustomer.toString()}");
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
                                              child: InkWell(
                                                onTap: (){
                                                  if(type == 0) {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (
                                                                context) =>
                                                                CustomerDetailPage(
                                                                  customerData: customerDetailList[subIndex],
                                                                )
                                                        )
                                                    ).then((result){
                                                      if(result!=null){
                                                        setState(() {
                                                          customerDetailList[subIndex] = result['data'];
                                                        });
                                                      }
                                                    });
                                                  } else {
                                                    Navigator.pop(context);
                                                  }
                                                },
                                                child: Container(
                                                  margin: EdgeInsets.only(left: 16.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      Text(
                                                        '${customerDetailList[subIndex]['firstname']}',
                                                        style: TextStyle(
                                                            color: customerDetailList[subIndex]['clientdisabled'] ? AppColor.DEACTIVATE : AppColor.TYPE_PRIMARY,
                                                            fontFamily: 'WorkSans',
                                                            fontWeight: FontWeight.w600,
                                                            fontSize: TextSize.headerText
                                                        ),
                                                      ),
                                                      SizedBox(height: 3.0,),
                                                      Text(
                                                        customerDetailList[subIndex]['email'] == null ? '---' : '${customerDetailList[subIndex]['email']}',
                                                        style: TextStyle(
                                                            color: customerDetailList[subIndex]['clientdisabled'] ? AppColor.DEACTIVATE : AppColor.TYPE_SECONDARY,
                                                            fontFamily: 'WorkSans',
                                                            fontWeight: FontWeight.w500,
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
                                      Divider(
                                        height: 1.0,
                                        color: AppColor.SEC_DIVIDER,
                                      ),
                                    ],
                                  ),
                                  actions: <Widget>[
                                    InkWell(
                                      onTap:(){
                                        setState(() {
                                          if(customerList[index]['values'][subIndex]['status'] == 0) {
                                            deleteEnable = true;
                                            customerList[index]['values'][subIndex]['status'] = 1;
                                            selectCustomer.add("${customerList[index]['values'][subIndex]}");
                                            deactivateEnable = selectCustomer.length > 0;
                                          } else {
                                            deleteEnable = true;
                                            customerList[index]['values'][subIndex]['status'] = 0;
                                            selectCustomer.removeWhere((element){
                                              return element['clientid'] == customerList[index]['values'][subIndex]['clientid'];
                                            });
                                            deactivateEnable = selectCustomer.length > 0;
                                          }
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
                                  ],
                                  secondaryActions: <Widget>[
    //                                IconSlideAction(
    //                                  caption: 'Activate',
    //                                  color: AppColor.TYPE_PRIMARY,
    //                                  icon: Icons.visibility,
    //                                  onTap: () {}
    //                                ),
                                    InkWell(
                                      onTap: (){
                                        selectCustomer.clear();
                                        selectCustomer.add(customerList[index]['values'][subIndex]);
                                        showCustomDialog(
                                          context,
                                          customerList[index]['values'][subIndex]['clientdisabled']
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
                                              customerDetailList[subIndex]['clientdisabled'] ? 'assets/activate_user.png' : 'assets/deactivate_user.png',
                                              fit: BoxFit.contain,
                                              height: 24.0,
                                              width: 24.0,
                                              color: AppColor.WHITE_COLOR,
                                            ),
                                            SizedBox(width: 6.0,),
                                            Flexible(
                                              child: Text(
                                                customerDetailList[subIndex]['clientdisabled'] ? 'Activate' : 'Inactivate',
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
                            ),
                          ),
                        ],
                      );
                    }
                  )
                ],
              ),
            ),
          ),
          //Search bar
          Positioned(
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
//                      Tex(
//                        'Search',
//                        style: TextStyle(
//                            color: AppColor.TYPE_SECONDARY,
//                            fontFamily: 'WorkSans',
//                            fontWeight: FontWeight.w500,
//                            fontSize: TextSize.subjectTitle
//                        ),
//                      ),
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
//                child: ListTile(
//                  leading: Image.asset(
//                      'assets/ic_search.png',
//                      fit: BoxFit.contain,
//                      height: 24.0,
//                      width: 24.0,
//                    ),
//                  title: TextField(
//                    controller: controller,
//                    decoration: new InputDecoration(
//                        hintText: 'Search', border: InputBorder.none),
//                    onChanged: onSearchTextChanged,
//                  ),
//                  trailing: new IconButton(icon: new Icon(Icons.cancel), onPressed: () {
//                    controller.clear();
//                    onSearchTextChanged('');
//                  },),
//                ),
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
                child: InkWell(
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
                      InkWell(
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
                              fontFamily: 'WorkSans'
                            ),
                          ),
                        ),
                      ),
                      Divider(
                        height: 1.0,
                        color: AppColor.SEC_DIVIDER,
                      ),
                      InkWell(
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
                                      fontFamily: 'WorkSans'
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
                                fontFamily: 'WorkSans'
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
                                fontFamily: 'WorkSans'
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
                                fontFamily: 'WorkSans'
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
                      InkWell(
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
                                fontFamily: 'WorkSans'
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
                                fontFamily: 'WorkSans'
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
                                fontFamily: 'WorkSans'
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
                        fontFamily: 'WorkSans'
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
                        fontFamily: 'WorkSans',
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
                        child: InkWell(
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
                                fontFamily: 'WorkSans',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: InkWell(
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
                                fontFamily: 'WorkSans',
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
                        fontFamily: 'WorkSans'
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
                        fontFamily: 'WorkSans',
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
                                fontFamily: 'WorkSans',
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
                                fontFamily: 'WorkSans',
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
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {
        _searchClear = false;
      });
      return;
    }
    _searchClear = true;
    for(int i=0; i<customerList.length ; i++) {
      for(int j=0; j<customerList[i]['values'].length ; j++) {
        if(customerList[i]['values'][j]['firstname'].toString().toLowerCase().contains(text.toLowerCase()) ||
            customerList[i]['values'][j]['lastname'].toString().toLowerCase().contains(text.toLowerCase())){
          setState(() {
            _searchResult.add(customerList[i]['values'][j]);
          });
        }
      }
    }
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
          customerList = response;
          customerMainList = response;
//        countryHeaderList = response;
          filterCustomerList1(customerList, 'inactive');
        });
//      } else {
//        _scaffoldKey.currentState.showSnackBar(HelperClass.showSnackBar(context, '${response['reason']}'));
//      }
    } else {

    }
  }

  void filterCustomerList(customersList, type) {
    print("Country list response get back: $customersList");
    customerList = List();
    for(int i=0; i<26; i++){
      List customerDataList = List();
      for(int j=0; j<customersList.length; j++){
        if(customersList[j]['firstname'].toString().toUpperCase().startsWith(String.fromCharCode(i+65))){
          customersList[j]['status'] = 0;
          customerDataList.add(customersList[j]);

          /*print("Disabled===${customersList[j]['clientdisabled']}");
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
          }*/
        }
      }
      var customerMap = {
        "key": customerDataList.length > 0 ? String.fromCharCode(i+65) : '',
        "values": customerDataList
      };
      print(customerMap);
      setState(() {
        customerList.add(customerMap);
      });
    }
//    print("List====$customerList");
  }

  void filterCustomerList1(customersList, type) {
    print("Country list response get back: $customersList");
    var customerList1 = List();
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
}
