import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dottie_inspector/connection_mixin.dart';
import 'package:dottie_inspector/database/database_helper.dart';
import 'package:dottie_inspector/inspectionPreferences/inspection_preferences.dart';
import 'package:dottie_inspector/pages/inspectionMain/inspection_customer_list1.dart';
import 'package:dottie_inspector/pages/inspectionMain/inspection_location_page.dart';
import 'package:dottie_inspector/pages/menu/drawer_page.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/SlideRightRoute.dart';
import 'package:dottie_inspector/utils/custom_toast.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/utils/inspection_utils.dart';
import 'package:dottie_inspector/utils/language.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:dottie_inspector/widget/bottom_general_button_widget.dart';
import 'package:dottie_inspector/widget/contacts_service.dart';
import 'package:dottie_inspector/widget/customer_selection_screen.dart';
import 'package:dottie_inspector/widget/gradient/grediant_box_border.dart';
import 'package:dottie_inspector/widget/masked_phone_number.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_hud/progress_hud.dart';

class InspectionAddCustomer extends StatefulWidget {
  static String tag = "add-customer-screen";
  final detail;
  final inspectionDefId;

  const InspectionAddCustomer({Key key, this.detail, this.inspectionDefId}) : super(key: key);

  @override
  _InspectionAddCustomerState createState() => _InspectionAddCustomerState();
}

class _InspectionAddCustomerState extends State<InspectionAddCustomer> with MyConnection{
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var imagePath = '';
  var inspectionDefIdLocal = '';
  bool isCustomerSelected = false;
  List emailList = [];
  List phoneList = [];
  List billingAddressList = [];
  List serviceLocationList = [];
  var blockDetail;

  String firstName = '';
  String lastName = '';
  String subTitle = 'How would you like to add your customer?';

  Map customerData = {};
  Contact contactData;
  var elevation = 0.0;
  final _scrollController = ScrollController();

  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;

  var customerId;

  ///Add new Customer
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController email1Controller = TextEditingController();
  var phone1Controller = MaskedTextController(mask: '(000) 000-0000');

  FocusNode firstNameFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();
  FocusNode email1Focus = FocusNode();
  FocusNode phone1Focus = FocusNode();

  bool isFirstNameFocus = false;
  bool isLastNameFocus = false;
  bool isEmail1Focus = false;
  bool isPhone1Focus = false;

  ///Edit Customer
  ///Add new Customer
  TextEditingController firstNameEditController = TextEditingController();
  TextEditingController lastNameEditController = TextEditingController();
  TextEditingController email1EditController = TextEditingController();
  var phone1EditController = MaskedTextController(mask: '(000) 000-0000');

  FocusNode firstNameEditFocus = FocusNode();
  FocusNode lastNameEditFocus = FocusNode();
  FocusNode email1EditFocus = FocusNode();
  FocusNode phone1EditFocus = FocusNode();

  bool isFirstNameEditFocus = false;
  bool isLastNameEditFocus = false;
  bool isEmail1EditFocus = false;
  bool isPhone1EditFocus = false;

  bool isClientIdServer = false;

  bool isLoaded = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map nameData;
  bool _isFormValidated = false;
  bool _autoValidate = false;

  var state;
  String lang = "en";

  final GlobalKey<FormState> _customerFormKey = GlobalKey<FormState>();
  var customerState;
  bool _allCustomerFieldValidate = false;
  bool isDarkMode = false;
  Color themeColor = AppColor.BLACK_COLOR;

  bool _isInternetAvailable = true;

  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  final dbHelper = DatabaseHelper.instance;

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

    _scrollController.addListener(() {
      setState(() {
        if(_scrollController.position.pixels > _scrollController.position.minScrollExtent){
          elevation = HelperClass.ELEVATION_1;
        } else {
          elevation = HelperClass.ELEVATION;
        }
      });
    });


    // _connectivity.initialise();
    // _connectivity.myStream.listen((source) {
    //   setState(() {
    //     if(source.keys.toList()[0] == ConnectivityResult.none) {
    //       print("No Internet found");
    //     } else if(source.keys.toList()[0] == ConnectivityResult.mobile) {
    //       print("Mobile");
    //     } else if(source.keys.toList()[0] == ConnectivityResult.wifi) {
    //       print("WIFI");
    //     }
    //   });
    // });

    initConnectivity();
    getPreferencesData();

    setFormStates();
    setEditFormStates();
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
      } else if ((_connectivityResult == ConnectivityResult.mobile) || (_connectivityResult == ConnectivityResult.wifi)) {
        _isInternetAvailable = true;
      }

      log("IsInternetAvailable====$_isInternetAvailable");
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    // connectivity.disposeStream();
    super.dispose();
  }

  void getPreferencesData() async {
    lang = await PreferenceHelper.getPreferenceData(PreferenceHelper.LANGUAGE) ?? "en";

    setState(() {
      var dynamicData = widget.detail;
      blockDetail = dynamicData['txt'][lang] ?? dynamicData['txt']['en'];
      inspectionDefIdLocal = "${widget.inspectionDefId}";
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
  }

  void setFormStates() {
    firstNameFocus.addListener((){
      if(state != null) {
        state(() {
          isFirstNameFocus = firstNameFocus.hasFocus;
        });
      }
    });
    lastNameFocus.addListener((){
      if(state != null) {
        state(() {
          isLastNameFocus = lastNameFocus.hasFocus;
        });
      }
    });
    email1Focus.addListener((){
      if(state != null) {
        state(() {
          isEmail1Focus = email1Focus.hasFocus;
        });
      }
    });
    phone1Focus.addListener((){
      if(state != null) {
        state(() {
          isPhone1Focus = phone1Focus.hasFocus;
        });
      }
    });
  }

  void setEditFormStates() {
    firstNameEditFocus.addListener((){
      if(customerState != null) {
        customerState(() {
          isFirstNameEditFocus = firstNameEditFocus.hasFocus;
        });
      }
    });
    lastNameEditFocus.addListener((){
      if(customerState != null) {
        customerState(() {
          isLastNameEditFocus = lastNameEditFocus.hasFocus;
        });
      }
    });
    email1EditFocus.addListener((){
      if(customerState != null) {
        customerState(() {
          isEmail1EditFocus = email1EditFocus.hasFocus;
        });
      }
    });
    phone1EditFocus.addListener((){
      if(customerState != null) {
        customerState(() {
          isPhone1EditFocus = phone1EditFocus.hasFocus;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode ? AppColor.BLACK_COLOR : AppColor.PAGE_COLOR,
      appBar: EmptyAppBar(isDarkMode: isDarkMode),
//       appBar: AppBar(
//         centerTitle: true,
//         elevation: elevation,
//         backgroundColor: AppColor.PAGE_COLOR,
//         /*leading: GestureDetector(
//           onTap: (){
//             Navigator.pop(context);
//           },
//           child: Container(
//             padding: EdgeInsets.all(16.0),
//             child: Image.asset(
//               'assets/ic_close.png',
//               fit: BoxFit.cover,
//               height: 28.0,
//               width: 28.0,
//             ),
//           ),
//         ),*/
//         /*IconButton(
//           padding: EdgeInsets.only(left: 16.0, right: 16.0),
//           icon: Icon(Icons.clear,color: themeColor,size: 28.0,),
//           onPressed: (){
//             Navigator.pop(context);
//           },
//         ),*/
//         leading: GestureDetector(
//           onTap: (){
//             _scaffoldKey.currentState.openDrawer();
// //            HelperClass.launchDetail(context, GeneralAutomationPhotoPage());
//           },
//           child: Container(
//             padding: EdgeInsets.all(16.0),
//             child: Image.asset(
//               'assets/ic_menu.png',
// //              'assets/ic_close.png',
//               fit: BoxFit.cover,
//               height: 28.0,
//               width: 28.0,
//             ),
//           ),
//         ),
//       ),
      drawer: Drawer(
        child: DrawerPage(),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GestureDetector(
                  onTap: () async {
                    initConnectivity();
                    _scaffoldKey.currentState.openDrawer();
                  },
                  child: Container(
                    child: Image.asset(
                      'assets/ic_menu.png',
                      fit: BoxFit.cover,
                      width: 44,
                      height: 44,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 10.0,),
                        Container(
                          margin: EdgeInsets.only(left: 24.0,right: 24.0, top: 0),
                          child: Text(
                            lang == "en" ? customerInfoEn : customerInfoEs,
                            style: TextStyle(
                                color: themeColor,
                                fontSize: TextSize.subjectTitle,
                                fontWeight: FontWeight.w500
                            ),
                          ),
                        ),

                       /* Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.symmetric(horizontal: 60.0,vertical: 8.0),
                          child: LinearPercentIndicator(
                            animationDuration: 200,
                            backgroundColor: Color(0xffE5E5E5),
                            percent: 0.20,
                            lineHeight: 8.0,
                            progressColor: AppColor.HEADER_COLOR,
                          ),
                        ),
*/
                        Container(
                          margin: EdgeInsets.only(left: 24.0,right: 24.0, top: 8),
                          child: Text(
                            blockDetail != null && blockDetail['title'] != null
                                ? "${blockDetail['title']}"
                                : lang == "en" ? customerTitleEn : customerTitleEs,
                            style: TextStyle(
                                fontSize: TextSize.pageTitleText,
                                color: themeColor,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 24.0,vertical: 8.0),
                          child: Text(
                            isCustomerSelected
                            ? 'Is your customer’s info. correct?'
                            :  blockDetail != null && blockDetail['helpertext'] != null
                                ? "${blockDetail['helpertext']}"
                                : 'How would you like to add your customer?',
                            style: TextStyle(
                                fontSize: TextSize.subjectTitle,
                                color: themeColor,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.normal,),
                          ),
                        ),
                        SizedBox(height: 40.0,),

                        isCustomerSelected
                        ? getCustomerWidget(context)
                        : Container(
                          margin: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [

                              //New Customer
                              GestureDetector(
                                onTap: (){
                                  /*Navigator.push(
                                      context,
                                      SlideRightRoute(
                                          page: NewCustomerInfoPage()
                                      )
                                  ).then((result) {
                                    if(result!=null){
                                      if(result['data'] != null){
                                        setState(() {
                                          customerData = result['data'];
                                          emailList = customerData['email'];
                                          phoneList = customerData['phone'];
                                          isCustomerSelected = true;
                                        });
                                      }
                                    }
                                  });*/

                                  openAddNewCustomerBottomSheet(context);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                                  margin: EdgeInsets.only(bottom: 8.0),
                                  decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? Color(0xff1F1F1F)
                                          : AppColor.WHITE_COLOR,
                                      borderRadius: BorderRadius.circular(32)
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: Image.asset(
                                          'assets/new_ui/ic_new_customer.png',
                                          fit: BoxFit.contain,
                                          height: 48.0,
                                          width: 48.0,
                                        ),
                                      ),
                                      SizedBox(width: 16.0,),
                                      Text(
                                        lang == "en" ? newPersonEn : newPersonEs,
                                        style: TextStyle(
                                            color: themeColor,
                                            fontSize: TextSize.headerText,
                                            fontWeight: FontWeight.w700,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),

                              //Import contacts
                              GestureDetector(
                                onTap: (){
                                  _askPermissions();
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                                  margin: EdgeInsets.only(bottom: 8.0),
                                  decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? Color(0xff1F1F1F)
                                          : AppColor.WHITE_COLOR,
                                      borderRadius: BorderRadius.circular(32)
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: Image.asset(
                                          'assets/new_ui/ic_add_customer.png',
                                          fit: BoxFit.contain,
                                          height: 48.0,
                                          width: 48.0,
                                        ),
                                      ),
                                      SizedBox(width: 16.0,),
                                      Text(
                                       lang == "en" ? searchYourContactEn : searchYourContactEs,
                                        style: TextStyle(
                                            color: themeColor,
                                            fontSize: TextSize.headerText,
                                            fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              //Existing Customer
                              GestureDetector(
                                onTap: () async {
                                  Navigator.push(
                                      context,
                                      SlideRightRoute(
                                          page: InspectionCustomerList1Page(
                                              type: 0
                                          )
                                      )
                                  ).then((result) async{
                                    if(result!=null){
                                      if(result['data'] != null) {
                                        setState(() {
                                          customerData = result['data'];
                                          emailList = customerData['email'];
                                          phoneList = customerData['phone'];
                                          isCustomerSelected = true;
                                          isClientIdServer = true;
                                        });

                                        var endPoint = "auth/myclient";
                                        await dbHelper.insertCustomerGeneralData({
                                          "url": '$endPoint',
                                          "verb":'POST',
                                          "customerlocalid": "${customerData['clientid']}",
                                          "customerserverid": "${customerData['clientid']}",
                                          "iscustomerserverid": "1",
                                          "inspectiondefid": inspectionDefIdLocal ?? "1",
                                          "payload": "",
                                        });
                                      }
                                    }
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                                  margin: EdgeInsets.only(bottom: 8.0),
                                  decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? Color(0xff1F1F1F)
                                          : AppColor.WHITE_COLOR,
                                      borderRadius: BorderRadius.circular(32)
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: Image.asset(
                                          'assets/new_ui/ic_search_customer.png',
                                          fit: BoxFit.contain,
                                          height: 48.0,
                                          width: 48.0,
                                        ),
                                      ),
                                      SizedBox(width: 12.0,),
                                      Expanded(
                                        child: Text(
                                          lang == "en" ? searchPreviousEn : searchPreviousEs,
                                          style: TextStyle(
                                              color: themeColor,
                                              fontSize: TextSize.headerText,
                                              fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 16.0,),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 160.0,)

                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          BottomGeneralButton(
            buttonName: lang == 'en' ? nextEn : nextEs,
            isActive: isCustomerSelected,
            onStartButton: (){
              if(isCustomerSelected){
                /*gotoNextPage();*/
                gotoNextItem();
              }
            },
          ),

          _progressHUD
        ],
      ),
    );
  }

  Future<void> _askPermissions() async {
    PermissionStatus permissionStatus = await Permission.contacts.request();
    if (permissionStatus == PermissionStatus.granted) {
      try {
        // Contact contact = await ContactsService.openDeviceContactPicker(
        //     iOSLocalizedLabels: iOSLocalizedLabels);


        var contact = (await ContactsService.getContacts(withThumbnails: false)).toList();
        log("Contact===>>>>${contact.toList().toString()}");
        if(contact != null) {
          Navigator.push(
            context,
            SlideRightRoute(
              page: CustomerSelectionScreen(
                contactList: contact,
              )
            )
          ).then((contactData) {
            if(contactData != null) {
              var contact = contactData['contactData'];
              setState(() {
                contactData = contact;
                emailList.clear();
                phoneList.clear();

                if(contact.givenName.isNotEmpty){
                  nameData = {"first_name": "${contact.givenName}", "last_name": "${contact.familyName}"};
                  customerData['firstname'] = "${contact.givenName}";
                  customerData['lastname'] = "${contact.familyName}";
                }

                if(contact.emails.isNotEmpty){
                  emailList.add({
                    "email": "${contact.emails.first.value}",
                    "emailtag": "${HelperClass.getEmailLabelText(HelperClass.getEmailLabelIndex(contact.emails.first.label))}",
                    "clientemailpreferred": false,
                    "selectedIndex" : HelperClass.getEmailLabelIndex("${contact.emails.first.label}")
                  });
                  log("EmailList====>>>$emailList");
                }
                if(contact.phones.isNotEmpty){
                  phoneList.add({
                    "phoneno": "${contact.phones.first.value}",
                    "phonetag": "${HelperClass.getLabelText(HelperClass.getLabelIndex(contact.phones.first.label))}",
                    "clientphonepreferred": false,
                    "selectedIndex" : HelperClass.getLabelIndex("${contact.phones.first.label}")
                  });
                  log("PhoneList=====>>>$phoneList");
                }

                log("ContactList====>>>>$customerData");
              });

              openAddNewCustomerBottomSheet(context);
            }
          });
        }

        // var contact = (await ContactsService.getContacts(withThumbnails: false)).toList();

        /*setState(() {
          contactData = contact;
          emailList.clear();
          phoneList.clear();

          if(contact.givenName.isNotEmpty){
            nameData = {"first_name": "${contact.givenName}", "last_name": "${contact.familyName}"};
            customerData['firstname'] = "${contact.givenName}";
            customerData['lastname'] = "${contact.familyName}";
          }

          if(contact.emails.isNotEmpty){
            emailList.add({
              "email": "${contact.emails.first.value}",
              "emailtag": "${HelperClass.getEmailLabelText(HelperClass.getEmailLabelIndex(contact.emails.first.label))}",
              "clientemailpreferred": false,
              "selectedIndex" : HelperClass.getEmailLabelIndex("${contact.emails.first.label}")
            });
            print(emailList);
          }
          if(contact.phones.isNotEmpty){
            phoneList.add({
              "phoneno": "${contact.phones.first.value}",
              "phonetag": "${HelperClass.getLabelText(HelperClass.getLabelIndex(contact.phones.first.label))}",
              "clientphonepreferred": false,
              "selectedIndex" : HelperClass.getLabelIndex("${contact.phones.first.label}")
            });
            print(phoneList);
          }
        });
        openAddNewCustomerBottomSheet(context);*/
        /*Navigator.push(
          context,
          SlideRightRoute(
            page: NewCustomerInfoPage(
              contact: contactData,
            )
          )
        ).then((result){
          if(result != null){
            if(result['data'] != null){
              setState(() {
                customerData = result['data'];
                isCustomerSelected = true;
                emailList = customerData['email'];
                phoneList = customerData['phone'];
              });
            }
          }
        });*/
      } catch(error, stackTrace) {
        print(error);
        print(stackTrace);
      }
    } else {
      _handleInvalidPermissions(permissionStatus);
      openAppSettings();
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      throw PlatformException(
          code: "PERMISSION_DENIED",
          message: "Access to contact denied",
          details: null
      );
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      openAppSettings();
      CustomToast.showColoredToast('Contacts feature is not available on device');
      throw PlatformException(
          code: "PERMISSION_DISABLED",
          message: "Contacts feature is not available on device",
          details: null
      );
    }
  }

  Widget getCustomerWidget(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(left: 16.0,right: 16, top: 16, bottom: 16),
          margin: EdgeInsets.only(bottom: 8.0, left: 16.0,right: 16, ),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Color(0xff1F1F1F)
                : AppColor.TYPE_PRIMARY.withOpacity(0.04),
            borderRadius: BorderRadius.circular(32.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: AppColor.gradientColor(1.0)
                  ),
                  borderRadius: BorderRadius.circular(32.0),
                ),
                height: 48.0,
                width: 48.0,
                alignment: Alignment.center,
                child: Text(
                  '${customerData['firstname'][0]}',
                  style: TextStyle(
                      color: AppColor.WHITE_COLOR,
                      fontWeight: FontWeight.w500,
                      fontSize: 24.0
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
                        '${customerData['firstname'] ?? ''} ${customerData['lastname'] ?? ''}',
                        style: TextStyle(
                            color: themeColor,
                            fontWeight: FontWeight.w700,
                            fontSize: TextSize.headerText
                        ),
                      ),
                      SizedBox(height: 4.0,),
                      Text(
                        customerData['email'] == null
                            ? '---'
                            : customerData['email'].length > 0
                            ? '${customerData['email'][0]['email']}'
                            : '---',
                        style: TextStyle(
                            color: themeColor,
                            fontWeight: FontWeight.w500,
                            fontSize: TextSize.subjectTitle
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 8.0),
                height: 48.0,
                width: 48.0,
                decoration: BoxDecoration(
                    color: Color(0xffDCFFF3),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColor.TRANSPARENT,
                      width: 1.0,
                    )
                ),
                child: Icon(
                  Icons.done,
                  size: 24.0,
                  color: Color(0xff008B4A),
                ),
              ),
            ],
          ),
        ),

        Container(
          margin: EdgeInsets.only(top: 0, bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center ,
            children: [
              GestureDetector(
                onTap: (){
                  openEditCustomerBottomSheet(context);
                },
                child: Container(
                  width: 132,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Color(0xff1F1F1F)
                        : AppColor.TYPE_PRIMARY.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    lang == "en" ? 'Edit' : "Editar",
                    style: TextStyle(
                        color: themeColor,
                        fontWeight: FontWeight.w700,
                        fontSize: TextSize.subjectTitle
                    ),
                  ),
                ),
              ),

              SizedBox(width: 8,),

              GestureDetector(
                onTap: (){
                  setState(() {
                    isCustomerSelected = false;
                    customerData = null;
                  });
                },
                child: Container(
                  width: 132,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Color(0xff1F1F1F)
                        : AppColor.TYPE_PRIMARY.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                  child: Text(
                    lang == "en" ? 'Change' : "Cambio",
                    style: TextStyle(
                        color: themeColor,
                        fontWeight: FontWeight.w700,
                        fontSize: TextSize.subjectTitle
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Future<void> getCustomerDetail(id) async {
    // if(await HelperClass.internetConnectivity()) {
      _progressHUD.state.show();
      FocusScope.of(context).requestFocus(FocusNode());
      var response = await request.getAuthRequest("auth/myclient/$id");
//    print("Country list response get back: $response");
      _progressHUD.state.dismiss();

      if (response != null) {
        if (response['success']!=null && !response['success']) {
          CustomToast.showToastMessage('${response['reason']}');
        } else {
          setState(() {
            customerData = response;
            emailList = customerData['email'];
            phoneList = customerData['phone'];
            isCustomerSelected = true;
          });
        }
      }
    // } else {
    //   HelperClass.openSnackBar(context);
    // }
  }

  Future<void> getCustomerDetailLocalDB(id) async {
    var response = await dbHelper.getSingleCustomerGeneralRecord(customerData['clientid']);
    var resultList = response.toList();

    log("responseType===${resultList.runtimeType}");

    if(resultList.length > 0) {
      var resultData = resultList[0]['payload'].toString();
      var transformedData = json.decode(resultData);

      setState(() {
        customerData = transformedData;
        emailList = customerData['email'];
        phoneList = customerData['phone'];
        isCustomerSelected = true;
      });
    }
  }

  void openAddNewCustomerBottomSheet(context){
    if(customerData != null) {
      var emailData = emailList.length > 0 ? emailList[0] : "";
      var phoneData = phoneList.length > 0 ? phoneList[0] : "";
      firstNameController.text = customerData['firstname'];
      lastNameController.text = customerData['lastname'];
      email1Controller.text = emailData == "" ? "" :emailData['email'];
      phone1Controller.text = phoneData == "" ? "" :phoneData['phoneno'];
    }

    isLoaded = false;
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        clipBehavior: Clip.none,
        barrierColor: isDarkMode ? Color(0xff000000).withOpacity(0.8) : Color(0xff000000).withOpacity(0.5),
        isDismissible: false,
        enableDrag: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        backgroundColor: isDarkMode ? Color(0xff333333) : AppColor.PAGE_COLOR,
        builder: (context){
          return StatefulBuilder(
            builder: (context1, myState){
              state = myState;
              return GestureDetector(
                onTap: (){
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height - 50,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: (){
                                    Navigator.pop(context);
                                    setState(() {
                                      myState((){
                                        _autoValidate = false;
                                        _isFormValidated = false;
                                        firstNameController.text = "";
                                        lastNameController.text = "";
                                        email1Controller.text = "";
                                        phone1Controller.text = "";
                                      });
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
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
                                  lang == "en" ? newCustomerTitleEn : newCustomerTitleEs,
                                  style: TextStyle(
                                    color: themeColor,
                                    fontSize: TextSize.headerText,
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                GestureDetector(
                                  onTap: (){
                                    if(firstNameController.text.toString() == ""){
                                      CustomToast.showToastMessage("Please enter first name");
                                    } else if(lastNameController.text.toString() == "") {
                                      CustomToast.showToastMessage("Please enter last name");
                                    } else {
                                      // log("_isInternetAvailable====$_isInternetAvailable");
                                      if(_isInternetAvailable) {
                                        setState(() {
                                          myState(() {
                                            isLoaded = true;
                                          });
                                        });
                                      }
                                      setParameters(myState);
                                    }
                                  },
                                  child: Theme(
                                    data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                                    child: Container(
                                      alignment: Alignment.bottomCenter,
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(colors: [
                                            _isFormValidated ? Color(0xff013399) : themeColor.withOpacity(0.6),
                                            _isFormValidated ? Color(0xffBC96E6) : themeColor.withOpacity(0.6),
                                          ]),
                                          borderRadius: BorderRadius.all(Radius.circular(32.0))
                                      ),
                                      margin: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                                      padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 10.0),
                                      child: Center(
                                        child: Text(
                                          lang == "en" ? saveEn : saveEs,
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

                         // Form Data
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Form(
                                  key: _formKey,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        /***
                                         * First Name
                                         */
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                          padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: isFirstNameFocus && isDarkMode
                                                    ? AppColor.gradientColor(0.32)
                                                    : isFirstNameFocus
                                                    ? AppColor.gradientColor(0.16)
                                                    : isDarkMode
                                                    ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                                                    : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
                                              ),
                                              borderRadius: BorderRadius.circular(32),
                                              border: GradientBoxBorder(
                                                  gradient: LinearGradient(
                                                    colors: isFirstNameFocus
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
                                                lang == "en" ? firstNameTitleEn : firstNameTitleEs,
                                                style: TextStyle(
                                                    fontSize: TextSize.bodyText,
                                                    color: themeColor.withOpacity(1.0),
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle: FontStyle.normal
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              TextFormField(
                                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                                controller: firstNameController,
                                                focusNode: firstNameFocus,
                                                onFieldSubmitted: (term) {
                                                  firstNameFocus.unfocus();
                                                  FocusScope.of(context).requestFocus(lastNameFocus);

                                                  // checkAutoValidation(firstNameController, myState);
                                                },
                                                validator: (value) {
                                                  return validateString( lang == "en" ? firstNameTitleEn : firstNameTitleEs);
                                                },
                                                textInputAction: TextInputAction.next,
                                                textCapitalization: TextCapitalization.sentences,
                                                keyboardType: TextInputType.name,
                                                textAlign: TextAlign.start,
                                                decoration: InputDecoration(
                                                  fillColor: AppColor.WHITE_COLOR,
                                                  hintText:  lang == "en" ? givenNameEn : givenNameEs,
                                                  filled: false,
                                                  border: InputBorder.none,
                                                  contentPadding: EdgeInsets.only(top: 0,),
                                                  hintStyle: TextStyle(
                                                      fontSize: TextSize.headerText,
                                                      fontWeight: FontWeight.w700,
                                                      color: isDarkMode
                                                          ? Color(0xff545454)
                                                          : Color(0xff808080)
                                                  ),
                                                ),
                                                style: TextStyle(
                                                    color: themeColor,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: TextSize.headerText
                                                ),
                                                inputFormatters: [LengthLimitingTextInputFormatter(40)],
                                                onChanged: (value){
                                                  setState(() {
                                                    myState(() {
                                                      _isFormValidated = _formKey.currentState.validate();
                                                    });
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        /***
                                         * Last Name
                                         */
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                          padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: isLastNameFocus && isDarkMode
                                                    ? AppColor.gradientColor(0.32)
                                                    : isLastNameFocus
                                                    ? AppColor.gradientColor(0.16)
                                                    : isDarkMode
                                                    ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                                                    : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
                                              ),
                                              borderRadius: BorderRadius.circular(32),
                                              border: GradientBoxBorder(
                                                  gradient: LinearGradient(
                                                    colors: isLastNameFocus
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
                                                lang == "en" ? lastNameEn : lastNameEs,
                                                style: TextStyle(
                                                    fontSize: TextSize.bodyText,
                                                    color: themeColor.withOpacity(1.0),
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle: FontStyle.normal
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              TextFormField(
                                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                                controller: lastNameController,
                                                focusNode: lastNameFocus,
                                                onFieldSubmitted: (term) {
                                                  lastNameFocus.unfocus();
                                                  FocusScope.of(context).requestFocus(email1Focus);
                                                  // checkAutoValidation(lastNameController, myState);
                                                },
                                                validator: (value) {
                                                  return validateString( lang == "en" ? lastNameEn : lastNameEs);
                                                },
                                                textInputAction: TextInputAction.next,
                                                keyboardType: TextInputType.text,
                                                textCapitalization: TextCapitalization.sentences,
                                                textAlign: TextAlign.start,
                                                decoration: InputDecoration(
                                                  fillColor: AppColor.WHITE_COLOR,
                                                  hintText:  lang == "en" ? familyNameEn : familyNameEs,
                                                  filled: false,
                                                  border: InputBorder.none,
                                                  contentPadding: EdgeInsets.only(top: 0,),
                                                  hintStyle: TextStyle(
                                                      fontSize: TextSize.headerText,
                                                      fontWeight: FontWeight.w700,
                                                      color: isDarkMode
                                                          ? Color(0xff545454)
                                                          : Color(0xff808080)
                                                  ),
                                                ),
                                                style: TextStyle(
                                                    color: themeColor,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: TextSize.headerText
                                                ),
                                                inputFormatters: [LengthLimitingTextInputFormatter(40)],
                                                onChanged: (value){
                                                  setState(() {
                                                    myState(() {
                                                      _isFormValidated = _formKey.currentState.validate();
                                                    });
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        /***
                                         * Email
                                         */
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                          padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: isEmail1Focus && isDarkMode
                                                    ? AppColor.gradientColor(0.32)
                                                    : isEmail1Focus
                                                    ? AppColor.gradientColor(0.16)
                                                    : isDarkMode
                                                    ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                                                    : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
                                              ),
                                              borderRadius: BorderRadius.circular(32),
                                              border: GradientBoxBorder(
                                                  gradient: LinearGradient(
                                                    colors: isEmail1Focus
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
                                                lang == "en" ? emailOptionalEn : emailOptionalEs,
                                                style: TextStyle(
                                                    fontSize: TextSize.bodyText,
                                                    color: themeColor.withOpacity(1.0),
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle: FontStyle.normal
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              TextFormField(
                                                controller: email1Controller,
                                                focusNode: email1Focus,
                                                onFieldSubmitted: (term) {
                                                  email1Focus.unfocus();
                                                  FocusScope.of(context).requestFocus(phone1Focus);
                                                },
                                                textInputAction: TextInputAction.next,
                                                keyboardType: TextInputType.text,
                                                textAlign: TextAlign.start,
                                                decoration: InputDecoration(
                                                  fillColor: AppColor.WHITE_COLOR,
                                                  hintText:  lang == "en" ? emailHintEn : emailHintEs,
                                                  filled: false,
                                                  border: InputBorder.none,
                                                  contentPadding: EdgeInsets.only(top: 0,),
                                                  hintStyle: TextStyle(
                                                      fontSize: TextSize.headerText,
                                                      fontWeight: FontWeight.w700,
                                                      color: isDarkMode
                                                          ? Color(0xff545454)
                                                          : Color(0xff808080)
                                                  ),
                                                ),
                                                style: TextStyle(
                                                    color: themeColor,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: TextSize.headerText
                                                ),
                                                inputFormatters: [LengthLimitingTextInputFormatter(40)],
                                                onChanged: (value){

                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        /***
                                         * Phone
                                         */
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                          padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: isPhone1Focus && isDarkMode
                                                    ? AppColor.gradientColor(0.32)
                                                    : isPhone1Focus
                                                    ? AppColor.gradientColor(0.16)
                                                    : isDarkMode
                                                    ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                                                    : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
                                              ),
                                              borderRadius: BorderRadius.circular(32),
                                              border: GradientBoxBorder(
                                                  gradient: LinearGradient(
                                                    colors: isPhone1Focus
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
                                                lang == "en" ? phoneOptionalEn : phoneOptionalEs,
                                                style: TextStyle(
                                                  fontSize: TextSize.bodyText,
                                                  color: themeColor.withOpacity(1.0),
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle: FontStyle.normal,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              TextFormField(
                                                controller: phone1Controller,
                                                focusNode: phone1Focus,
                                                onFieldSubmitted: (term) {
                                                  phone1Focus.unfocus();
                                                },
                                                textInputAction: TextInputAction.done,
                                                keyboardType: TextInputType.number,
                                                textAlign: TextAlign.start,
                                                decoration: InputDecoration(
                                                  fillColor: AppColor.WHITE_COLOR,
                                                  hintText: "(000) 000-0000",
                                                  filled: false,
                                                  border: InputBorder.none,
                                                  contentPadding: EdgeInsets.only(top: 0,),
                                                  hintStyle: TextStyle(
                                                      fontSize: TextSize.headerText,
                                                      fontWeight: FontWeight.w700,
                                                      color: isDarkMode
                                                          ? Color(0xff545454)
                                                          : Color(0xff808080)
                                                  ),
                                                ),
                                                style: TextStyle(
                                                    color: themeColor,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: TextSize.headerText
                                                ),
                                                inputFormatters: [LengthLimitingTextInputFormatter(40)],
                                                onChanged: (value){

                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        margin: EdgeInsets.only(top: 400.0),
                        child: Visibility(
                          visible: isLoaded,
                          child: Container(
                            child: Center(
                              child: Container(
                                child: CircularProgressIndicator(
                                  backgroundColor: AppColor.TRANSPARENT,
                                  color: AppColor.THEME_PRIMARY,
                                  strokeWidth: 5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        }
    );
  }

  void openEditCustomerBottomSheet(context){
    var emailData = emailList.length > 0 ? emailList[0] : "";
    var phoneData = phoneList.length > 0 ? phoneList[0] : "";
    firstNameEditController.text = customerData['firstname'];
    lastNameEditController.text = customerData['lastname'];
    email1EditController.text = emailData != "" ? emailData['email'] : "";
    phone1EditController.text = phoneData != "" ? phoneData['phoneno'] : "";
    isLoaded = false;

    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        clipBehavior: Clip.none,
        barrierColor: isDarkMode ? Color(0xff000000).withOpacity(0.8) : Color(0xff000000).withOpacity(0.5),
        isDismissible: false,
        enableDrag: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        backgroundColor: isDarkMode ? Color(0xff333333) : AppColor.PAGE_COLOR,
        builder: (context){
          return StatefulBuilder(
            builder: (context1, myState){
              customerState = myState;
              return GestureDetector(
                onTap: (){
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height - 50,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
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
                                  lang == 'en' ? "Edit Customer" : "Editar cliente",
                                  style: TextStyle(
                                    color: themeColor,
                                    fontSize: TextSize.headerText,
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                GestureDetector(
                                  onTap: (){
                                    if(firstNameEditController.text.toString() != ""
                                        || lastNameEditController.text.toString() != ""){
                                      setState(() {
                                        myState((){
                                          isLoaded = true;
                                        });
                                      });

                                      if(_isInternetAvailable) {
                                        updateProfileDetail(myState);
                                      } else {
                                        updateProfileDetailForLocalDB(myState);
                                      }
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
                                          lang == 'en' ? saveEn : saveEs,
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

                          // Form Data
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Form(
                                  key: _customerFormKey,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        /***
                                         * First Name
                                         */
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                          padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: isFirstNameEditFocus && isDarkMode
                                                    ? AppColor.gradientColor(0.32)
                                                    : isFirstNameEditFocus
                                                    ? AppColor.gradientColor(0.16)
                                                    : isDarkMode
                                                    ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                                                    : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
                                              ),
                                              borderRadius: BorderRadius.circular(32.0),
                                              border: GradientBoxBorder(
                                                  gradient: LinearGradient(
                                                    colors: isFirstNameEditFocus
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
                                                lang == "en" ? firstNameTitleEn : firstNameTitleEs,
                                                style: TextStyle(
                                                    fontSize: TextSize.subjectTitle,
                                                    color: themeColor.withOpacity(1.0),
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle: FontStyle.normal
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              TextFormField(
                                                controller: firstNameEditController,
                                                focusNode: firstNameEditFocus,
                                                onFieldSubmitted: (term) {
                                                  firstNameEditFocus.unfocus();
                                                  FocusScope.of(context).requestFocus(lastNameEditFocus);
                                                },
                                                textCapitalization: TextCapitalization.sentences,
                                                textInputAction: TextInputAction.next,
                                                keyboardType: TextInputType.name,
                                                textAlign: TextAlign.start,
                                                validator: (value){
                                                  return validateCustomerString(value, lang == "en" ? givenNameEn : givenNameEs);
                                                },
                                                decoration: InputDecoration(
                                                  fillColor: AppColor.WHITE_COLOR,
                                                  hintText: lang == "en" ? givenNameEn : givenNameEs,
                                                  filled: false,
                                                  border: InputBorder.none,
                                                  contentPadding: EdgeInsets.only(top: 0,),
                                                  hintStyle: TextStyle(
                                                      fontSize: TextSize.headerText,
                                                      fontWeight: FontWeight.w700,
                                                      color: isDarkMode
                                                          ? Color(0xff545454)
                                                          : Color(0xff808080)
                                                  ),
                                                ),
                                                style: TextStyle(
                                                    color: themeColor,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: TextSize.headerText
                                                ),
                                                inputFormatters: [LengthLimitingTextInputFormatter(40)],
                                                onChanged: (value){
                                                  myState((){
                                                    setState(() {
                                                      _allCustomerFieldValidate = _customerFormKey.currentState.validate();
                                                    });
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        /***
                                         * Last Name
                                         */
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                          padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: isLastNameEditFocus && isDarkMode
                                                    ? AppColor.gradientColor(0.32)
                                                    : isLastNameEditFocus
                                                    ? AppColor.gradientColor(0.16)
                                                    : isDarkMode
                                                    ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                                                    : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
                                              ),
                                              borderRadius: BorderRadius.circular(32.0),
                                              border: GradientBoxBorder(
                                                  gradient: LinearGradient(
                                                    colors: isLastNameEditFocus
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
                                                lang == "en" ? lastNameEn : lastNameEs,
                                                style: TextStyle(
                                                    fontSize: TextSize.subjectTitle,
                                                    color: themeColor.withOpacity(1.0),
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle: FontStyle.normal
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              TextFormField(
                                                controller: lastNameEditController,
                                                focusNode: lastNameEditFocus,
                                                onFieldSubmitted: (term) {
                                                  lastNameEditFocus.unfocus();
                                                  FocusScope.of(context).requestFocus(email1EditFocus);
                                                },
                                                validator: (value) {
                                                  return validateCustomerString(value, lang == "en" ? lastNameEn : lastNameEs);
                                                },
                                                textCapitalization: TextCapitalization.sentences,
                                                textInputAction: TextInputAction.next,
                                                keyboardType: TextInputType.text,
                                                textAlign: TextAlign.start,
                                                decoration: InputDecoration(
                                                  fillColor: AppColor.WHITE_COLOR,
                                                  hintText: lang == "en" ? familyNameEn : familyNameEs,
                                                  filled: false,
                                                  border: InputBorder.none,
                                                  contentPadding: EdgeInsets.only(top: 0,),
                                                  hintStyle: TextStyle(
                                                      fontSize: TextSize.headerText,
                                                      fontWeight: FontWeight.w700,
                                                      color: isDarkMode
                                                          ? Color(0xff545454)
                                                          : Color(0xff808080)
                                                  ),
                                                ),
                                                style: TextStyle(
                                                    color: themeColor,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: TextSize.headerText
                                                ),
                                                inputFormatters: [LengthLimitingTextInputFormatter(40)],
                                                onChanged: (value){
                                                  myState((){
                                                    setState(() {
                                                      _allCustomerFieldValidate = _customerFormKey.currentState.validate();
                                                    });
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        /***
                                         * Email
                                         */
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                          padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: isEmail1EditFocus && isDarkMode
                                                    ? AppColor.gradientColor(0.32)
                                                    : isEmail1EditFocus
                                                    ? AppColor.gradientColor(0.16)
                                                    : isDarkMode
                                                    ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                                                    : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
                                              ),
                                              borderRadius: BorderRadius.circular(32.0),
                                              border: GradientBoxBorder(
                                                  gradient: LinearGradient(
                                                    colors: isEmail1EditFocus
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
                                                lang == "en" ? emailOptionalEn : emailOptionalEs,
                                                style: TextStyle(
                                                    fontSize: TextSize.subjectTitle,
                                                    color: themeColor.withOpacity(1.0),
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle: FontStyle.normal
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              TextFormField(
                                                controller: email1EditController,
                                                focusNode: email1EditFocus,
                                                onFieldSubmitted: (term) {
                                                  email1EditFocus.unfocus();
                                                  FocusScope.of(context).requestFocus(phone1EditFocus);
                                                },
                                                textInputAction: TextInputAction.next,
                                                keyboardType: TextInputType.text,
                                                textAlign: TextAlign.start,
                                                decoration: InputDecoration(
                                                  fillColor: AppColor.WHITE_COLOR,
                                                  hintText: lang == "en" ? emailHintEn : emailHintEs,
                                                  filled: false,
                                                  border: InputBorder.none,
                                                  contentPadding: EdgeInsets.only(top: 0,),
                                                  hintStyle: TextStyle(
                                                      fontSize: TextSize.headerText,
                                                      fontWeight: FontWeight.w700,
                                                      color: isDarkMode
                                                          ? Color(0xff545454)
                                                          : Color(0xff808080)
                                                  ),
                                                ),
                                                style: TextStyle(
                                                    color: themeColor,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: TextSize.headerText
                                                ),
                                                inputFormatters: [LengthLimitingTextInputFormatter(40)],
                                                onChanged: (value){

                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        /***
                                         * Phone
                                         */
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                          padding: EdgeInsets.only(left: 16.0,right: 16.0, top: 16.0, bottom: 8.0),
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: isPhone1EditFocus && isDarkMode
                                                    ? AppColor.gradientColor(0.32)
                                                    : isPhone1EditFocus
                                                    ? AppColor.gradientColor(0.16)
                                                    : isDarkMode
                                                    ? [Color(0xff1f1f1f), Color(0xff1f1f1f)]
                                                    : [AppColor.WHITE_COLOR, AppColor.WHITE_COLOR],
                                              ),
                                              borderRadius: BorderRadius.circular(32.0),
                                              border: GradientBoxBorder(
                                                  gradient: LinearGradient(
                                                    colors: isPhone1EditFocus
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
                                                lang == "en" ? phoneOptionalEn : phoneOptionalEs,
                                                style: TextStyle(
                                                  fontSize: TextSize.subjectTitle,
                                                  color: themeColor.withOpacity(1.0),
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle: FontStyle.normal,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              TextFormField(
                                                controller: phone1EditController,
                                                focusNode: phone1EditFocus,
                                                onFieldSubmitted: (term) {
                                                  phone1EditFocus.unfocus();
                                                },
                                                textInputAction: TextInputAction.done,
                                                keyboardType: TextInputType.number,
                                                textAlign: TextAlign.start,
                                                decoration: InputDecoration(
                                                  fillColor: AppColor.WHITE_COLOR,
                                                  hintText: "(000) 000-0000",
                                                  filled: false,
                                                  border: InputBorder.none,
                                                  contentPadding: EdgeInsets.only(top: 0,),
                                                  hintStyle: TextStyle(
                                                      fontSize: TextSize.headerText,
                                                      fontWeight: FontWeight.w700,
                                                      color: isDarkMode
                                                          ? Color(0xff545454)
                                                          : Color(0xff808080)
                                                  ),
                                                ),
                                                style: TextStyle(
                                                    color: themeColor,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: TextSize.headerText
                                                ),
                                                inputFormatters: [LengthLimitingTextInputFormatter(40)],
                                                onChanged: (value){

                                                },
                                              ),
                                            ],
                                          ),
                                        ),

                                        /***
                                         * Remove Customer from inspection
                                         */
                                        GestureDetector(
                                          onTap: () async {
                                            setState(() {
                                              myState((){
                                                isLoaded = true;
                                              });
                                            });
                                            if(_isInternetAvailable) {
                                              removeCustomerDetail(myState);
                                            } else {
                                              removeCustomerFromLocalDB(myState);
                                            }
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context).size.width,
                                            margin: EdgeInsets.only(top: 16.0, bottom: 0.0),
                                            padding: EdgeInsets.all(16.0),
                                            decoration: BoxDecoration(
                                                color: AppColor.WHITE_COLOR,
                                                borderRadius: BorderRadius.circular(16.0)
                                            ),
                                            child: Text(
                                              lang == "en" ? removeCustomerEn : removeCustomerEs,
                                              style: TextStyle(
                                                fontSize: TextSize.headerText,
                                                color: AppColor.RED_COLOR.withOpacity(1.0),
                                                fontWeight: FontWeight.w700,
                                                fontStyle: FontStyle.normal,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),

                                        SizedBox(
                                          height: 200,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SingleChildScrollView(
                      child: Container(
                        margin: EdgeInsets.only(top: 400.0),
                        color: isLoaded ? AppColor.GREY_COLOR.withOpacity(0.4) : AppColor.TRANSPARENT,
                        child: Visibility(
                          visible: isLoaded,
                          child: Container(
                            child: Center(
                              child: Container(
                                child: CircularProgressIndicator(
                                  backgroundColor: AppColor.TRANSPARENT,
                                  color: AppColor.THEME_PRIMARY,
                                  strokeWidth: 5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        }
    );
  }

  void setParameters(myState) {
    FocusScope.of(context).requestFocus(FocusNode());
    var phoneList = [];
    var emailList = [];

    if(email1Controller.text.toString().trim() != "") {
      emailList.add({
        "email": "${email1Controller.text}",
        "emailtag": "Work",
        "clientemailpreferred": false
      });
    }

    if(phone1Controller.text.toString().trim() != "") {
      phoneList.add({
        "phoneno": "${phone1Controller.text.toString().trim()}",
        "phonetag": "Home",
        "clientphonepreferred": false
      });
    }

    var requestJson = {
      "firstname": "${firstNameController.text}",
      "lastname": "${lastNameController.text}",
      "nickname":" ",
      "notes": "",
      "phone": phoneList,
      "email": emailList,
      "address": [],
      "servicelocation": []
    };

    String requestParam = json.encode(requestJson);

    if(_isInternetAvailable) {
      createClient(requestParam, myState);
    } else {
      var resultData = {
        "clientid": 0,
        "iscompany": false,
        "personid": 0,
        "firstname": "${firstNameController.text}",
        "lastname": "${lastNameController.text}",
        "email": emailList,
        "phone": phoneList,
        "clientdisabled": false,
        "avatar": null
      };
      insertCustomerRecordIntoLocalDB(requestParam, myState, resultData);
    }
  }

  void insertCustomerRecordIntoLocalDB(requestParam, myState, resultData) async {
    var endPoint = "auth/myclient";
    var response = await dbHelper.insertCustomerGeneralData({
      "url": '$endPoint',
      "verb":'POST',
      "customerlocalid": "1",
      "customerserverid": "0",
      "iscustomerserverid": "0",
      "inspectiondefid": inspectionDefIdLocal ?? "1",
      "payload": requestParam,
    });

    if(response != null) {
      setState(() {
        myState((){
          customerData = resultData;

          customerData['clientid'] = response;
          emailList = customerData['email'];
          phoneList = customerData['phone'];
          isLoaded = false;
          isCustomerSelected = true;
          isClientIdServer = false;
        });
      });

      Navigator.of(context).pop();
    } else {
      log("Something went wrong!!!");
    }
  }

  void checkAutoValidation(controller, state) {
    if(isStringValidated(firstNameController.text.toString())) {
      setState(() {
        state((){
          _isFormValidated = _formKey.currentState.validate();
          _autoValidate = true;
        });
      });
    } else {
      setState(() {
        state((){
          _autoValidate = false;
        });
      });
    }
  }

  bool isStringValidated(String value) {
    if(value!='' && value!=null) {
      if(!value.startsWith(' '))
        return true;
      else
        return false;
    } else {
      return false;
    }
  }

  String validateString(String value) {
    if(value!='' && value!=null) {
      if(!value.startsWith(' '))
        return null;
      else
        return 'Enter your $value';
    } else {
      return 'Enter your $value';
    }

  }

  String validateCustomerString(String value, String type) {
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

  ///////////////////////////API Integration/////////////////////////////
  Future<void> createClient(requestParam, myState) async {
      _progressHUD.state.show();
      FocusScope.of(context).requestFocus(FocusNode());

      var response = await request.postRequest("auth/myclient", requestParam);
      _progressHUD.state.dismiss();

      if (response != null) {
        if(response['success'] != null){
          // _scaffoldKey.currentState.showSnackBar(HelperClass.showSnackBar(context, '${response['reason']}'));
          CustomToast.showToastMessage("${response['reason']}");
        } else {
          // isCustomerSelected = true;
          var endPoint = "auth/myclient";
          await dbHelper.insertCustomerGeneralData({
            "url": '$endPoint',
            "verb":'POST',
            "customerlocalid": "${response['clientid']}",
            "customerserverid": "${response['clientid']}",
            "iscustomerserverid": "1",
            "inspectiondefid": inspectionDefIdLocal ?? "1",
            "payload": requestParam,
          });

          setState(() {
            myState((){
              customerData = response;
              emailList = customerData['email'];
              phoneList = customerData['phone'];
              isLoaded = false;
              isCustomerSelected = true;
              isClientIdServer = true;
            });
          });

          Navigator.of(context).pop();
          // gotoNextItem();
        }
      } else {
        CustomToast.showToastMessage('Something Went Wrong!');
      }
  }

  void updateProfileDetailForLocalDB(myState) async {
    FocusScope.of(context).requestFocus(FocusNode());

    var phoneList = [];
    var emailList = [];

    if(customerData != null) {
      if(customerData['email'] != null && customerData["email"].length > 0){
        if(email1EditController.text.toString().trim() != "") {
          emailList.add({
            "emailid": "${customerData['email'][0]['emailid']}",
            "email": "${email1EditController.text}",
            "emailtag": "Work",
            "clientemailpreferred": false
          });
        }
      } else {
        if(email1EditController.text.toString().trim() != "") {
          emailList.add({
            "email": "${email1EditController.text}",
            "emailtag": "Work",
            "clientemailpreferred": false
          });
        }
      }

      if(customerData['phone'] != null && customerData["phone"].length > 0){
        if(phone1EditController.text.toString().trim() != "") {
          emailList.add({
            "phoneid": "${customerData['phone'][0]['phoneid']}",
            "phoneno": "${phone1EditController.text}",
            "phonetag": "Work",
            "clientphonepreferred": false
          });
        }
      } else {
        if(phone1Controller.text.toString().trim() != "") {
          emailList.add({
            "phoneno": "${phone1Controller.text}",
            "phonetag": "Work",
            "clientphonepreferred": false
          });
        }
      }
    }

    log("PhoneList=====$phoneList");
    log("EmailList=====$emailList");

    var requestJson;
    if(firstNameEditController.text == ''){
      requestJson = {"lastname": "${lastNameEditController.text.toString().trim()}"};
    } else if(lastNameEditController.text == ''){
      requestJson = {"firstname": "${firstNameEditController.text.toString().trim()}"};
    } else {
      requestJson = {
        "firstname": "${firstNameEditController.text.toString().trim()}",
        "lastname": "${lastNameEditController.text.toString().trim()}",
        "email": emailList,
        "phone": phoneList
      };
    }
    log("RequestJson=====$requestJson");
    var requestParam = json.encode(requestJson);

    var response = await dbHelper.updateCustomerGeneralDetail(
      customerLocalId: customerData['clientid'],
      payload: requestParam,
    );

    if(response != null) {
      setState(() {
        myState((){
          customerData['firstname'] = firstNameEditController.text.toString().trim();
          customerData['lastname'] = lastNameEditController.text.toString().trim();
          this.emailList = emailList;
          this.phoneList = phoneList;
          isLoaded = false;

          isClientIdServer = false;
        });
      });
      Navigator.pop(context);
    }
  }

  void updateProfileDetail(myState) async {
    // _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());

    var phoneList = [];
    var emailList = [];

    log("FirstName=====${firstNameEditController.text}");
    log("LastName=====${firstNameEditController.text}");

    if(customerData != null) {
      if(customerData['email'] != null && customerData["email"].length > 0){
        if(email1EditController.text.toString().trim() != "") {
          emailList.add({
            "emailid": "${customerData['email'][0]['emailid']}",
            "email": "${email1EditController.text}",
            "emailtag": "Work",
            "clientemailpreferred": false
          });
        }
      } else {
        if(email1EditController.text.toString().trim() != "") {
          emailList.add({
            "email": "${email1EditController.text}",
            "emailtag": "Work",
            "clientemailpreferred": false
          });
        }
      }

      if(customerData['phone'] != null && customerData["phone"].length > 0){
        if(phone1EditController.text.toString().trim() != "") {
          emailList.add({
            "phoneid": "${customerData['phone'][0]['phoneid']}",
            "phoneno": "${phone1EditController.text}",
            "phonetag": "Work",
            "clientphonepreferred": false
          });
        }
      } else {
        if(phone1Controller.text.toString().trim() != "") {
          emailList.add({
            "phoneno": "${phone1Controller.text}",
            "phonetag": "Work",
            "clientphonepreferred": false
          });
        }
      }
    }

    log("PhoneList=====$phoneList");
    log("EmailList=====$emailList");

    var requestJson;
    if(firstNameEditController.text == ''){
      requestJson = {"lastname": "${lastNameEditController.text.toString().trim()}"};
    } else if(lastNameEditController.text == ''){
      requestJson = {"firstname": "${firstNameEditController.text.toString().trim()}"};
    } else {
      requestJson = {
        "firstname": "${firstNameEditController.text.toString().trim()}",
        "lastname": "${lastNameEditController.text.toString().trim()}",
        "email": emailList,
        "phone": phoneList
      };
    }
    log("RequestJson=====$requestJson");
    var requestParam = json.encode(requestJson);
    var response = await request.patchRequest("auth/myclient/${customerData['clientid']}", requestParam);
    // _progressHUD.state.dismiss();

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage('${response['reason']}');
      } else {
         await dbHelper.updateCustomerGeneralDetail(
          customerLocalId: customerData['clientid'],
          payload: requestParam,
        );

        setState(() {
          myState((){
            customerData['firstname'] = firstNameEditController.text.toString().trim();
            customerData['lastname'] = lastNameEditController.text.toString().trim();
            isLoaded = false;
          });
        });
        Navigator.pop(context);
      }
    }
  }

  Future removeCustomerFromLocalDB(myState) async {
    try{
      var response = await dbHelper.deleteSingleCustomerGeneralTableData(customerData['clientid']);

      if(response != null) {
        setState(() {
          myState((){
            isLoaded = false;
          });
        });

        int inspectionIndex = await InspectionPreferences.getInspectionId(InspectionPreferences.INSPECTION_INDEX);
        InspectionUtils.decrementIndex(inspectionIndex);
        Navigator.of(context).pop(true);
        Navigator.of(context).pop(true);

      } else {
        CustomToast.showToastMessage("Something Went Wrong!");
      }
    }catch(e) {
      log("removeCustomerFromLocalDBStackTrace===$e");
    }
  }

  Future<void> removeCustomerDetail(myState) async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var response = await request.deleteAuthRequest("auth/myclient/${customerData['clientid']}");
    _progressHUD.state.dismiss();

    if (response != null) {
      if(response['success'] != null && response['success']){
        await dbHelper.deleteSingleCustomerGeneralTableData(customerData['clientid']);

        setState(() {
          myState((){
            isLoaded = false;
          });
        });
        int inspectionIndex = await InspectionPreferences.getInspectionId(InspectionPreferences.INSPECTION_INDEX);
        InspectionUtils.decrementIndex(inspectionIndex);
        Navigator.of(context).pop(true);
        Navigator.of(context).pop(true);
      } else {
        CustomToast.showToastMessage("Something Went Wrong!");
      }
    } else {
      CustomToast.showToastMessage("Something Went Wrong!");
    }
  }

  void gotoNextPage() async {
    var listItem = await InspectionPreferences.getPreferenceData("${InspectionPreferences.INSPECTION_DETAIL_LIST}");
    List inspectionListItem = json.decode(listItem);

    print("Inspection Detail====>>>$inspectionListItem");

    var inspectionData;

    for(int i=0; i<inspectionListItem.length; i++) {
      if(inspectionListItem[i]['status'] == 0){
        if(inspectionListItem[i]['blocktype'] == 'service address') {
          inspectionData = inspectionListItem[i]['txt'][lang] ?? inspectionListItem[i]['txt']['en'];
          inspectionListItem[i]['status'] = 1;

          InspectionPreferences.clearPreferenceData(InspectionPreferences.INSPECTION_DETAIL_LIST);
          InspectionPreferences.setPreferenceData(
              InspectionPreferences.INSPECTION_DETAIL_LIST,
              json.encode(inspectionListItem)
          );
          break;
        }
      }
    }

    if(inspectionData != null){
      Navigator.push(
          context,
          SlideRightRoute(
              page: InspectionLocationPage(
                  clientId: "${customerData['clientid']}",
                  clientData: customerData,
                  detail: inspectionData,
                  inspectionDefId: inspectionDefIdLocal
              )
          )
      );
    }
  }

  void gotoNextItem() async {
    var listItemData = await InspectionPreferences.getPreferenceData(InspectionPreferences.INSPECTION_DATA);
    var transformedData = json.decode(listItemData);
    int inspectionIndex = await InspectionPreferences.getInspectionId(InspectionPreferences.INSPECTION_INDEX);

    print(transformedData);

    var inspectionData;
    int index;

    print("Index====$inspectionIndex");
    print("Length====${transformedData.length}");
    for(int i=inspectionIndex??0; i<transformedData.length; i++) {
      var data = await InspectionUtils.getInspectionBlockTypeData(transformedData[i], transformedData.length);
      if(data != null){
        if(data.runtimeType == InspectionLocationPage){
          inspectionData = transformedData[i];
          index = i;
          break;
        }
      }
    }

    if(inspectionData != null){
      InspectionPreferences.clearPreferenceData(InspectionPreferences.INSPECTION_INDEX);
      InspectionPreferences.setInspectionId(
          InspectionPreferences.INSPECTION_INDEX,
          ++index
      );

      Navigator.push(
          context,
          SlideRightRoute(
              page: InspectionLocationPage(
                detail: inspectionData,
                clientId: "${customerData['clientid']}",
                clientData: customerData,
                inspectionDefId: inspectionDefIdLocal,
                isClientServer: isClientIdServer
              )
          )
      ).then((result){
        if(result != null){
          if(result){
            setState(() {
              customerData = {};
              isCustomerSelected = false;
            });
          }
        }
      });
    }


   /* if(transformedData.containsKey("children")){

      int inspectionDefId = await InspectionPreferences.getInspectionId(InspectionPreferences.INSPECTION_DEF_ID);
      print("KEY VALUE=====>>>$inspectionDefId");
      if(inspectionDefId != null) {
        HelperClass.getInspectionData(
            "inspectiondefid", inspectionDefId, transformedData['children'],
                (inspectionData){
                  print("InspectionData===>>>>$inspectionData");

                  if(inspectionData != null){
                    InspectionPreferences.clearPreferenceData(InspectionPreferences.INSPECTION_DEF_ID);
                    InspectionPreferences.setInspectionId(
                        InspectionPreferences.INSPECTION_DEF_ID,
                        ++inspectionDefId
                    );

                    Navigator.push(
                        context,
                        SlideRightRoute(
                            page: InspectionLocationPage(
                                clientId: "${customerData['clientid']}",
                                clientData: customerData,
                                detail: inspectionData,
                                inspectionDefId: inspectionDefIdLocal
                            )
                        )
                    );
                  }
            }
        );
      }
    }*/
  }
}
