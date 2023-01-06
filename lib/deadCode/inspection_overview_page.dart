import 'dart:async';
import 'dart:convert';

import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/SlideRightRoute.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InspectionOverviewPage extends StatefulWidget {
  @override
  _InspectionOverviewPageState createState() => _InspectionOverviewPageState();
}

class _InspectionOverviewPageState extends State<InspectionOverviewPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List questionList;
  List equipmentItemList;
  var jsonResult;
  int mainIndex = 0;

  @override
  void initState() {
    super.initState();

//    getJsonFile();
    Timer(Duration(milliseconds: 10), (){getPreferenceData();});
  }

  Future getPreferenceData() async {
    var preferenceData = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_LIST);

    var inspectionItem = json.decode(preferenceData);
    print("Type===${inspectionItem.runtimeType}");
    var qList = List();
    questionList = List();
    qList = inspectionItem['questions'];
    for(int i=0; i<qList.length; i++){
      if(qList[i].containsKey('vesselname') || qList[i].containsKey('equipmentdescription')
      || qList[i].containsKey('title')){
        setState(() {
          questionList.add(qList[i]);
        });
      }
    }
    print(questionList);
  }

  void getJsonFile() async {
    String data = await DefaultAssetBundle.of(context).loadString("assets/inspection_item_list.json");

    setState(() {
      jsonResult = json.decode(data);
      equipmentItemList = List();
      equipmentItemList = jsonResult['data'];
    });
    print("JsonResult $jsonResult");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColor.PAGE_COLOR,
      appBar: AppBar(
          elevation: 0.0,
          backgroundColor: AppColor.PAGE_COLOR,
          leading: IconButton(
            padding: EdgeInsets.only(left: 16.0, right: 0.0),
            icon: Icon(
              Icons.clear,
              color: AppColor.TYPE_PRIMARY,
              size: 32.0,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              padding: EdgeInsets.only(left: 0.0, right: 20.0),
              icon: Icon(
                Icons.info_outline,
                size: 28.0,
                color: AppColor.TYPE_PRIMARY,
              ),
              onPressed: () {
                bottomSelectNavigation(context);
              },
            ),
          ],
          title: Container(
            alignment: Alignment.center,
            child: Text(
              'Chapters',
              style: TextStyle(
                fontSize: TextSize.headerText,
                color: AppColor.TYPE_PRIMARY,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ),

      body: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(left: 16.0, top: 10.0),
                height: 180.0,
                child: ListView.builder(
                  itemCount: questionList != null ? questionList.length : 0,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index){
                    return InkWell(
                      onTap: (){
                        setState(() {
                          mainIndex = index;
                          print(mainIndex);
                        });
                      },
                      child: Container(
                        height: 180.0,
                        margin: EdgeInsets.only(right: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              height: 72.0,
                              width: 150.0,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
//                                borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0))
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    right: 0.0,
                                    left: 0.0,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0),topRight: Radius.circular(16.0),),
                                      child: Image.asset(
                                        "assets/ic_safety_bg.png",
                                        fit: BoxFit.fill,
                                        height: 90.0,
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Image.asset(
                                      "assets/ic_life_jacket.png",
                                      height: 36.0,
                                      width: 36.0,
                                      color: AppColor.WHITE_COLOR,
                                      fit: BoxFit.cover,
                                    ),
                                  ),

                                  Positioned(
                                    right: 6.0,
                                    top: 8.0,
                                    child: Icon(
                                      Icons.check_circle,
                                      color: AppColor.WHITE_COLOR,
                                      size: 24.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 150.0,
                              height: 75.0,
                              decoration: BoxDecoration(
                                  color: AppColor.WHITE_COLOR,
                                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16.0), bottomRight: Radius.circular(16.0))
                              ),
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
                              child: Text(
                                questionList[index].containsKey("vesselname")
                                    ? '${questionList[index]['vesselname']}'
                                    : questionList[index].containsKey("equipmentdescription")
                                    ? '${questionList[index]['equipmentdescription']}'
                                    : '${questionList[index]['title']}',
                                style: TextStyle(
                                  fontSize: TextSize.subjectTitle,
                                  color: AppColor.TYPE_PRIMARY,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                ),
              ),

              questionList != null
              ? ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 2000.0
                ),
                child: Container(
                  child: ListView.builder(
                    itemCount: questionList[mainIndex]['questions'] != null ? questionList[mainIndex]['questions'].length : 0,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, subIndex){
                      var type = "";
                      if(questionList[mainIndex]['vesseltype'] != null){
                        type = questionList[mainIndex]['vesseltype']['label'];
                      } else if(questionList[mainIndex]['equipmenttype'] != null) {
                        type = questionList[mainIndex]['equipmenttype']['equipmenttype'];
                      } else if(questionList[mainIndex]['title'] != null){
                        type = questionList[mainIndex]['title'];
                      }
                      return getQuestionWidget(
                        questionList[mainIndex]['questions'][subIndex],
                        type
                      );
                    },
                  ),
                ),
              )
              : Container(),
              SizedBox(height: 120.0,)
            ],
          ),
        ),
      ),
    );
  }

  Widget getTitleWidget(title){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 16.0),
      margin: EdgeInsets.only(bottom: 0.0,left: 8.0),
      child: Text(
        '$title',
        style: TextStyle(
            color: AppColor.TYPE_PRIMARY.withOpacity(0.6),
            fontSize: TextSize.headerText,
            fontWeight: FontWeight.w700,
            fontFamily: 'WorkSans'
        ),
      ),
    );
  }

  Widget getQuestionWidget(questionItem, type){
    var title = questionItem['title'];
    bool answered = questionItem['answered'];

    return InkWell(
      onTap: (){
        print(questionItem);
        print(type);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
            color: AppColor.WHITE_COLOR,
            borderRadius: BorderRadius.circular(16)
        ),
        margin: EdgeInsets.only(bottom: 8.0, left: 16.0, right: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                decoration: BoxDecoration(
                  color: answered ? AppColor.THEME_PRIMARY.withOpacity(0.12) : AppColor.TYPE_PRIMARY.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: answered ? AppColor.TRANSPARENT : AppColor.TYPE_PRIMARY.withOpacity(0.6),
                    width: 1.0
                  )
                ),
                height: 48.0,
                width: 48.0,
                child: Icon(
                    Icons.done,
                    size: 24.0,
                    color: answered ? AppColor.THEME_PRIMARY : AppColor.TRANSPARENT,
                )
            ),
            SizedBox(width: 16.0,),
            Expanded(
              child: Text(
                '$title',
                style: TextStyle(
                    color: AppColor.TYPE_PRIMARY,
                    fontSize: TextSize.headerText,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'WorkSans'
                ),
              ),
            ),
            SizedBox(width: 16.0,),
            Icon(Icons.keyboard_arrow_right, size: 24.0, color: AppColor.TYPE_PRIMARY.withOpacity(0.6),)
          ],
        ),
      ),
    );
  }

  void  bottomSelectNavigation(context){
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                  children: [
                    SizedBox(height: 24.0,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 16.0),
                          height: 42.0,
                          width: 42.0,
                          decoration: BoxDecoration(
                              color: AppColor.WHITE_COLOR,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColor.TYPE_SECONDARY,
                                width: 1.0,
                              )
                          ),
                          child: Icon(
                            Icons.done,
                            size: 24.0,
                            color: AppColor.WHITE_COLOR,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
                                child: Text(
                                  'Not Yet Seen',
                                  style: TextStyle(
                                      fontSize: TextSize.headerText,
                                      color: AppColor.TYPE_PRIMARY,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'WorkSans'
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 16.0, right: 16.0),
                                child: Text(
                                  'Questions within this section haven’t been viewed yet',
                                  style: TextStyle(
                                      fontSize: TextSize.subjectTitle,
                                      color: AppColor.TYPE_PRIMARY.withOpacity(0.6),
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'WorkSans'
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.0,),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 16.0),
                          child: CircleAvatar(
                            backgroundColor: AppColor.THEME_PRIMARY.withOpacity(0.15),
                            radius: 24.0,
                            child: Container(
                                padding: EdgeInsets.all(12.0),
                                child: Icon(
                                    Icons.done,
                                    size: 24.0,
                                    color: AppColor.THEME_PRIMARY
                                )
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
                                child: Text(
                                  'Complete',
                                  style: TextStyle(
                                      fontSize: TextSize.headerText,
                                      color: AppColor.TYPE_PRIMARY,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'WorkSans'
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 5.0),
                                child: Text(
                                  'All required questions within this section has been completed',
                                  style: TextStyle(
                                      fontSize: TextSize.subjectTitle,
                                      color: AppColor.TYPE_PRIMARY.withOpacity(0.6),
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'WorkSans'
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.0,),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 16.0),
                          height: 42.0,
                          width: 42.0,
                          decoration: BoxDecoration(
                              color: AppColor.WHITE_COLOR,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColor.TYPE_SECONDARY.withOpacity(0.7),
                                width: 1.0,
                              )
                          ),
                          child: Icon(
                            FontAwesomeIcons.arrowRight,
                            size: 24.0,
                            color: AppColor.TYPE_PRIMARY.withOpacity(0.6),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
                                child: Text(
                                  'Skipped',
                                  style: TextStyle(
                                      fontSize: TextSize.headerText,
                                      color: AppColor.TYPE_PRIMARY,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'WorkSans'
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 5.0),
                                child: Text(
                                  'This section was skipped and questions haven’t been viewed',
                                  style: TextStyle(
                                      fontSize: TextSize.subjectTitle,
                                      color: AppColor.TYPE_PRIMARY.withOpacity(0.6),
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'WorkSans'
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.0,),
                    InkWell(
                      onTap: () {
                        print("Printed");
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 56.0,
                        margin: EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
                        decoration: BoxDecoration(
                            color: AppColor.THEME_PRIMARY,
                            borderRadius: BorderRadius.all(Radius.circular(16.0))),
                        child: Center(
                          child: Text(
                            'GOT IT!',
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
                  ],
                ),
              ),
            );
          },
        );
      }
    );
  }

  void navigateScreen(context, screenName){
    Navigator.pushReplacement(
      context,
      SlideRightRoute(
        page: screenName
      )
    );
  }
}
