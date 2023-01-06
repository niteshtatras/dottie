import 'dart:async';
import 'dart:convert';

import 'package:dottie_inspector/deadCode/customerDetail/customer_name.dart';
import 'package:dottie_inspector/deadCode/customerDetail/customer_phone.dart';
import 'package:dottie_inspector/deadCode/customerDetail/customer_service_location.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/SlideRightRoute.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:flutter/material.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../deadCode/customerDetail/customer_billing_address.dart';
import '../../deadCode/customerDetail/customer_email.dart';


class CustomerDetailPage extends StatefulWidget {
  final customerData;

  const CustomerDetailPage({Key key, this.customerData, }) : super(key: key);

  @override
  _CustomerDetailPageState createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;

  Timer timer;
  int statusCode = 0;

  String firstName = '';
  String lastName = '';
  String noteDescription = '';

  List emailList = List();
  List phoneList = List();
  List billingAddressList = List();
  List serviceLocationList = List();

  var customerData;

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

    print(widget.customerData);

    customerData = widget.customerData ?? null;
    timer = Timer(Duration(milliseconds: 1000), getCustomerDetail);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColor.WHITE_COLOR,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: AppColor.WHITE_COLOR,
        leading: IconButton(
          padding: EdgeInsets.only(left: 16.0, right: 16.0),
          icon: Icon(Icons.keyboard_backspace,color: AppColor.TYPE_PRIMARY,size: 32.0,),
          onPressed: (){
            Navigator.of(context).pop({"data": customerData});
          },
        ),
        title: InkWell(
          onTap: (){
           // Navigator.push(
           //   context,
           //   SlideRightRoute(
           //      page: InspectionPage()
           //   )
           // );
          },
          child: Text(
            '${customerData['firstname']}',
            style: TextStyle(
                color: AppColor.TYPE_PRIMARY,
                fontSize: TextSize.headerText,
                fontWeight: FontWeight.w600
            ),
          ),
        ),
        actions: <Widget>[
          InkWell(
            onTap: (){
              if(customerData['clientdisabled']){
                showLoading(context, 'You are about to activate a customer.', 'normal', 0);
              } else {
                showLoading(context, 'You are about to inactivate a customer.', 'normal', 0);
              }
            },
            child: Container(
              padding: EdgeInsets.all(12.0),
              child: Image.asset(
                customerData['clientdisabled'] ? 'assets/activate_user.png' : 'assets/deactivate_user.png',
                fit: BoxFit.contain,
                height: 28.0,
                width: 28.0,
                color: AppColor.TYPE_PRIMARY,
              ),
            ),
          )
        ],
      ),
      body: WillPopScope(
        onWillPop: () async{
          Navigator.of(context).pop({"data":customerData});
          return true;
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              child:
              statusCode==0
              ? Container()
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 22.0),
                    child:  Text(
                      'PERSONAL',
                      style: TextStyle(
                          color: AppColor.TYPE_SECONDARY,
                          fontSize: TextSize.bodyText,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Work Sans'
                      ),
                    ),
                  ),

                  ///Name
                  InkWell(
                    onTap: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddCustomerName(
                                nameData: {
                                  "first_name": "$firstName",
                                  "last_name": "$lastName"
                                },
                              )
                          )
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Name',
                            style: TextStyle(
                                color: AppColor.TYPE_SECONDARY,
                                fontSize: TextSize.subjectTitle,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'WorkSans'
                            ),
                          ),
                          SizedBox(height: 3.0,),
                          Text(
                            '$firstName $lastName',
                            style: TextStyle(
                                color: AppColor.TYPE_PRIMARY,
                                fontSize: TextSize.headerText,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'WorkSans'
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(height: 1.0, color: AppColor.SEC_DIVIDER,),

                  ///Email
                  Container(
                    child: ListView.builder(
                      itemCount: emailList != null ? emailList.length : 0,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index){
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: (){
                                bottomNavigation(context, "Email Customer", "Remove Email Address", 'email', index);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      '${emailList[index]['emailtag']} Email',
                                      style: TextStyle(
                                          color: AppColor.TYPE_SECONDARY,
                                          fontSize: TextSize.subjectTitle,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'WorkSans'
                                      ),
                                    ),
                                    SizedBox(height: 3.0,),
                                    Text(
                                      '${emailList[index]['email']}',
                                      style: TextStyle(
                                          color: AppColor.TYPE_PRIMARY,
                                          fontSize: TextSize.headerText,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'WorkSans'
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
                        );
                      },
                    ),
                  ),

                  ///Add Email Address
                  emailList != null && emailList.length > 1
                  ? Container()
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddCustomerEmail(
                                    type: "details",
                                    clientId: "${customerData['clientid']}",
                                  )
                              )
                          ).then((result) {
                            if(result != null){
                              setState(() {
                                emailList.add(result['data']);
                              });
                            }
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 28.0),
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            emailList.length == 0 ? 'Add Email Address' : emailList.length == 1 ? 'Add Another Email Address' : '',
                            style: TextStyle(
                                color: AppColor.THEME_PRIMARY,
                                fontSize: TextSize.headerText,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'WorkSans'
                            ),
                          ),
                        ),
                      ),
                      Divider(height: 1.0, color: AppColor.SEC_DIVIDER,),
                    ],
                  ),

                  ///Phone
                  Container(
                    child: ListView.builder(
                      itemCount: phoneList != null ? phoneList.length : 0,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index){
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: (){
                                bottomNavigation(context, "Call Customer", "Remove Phone Number", 'phone', index);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      '${phoneList[index]['phonetag']} Phone',
                                      style: TextStyle(
                                          color: AppColor.TYPE_SECONDARY,
                                          fontSize: TextSize.subjectTitle,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'WorkSans'
                                      ),
                                    ),
                                    SizedBox(height: 3.0,),
                                    Text(
                                      '${phoneList[index]['phoneno']}',
                                      style: TextStyle(
                                          color: AppColor.TYPE_PRIMARY,
                                          fontSize: TextSize.headerText,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'WorkSans'
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
                        );
                      },
                    ),
                  ),
                  ///Add Phone Number
                  phoneList != null && phoneList.length > 1
                  ? Container()
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddCustomerPhone(
                                    type: "details",
                                    clientId: "${customerData['clientid']}",
                                  )
                              )
                          ).then((result) {
                            if(result != null){
                              setState(() {
                                phoneList.add(result['data']);
                              });
                            }
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 28.0),
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            phoneList.length == 0 ? 'Add Phone Number' : phoneList.length == 1 ? 'Add Another Phone Number' : '',
                            style: TextStyle(
                                color: AppColor.THEME_PRIMARY,
                                fontSize: TextSize.headerText,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'WorkSans'
                            ),
                          ),
                        ),
                      ),
                      Divider(height: 1.0, color: AppColor.SEC_DIVIDER,),
                    ],
                  ),

                  ///Billing Address Detail
                  Container(
                    padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 22.0),
                    child:  Text(
                      'BILLING ADDRESS',
                      style: TextStyle(
                          color: AppColor.TYPE_SECONDARY,
                          fontSize: TextSize.bodyText,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'WorkSans'
                      ),
                    ),
                  ),
                  Container(
                    child: ListView.builder(
                      itemCount: billingAddressList != null ? billingAddressList.length : 0,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index){
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: (){
                                bottomNavigation(context, '${billingAddressList[index]['street1']} ${billingAddressList[index]['city']} ', 'Remove Billing Address', 'billing', index);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Location ${index+1}',
                                      style: TextStyle(
                                          color: AppColor.TYPE_SECONDARY,
                                          fontSize: TextSize.subjectTitle,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'WorkSans'
                                      ),
                                    ),
                                    SizedBox(height: 3.0,),
                                    Text(
                                      '${billingAddressList[index]['street1']} ${billingAddressList[index]['city']} ',
                                      style: TextStyle(
                                          color: AppColor.TYPE_PRIMARY,
                                          fontSize: TextSize.headerText,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'WorkSans'
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
                        );
                      },
                    ),
                  ),
                  ///Add Billing Address
                  billingAddressList != null && billingAddressList.length > 1
                  ? Container()
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddCustomerBillingAddress(
                                    type: "details",
                                    clientId: "${customerData['clientid']}"
                                  )
                              )
                          ).then((result) {
                            if(result != null){
                              setState(() {
                                billingAddressList.add(result['data']);
                              });
                            }
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 28.0),
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            billingAddressList.length == 0 ? 'Add Billing Address' : billingAddressList.length == 1 ? 'Add Another Billing Address' : '',
                            style: TextStyle(
                                color: AppColor.THEME_PRIMARY,
                                fontSize: TextSize.headerText,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'WorkSans'
                            ),
                          ),
                        ),
                      ),
                      Divider(height: 1.0, color: AppColor.SEC_DIVIDER,),
                    ],
                  ),

                  ///Service Location Detail
                  Container(
                    padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 22.0),
                    child:  Text(
                      'SERVICE LOCATIONS',
                      style: TextStyle(
                          color: AppColor.TYPE_SECONDARY,
                          fontSize: TextSize.bodyText,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'WorkSans'
                      ),
                    ),
                  ),
                  Container(
                    child: ListView.builder(
                      itemCount: serviceLocationList != null ? serviceLocationList.length : 0,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index){
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: (){
                                bottomNavigation(context, '${serviceLocationList[index]['serviceaddressnick']} ${serviceLocationList[index]['city']} ', 'Remove Service Location', 'service', index);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Location ${index+1}',
                                      style: TextStyle(
                                          color: AppColor.TYPE_SECONDARY,
                                          fontSize: TextSize.subjectTitle,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'WorkSans'
                                      ),
                                    ),
                                    SizedBox(height: 3.0,),
                                    Text(
                                      '${serviceLocationList[index]['serviceaddressnick']} ${serviceLocationList[index]['city']} ',
                                      style: TextStyle(
                                          color: AppColor.TYPE_PRIMARY,
                                          fontSize: TextSize.headerText,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'WorkSans'
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
                        );
                      },
                    ),
                  ),

                  ///Add Billing Address
                  serviceLocationList == null /*&& serviceLocationList.length > 1*/
                  ? Container()
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddCustomerServiceLocationPage(
                                      type: "details",
                                      clientId: "${customerData['clientid']}"
                                  )
                              )
                          ).then((result) {
                            if(result != null){
                              setState(() {
                                serviceLocationList.add(result['data']);
                              });
                            }
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 28.0),
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            serviceLocationList.length == 0 ? 'Add Service Location' : serviceLocationList.length >= 1 ? 'Add Another Service Location' : '',
                            style: TextStyle(
                                color: AppColor.THEME_PRIMARY,
                                fontSize: TextSize.headerText,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'WorkSans'
                            ),
                          ),
                        ),
                      ),
                      Divider(height: 1.0, color: AppColor.SEC_DIVIDER,),
                    ],
                  ),

                  ///Notes
                  Container(
                    padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 22.0),
                    child:  Text(
                      'NOTES',
                      style: TextStyle(
                          color: AppColor.TYPE_SECONDARY,
                          fontSize: TextSize.bodyText,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'WorkSans'
                      ),
                    ),
                  ),

                  //Notes detail
                  Container(
                    padding: EdgeInsets.symmetric(horizontal:20.0, vertical: 25.0),
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      '$noteDescription',
                      style: TextStyle(
                          color: AppColor.TYPE_PRIMARY,
                          fontSize: TextSize.headerText,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'WorkSans'
                      ),
                    ),
                  ),
                  Divider(height: 1.0, color: AppColor.SEC_DIVIDER,),
                  SizedBox(height: 82.0,)
                ],
              ),
            ),
            _progressHUD
          ],
        ),
      ),
    );
  }

  void addCustomerDetail() {
    setState(() {
      statusCode = 0;
      emailList.clear();
      phoneList.clear();
      billingAddressList.clear();
      serviceLocationList.clear();
      getCustomerDetail();
    });
  }

  void bottomNavigation(context, firstContent, secondContent, type, index){
    showModalBottomSheet(
        context: _scaffoldKey.currentContext,
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
                          if(type == 'email'){
                            _launchURL("${emailList[index]['email']}", "", "");
                          } else if(type == 'phone'){
                            launch(('tel://${phoneList[index]['phoneno']}'));
                          }
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                          child: Text(
                            '$firstContent',
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
                          if(type == 'email'){
                            showLoading(context, 'You\'re about to remove an email address.', type, index);
                          } else if(type == 'phone'){
                            showLoading(context, 'You\'re about to remove a phone number.', type, index);
                          } else if(type == 'service'){
                            showLoading(context, 'You\'re about to remove the service location.', type, index);
                          } else if(type == 'billing'){
                            showLoading(context, 'You\'re about to remove the billing address.', type, index);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                          child: Text(
                            '$secondContent',
                            style: TextStyle(
                                fontSize: TextSize.headerText,
                                color: AppColor.RED_COLOR,
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
                      Container(
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

  _launchURL(String toMailId, String subject, String body) async {
    var url = 'mailto:$toMailId?subject=$subject&body=$body';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void showLoading(context, content, type, index) {
    var sLoadingContext;
    print("show loading call");
    showDialog(
      context: _scaffoldKey.currentContext,
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
                  padding: EdgeInsets.symmetric(horizontal: 28.0, vertical: 10.0),
                  child: Text(
                    '$content',
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
                            if(type == 'normal'){
                              activateCustomer(!customerData['clientdisabled']);
                            } else {
                              removeCustomerDetail(type, index);
                            }
                            Navigator.pop(_scaffoldKey.currentContext);
                          },
                          child: Container(
                            height: 56.0,
                            alignment: Alignment.center,
                            child: Text(
                              type != 'normal' ? 'REMOVE' : customerData['clientdisabled'] ? 'ACTIVATE' : 'INACTIVATE',
                              style: TextStyle(
                                fontSize: TextSize.subjectTitle,
                                color: type == 'normal' ? AppColor.TYPE_PRIMARY : AppColor.RED_COLOR,
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

  Future<void> getCustomerDetail() async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var response = await request.getAuthRequest("auth/myclient/${customerData['clientid']}");
//    print("Country list response get back: $response");
    _progressHUD.state.dismiss();

    if (response != null) {
      setState(() {
        statusCode = 200;
        firstName = response['firstname'];
        lastName = response['lastname'];
        noteDescription = response['clientnotes'];

        emailList = response['email'];
        phoneList = response['phone'];
        billingAddressList = response['billingaddress'];
        serviceLocationList = response['servicelocation'];
      });
    } else {

    }
  }

  Future<void> removeCustomerDetail(type, index) async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var response;
    if(type == 'email') {
      response = await request.deleteAuthRequest("auth/myclient/${customerData['clientid']}/email/${emailList[index]['emailid']}");
    } else if(type == 'phone') {
      response = await request.deleteAuthRequest("auth/myclient/${customerData['clientid']}/phone/${phoneList[index]['phoneid']}");
    } else if(type == 'service') {
      response = await request.deleteAuthRequest("auth/myclient/${customerData['clientid']}/servicelocation/${serviceLocationList[index]['addressid']}");
    } else if(type == 'billing') {
      response = await request.deleteAuthRequest("auth/myclient/${customerData['clientid']}/address/${billingAddressList[index]['addressid']}");
    }
    _progressHUD.state.dismiss();

    if (response != null) {
      if(response['success'] != null && response['success']){
        setState(() {
          if(type == 'email') {
            emailList.removeAt(index);
          } else if(type == 'phone') {
            phoneList.removeAt(index);
          } else if(type == 'service') {
            serviceLocationList.removeAt(index);
          } else if(type == 'billing') {
            billingAddressList.removeAt(index);
          }
        });
      } else {
        HelperClass.showSnackBar(context, 'Something Went Wrong!');
      }
    } else {
      HelperClass.showSnackBar(context, 'Something Went Wrong!');
    }
  }

  Future<void> activateCustomer(clientDisabled) async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var requestJson = {
      "clientdisabled": clientDisabled
    };
    var requestParam = json.encode(requestJson);
    var  response = await request.patchRequest("auth/myclient/${customerData['clientid']}", requestParam);
    _progressHUD.state.dismiss();

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        HelperClass.showSnackBar(context, '${response['reason']}');
      } else {
        setState(() {
          var clientData = {
            "clientid":"${response['clientid']}",
            "iscompany": response['iscompany'],
            "personid":"${response['personid']}",
            "firstname":"${response['firstname']}",
            "lastname":"${response['lastname']}",
            "emailid": response['email'].length > 0 ? "${response['email'][0]['emailid']}" : '',
            "email": response['email'].length > 0 ? "${response['email'][0]['email']}" : '',
            "phoneid": response['phone'].length > 0 ? "${response['phone'][0]['phoneid']}" : '',
            "phoneno": response['phone'].length > 0 ? "${response['phone'][0]['phoneno']}" : '',
            "servicelocations":"${response['']}",
            "clientdisabled": response['clientdisabled'],
            "avatar":"${response['avatar']}",
          };
          customerData = clientData;
        });
      }
    } else {
      HelperClass.showSnackBar(context, 'Something Went Wrong!');
    }
  }
}
