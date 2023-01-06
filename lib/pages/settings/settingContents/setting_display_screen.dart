import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/custom_toast.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:dottie_inspector/widget/custome_progress_bar.dart';
import 'package:dottie_inspector/widget/dateTimePicker/bottom_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class SettingDisplayScreen extends StatefulWidget {
  const SettingDisplayScreen({Key key}) : super(key: key);

  @override
  _SettingDisplayScreenState createState() => _SettingDisplayScreenState();
}

class _SettingDisplayScreenState extends State<SettingDisplayScreen> {

  var elevation = 0.0;
  final _scrollController = ScrollController();
  List dateList = [];
  List timeList = [];

  var currentDate = "";
  var currentDateFormat;
  var currentTime = "";
  var currentTimeFormat;

  // var timeFormatter = DateFormat('h:mm a');
  // var dateFormatter = DateFormat('dd/MM/yyyy');

  String currentLanguage = "English";
  bool isEnglishLang = true;

  AllHttpRequest request = new AllHttpRequest();
  ProgressHUD _progressHUD;
  var _loading = false;

  var themeMode = "";
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

    getJsonFile();
  }

  void getPreferenceData() async {
    var lang = await PreferenceHelper.getPreferenceData(PreferenceHelper.LANGUAGE) ?? "en";

    setState(() {
      currentLanguage = lang == "en" ? "English" : "Spanish";
      isEnglishLang = lang == 'en';
    });

   await PreferenceHelper.getPreferenceData(PreferenceHelper.DATE_FORMAT).then((value){
      setState(() {
        currentDateFormat = value == null ? "dd/MM/yyyy" : value;
        currentDate =  DateFormat(currentDateFormat).format(DateTime.now());

        log("DateFormat====$currentDateFormat, and CurrentDate====$currentDate");
      });
    });

    PreferenceHelper.getPreferenceData(PreferenceHelper.TIME_FORMAT).then((value){
      setState(() {
        currentTimeFormat = value == null ? "h:mm a" : value;
        currentTime = DateFormat(currentTimeFormat).format(DateTime.now());

        log("TimeFormat====$currentTimeFormat, and CurrentTime====$currentTime");
      });
    });

    await PreferenceHelper.getPreferenceData(PreferenceHelper.THEME_MODE).then((value){
      setState(() {
        themeMode = value == null ? "" : value;
        log("Tgheme====$value");
        var localTheme = value;
        if(themeMode == "auto") {
          var brightness = MediaQuery.of(context).platformBrightness;
          localTheme = Brightness.dark ==  brightness ? "dark" : "light";
        }
        isDarkMode = localTheme == "dark";
        themeColor = isDarkMode ? AppColor.WHITE_COLOR : AppColor.BLACK_COLOR;

        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: isDarkMode ? Colors.black : AppColor.THEME_PRIMARY.withOpacity(0.4),
          statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        ));
      });
    });
  }

  void getJsonFile() async {
    String dateFormat = await DefaultAssetBundle.of(context).loadString("assets/settings/date_format.json");
    String timeFormat = await DefaultAssetBundle.of(context).loadString("assets/settings/time_format.json");

    setState(() {
      dateList = json.decode(dateFormat);
      timeList = json.decode(timeFormat);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? AppColor.BLACK_COLOR : AppColor.PAGE_COLOR,
      appBar: EmptyAppBar(isDarkMode: isDarkMode),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Stack(
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

                    Visibility(
                      visible: elevation != 0,
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        child: Text(
                          isEnglishLang ? 'Display' : 'Mostrar',
                          style: TextStyle(
                              color: themeColor,
                              fontSize: TextSize.headerText,
                              fontWeight: FontWeight.w600
                          ),
                        ),
                      ),
                    ),
                  ],
                )
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
                            isEnglishLang ? 'Display' : 'Mostrar',
                            style: TextStyle(
                                color: themeColor,
                                fontSize: TextSize.greetingTitleText,
                                fontWeight: FontWeight.w700
                            ),
                          ),
                        ),

                        SizedBox(height: 16,),

                        Container(
                          margin: EdgeInsets.only(top:24, left: 8, right: 8),
                          child: Text(
                            isEnglishLang ? 'Language & Region' : 'Idioma y región',
                            style: TextStyle(
                                color: themeColor,
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
                            color: isDarkMode
                                ? Color(0xff1F1F1F)
                                : AppColor.WHITE_COLOR,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                isEnglishLang ? 'Language' : 'Idioma',
                                style: TextStyle(
                                    color: themeColor,
                                    fontSize: TextSize.headerText,
                                    fontWeight: FontWeight.w700
                                ),
                              ),

                              SizedBox(height: 8,),
                              Text(
                                isEnglishLang ? 'Changes the language used in the app' : 'Cambia el idioma utilizado en la aplicación.',
                                style: TextStyle(
                                    color: themeColor,
                                    fontSize: TextSize.bodyText,
                                    fontWeight: FontWeight.w500
                                ),
                              ),

                              SizedBox(height: 24,),

                              GestureDetector(
                                onTap: (){
                                  bottomLanguagePicker(context);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                  decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? Color(0xff333333)
                                          : AppColor.TYPE_PRIMARY.withOpacity(0.04),
                                      borderRadius: BorderRadius.circular(16)
                                  ),
                                  width: 150,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "$currentLanguage",
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
                            ],
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(top: 8),
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Color(0xff1F1F1F)
                                : AppColor.WHITE_COLOR,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                isEnglishLang ? 'Region' : 'Región',
                                style: TextStyle(
                                    color: themeColor,
                                    fontSize: TextSize.headerText,
                                    fontWeight: FontWeight.w700
                                ),
                              ),

                              SizedBox(height: 8,),
                              Text(
                                isEnglishLang ? 'Changes your default country' : 'Cambia tu país predeterminado',
                                style: TextStyle(
                                    color: themeColor,
                                    fontSize: TextSize.bodyText,
                                    fontWeight: FontWeight.w500
                                ),
                              ),

                              SizedBox(height: 24,),

                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? Color(0xff333333)
                                        : AppColor.TYPE_PRIMARY.withOpacity(0.04),
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
                                              color: themeColor
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Icon(Icons.arrow_drop_down,color: themeColor, size: 18,)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(top:24, left: 8, right: 8),
                          child: Text(
                            isEnglishLang ? 'Theme' : 'Tema',
                            style: TextStyle(
                                color: themeColor,
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
                            color: isDarkMode
                                ? Color(0xff1F1F1F)
                                : AppColor.WHITE_COLOR,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [

                              SizedBox(height: 24,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      isEnglishLang ? "Auto" : "Auto",
                                      style: TextStyle(
                                          fontSize: TextSize.headerText,
                                          fontWeight: FontWeight.w700,
                                          color: themeColor
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        var brightness = MediaQuery.of(context).platformBrightness;
                                        log("Brightness===$brightness");
                                        themeMode = "auto";
                                        isDarkMode = brightness == Brightness.dark;
                                        themeColor = isDarkMode ? AppColor.WHITE_COLOR : AppColor.BLACK_COLOR;
                                      });
                                      PreferenceHelper.setPreferenceData(PreferenceHelper.THEME_MODE, themeMode);

                                      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                                        statusBarColor: isDarkMode ? Colors.black : AppColor.THEME_PRIMARY.withOpacity(0.4),
                                        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
                                      ));
                                    },
                                    child: Image.asset(
                                      themeMode == "auto"
                                      ? "assets/settings/ic_check_box.png"
                                      : "assets/settings/ic_uncheck_box.png",
                                      height: 24,
                                      width: 24,
                                    ),
                                  )
                                ],
                              ),

                              SizedBox(height: 48,),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      isEnglishLang ? "Light" : "Ligero",
                                      style: TextStyle(
                                          fontSize: TextSize.headerText,
                                          fontWeight: FontWeight.w700,
                                          color: themeColor
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: (){
                                      setState(() {
                                        themeMode = "light";
                                        isDarkMode = themeMode == "dark";
                                        themeColor = isDarkMode ? AppColor.WHITE_COLOR : AppColor.BLACK_COLOR;
                                      });
                                      PreferenceHelper.setPreferenceData(PreferenceHelper.THEME_MODE, themeMode);

                                      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                                        statusBarColor: isDarkMode ? Colors.black : AppColor.THEME_PRIMARY.withOpacity(0.4),
                                        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
                                      ));
                                    },
                                    child: Image.asset(
                                      themeMode == "light"
                                          ? "assets/settings/ic_check_box.png"
                                          : "assets/settings/ic_uncheck_box.png",
                                      height: 24,
                                      width: 24,
                                    ),
                                  )
                                ],
                              ),

                              SizedBox(height: 48,),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      isEnglishLang ? "Dark" : "Oscuro",
                                      style: TextStyle(
                                          fontSize: TextSize.headerText,
                                          fontWeight: FontWeight.w700,
                                          color: themeColor
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: (){
                                      setState(() {
                                        themeMode = "dark";
                                        isDarkMode = themeMode == "dark";
                                        themeColor = isDarkMode ? AppColor.WHITE_COLOR : AppColor.BLACK_COLOR;
                                      });
                                      PreferenceHelper.setPreferenceData(PreferenceHelper.THEME_MODE, themeMode);

                                      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                                        statusBarColor: isDarkMode ? Colors.black : AppColor.THEME_PRIMARY.withOpacity(0.4),
                                        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
                                      ));
                                    },
                                    child: Image.asset(
                                      themeMode == "dark"
                                          ? "assets/settings/ic_check_box.png"
                                          : "assets/settings/ic_uncheck_box.png",
                                      height: 24,
                                      width: 24,
                                    ),
                                  )
                                ],
                              ),

                              SizedBox(height: 24,),
                            ],
                          )
                        ),

                        Container(
                          margin: EdgeInsets.only(top:24, left: 8, right: 8),
                          child: Text(
                            isEnglishLang ? 'Display' : 'Mostrar',
                            style: TextStyle(
                                color: themeColor,
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
                            color: isDarkMode
                                ? Color(0xff1F1F1F)
                                : AppColor.WHITE_COLOR,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                isEnglishLang ? 'Date Format' : 'Formato de fecha',
                                style: TextStyle(
                                    color: themeColor,
                                    fontSize: TextSize.headerText,
                                    fontWeight: FontWeight.w700
                                ),
                              ),

                              SizedBox(height: 8,),
                              Text(
                                isEnglishLang ? 'Changes the format for all dates in the app' : 'Cambia el formato de todas las fechas en la aplicación.',
                                style: TextStyle(
                                    color: themeColor,
                                    fontSize: TextSize.bodyText,
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                              SizedBox(height: 16,),
                              Text(
                                '$currentDate',
                                style: TextStyle(
                                    color: themeColor,
                                    fontSize: TextSize.subjectTitle,
                                    fontWeight: FontWeight.w700
                                ),
                              ),

                              SizedBox(height: 24,),

                              GestureDetector(
                                onTap: () {
                                  bottomDatePicker(context);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                  decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? Color(0xff333333)
                                          : AppColor.TYPE_PRIMARY.withOpacity(0.04),
                                      borderRadius: BorderRadius.circular(16)
                                  ),
                                  width: 180,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "$currentDateFormat",
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
                            ],
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(top: 8),
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Color(0xff1F1F1F)
                                : AppColor.WHITE_COLOR,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                isEnglishLang ? 'Time Format' : 'Formato de tiempo',
                                style: TextStyle(
                                    color: themeColor,
                                    fontSize: TextSize.headerText,
                                    fontWeight: FontWeight.w700
                                ),
                              ),

                              SizedBox(height: 8,),
                              Text(
                                isEnglishLang ? 'Changes the format for all times in the app' : 'Cambia el formato para todos los tiempos en la aplicación.',
                                style: TextStyle(
                                    color: themeColor,
                                    fontSize: TextSize.bodyText,
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                              SizedBox(height: 16,),
                              Text(
                                '$currentTime',
                                style: TextStyle(
                                    color: themeColor,
                                    fontSize: TextSize.subjectTitle,
                                    fontWeight: FontWeight.w700
                                ),
                              ),

                              SizedBox(height: 24,),

                              GestureDetector(
                                onTap: (){
                                  bottomTimePicker(context);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                  decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? Color(0xff333333)
                                          : AppColor.TYPE_PRIMARY.withOpacity(0.04),
                                      borderRadius: BorderRadius.circular(16)
                                  ),
                                  width: 200,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "$currentTimeFormat",
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
          ),
          _progressHUD
        ],
      ),
    );
  }

  void showBottomPicker(mapData, type) {
    var date = mapData['initialTime'];
    BottomPicker.time(
      isDarkMode: isDarkMode,
        title:  "",
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

  void bottomDatePicker(context){
    showModalBottomSheet(
        context: context,
        barrierColor: isDarkMode ? Color(0xff000000).withOpacity(0.8) : Color(0xff000000).withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        backgroundColor: isDarkMode ? Color(0xff1f1f1f) : Colors.white,
        isDismissible: true,
        builder: (context){
          return StatefulBuilder(
            builder: (context1, myState){
              return Stack(
                fit: StackFit.expand,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.only(top: 16.0,left: 16, right: 16, bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isEnglishLang ? 'Select Date Format' : 'Seleccionar formato de fecha',
                              style: TextStyle(
                                fontSize: TextSize.headerText,
                                color: themeColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            GestureDetector(
                              onTap: (){
                                Navigator.pop(context);
                              },
                              child: Container(
                                child: Image.asset(
                                  'assets/ic_back_close.png',
                                  height: 32.0,
                                  width: 32.0,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 1, 
                        color: isDarkMode ? AppColor.DIVIDER.withOpacity(0.4) : AppColor.DIVIDER,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 24),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: dateList != null ? dateList.length : 0,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return Container(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          GestureDetector(
                                            onTap: ()async {
                                              // var formDate = getDateTimeFormat(dateList[index]['key']);
                                              // setState(() {
                                              //   currentDate = formDate;
                                              //   currentDateFormat = dateList[index]['value'];
                                              // });
                                              if(await HelperClass.internetConnectivity()) {
                                                updateDisplayPreferences('date', index);
                                              } else {
                                                HelperClass.openSnackBar(context);
                                              }
                                              Navigator.pop(context);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(vertical: 6),
                                              child: Text(
                                                dateList[index]['value'],
                                                style: TextStyle(
                                                  fontSize: TextSize.subjectTitle,
                                                  color: themeColor,
                                                  fontWeight: FontWeight.w600
                                                ),
                                              ),
                                            ),
                                          ),
                                          Divider(height: 1, thickness: 1, color: isDarkMode ? AppColor.DIVIDER.withOpacity(0.4) : AppColor.DIVIDER,)
                                        ],
                                      ),
                                    );
                                  },
                                ),

                                SizedBox(
                                  height: 12.0,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 0,)
                    ],
                  ),
                  // Positioned(
                  //   bottom: 0,
                  //   left: 0,
                  //   right: 0,
                  //   child: Container(
                  //     alignment: Alignment.center,
                  //     child: GestureDetector(
                  //       onTap: (){
                  //         Navigator.pop(context);
                  //       },
                  //       child: Container(
                  //         margin: EdgeInsets.only(top: 32, bottom: 16),
                  //         alignment: Alignment.center,
                  //         height: 64,
                  //         width: 110,
                  //         // padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  //         decoration: BoxDecoration(
                  //             color: themeColor,
                  //             borderRadius: BorderRadius.circular(32)
                  //         ),
                  //         child: Text(
                  //           'Cancel',
                  //           style: TextStyle(
                  //             fontSize: TextSize.subjectTitle,
                  //             color: AppColor.WHITE_COLOR,
                  //             fontWeight: FontWeight.w700,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              );
            },
          );
        }
    );
  }

  void bottomTimePicker(context){
    showModalBottomSheet(
        context: context,
        barrierColor: isDarkMode ? Color(0xff000000).withOpacity(0.8) : Color(0xff000000).withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        backgroundColor: isDarkMode ? Color(0xff1f1f1f) : Colors.white,
        isDismissible: true,
        builder: (context){
          return StatefulBuilder(
            builder: (context1, myState){
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(top: 16.0,left: 16, right: 16, bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEnglishLang ? 'Select Time Format' : 'Seleccionar formato de hora',
                          style: TextStyle(
                            fontSize: TextSize.headerText,
                            color: themeColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        GestureDetector(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          child: Container(
                            child: Image.asset(
                              'assets/ic_back_close.png',
                              height: 32.0,
                              width: 32.0,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, thickness: 1, color: isDarkMode ? AppColor.DIVIDER.withOpacity(0.4) : AppColor.DIVIDER,),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 24),
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: timeList != null ? timeList.length : 0,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          if(await HelperClass.internetConnectivity()) {
                                            updateDisplayPreferences('time', index);
                                          } else {
                                            HelperClass.openSnackBar(context);
                                          }
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(vertical: 6),
                                          child: Text(
                                            timeList[index]['value'],
                                            style: TextStyle(
                                                fontSize: TextSize.subjectTitle,
                                                color: themeColor,
                                                fontWeight: FontWeight.w600
                                            ),
                                          ),
                                        ),
                                      ),
                                      Divider(height: 1, thickness: 1, color: isDarkMode ? AppColor.DIVIDER.withOpacity(0.4) : AppColor.DIVIDER,),
                                    ],
                                  ),
                                );
                              },
                            ),

                            SizedBox(
                              height: 12.0,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 0,)
                ],
              );
            },
          );
        }
    );
  }

  void bottomLanguagePicker(context){
    showModalBottomSheet(
        context: context,
        barrierColor: isDarkMode ? Color(0xff000000).withOpacity(0.8) : Color(0xff000000).withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        backgroundColor: isDarkMode ? Color(0xff1f1f1f) : Colors.white,
        builder: (context){
          return StatefulBuilder(
            builder: (context1, myState){
              return SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 12.0,),
                      GestureDetector(
                        onTap: (){
                          updateDisplayLanguagePreferences("en");
                          Navigator.pop(context);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                          child: Text(
                            'English',
                            style: TextStyle(
                                fontSize: TextSize.headerText,
                                color: themeColor,
                                fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      Divider(height: 1, thickness: 1, color: isDarkMode ? AppColor.DIVIDER.withOpacity(0.4) : AppColor.DIVIDER,),
                      GestureDetector(
                        onTap: (){
                          updateDisplayLanguagePreferences("es");
                          Navigator.pop(context);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                          child: Text(
                            'Spanish',
                            style: TextStyle(
                                fontSize: TextSize.headerText,
                                color: themeColor,
                                fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      Divider(height: 1, thickness: 1, color: isDarkMode ? AppColor.DIVIDER.withOpacity(0.4) : AppColor.DIVIDER,),
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                          child: Text(
                            isEnglishLang ? 'Cancel' : 'Cancelar',
                            style: TextStyle(
                                fontSize: TextSize.headerText,
                                color: isDarkMode
                                      ? AppColor.WHITE_COLOR.withOpacity(0.6)
                                      : AppColor.TYPE_PRIMARY.withOpacity(0.6),
                                fontWeight: FontWeight.w700,
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

  String getDateTimeFormat(dateTimeFormatter) {
    var formatter = DateFormat('$dateTimeFormatter');
    String formatted = formatter.format(DateTime.now());
    return formatted;
  }

  void updateDisplayPreferences(type, index) async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var requestJson;
    if(type == "time") {
      requestJson = {"TimeFormat": timeList[index]['key']};
    } else if(type == "date"){
      requestJson = {"DateFormat": dateList[index]['key']};
    }
    log("RequestParam====>>>$requestJson");
    var requestParam = json.encode(requestJson);
    var response = await request.patchRequest("auth/me/setPreference", requestParam);
    _progressHUD.state.dismiss();

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage('${response['reason']}');
      } else {
        setState(() {
          var formDate;
          if(type == "time") {
            formDate = getDateTimeFormat(timeList[index]['key']);
            currentTime = formDate;
            currentTimeFormat = timeList[index]['value'];

            PreferenceHelper.setPreferenceData(PreferenceHelper.TIME_FORMAT, "${timeList[index]['key']}");
          } else {
            formDate = getDateTimeFormat(dateList[index]['key']);
            currentDate = formDate;
            currentDateFormat = dateList[index]['value'];

            PreferenceHelper.setPreferenceData(PreferenceHelper.DATE_FORMAT, "${dateList[index]['key']}");
          }
        });
        // CustomToast.showToastMessage('Business hours saved');
        // Navigator.pop(context);
      }
    }
  }

  void updateDisplayLanguagePreferences(lang) async {
    _progressHUD.state.show();
    FocusScope.of(context).requestFocus(FocusNode());
    var requestJson = {"lang": lang};
    log("RequestParam====>>>$requestJson");
    var requestParam = json.encode(requestJson);
    var response = await request.patchRequest("auth/me/setPreference", requestParam);
    _progressHUD.state.dismiss();

    if (response != null) {
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage('${response['reason']}');
      } else {
        PreferenceHelper.setPreferenceData(PreferenceHelper.LANGUAGE, lang);
        setState(() {
          currentLanguage = lang == "en" ? "English" : "Spanish";
          isEnglishLang = lang == "en";
        });
        // CustomToast.showToastMessage('Business hours saved');
        // Navigator.pop(context);
      }
    }
  }
}
