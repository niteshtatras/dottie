// import 'package:dottie_inspector/deadCode/mapboxLocation/mapBoxSearchTab.dart';
// import 'package:dottie_inspector/res/color.dart';
// import 'package:dottie_inspector/res/size.dart';
// import 'package:dottie_inspector/utils/helper_class.dart';
// import 'package:flutter/material.dart';
//
// class InspectionLocationSearchPage extends StatefulWidget {
//   @override
//   _InspectionLocationSearchPageState createState() => _InspectionLocationSearchPageState();
// }
//
// class _InspectionLocationSearchPageState extends State<InspectionLocationSearchPage> {
//   final _scaffoldKey = GlobalKey<ScaffoldState>();
//   var elevation = 0.0;
//   final _scrollController = ScrollController();
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _scrollController.addListener(() {
//       setState(() {
//         if(_scrollController.position.pixels > _scrollController.position.minScrollExtent){
//           elevation = HelperClass.ELEVATION_1;
//         } else {
//           elevation = HelperClass.ELEVATION;
//         }
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       backgroundColor: AppColor.PAGE_COLOR,
//       appBar: AppBar(
//         centerTitle: false,
//         elevation: elevation,
//         backgroundColor: AppColor.PAGE_COLOR,
//         /*leading: IconButton(
//           padding: EdgeInsets.only(left: 16.0, right: 16.0),
//           icon: Icon(Icons.arrow_back_ios,color: AppColor.TYPE_PRIMARY,size: 28.0,),
//           onPressed: (){
//             Navigator.pop(context);
//           },
//         ),*/
//         leading: InkWell(
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
//         ),
//         title: Text(
//           'Search for An Address',
//           style: TextStyle(
//               color: AppColor.TYPE_PRIMARY,
//               fontSize: TextSize.headerText,
//               fontWeight: FontWeight.w700
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         controller: _scrollController,
//         child: Container(
//           margin: EdgeInsets.only(top: 8.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               MapBoxPlaceSearchWidget(
//                 popOnSelect: false,
//                 apiKey: "${HelperClass.MAP_ID}",
//                 limit: 10,
//                 country: "us",
//                 searchHint: 'Type address...',
//                 onSelected: (place) {
//                   if(place != null) {
//                     print('Place0====$place');
//                     print('Place1====${place.addressNumber}');
//                     print('Place2====${place.text}');
//                     print('Place3====${place.placeName}');
//                     print('Place4====${place.id}');
//                     print('Place5====${place.geometry}');
//                     print('Place6====${place.matchingPlaceName}');
//                     print('Place7====${place.matchingText}');
//                     print('Place8====${place.properties.address}');
//                     print('Place9====${place.context}');
//
// //                      print('Place====${place.toJson()}');
//                      Navigator.of(context).pop({
//                       "place": place
//                     });
//                   }
//                 },
//                 context: context,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
