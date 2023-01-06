import 'dart:convert';
import 'dart:developer';

import 'package:bottom_picker/resources/arrays.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/custom_toast.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:dottie_inspector/widget/bottom_general_button_widget.dart';
import 'package:dottie_inspector/widget/bottom_general_dark_button_widget.dart';
import 'package:dottie_inspector/widget/custom_switch.dart';
import 'package:dottie_inspector/widget/custome_progress_bar.dart';
import 'package:dottie_inspector/widget/dateTimePicker/bottom_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class BusinessHour extends StatefulWidget {
  final preferences;
  const BusinessHour({Key key, this.preferences}) : super(key: key);

  @override
  _BusinessHourState createState() => _BusinessHourState();
}

class _BusinessHourState extends State<BusinessHour> {

  List businessHourList = [];
  var elevation = 0.0;
  final _scrollController = ScrollController();
  var preferences;


  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;

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

    _scrollController.addListener(() {
      setState(() {
        if(_scrollController.position.pixels > _scrollController.position.minScrollExtent){
          elevation = HelperClass.ELEVATION_1;
        } else {
          elevation = HelperClass.ELEVATION;
        }
      });
    });

    getPreferenceData();
    setBusinessHourTime();
  }

  void getPreferenceData() async {
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

  void setBusinessHourTime() async {
    var businessHourEncoded = await PreferenceHelper.getPreferenceData(PreferenceHelper.BUSINESS_HOUR);
    log("BusinessHourEncoded===>$businessHourEncoded");
    var businessHourDecoded = businessHourEncoded != null ? json.decode(businessHourEncoded) : null;
    log("BusinessHourDecoded===>${businessHourDecoded.runtimeType}");

    if(businessHourDecoded != null) {
      var keyList = businessHourDecoded.keys.toList();

      setState(() {
        for (int i = 0; i < keyList.length; i++) {
          var fromTime = getDayTime(businessHourDecoded[keyList[i]], 0, "from");
          var toTime = getDayTime(businessHourDecoded[keyList[i]], 1, "to");
          businessHourList.add({
            "index": i,
            "dayName": getKeyDayName(keyList[i]),
            "isOpen": businessHourDecoded[keyList[i]].length>0,
            "fromTime": getChangedTime(fromTime),
            "toTime": getChangedTime(toTime),
            "fromHHMM": fromTime,
            "toHHMM": toTime,
            "initialFromTime": getInitialTime(fromTime),
            "initialToTime": getInitialTime(toTime)
          });
        }
      });
    } else {
      print("Else");
      setState(() {
        for (int i = 0; i < 7; i++) {
          businessHourList.add({
            "index": i,
            "dayName": getDayName(i),
            "isOpen": false,
            "fromTime": "09:00 AM",
            "toTime": "05:00 PM",
            "fromHHMM": "09:00",
            "toHHMM": "17:00",
            "initialFromTime": DateTime.now(),
            "initialToTime": DateTime.now()
          });
        }
      });
    }
    // if(widget.preferences['BusinessHours'] != null) {
    //   preferences = widget.preferences['BusinessHours'];
    //
    //   var keyList = preferences.keys.toList();
    //
    //   for (int i = 0; i < keyList.length; i++) {
    //     var fromTime = getDayTime(preferences[keyList[i]], 0, "from");
    //     var toTime = getDayTime(preferences[keyList[i]], 1, "to");
    //     businessHourList.add({
    //       "index": i,
    //       "dayName": getKeyDayName(keyList[i]),
    //       "isOpen": preferences[keyList[i]].length>0,
    //       "fromTime": getChangedTime(fromTime),
    //       "toTime": getChangedTime(toTime),
    //       "fromHHMM": fromTime,
    //       "toHHMM": toTime,
    //       "initialFromTime": getInitialTime(fromTime),
    //       "initialToTime": getInitialTime(toTime)
    //     });
    //   }
    // } else {
    //   for (int i = 0; i < 7; i++) {
    //     businessHourList.add({
    //       "index": i,
    //       "dayName": getDayName(i),
    //       "isOpen": false,
    //       "fromTime": "09:00 AM",
    //       "toTime": "05:00 PM",
    //       "fromHHMM": "09:00",
    //       "toHHMM": "17:00",
    //       "initialFromTime": DateTime.now(),
    //       "initialToTime": DateTime.now()
    //     });
    //   }
    // }
  }

  String getKeyDayName(key) {
    switch(key) {
      case "Sun": return "Sunday";
      case "Mon": return "Monday";
      case "Tue": return "Tuesday";
      case "Wed": return "Wednesday";
      case "Thu": return "Thursday";
      case "Fri": return "Friday";
      case "Sat": return "Saturday";
      default: return "Saturday";
    }
  }

  String getDayTime(data, index, type) {
    if(data != null && data.length>0) {
      return data[index];
    }
    return type == "from" ? "09:00" : "17:00";
  }

  String getDayName(index) {
    switch(index) {
      case 0: return "Sunday";
      case 1: return "Monday";
      case 2: return "Tuesday";
      case 3: return "Wednesday";
      case 4: return "Thursday";
      case 5: return "Friday";
      default: return "Saturday";
    }
  }

  DateTime getInitialTime(time) {
    var newDate = DateFormat.Hm("en_US");
    var dateTime = newDate.parse(time);

    return dateTime;
  }

  String getChangedTime(time) {
    var newDate = DateFormat.Hm("en_US");
    var formatter = DateFormat('hh:mm a');
    String formatted = formatter.format(newDate.parse(time));
    return formatted;
    // var temp = int.parse(time.split(':')[0]);
    // String t;
    // if(temp >= 12 && temp <24){
    //   t = " PM";
    // }
    // else{
    //   t = " AM";
    // }
    // if (temp > 12) {
    //   temp = temp - 12;
    //   if (temp < 10) {
    //     time = time.replaceRange(0, 2, "0$temp");
    //     time += t;
    //   } else {
    //     time = time.replaceRange(0, 2, "$temp");
    //     time += t;
    //   }
    // } else if (temp == 00) {
    //   time = time.replaceRange(0, 2, '12');
    //   time += t;
    // }else{
    //   time += t;
    // }
    //
    // print("NewTime==$time");
    // return time;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? AppColor.BLACK_COLOR : AppColor.PAGE_COLOR,
      appBar: EmptyAppBar(isDarkMode: isDarkMode),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        child: Image.asset(
                          isDarkMode
                            ? 'assets/ic_dark_back_button.png'
                            : 'assets/ic_close_button.png',
                          fit: BoxFit.cover,
                          width: 48,
                          height: 48,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 9,
                      child: Visibility(
                        visible: elevation != 0,
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            'Business Hour',
                            style: TextStyle(
                                color: themeColor,
                                fontSize: TextSize.headerText,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                  ],
                ),
              ),
              Visibility(
                  visible: elevation != 0,
                  child: Divider(
                    height: 0.5,
                    thickness: 1,
                    color: isDarkMode ? AppColor.DIVIDER.withOpacity(0.4) : AppColor.DIVIDER,
                  )
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 10,),

                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'Business Hours',
                            style: TextStyle(
                                color: themeColor,
                                fontSize: TextSize.greetingTitleText,
                                fontWeight: FontWeight.w700
                            ),
                          ),
                        ),

                        SizedBox(height: 16,),

                        ListView.builder(
                          itemCount: businessHourList.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.only(bottom: 8),
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? Color(0xff1F1F1F)
                                      : AppColor.WHITE_COLOR,
                                borderRadius: BorderRadius.circular(32)
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          businessHourList[index]['dayName'],
                                          style: TextStyle(
                                              fontSize: TextSize.headerText,
                                              fontWeight: FontWeight.w700,
                                              color: themeColor
                                          ),
                                        ),
                                        CustomSwitch(
                                          value: businessHourList[index]['isOpen'],
                                          onChanged: (value) {
                                            setState(() {
                                              businessHourList[index]['isOpen'] = value;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),

                                  businessHourList[index]['isOpen']
                                  ? Container(
                                    margin: EdgeInsets.only(top: 16),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: (){
                                              showBottomPicker(businessHourList[index], "from");
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                              decoration: BoxDecoration(
                                                  color: isDarkMode
                                                      ? Color(0xff333333)
                                                      : AppColor.TYPE_PRIMARY.withOpacity(0.04),
                                                  borderRadius: BorderRadius.circular(16)
                                              ),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      businessHourList[index]['fromTime'],
                                                      style: TextStyle(
                                                          fontSize: TextSize.subjectTitle,
                                                          fontWeight: FontWeight.w700,
                                                          color: themeColor
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 8,),
                                                  Icon(Icons.arrow_drop_down,color: themeColor, size: 18,)
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),

                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 16),
                                          child: Text(
                                            "To",
                                            style: TextStyle(
                                                fontSize: TextSize.subjectTitle,
                                                fontWeight: FontWeight.w700,
                                                color: themeColor
                                            ),
                                          ),
                                        ),

                                        Expanded(
                                          child: GestureDetector(
                                            onTap: (){
                                              showBottomPicker(businessHourList[index], "to");
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                              decoration: BoxDecoration(
                                                  color: isDarkMode
                                                      ? Color(0xff333333)
                                                      : AppColor.TYPE_PRIMARY.withOpacity(0.04),
                                                  borderRadius: BorderRadius.circular(16)
                                              ),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      businessHourList[index]['toTime'],
                                                      style: TextStyle(
                                                          fontSize: TextSize.subjectTitle,
                                                          fontWeight: FontWeight.w700,
                                                          color: themeColor
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 8,),
                                                  Icon(Icons.arrow_drop_down,color: themeColor, size: 18,)
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                  : Container(
                                    margin: EdgeInsets.only(top: 16),
                                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                    decoration: BoxDecoration(
                                        color: isDarkMode
                                        ? Color(0xff333333)
                                        : AppColor.TYPE_PRIMARY.withOpacity(0.04),
                                        borderRadius: BorderRadius.circular(16)
                                    ),
                                    child: Text(
                                      "Closed",
                                      style: TextStyle(
                                          fontSize: TextSize.subjectTitle,
                                          fontWeight: FontWeight.w700,
                                          color: themeColor
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        SizedBox(height: 120,),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),

          BottomGeneralButton(
            isActive: true,
            buttonName: "Save",
            onStartButton: () async {
              if(await HelperClass.internetConnectivity()) {
                updateBusinessHour();
              } else {
                HelperClass.openSnackBar(context);
              }
            },
          ),
          _progressHUD
        ],
      ),
    );
  }

  void showBottomPicker(mapData, type) {
    var date = type == 'to' ? mapData['initialToTime'] : mapData['initialFromTime'];
    BottomPicker.time(
        title:  "",
        isDarkMode: isDarkMode,
        titleStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize:  15,
            color: Colors.orange
        ),

        backgroundColor: isDarkMode ? Color(0xff1f1f1f) : Colors.white,
        onSubmit: (index) {
          print(index.runtimeType);
          var data = getTimeFormat(index);
          var data24 = get24TimeFormat(index);
          // log(data);
          setState(() {
            if(type == "to") {
              mapData['toTime'] = data;
              mapData['toHHMM'] = data24;
              mapData['initialToTime'] = index;
            } else {
              mapData['fromTime'] = data;
              mapData['fromHHMM'] = data24;
              mapData['initialFromTime'] = index;
            }
          });
        },
        onClose: () {
          print("Picker closed");
        },
        initialDateTime: date,
        pickerTextStyle: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize:  18,
            color: isDarkMode ? Colors.white : Colors.black
        ),
        dismissable: true,
        gradientColors: [
          Color(0xff013399),
          Color(0xffBC96E6)
        ],
        use24hFormat:  false,
    ).show(context);
  }

  String getTimeFormat(date) {
    var formatter = DateFormat('hh:mm a');
    String formatted = formatter.format(date);
    return formatted;
  }

  String get24TimeFormat(date) {
    var formatter = DateFormat('HH:mm');
    String formatted = formatter.format(date);
    return formatted;
  }

  void updateBusinessHour() async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    // var requestJson = {"password": "${_confirmPasswordController.text.toString().trim()}"};
    List businessList = [];
    for(int i=0; i<businessHourList.length; i++) {
      if(businessHourList[i]['isOpen']) {
        businessList.add(["${businessHourList[i]['fromHHMM']}","${businessHourList[i]['toHHMM']}"]);
      } else {
        businessList.add([]);
      }
    }

    var subscriptionData = await PreferenceHelper.getSellInformationData(PreferenceHelper.SELL_INFORMATION);
    bool isSellInformation = subscriptionData ?? false;

    var requestJson = {
      "preferences": {
        "BusinessHours": {
          "Sun": businessList[0],
          "Mon": businessList[1],
          "Tue": businessList[2],
          "Wed": businessList[3],
          "Thu": businessList[4],
          "Fri": businessList[5],
          "Sat": businessList[6]
        },
        "DoNotSell": isSellInformation
      }
    };
    log("RequestJson===$requestJson");

    var requestParam = json.encode(requestJson);
    var response = await request.postRequest("auth/admin/setCompanyPrefs", requestParam);
    _progressHUD.state.dismiss();

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage('${response['reason']}');
      } else {
        CustomToast.showToastMessage('Business hours saved');

        var businessHour = response['BusinessHours'] != null ? json.encode(response['BusinessHours']) : null;
        PreferenceHelper.setPreferenceData(PreferenceHelper.BUSINESS_HOUR, businessHour);
        // Navigator.pop(context);
      }
    }
  }
}
