// import 'dart:async';
//
// import 'package:dottie_inspector/res/color.dart';
// import 'package:dottie_inspector/res/size.dart';
// // import 'package:dottie_inspector/widget/mapboxLocation/place_search.dart' as placeSearch;
// import 'package:dottie_inspector/deadCode/mapboxLocation/place_search.dart' as placeSearch;
// import 'package:flutter/material.dart';
// import 'package:mapbox_search_flutter/mapbox_search_flutter.dart';
//
// class MapBoxPlaceSearchWidget extends StatefulWidget {
//   MapBoxPlaceSearchWidget({
//     @required this.apiKey,
//     this.onSelected,
//     // this.onSearch,
//     this.searchHint = 'Search',
//     this.language = 'en',
//     this.location,
//     this.limit = 5,
//     this.country,
//     this.context,
//     this.height,
//     this.popOnSelect = false,
//   });
//
//   /// True if there is different search screen and you want to pop screen on select
//   final bool popOnSelect;
//
//   ///To get the height of the page
//   final BuildContext context;
//
//   /// Height of whole search widget
//   final double height;
//
//   /// API Key of the MapBox.
//   final String apiKey;
//
//   /// The callback that is called when one Place is selected by the user.
//   final void Function(MapBoxPlace place) onSelected;
//
//   /// The callback that is called when the user taps on the search icon.
//   // final void Function(MapBoxPlaces place) onSearch;
//
//   /// Language used for the autocompletion.
//   ///
//   /// Check the full list of [supported languages](https://docs.mapbox.com/api/search/#language-coverage) for the MapBox API
//   final String language;
//
//   /// The point around which you wish to retrieve place information.
//   final Location location;
//
//   /// Limits the no of predections it shows
//   final int limit;
//
//   ///Limits the search to the given country
//   ///
//   /// Check the full list of [supported countries](https://docs.mapbox.com/api/search/) for the MapBox API
//   final String country;
//
//   ///Search Hint Localization
//   final String searchHint;
//
//   @override
//   _MapBoxPlaceSearchWidgetState createState() =>
//       _MapBoxPlaceSearchWidgetState();
// }
//
// class _MapBoxPlaceSearchWidgetState extends State<MapBoxPlaceSearchWidget>
//     with SingleTickerProviderStateMixin {
//   TextEditingController _textEditingController = TextEditingController();
//   AnimationController _animationController;
//
//   // SearchContainer height.
//   Animation _containerHeight;
//
//   // Place options opacity.
//   Animation _listOpacity;
//
//   List<MapBoxPlace> _placePredictions = [];
//
//   // MapBoxPlace _selectedPlace;
//
//   Timer _debounceTimer;
//
//   @override
//   void initState() {
//     _animationController =
//         AnimationController(vsync: this, duration: Duration(milliseconds: 500));
//     _containerHeight = Tween<double>(
//         begin: 73,
//         end: widget.height ??
//             MediaQuery.of(widget.context).size.height - 112 ??
//             300)
//         .animate(
//       CurvedAnimation(
//         curve: Interval(0.0, 0.5, curve: Curves.easeInOut),
//         parent: _animationController,
//       ),
//     );
//     _listOpacity = Tween<double>(
//       begin: 0,
//       end: 1,
//     ).animate(
//       CurvedAnimation(
//         curve: Interval(0.5, 1.0, curve: Curves.easeInOut),
//         parent: _animationController,
//       ),
//     );
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _debounceTimer?.cancel();
//     _animationController?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) => Container(
//     padding: EdgeInsets.symmetric(horizontal: 0),
//     width: MediaQuery.of(context).size.width,
//     child: _searchContainer(
//       child: _searchInput(context),
//     ),
//   );
//
//   // Widgets
//   Widget _searchContainer({Widget child}) {
//     return ConstrainedBox(
//       constraints: BoxConstraints(
//         minHeight: 100
//       ),
//       child: Container(
//         height: _containerHeight.value,
//         decoration: _containerDecoration(),
//         padding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
//         alignment: Alignment.center,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: <Widget>[
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 0.0),
//               child: child,
//             ),
//             SizedBox(height: 10),
//             Expanded(
//               child: Container(
//                 child: Opacity(
//                   opacity: _listOpacity.value,
//                   child: ListView(
//                         // addSemanticIndexes: true,
//                         // itemExtent: 10,
//                         children: <Widget>[
//                            for (var places in _placePredictions)
//                               _placeOption(places),
//                         ],
//                     )
//                 ),
//
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Widgets
//   Widget _searchContainer1({Widget child}) {
//     return AnimatedBuilder(
//         animation: _animationController,
//         builder: (context, _) {
//           return Container(
//             height: _containerHeight.value,
//             decoration: _containerDecoration(),
//             padding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
//             alignment: Alignment.center,
//             child: Column(
//               children: <Widget>[
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 0.0),
//                   child: child,
//                 ),
//                 SizedBox(height: 10),
//                 Expanded(
//                   child: Container(
//                     margin: EdgeInsets.only(top: 10),
//                     child: Opacity(
//                       opacity: _listOpacity.value,
//                       child: ListView(
//                         // addSemanticIndexes: true,
//                         // itemExtent: 10,
//                         children: <Widget>[
//                           for (var places in _placePredictions)
//                             _placeOption(places),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         });
//   }
//
//   Widget _searchInput1(BuildContext context) {
//     return Container(
//       child: TextField(
//         decoration: _inputStyle(),
//         controller: _textEditingController,
//         autofocus: true,
//         style: TextStyle(
//           fontSize: TextSize.headerText,
//           color: AppColor.TYPE_PRIMARY,
//           fontWeight: FontWeight.w600,
//         ),
//         onChanged: (value) async {
//           _debounceTimer?.cancel();
//           _debounceTimer = Timer(
//             Duration(milliseconds: 750),
//                 () async {
//               await _autocompletePlace(value);
//               if (mounted) {
//                 setState(() {});
//               }
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _searchInput(BuildContext context) {
//     return Container(
//       height: 72.0,
//       padding: EdgeInsets.symmetric(horizontal: 16.0),
//       margin: EdgeInsets.symmetric(horizontal: 16.0),
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16.0),
//           color: AppColor.LOADER_COLOR.withOpacity(0.08)
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           Image.asset(
//             'assets/welcome/ic_search.png',
//             fit: BoxFit.contain,
//             height: 20.0,
//             width: 20.0,
//             color: AppColor.TYPE_PRIMARY,
//           ),
//           Expanded(
//             child: TextField(
//               decoration: InputDecoration(
//                 fillColor: AppColor.TRANSPARENT,
//                 contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
//                 filled: false,
//                 border: InputBorder.none,
//                 hintStyle: TextStyle(
//                     fontSize: TextSize.subjectTitle,
//                     color: AppColor.TYPE_PRIMARY.withOpacity(0.6)
//                 ),
//               ),
//               controller: _textEditingController,
//               autofocus: true,
//               style: TextStyle(
//                 fontSize: TextSize.headerText,
//                 color: AppColor.TYPE_PRIMARY,
//                 fontWeight: FontWeight.w600,
//               ),
//               onChanged: (value) async {
//                 _debounceTimer?.cancel();
//                 _debounceTimer = Timer(
//                   Duration(milliseconds: 750),
//                       () async {
//                     await _autocompletePlace(value);
//                     if (mounted) {
//                       setState(() {});
//                     }
//                   },
//                 );
//               },
//             ),
//           ),
//           Visibility(
//             visible: _textEditingController.text != '',
//             child: InkWell(
//               onTap: (){
//                 setState(() {
//                   _placePredictions = [];
//                   _textEditingController.text = '';
//                 });
//               },
//               child: Container(
//                 height: 56.0,
//                 alignment: Alignment.center,
//                 padding: EdgeInsets.symmetric(horizontal: 16.0),
//                 decoration: BoxDecoration(
//                     color: AppColor.TYPE_PRIMARY ,
//                     borderRadius: BorderRadius.all(Radius.circular(16.0))
//                 ),
//                 child: Text(
//                   'CLEAR',
//                   textAlign: TextAlign.left,
//                   style: TextStyle(
//                     color: AppColor.WHITE_COLOR,
//                     fontSize: TextSize.headerText,
//                     fontWeight: FontWeight.w600,
//                     fontStyle: FontStyle.normal,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
//
//   Widget _placeOption(MapBoxPlace prediction) {
//     String place = prediction.text;
//     String fullName = prediction.placeName;
//
//     var placeName =  place.length < 45
//         ? "$place"
//         : "${place.replaceRange(45, place.length, "")} ...";
//     var placeSearched = _textEditingController.text;
//
//     print("Place === $placeName");
//
//     return MaterialButton(
//       onPressed: () => _selectPlace(prediction),
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
//         margin: EdgeInsets.only(bottom: 8.0),
//         decoration: BoxDecoration(
//           color: AppColor.WHITE_COLOR,
//           borderRadius: BorderRadius.circular(16.0),
//         ),
//         child: ListTile(
//           leading: Container(
//             padding: EdgeInsets.all(12.0),
//             decoration: BoxDecoration(
//                 color: AppColor.BACKGROUND_COLOR.withOpacity(0.12),
//                 borderRadius: BorderRadius.circular(24)
//             ),
//             child: Image.asset(
//               'assets/ic_location_search.png',
//               width: 24.0,
//               height: 24.0,
//               color: AppColor.THEME_PRIMARY,
//             ),
//           ),
//           title: RichText(
//             maxLines : 1,
//             text: TextSpan(
//               children: <TextSpan>[
//                /* TextSpan(
// //                text: placeName == null ? "" :"${placeName.substring(0, _textEditingController.text.length)}",
//                   text: placeName,
//                   style: TextStyle(
//                     color: AppColor.TYPE_PRIMARY,
//                     fontSize: TextSize.headerText,
//                     fontWeight: FontWeight.w700
//                   ),
//                 ),*/
//                 TextSpan(
// //                text: "${placeName.substring(_textEditingController.text.length)}",
//                   text: '$placeName',
//                   style: TextStyle(
//                       color: AppColor.TYPE_PRIMARY.withOpacity(1.0),
//                       fontSize: TextSize.headerText,
//                       fontWeight: FontWeight.w700
//                   ),
//                 )
//               ]
//             ),
//           ),
// //        title: Text(
// //          place.length < 45
// //              ? "$place"
// //              : "${place.replaceRange(45, place.length, "")} ...",
// //          style: TextStyle(
// //            color: AppColor.TYPE_PRIMARY,
// //            fontSize: TextSize.headerText,
// //            fontWeight: FontWeight.w400
// //          ),
// //          maxLines: 1,
// //        ),
//           subtitle: Text(
//             fullName,
//             overflow: TextOverflow.ellipsis,
//             style:  TextStyle(
//               color: AppColor.TYPE_PRIMARY.withOpacity(0.6),
//               fontSize: TextSize.headerText,
//               fontWeight: FontWeight.w600
//             ),
//             maxLines: 1,
//           ),
//           contentPadding: EdgeInsets.symmetric(
//             horizontal: 0,
//             vertical: 0,
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Styling
//   InputDecoration _inputStyle() {
//     return InputDecoration(
//       filled: true,
//       fillColor: AppColor.THEME_PRIMARY.withOpacity(0.08),
//       hintText: widget.searchHint,
//       enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16.0),
//           borderSide: BorderSide(
//             color: AppColor.THEME_PRIMARY,
//             width: 0,
//           )
//       ),
//       focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16.0),
//           borderSide: BorderSide(
//             color: AppColor.THEME_PRIMARY,
//             width: 0,
//           )
//       ),
//       border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16.0),
//           borderSide: BorderSide(
//             color: AppColor.THEME_PRIMARY,
//             width: 0,
//           )
//       ),
//       hintStyle: TextStyle(
//         fontSize: TextSize.subjectTitle,
//         color: AppColor.TYPE_SECONDARY,
//       ),
// //      contentPadding: EdgeInsets.only(right: 8.0, top: 16.0, bottom: 16.0),
//       prefixIcon: Container(
//         padding: EdgeInsets.only(left: 16.0, right: 8, top: 16.0, bottom: 16.0),
//         child: Image.asset(
//           'assets/ic_search.png',
//           height: 24.0,
//           width: 24.0,
//         ),
//       ),
//       suffix: Visibility(
//         visible: _textEditingController.text != '',
//         child: InkWell(
//           onTap: (){
//             setState(() {
//               _textEditingController.text = '';
//             });
//           },
//           child: Container(
//             height: 56.0,
//             alignment: Alignment.center,
//             padding: EdgeInsets.symmetric(horizontal: 16.0),
//             decoration: BoxDecoration(
//                 color: AppColor.TYPE_PRIMARY ,
//                 borderRadius: BorderRadius.all(Radius.circular(16.0))
//             ),
//             child: Text(
//               _textEditingController.text.length != 0 ? "CLEAR" : "",
//               style: TextStyle(
//                 fontSize: TextSize.subjectTitle,
//                 fontWeight: FontWeight.w600,
//                 color: AppColor.TYPE_PRIMARY.withOpacity(0.80)
//               ),
//             ),
//           ),
//         ),
//       )
//     );
//   }
//
//   BoxDecoration _containerDecoration() {
//     return BoxDecoration(
//       color: AppColor.TRANSPARENT,
//       borderRadius: BorderRadius.all(Radius.circular(6.0)),
// //      boxShadow: [
// //        BoxShadow(color: Colors.black, blurRadius: 0, spreadRadius: 0)
// //      ],
//     );
//   }
//
//   // Methods
//   Future _autocompletePlace(String input) async {
//     /// Will be called when the input changes. Making callbacks to the Places
//     /// Api and giving the user Place options
//     ///
//     if (input.length > 0) {
//       var placesSearch = placeSearch.PlacesSearch(
//         apiKey: widget.apiKey,
//         country: widget.country,
//       );
//
//       final predictions = await placesSearch.getPlaces(
//         input,
//         location: widget.location,
//       );
//
//       await _animationController.animateTo(0.5);
//
//       setState(() => _placePredictions = predictions);
//
//       await _animationController.forward();
//     } else {
//       await _animationController.animateTo(0.5);
//       setState(() => _placePredictions = []);
//       await _animationController.reverse();
//     }
//   }
//
//   void _selectPlace(MapBoxPlace prediction) async {
//     /// Will be called when a user selects one of the Place options.
//
//    /* // Sets TextField value to be the location selected
//     _textEditingController.value = TextEditingValue(
//       text: prediction.placeName,
//       selection: TextSelection.collapsed(offset: prediction.placeName.length),
//     );
//
//     // Makes animation
//     await _animationController.animateTo(0.5);
//     setState(() {
//       _placePredictions = [];
//       // _selectedPlace = prediction;
//     });
//     _animationController.reverse();*/
//
//     // Calls the `onSelected` callback
//     widget.onSelected(prediction);
//     if (widget.popOnSelect) Navigator.pop(context);
//   }
// }
