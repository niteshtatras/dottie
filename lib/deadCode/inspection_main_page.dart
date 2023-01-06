import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class InspectionMainPage extends StatefulWidget {
  @override
  _InspectionMainPageState createState() => _InspectionMainPageState();
}

class _InspectionMainPageState extends State<InspectionMainPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List investigatingList = List();
  List inspectionItemList = List();

  @override
  void initState() {
    super.initState();

    for(int i=0; i<5; i++){
      inspectionItemList.add("Index ${i+1}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColor.WHITE_COLOR,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: AppColor.WHITE_COLOR,
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
      ),

      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 10.0,),
                Text(
                  'Start: 3 of 3',
                  style: TextStyle(
                    color: AppColor.TYPE_PRIMARY.withOpacity(0.6),
                    fontSize: TextSize.subjectTitle,
                    fontWeight: FontWeight.w500,),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 8.0,
                ),
                Container(
                  alignment: Alignment.center,
                  child: LinearPercentIndicator(
                    animationDuration: 200,
                    backgroundColor: Color(0xFFE5E5E5),
                    percent: 0.45,
                    lineHeight: 8.0,
                    progressColor: AppColor.HEADER_COLOR,
                  ),
                ),
                SizedBox(
                  height: 24.0,
                ),
                //Title
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 36.0),
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.center,
                  child: Text(
                    'Now, let’s take a quick inventory',
                    style: TextStyle(
                        fontSize: TextSize.pageTitleText,
                        color: AppColor.TYPE_PRIMARY,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                //Sub Title
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 36.0),
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.center,
                  child: Text(
                    'Let me know which items you would like to inspect',
                    style: TextStyle(
                        fontSize: TextSize.headerText,
                        color: AppColor.TYPE_PRIMARY,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: 24.0,),
                ListView.builder(
                  itemCount: investigatingList.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index){
                    return GestureDetector(
                      onTap: (){
                        setState(() {
                          inspectionItemList.insert(0, investigatingList[index]);
                          investigatingList.removeAt(index);
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: Text("${investigatingList[index]}"),
                      ),
                    );
                  },
                ),

                SizedBox(height: 48.0,),
                ListView.builder(
                  itemCount: inspectionItemList.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index){
                    return GestureDetector(
                      onTap: (){
                        setState(() {
                          investigatingList.insert(0, inspectionItemList[index]);
                          inspectionItemList.removeAt(index);
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: Text("${inspectionItemList[index]}"),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      )
    );
  }
}
