import 'dart:developer';

import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/widget/custom_switch.dart';
import 'package:dottie_inspector/widget/dateTimePicker/bottom_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key key}) : super(key: key);

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {

  var elevation = 0.0;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      setState(() {
        if(_scrollController.position.pixels > _scrollController.position.minScrollExtent){
          elevation = HelperClass.ELEVATION_1;
        } else {
          elevation = HelperClass.ELEVATION;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.PAGE_COLOR,
      appBar: EmptyAppBar(isDarkMode: false),
      body: Stack(
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
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        child: Image.asset(
                          'assets/ic_close_button.png',
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
                            'Subscription',
                            style: TextStyle(
                                color: AppColor.BLACK_COLOR,
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
                    color: AppColor.DIVIDER,
                  )
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 6,),

                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 0),
                          child: Text(
                            'Subscription',
                            style: TextStyle(
                                color: AppColor.BLACK_COLOR,
                                fontSize: TextSize.greetingTitleText,
                                fontWeight: FontWeight.w700
                            ),
                          ),
                        ),

                        SizedBox(height: 16,),

                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 0),
                          child: Text(
                            'Inspector Dottie subscription can’t be purchased in this app.',
                            style: TextStyle(
                                color: AppColor.BLACK_COLOR,
                                fontSize: TextSize.subjectTitle,
                                fontWeight: FontWeight.w600,
                                height: 1.5
                            ),
                          ),
                        ),

                        SizedBox(height: 32,),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 0),
                          child: Text(
                            'Plan',
                            style: TextStyle(
                                color: AppColor.BLACK_COLOR,
                                fontSize: 22,
                                fontWeight: FontWeight.w700
                            ),
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(top: 8),
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColor.WHITE_COLOR,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Language',
                                style: TextStyle(
                                    color: AppColor.BLACK_COLOR,
                                    fontSize: TextSize.headerText,
                                    fontWeight: FontWeight.w700
                                ),
                              ),

                              SizedBox(height: 8,),
                              Text(
                                'Changes the language used in the app',
                                style: TextStyle(
                                    color: AppColor.BLACK_COLOR,
                                    fontSize: TextSize.bodyText,
                                    fontWeight: FontWeight.w500
                                ),
                              ),

                              SizedBox(height: 24,),

                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                decoration: BoxDecoration(
                                    color: AppColor.TYPE_PRIMARY.withOpacity(0.04),
                                    borderRadius: BorderRadius.circular(16)
                                ),
                                width: 120,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "English",
                                        style: TextStyle(
                                            fontSize: TextSize.subjectTitle,
                                            fontWeight: FontWeight.w700,
                                            color: AppColor.BLACK_COLOR
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Icon(Icons.arrow_drop_down,color: AppColor.BLACK_COLOR, size: 18,)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(top: 8),
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColor.WHITE_COLOR,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Region',
                                style: TextStyle(
                                    color: AppColor.BLACK_COLOR,
                                    fontSize: TextSize.headerText,
                                    fontWeight: FontWeight.w700
                                ),
                              ),

                              SizedBox(height: 8,),
                              Text(
                                'Changes your default country',
                                style: TextStyle(
                                    color: AppColor.BLACK_COLOR,
                                    fontSize: TextSize.bodyText,
                                    fontWeight: FontWeight.w500
                                ),
                              ),

                              SizedBox(height: 24,),

                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                decoration: BoxDecoration(
                                    color: AppColor.TYPE_PRIMARY.withOpacity(0.04),
                                    borderRadius: BorderRadius.circular(16)
                                ),
                                width: 160,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: FittedBox(
                                        child: Text(
                                          "United States",
                                          style: TextStyle(
                                              fontSize: TextSize.subjectTitle,
                                              fontWeight: FontWeight.w700,
                                              color: AppColor.BLACK_COLOR
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Icon(Icons.arrow_drop_down,color: AppColor.BLACK_COLOR, size: 18,)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(top:24, left: 8, right: 8),
                          child: Text(
                            'Display',
                            style: TextStyle(
                                color: AppColor.BLACK_COLOR,
                                fontSize: TextSize.subjectTitle,
                                fontWeight: FontWeight.w700
                            ),
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(top: 8),
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColor.WHITE_COLOR,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Date Format',
                                style: TextStyle(
                                    color: AppColor.BLACK_COLOR,
                                    fontSize: TextSize.headerText,
                                    fontWeight: FontWeight.w700
                                ),
                              ),

                              SizedBox(height: 8,),
                              Text(
                                'Changes the format for all dates in the app',
                                style: TextStyle(
                                    color: AppColor.BLACK_COLOR,
                                    fontSize: TextSize.bodyText,
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                              SizedBox(height: 16,),
                              Text(
                                '01/27/2022',
                                style: TextStyle(
                                    color: AppColor.BLACK_COLOR,
                                    fontSize: TextSize.subjectTitle,
                                    fontWeight: FontWeight.w700
                                ),
                              ),

                              SizedBox(height: 24,),

                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                decoration: BoxDecoration(
                                    color: AppColor.TYPE_PRIMARY.withOpacity(0.04),
                                    borderRadius: BorderRadius.circular(16)
                                ),
                                width: 160,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "MM/DD/YY",
                                        style: TextStyle(
                                            fontSize: TextSize.subjectTitle,
                                            fontWeight: FontWeight.w700,
                                            color: AppColor.BLACK_COLOR
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Icon(Icons.arrow_drop_down,color: AppColor.BLACK_COLOR, size: 18,)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(top: 8),
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColor.WHITE_COLOR,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Time Format',
                                style: TextStyle(
                                    color: AppColor.BLACK_COLOR,
                                    fontSize: TextSize.headerText,
                                    fontWeight: FontWeight.w700
                                ),
                              ),

                              SizedBox(height: 8,),
                              Text(
                                'Changes the format for all times in the app',
                                style: TextStyle(
                                    color: AppColor.BLACK_COLOR,
                                    fontSize: TextSize.bodyText,
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                              SizedBox(height: 16,),
                              Text(
                                '1:30 pm',
                                style: TextStyle(
                                    color: AppColor.BLACK_COLOR,
                                    fontSize: TextSize.subjectTitle,
                                    fontWeight: FontWeight.w700
                                ),
                              ),

                              SizedBox(height: 24,),

                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                decoration: BoxDecoration(
                                    color: AppColor.TYPE_PRIMARY.withOpacity(0.04),
                                    borderRadius: BorderRadius.circular(16)
                                ),
                                width: 160,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "HH:MM XM",
                                        style: TextStyle(
                                            fontSize: TextSize.subjectTitle,
                                            fontWeight: FontWeight.w700,
                                            color: AppColor.BLACK_COLOR
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Icon(Icons.arrow_drop_down,color: AppColor.BLACK_COLOR, size: 18,)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),


                        SizedBox(height: 120,)
                      ],
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  void showBottomPicker(mapData, type) {
    var date = mapData['initialTime'];
    BottomPicker.time(
      title:  "",
      isDarkMode: false,
      titleStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize:  15,
          color: Colors.orange
      ),
      onSubmit: (index) {
        print(index.runtimeType);
        var data = getTimeFormat(index);
        log(data);
        setState(() {
          if(type == "to") {
            mapData['toTime'] = data;
          } else {
            mapData['fromTime'] = data;
          }
          mapData['initialTime'] = index;
        });
      },
      onClose: () {
        print("Picker closed");
      },
      initialDateTime: date,
      pickerTextStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize:  18,
          color: Colors.black
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
}
