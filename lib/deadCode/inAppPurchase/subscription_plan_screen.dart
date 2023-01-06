// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
//
// // import 'package:dottie_inspector/pages/settings/inAppPurchase/consumable_store.dart';
// import 'package:dottie_inspector/pages/settings/inAppPurchase/consumable_store.dart';
// import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
// import 'package:dottie_inspector/res/color.dart';
// import 'package:dottie_inspector/res/size.dart';
// import 'package:dottie_inspector/utils/app_log.dart';
// import 'package:dottie_inspector/utils/custom_toast.dart';
// import 'package:dottie_inspector/utils/empty_app_bar.dart';
// import 'package:dottie_inspector/utils/globalInstance.dart';
// import 'package:dottie_inspector/utils/helper_class.dart';
// import 'package:dottie_inspector/webServices/AllRequest.dart';
// import 'package:dottie_inspector/widget/GradientText.dart';
// import 'package:dottie_inspector/widget/bottom_general_button_widget.dart';
// import 'package:dottie_inspector/widget/custome_progress_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
//
// import 'package:in_app_purchase_android/billing_client_wrappers.dart';
// import 'package:in_app_purchase_android/in_app_purchase_android.dart';
// import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
// import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
// import 'package:intl/intl.dart';
//
//
// class SubscriptionPlanScreen extends StatefulWidget {
//   const SubscriptionPlanScreen({Key key}) : super(key: key);
//
//   @override
//   _SubscriptionPlanScreenState createState() => _SubscriptionPlanScreenState();
// }
//
// const bool _kAutoConsume = true;
//
// // const String _kConsumableId = 'consumable';
// // const String _kUpgradeId = 'upgrade';
// // const String _kSilverSubscriptionId = 'subscription_silver';
// // const String _kGoldSubscriptionId = 'subscription_gold';
// const String _kMaxId = "Max1";
// const String _kPlusId = "Plus1";
// const String _kMaxIdAndroid = "max1";
// const String _kPlusIdAndroid = "plus1";
// const List<String> _kProductIds = <String>[
//   _kMaxId,
//   _kPlusId
// ];
//
// const List<String> _kAndroidProductIds = <String>[
//   _kMaxIdAndroid,
//   _kPlusIdAndroid
// ];
//
// class _SubscriptionPlanScreenState extends State<SubscriptionPlanScreen> {
//   var elevation = 0.0;
//   final _scrollController = ScrollController();
//
//   AllHttpRequest request = new AllHttpRequest();
//   ProgressHUD _progressHUD;
//   var _loading = false;
//
//   List subscriptionList = [];
//
//   ///
//   /// Subscription Data Type
//   ///
//   ///
//   final InAppPurchase _inAppPurchase = InAppPurchase.instance;
//   StreamSubscription<List<PurchaseDetails>> _subscription;
//   List<String> _notFoundIds = [];
//   List<ProductDetails> _products = [];
//   List<PurchaseDetails> _purchases = [];
//   List<String> _consumables = [];
//   bool _isAvailable = false;
//   bool _purchasePending = false;
//   String _queryProductError;
//
//   String productId = "";
//   String productName = "";
//   String productPrice = "";
//   String productDate = "";
//
//   @override
//   void initState() {
//     _progressHUD = ProgressHUD(
//       backgroundColor: Colors.transparent,
//       color: Colors.white,
//       containerColor: AppColor.LOADER_COLOR,
//       borderRadius: 5.0,
//       loading: _loading,
//       text: 'Loading...',
//     );
//
//     _scrollController.addListener(() {
//       setState(() {
//         if(_scrollController.position.pixels > _scrollController.position.minScrollExtent){
//           elevation = HelperClass.ELEVATION_1;
//         } else {
//           elevation = HelperClass.ELEVATION;
//         }
//       });
//     });
//
//     getPreferenceData();
//
//     // getJsonFile();
//     Timer(Duration(milliseconds: 100), getSubscriptionList);
//     Timer(Duration(milliseconds: 100), (){
//       _progressHUD.state.show();
//     });
//
//     final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
//     _subscription = purchaseUpdated.listen((purchaseDetailsList) {
//       print("PurchaseUpdate====$purchaseDetailsList");
//       _listenToPurchaseUpdated(purchaseDetailsList);
//     }, onDone: () {
//       print("PurchaseUpdate====Done");
//       _subscription.cancel();
//     }, onError: (error) {
//       print("PurchaseUpdate====Error===$error");
//       // handle error here.
//     });
//     initStoreInfo();
//     super.initState();
//   }
//
//   void getPreferenceData() async {
//     var productId = await PreferenceHelper.getPreferenceData(PreferenceHelper.PRODUCT_ID) ?? "";
//     var productTransactionDate = await PreferenceHelper.getPreferenceData(PreferenceHelper.PRODUCT_TRANSACTION_DATE) ?? "";
//     setState(() {
//       this.productId = productId;
//       this.productDate = productTransactionDate;
//     });
//   }
//
//   // @override
//   Widget build1(BuildContext context) {
//     List<Widget> stack = [];
//     if (_queryProductError == null) {
//       stack.add(
//         ListView(
//           children: [
//             _buildConnectionCheckTile(),
//             _buildProductList(),
//             _buildConsumableBox(),
//             _buildRestoreButton(),
//           ],
//         ),
//       );
//     } else {
//       stack.add(Center(
//         child: Text(_queryProductError),
//       ));
//     }
//     if (_purchasePending) {
//       stack.add(
//         Stack(
//           children: [
//             Opacity(
//               opacity: 0.3,
//               child: const ModalBarrier(dismissible: false, color: Colors.grey),
//             ),
//             Center(
//               child: CircularProgressIndicator(),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return Scaffold(
//         backgroundColor: AppColor.PAGE_COLOR,
//         appBar: AppBar(
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back),
//             onPressed: (){
//               Navigator.pop(context);
//             },
//           ),
//         ),
//       body: Stack(
//         children: stack,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColor.PAGE_COLOR,
//       appBar: EmptyAppBar(),
//       body: Stack(
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               buildAppBar(),
//
//               _queryProductError == null
//                 ? buildSingleChildScrollView()
//                 : Center(
//                 child: Text(_queryProductError),
//               )
//             ],
//           ),
//           _progressHUD
//         ],
//       ),
//     );
//   }
//
//   Widget buildSingleChildScrollView() {
//     Map<String, PurchaseDetails> purchases =
//     Map.fromEntries(_purchases.map((PurchaseDetails purchase) {
//       if (purchase.pendingCompletePurchase) {
//         _inAppPurchase.completePurchase(purchase);
//       }
//       return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
//     }));
//     return Expanded(
//               child: SingleChildScrollView(
//                 controller: _scrollController,
//                 child: Container(
//                   margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       SizedBox(height: 6,),
//
//                       Container(
//                         margin: EdgeInsets.symmetric(horizontal: 0),
//                         child: Text(
//                           'Upgrade',
//                           style: TextStyle(
//                               color: AppColor.BLACK_COLOR,
//                               fontSize: TextSize.greetingTitleText,
//                               fontWeight: FontWeight.w700
//                           ),
//                         ),
//                       ),
//
//                       SizedBox(height: 16,),
//
//                       Container(
//                         child: ListView.builder(
//                           itemCount: subscriptionList.length,
//                           shrinkWrap: true,
//                           physics: NeverScrollableScrollPhysics(),
//                           itemBuilder: (context, index) {
//                             String productId1;
//                             if(Platform.isIOS) {
//                               productId1 = subscriptionList[index]['codes']['Apple'];
//                             } else {
//                               productId1 = subscriptionList[index]['codes']['Google'];
//                             }
//                             String productUpdateButton = "Subscribe";
//                             if(productId == ""){
//                               productUpdateButton = "Subscribe";
//                             } else if(productId == productId1) {
//                               productUpdateButton = "Active";
//                             } else if((productId1 == _kPlusId || productId1 == _kPlusIdAndroid) && (productName != subscriptionList[index]['txt']['en']['productname'])) {
//                               productUpdateButton = "Downgrade";
//                             } else if((productId1 == _kMaxId || productId1 == _kMaxIdAndroid) && (productName != subscriptionList[index]['txt']['en']['productname'])) {
//                               productUpdateButton = "Upgrade";
//                             } else {
//                               productUpdateButton = "Subscribe";
//                             }
//                             return Stack(
//                               children: [
//
//                                 Container(
//                                   margin: EdgeInsets.only(bottom: 16),
//                                   // decoration: BoxDecoration(
//                                   //   image: DecorationImage(
//                                   //     image: AssetImage(
//                                   //       index == 1
//                                   //           ? 'assets/subscription/ic_background1.png'
//                                   //           : 'assets/subscription/ic_background2.png',
//                                   //     ),
//                                   //     fit: BoxFit.fill
//                                   //   )
//                                   // ),
//                                   child: Stack(
//                                     children: [
//                                       Positioned.fill(
//                                         child: Container(
//                                           decoration: BoxDecoration(
//                                               borderRadius: BorderRadius.circular(32)
//                                           ),
//                                           child: ClipRRect(
//                                             borderRadius: BorderRadius.circular(32),
//                                             child: Image.asset(
//                                               index == 1
//                                                   ? 'assets/subscription/ic_background1.png'
//                                                   : 'assets/subscription/ic_background2.png',
//                                               fit: BoxFit.cover,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//
//                                       Positioned.fill(
//                                         child: Container(
//                                           decoration: BoxDecoration(
//                                               borderRadius: BorderRadius.circular(32)
//                                           ),
//                                           child: ClipRRect(
//                                             borderRadius: BorderRadius.circular(32),
//                                             child: Image.asset(
//                                               index == 1
//                                                   ? 'assets/subscription/ic_patter_1.png'
//                                                   : 'assets/subscription/ic_pattern2.png',
//                                               fit: BoxFit.cover,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//
//                                       Container(
//                                         padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           mainAxisAlignment: MainAxisAlignment.start,
//                                           children: [
//                                             Container(
//                                               margin: EdgeInsets.only(bottom: 16),
//                                               child: Image.network(
//                                                 "https://inspectordottie.com/images/inspector-dottie-mark.png",
//                                                 fit: BoxFit.cover,
//                                                 width: 80,
//                                                 height: 80,
//                                                 loadingBuilder: (context, child, loadingProgress){
//                                                   if(loadingProgress == null) {
//                                                     return child;
//                                                   } else {
//                                                     return Container(
//                                                       height: 80,
//                                                       color: AppColor.WHITE_COLOR,
//                                                       child: Center(
//                                                         child: CircularProgressIndicator(
//                                                           value: loadingProgress.expectedTotalBytes != null ?
//                                                           loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
//                                                               : null,
//                                                         ),
//                                                       ),
//                                                     );
//                                                   }
//                                                 },
//                                               ),
//                                             ),
//
//                                             Row(
//                                               crossAxisAlignment: CrossAxisAlignment.center,
//                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                               children: [
//                                                 Text(
//                                                   subscriptionList[index]['txt']['en']['productname'],
//                                                   style: TextStyle(
//                                                     fontWeight: FontWeight.w700,
//                                                     color: AppColor.WHITE_COLOR,
//                                                     fontSize: TextSize.greetingTitleText
//                                                   ),
//                                                 ),
//
//                                                 productId != null && productId != "" && productId == productId1
//                                                 ? Image.asset(
//                                                   "assets/subscription/ic_subscription_done.png",
//                                                   height: 48,
//                                                   width: 48,
//                                                   fit: BoxFit.contain,
//                                                 )
//                                                 : Text.rich(
//                                                   TextSpan(
//                                                     text: "\$${subscriptionList[index]['price']}",
//                                                     style: TextStyle(
//                                                         fontWeight: FontWeight.w800,
//                                                         color: AppColor.WHITE_COLOR,
//                                                         fontSize: TextSize.greetingTitleText
//                                                     ),
//                                                     children: [
//                                                       TextSpan(
//                                                         text: "/${subscriptionList[index]['txt']['en']['period']}",
//                                                         style: TextStyle(
//                                                             fontWeight: FontWeight.w600,
//                                                             color: AppColor.WHITE_COLOR,
//                                                             fontSize: 24
//                                                         ),
//                                                       )
//                                                     ]
//                                                   )
//                                                 ),
//                                               ],
//                                             ),
//
//                                             SizedBox(height: 32,),
//
//                                             productId != null && productId != "" && productId == productId1
//                                             ? Container(
//                                               margin: EdgeInsets.only(bottom: 16),
//                                               child: Text.rich(
//                                                   TextSpan(
//                                                       text: "Your plan will ",
//                                                       style: TextStyle(
//                                                           fontWeight: FontWeight.w500,
//                                                           color: AppColor.WHITE_COLOR,
//                                                           fontSize: TextSize.headerText
//                                                       ),
//                                                       children: [
//                                                         TextSpan(
//                                                           text: "Renew on $productDate",
//                                                           style: TextStyle(
//                                                               fontWeight: FontWeight.w700,
//                                                               color: AppColor.WHITE_COLOR,
//                                                               fontSize: TextSize.headerText
//                                                           ),
//                                                         ),
//                                                         TextSpan(
//                                                           text: ", unless canceled 24 hours beforehand.",
//                                                           style: TextStyle(
//                                                               fontWeight: FontWeight.w500,
//                                                               color: AppColor.WHITE_COLOR,
//                                                               fontSize: TextSize.headerText
//                                                           ),
//                                                         )
//                                                       ]
//                                                   )
//                                               ),
//                                             )
//                                             : ListView.builder(
//                                               itemCount: subscriptionList[index]['features'] != null ? subscriptionList[index]['features'].length : 0,
//                                               shrinkWrap: true,
//                                               physics: NeverScrollableScrollPhysics(),
//                                               itemBuilder: (context, subIndex) {
//                                                 return getSubscriptionSubList(subscriptionList[index]['features'][subIndex]);
//                                               },
//                                             ),
//
//                                             Container(
//                                               child: InkWell(
//                                                 onTap: () async {
//                                                   if(productUpdateButton == "Active") {
//                                                     print("This product is already purchased");
//                                                   } else {
//
//                                                     print("_purchases===$_purchases");
//                                                     // Map<String, PurchaseDetails> purchases =
//                                                     // Map.fromEntries(_purchases.map((PurchaseDetails purchase) {
//                                                     //   if (purchase.pendingCompletePurchase) {
//                                                     //     _inAppPurchase.completePurchase(purchase);
//                                                     //   }
//                                                     //   return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
//                                                     // }));
//
//                                                     PurchaseParam purchaseParam;
//                                                     ProductDetails productDetails;
//
//                                                     for(int i=0; i<_products.length; i++) {
//                                                       if(productId1 == "${_products[i].id}"){
//                                                         productDetails = _products[i];
//                                                       }
//                                                     }
//
//                                                     // previousPurchase.verificationData.localVerificationData;
//                                                     if (Platform.isAndroid) {
//                                                       // NOTE: If you are making a subscription purchase/upgrade/downgrade, we recommend you to
//                                                       // verify the latest status of you your subscription by using server side receipt validation
//                                                       // and update the UI accordingly. The subscription purchase status shown
//                                                       // inside the app may not be accurate.
//                                                       final oldSubscription = _getOldSubscription(productDetails, purchases);
//
//                                                       purchaseParam = GooglePlayPurchaseParam(
//                                                           productDetails: productDetails,
//                                                           applicationUserName: null,
//                                                           changeSubscriptionParam: (oldSubscription != null)
//                                                               ? ChangeSubscriptionParam(
//                                                             oldPurchaseDetails: oldSubscription,
//                                                             prorationMode: ProrationMode.immediateWithTimeProration,
//                                                           )
//                                                               : null
//                                                       );
//                                                     } else {
//                                                       purchaseParam = PurchaseParam(
//                                                         productDetails: productDetails,
//                                                         applicationUserName: null,
//                                                       );
//                                                     }
//
//                                                     if(Platform.isIOS) {
//                                                       var transactions = await SKPaymentQueueWrapper().transactions();
//                                                       transactions.forEach((skPaymentTransactionWrapper) {
//                                                         SKPaymentQueueWrapper().finishTransaction(skPaymentTransactionWrapper);
//                                                       });
//                                                     }
//                                                     // print("Purchase  Button Clicked====${purcharseParam.productDetails.id}");
//                                                     print("Purchase Param === $purchaseParam");
//                                                     _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
//                                                     // for(int i=0; i < _purchases.length; i++) {
//                                                     //   print("Purchase Item $i=== ${_purchases[i]} && ProductId====${productDetails.id}");
//                                                     //   if(productDetails.id == _purchases[i].productID) {
//                                                     //     // bool valid = await sendSubscriptionReceiptData(_purchases[i].verificationData.localVerificationData);
//                                                     //
//                                                     //     if(valid) {
//                                                     //
//                                                     //     }
//                                                     //     return;
//                                                     //   }
//                                                     // }
//
//                                                     // if (productDetails.id == _kMaxId) {
//                                                     //   _inAppPurchase.buyConsumable(
//                                                     //       purchaseParam: purchaseParam,
//                                                     //       autoConsume: _kAutoConsume || Platform.isIOS);
//                                                     // } else {
//                                                     //   _inAppPurchase.buyNonConsumable(
//                                                     //       purchaseParam: purchaseParam);
//                                                     // }
//                                                   }
//                                                 },
//                                                 child: Container(
//                                                   height: 56.0,
//                                                   decoration: BoxDecoration(
//                                                       color: AppColor.BLACK_COLOR,
//                                                       borderRadius: BorderRadius.all(Radius.circular(32.0))
//                                                   ),
//                                                   child: Center(
//                                                     child: Text(
//                                                       productUpdateButton,
//                                                       textAlign: TextAlign.center,
//                                                       style: TextStyle(
//                                                         color: AppColor.WHITE_COLOR,
//                                                         fontSize: TextSize.subjectTitle,
//                                                         fontWeight: FontWeight.bold,
//                                                         fontStyle: FontStyle.normal,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//
//                                             Container(
//                                               margin: EdgeInsets.only(top: 8),
//                                               child: Text(
//                                                 '${subscriptionList[index]['txt']['en']['epilogue']}',
//                                                 style: TextStyle(
//                                                     fontWeight: FontWeight.w600,
//                                                     color: AppColor.WHITE_COLOR,
//                                                     fontSize: TextSize.bodyText
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             );
//                           },
//                         ),
//                       ),
//
//                       Container(
//                         margin: EdgeInsets.symmetric(horizontal: 0),
//                         child: Text(
//                           'Payment will be charged to your Apple ID account at the confirmation of purchase. The subscription automatically renews unless it is cancelled at least 24 hours before the end of the current period.',
//                           style: TextStyle(
//                               color: AppColor.BLACK_COLOR,
//                               fontSize: TextSize.subjectTitle,
//                               fontWeight: FontWeight.w600,
//                               height: 1.5
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//
//                       Container(
//                         margin: EdgeInsets.only(top: 16),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             GestureDetector(
//                               onTap: (){
//                                 HelperClass.launchURL("https://dev.inspectordottie.com/Terms-of-Service");
//                               },
//                               child: GradientText(
//                                 'Terms of Service',
//                                 style: TextStyle(
//                                   fontSize: TextSize.subjectTitle,
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                                 gradient: LinearGradient(
//                                     colors: [
//                                       Color(0xff013399),
//                                       Color(0xffBC96E6)
//                                     ]
//                                 ),
//                               ),
//                             ),
//                             SizedBox(width: 16,),
//                             GestureDetector(
//                               onTap: (){
//                                 HelperClass.launchURL("https://dev.inspectordottie.com/Privacy-Policy");
//                               },
//                               child: GradientText(
//                                 'Privacy Policy',
//                                 style: TextStyle(
//                                   fontSize: TextSize.subjectTitle,
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                                 gradient: LinearGradient(
//                                     colors: [
//                                       Color(0xff013399),
//                                       Color(0xffBC96E6)
//                                     ]
//                                 ),
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//
//                       SizedBox(height: 120,)
//                     ],
//                   ),
//                 ),
//               ),
//             );
//   }
//
//   Widget buildAppBar() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         Container(
//                   margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       InkWell(
//                         onTap: () {
//                           Navigator.pop(context);
//                         },
//                         child: Container(
//                           child: Image.asset(
//                             'assets/ic_close_button.png',
//                             fit: BoxFit.cover,
//                             width: 48,
//                             height: 48,
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: Visibility(
//                           visible: elevation != 0,
//                           child: Container(
//                             alignment: Alignment.center,
//                             child: Text(
//                               'Subscription',
//                               style: TextStyle(
//                                   color: AppColor.BLACK_COLOR,
//                                   fontSize: TextSize.headerText,
//                                   fontWeight: FontWeight.w600
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       InkWell(
//                         onTap: (){
//                           _inAppPurchase.restorePurchases();
//                         },
//                         child: Container(
//                           alignment: Alignment.center,
//                           width: 100,
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               colors: [
//                                 Color(0xff013399),
//                                 Color(0xffBC96E6)
//                               ],
//                             ),
//                             borderRadius: BorderRadius.circular(32)
//                           ),
//                           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                           child: Text(
//                             'Restore',
//                             style: TextStyle(
//                               fontSize: TextSize.subjectTitle,
//                               fontWeight: FontWeight.w600,
//                               color: AppColor.WHITE_COLOR
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//         Visibility(
//             visible: elevation != 0,
//             child: Divider(
//               height: 0.5,
//               thickness: 1,
//               color: AppColor.DIVIDER,
//             )
//         ),
//       ],
//     );
//   }
//
//   Future<void> initStoreInfo() async {
//     final bool isAvailable = await _inAppPurchase.isAvailable();
//     print("initStoreInfo=IsAvailable====$isAvailable");
//     if (!isAvailable) {
//       log("initStoreInfo=IsAvailable====$isAvailable");
//       setState(() {
//         _isAvailable = isAvailable;
//         _products = [];
//         _purchases = [];
//         _notFoundIds = [];
//         _consumables = [];
//         _purchasePending = false;
//         _loading = false;
//         _progressHUD.state.dismiss();
//       });
//       return;
//     }
//
//     if (Platform.isIOS) {
//       var iosPlatformAddition = _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
//       await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
//     }
//     ProductDetailsResponse productDetailResponse;
//
//     if(Platform.isIOS) {
//       productDetailResponse = await _inAppPurchase.queryProductDetails(_kProductIds.toSet());
//     } else {
//       productDetailResponse = await _inAppPurchase.queryProductDetails(_kAndroidProductIds.toSet());
//     }
//     print("+++++++++++++++++++++++");
//     print('Error --> ${productDetailResponse.error.toString()}');
//     print('Product Detail Response--> ${productDetailResponse.toString()}');
//     print('Not Found Ids--> ${productDetailResponse.notFoundIDs}');
//     print('Product Details--> ${productDetailResponse.productDetails}');
//     print('Product Details Length--> ${productDetailResponse.productDetails.length}');
//     print("+++++++++++++++++++++++");
//     if (productDetailResponse.error != null) {
//       setState(() {
//         _queryProductError = productDetailResponse.error.message;
//         _isAvailable = isAvailable;
//         _products = productDetailResponse.productDetails;
//         _purchases = [];
//         _notFoundIds = productDetailResponse.notFoundIDs;
//         _consumables = [];
//         _purchasePending = false;
//         _loading = false;
//         _progressHUD.state.dismiss();
//       });
//       return;
//     }
//     print('value is--> ${productDetailResponse.productDetails.isEmpty}');
//     if (productDetailResponse.productDetails.isNotEmpty) {
//       print('value is--> ${productDetailResponse.productDetails.length}');
//       setState(() {
//         _queryProductError = null;
//         _isAvailable = isAvailable;
//         _products = productDetailResponse.productDetails;
//         _purchases = [];
//         _notFoundIds = productDetailResponse.notFoundIDs;
//         _consumables = [];
//         _progressHUD.state.dismiss();
//         _purchasePending = false;
//         _loading = false;
//       });
//       return;
//     }
//
//     List<String> consumables = await ConsumableStore.load();
//     print("initStoreInfo=consumables====$consumables");
//     setState(() {
//       _isAvailable = isAvailable;
//       _products = productDetailResponse.productDetails;
//       _notFoundIds = productDetailResponse.notFoundIDs;
//       _consumables = consumables;
//       _purchasePending = false;
//       _loading = false;
//       _progressHUD.state.dismiss();
//     });
//   }
//
//   void handleError(IAPError error) {
//     setState(() {
//       _purchasePending = false;
//       _progressHUD.state.dismiss();
//     });
//   }
//
//   Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
//     // IMPORTANT!! Always verify a purchase before delivering the product.
//     // For the purpose of an example, we directly return true.
//
//     String transactionDateString = purchaseDetails.transactionDate;
//     print("TransactionDate===$transactionDateString");
//     DateTime transactionDate = DateTime.fromMillisecondsSinceEpoch(int.parse(transactionDateString));
//     DateTime renewDateTime = DateTime(transactionDate.year, transactionDate.month+1, transactionDate.day);
//     String renewDate = DateFormat('M/d/yyyy').format(renewDateTime);
//     print("Date====$renewDate");
//     for(int i=0; i<_products.length; i++) {
//       if(purchaseDetails.productID == "${_products[i].id}"){
//         setState(() {
//           productId = "${_products[i].id}";
//           productName = "${_products[i].title}";
//           productPrice = "${_products[i].price}";
//           productDate = "$renewDate";
//         });
//       }
//     }
//
//     PreferenceHelper.setPreferenceData(PreferenceHelper.PRODUCT_ID, productId);
//     PreferenceHelper.setPreferenceData(PreferenceHelper.PRODUCT_NAME, productName ?? "");
//     PreferenceHelper.setPreferenceData(PreferenceHelper.PRODUCT_PRICE, productPrice ?? "");
//     PreferenceHelper.setPreferenceData(PreferenceHelper.PRODUCT_TRANSACTION_DATE, "$renewDate");
//
//     await sendSubscriptionReceiptData(
//         serverVerificationData: purchaseDetails.verificationData.serverVerificationData,
//         localVerificationData: purchaseDetails.verificationData.localVerificationData
//     );
//     return Future<bool>.value(true);
//   }
//
//   void printWrapped(String text) {
//     final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
//     pattern.allMatches(text).forEach((match) => print(match.group(0)));
//   }
//
//   void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
//     // handle invalid purchase here if  _verifyPurchase` failed.
//   }
//
//   void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
//     purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
//       if (purchaseDetails.status == PurchaseStatus.pending) {
//         _progressHUD.state.show();
//       } else {
//         if (purchaseDetails.status == PurchaseStatus.error) {
//           handleError(purchaseDetails.error);
//         } else if (purchaseDetails.status == PurchaseStatus.purchased ||
//             purchaseDetails.status == PurchaseStatus.restored) {
//           bool valid = await _verifyPurchase(purchaseDetails);
//           if (valid) {
//             deliverProduct(purchaseDetails);
//           } else {
//             _handleInvalidPurchase(purchaseDetails);
//             return;
//           }
//         }
//
//         if (purchaseDetails.pendingCompletePurchase) {
//           await _inAppPurchase.completePurchase(purchaseDetails);
//         }
//       }
//     });
//   }
//
//   Future<void> confirmPriceChange(BuildContext context) async {
//     if (Platform.isAndroid) {
//       final InAppPurchaseAndroidPlatformAddition androidAddition =
//       _inAppPurchase
//           .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
//       var priceChangeConfirmationResult =
//       await androidAddition.launchPriceChangeConfirmationFlow(
//         sku: 'purchaseId',
//       );
//       if (priceChangeConfirmationResult.responseCode == BillingResponse.ok) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text('Price change accepted'),
//         ));
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text(
//             priceChangeConfirmationResult.debugMessage ??
//                 "Price change failed with code ${priceChangeConfirmationResult.responseCode}",
//           ),
//         ));
//       }
//     }
//     if (Platform.isIOS) {
//       var iapStoreKitPlatformAddition = _inAppPurchase
//           .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
//       await iapStoreKitPlatformAddition.showPriceConsentIfNeeded();
//     }
//   }
//
//   Future<void> consume(String id) async {
//     await ConsumableStore.consume(id);
//     final List<String> consumables = await ConsumableStore.load();
//     setState(() {
//       _consumables = consumables;
//     });
//   }
//
//   void showPendingUI() {
//     setState(() {
//       _purchasePending = true;
//     });
//   }
//
//   void deliverProduct(PurchaseDetails purchaseDetails) async {
//     // IMPORTANT!! Always verify purchase details before delivering the product.
//     /*if (purchaseDetails.productID == _kMaxId) {
//       await ConsumableStore.save(purchaseDetails.purchaseID);
//       List<String> consumables = await ConsumableStore.load();
//       setState(() {
//         _purchasePending = false;
//         _consumables = consumables;
//       });
//     } else {
//       setState(() {
//         _purchases.add(purchaseDetails);
//         _purchasePending = false;
//       });
//     }*/
//     setState(() {
//       _purchases.add(purchaseDetails);
//       _progressHUD.state.dismiss();
//
//       print("Purchase Item===$_purchases");
//       // _purchasePending = false;
//     });
//   }
//
//   void getJsonFile() async {
//     String data = await DefaultAssetBundle.of(context).loadString("assets/subscription_list.json");
//
//     setState(() {
//       var jsonResult = json.decode(data);
//       subscriptionList = jsonResult;
//     });
//     print("subscriptionList====$subscriptionList");
//   }
//
//   @override
//   void dispose() {
//     if (Platform.isIOS) {
//       var iosPlatformAddition = _inAppPurchase
//           .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
//       iosPlatformAddition.setDelegate(null);
//     }
//     _subscription.cancel();
//     super.dispose();
//   }
//
//   Card _buildConnectionCheckTile() {
//     if (_loading) {
//       return Card(child: ListTile(title: const Text('Trying to connect...')));
//     }
//     final Widget storeHeader = ListTile(
//       leading: Icon(_isAvailable ? Icons.check : Icons.block,
//           color: _isAvailable ? Colors.green : ThemeData.light().errorColor),
//       title: Text(
//           'The store is ' + (_isAvailable ? 'available' : 'unavailable') + '.'),
//     );
//     final List<Widget> children = <Widget>[storeHeader];
//
//     if (!_isAvailable) {
//       children.addAll([
//         Divider(),
//         ListTile(
//           title: Text('Not connected',
//               style: TextStyle(color: ThemeData.light().errorColor)),
//           subtitle: const Text(
//               'Unable to connect to the payments processor. Has this app been configured correctly? See the example README for instructions.'),
//         ),
//       ]);
//     }
//     return Card(child: Column(children: children));
//   }
//
//   Card _buildProductList() {
//     if (_loading) {
//       return Card(
//           child: (ListTile(
//               leading: CircularProgressIndicator(),
//               title: Text('Fetching products...'))));
//     }
//     if (!_isAvailable) {
//       return Card();
//     }
//     final ListTile productHeader = ListTile(title: Text('Products for Sale'));
//     List<ListTile> productList = <ListTile>[];
//     if (_notFoundIds.isNotEmpty) {
//       productList.add(ListTile(
//           title: Text('[${_notFoundIds.join(", ")}] not found',
//               style: TextStyle(color: ThemeData.light().errorColor)),
//           subtitle: Text(
//               'This app needs special configuration to run. Please see example/README.md for instructions.')));
//     }
//
//     // This loading previous purchases code is just a demo. Please do not use this as it is.
//     // In your app you should always verify the purchase data using the `verificationData` inside the [PurchaseDetails] object before trusting it.
//     // We recommend that you use your own server to verify the purchase data.
//     Map<String, PurchaseDetails> purchases =
//     Map.fromEntries(_purchases.map((PurchaseDetails purchase) {
//       if (purchase.pendingCompletePurchase) {
//         _inAppPurchase.completePurchase(purchase);
//       }
//       return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
//     }));
//     productList.addAll(_products.map(
//           (ProductDetails productDetails) {
//         PurchaseDetails previousPurchase = purchases[productDetails.id];
//         return ListTile(
//             title: Text(
//               productDetails.title,
//             ),
//             subtitle: Text(
//               productDetails.description,
//             ),
//             trailing: previousPurchase != null
//                 ? IconButton(
//                 onPressed: () => confirmPriceChange(context),
//                 icon: Icon(Icons.upgrade))
//                 : TextButton(
//               child: Text(productDetails.price),
//               style: TextButton.styleFrom(
//                 backgroundColor: Colors.green[800],
//                 primary: Colors.white,
//               ),
//               onPressed: () {
//                 PurchaseParam purchaseParam;
//
//                 // previousPurchase.verificationData.localVerificationData;
//                 if (Platform.isAndroid) {
//                   // NOTE: If you are making a subscription purchase/upgrade/downgrade, we recommend you to
//                   // verify the latest status of you your subscription by using server side receipt validation
//                   // and update the UI accordingly. The subscription purchase status shown
//                   // inside the app may not be accurate.
//                   final oldSubscription = _getOldSubscription(productDetails, purchases);
//
//                   purchaseParam = GooglePlayPurchaseParam(
//                       productDetails: productDetails,
//                       applicationUserName: null,
//                       changeSubscriptionParam: (oldSubscription != null)
//                           ? ChangeSubscriptionParam(
//                         oldPurchaseDetails: oldSubscription,
//                         prorationMode: ProrationMode
//                             .immediateWithTimeProration,
//                       )
//                           : null);
//                 } else {
//                   purchaseParam = PurchaseParam(
//                     productDetails: productDetails,
//                     applicationUserName: null,
//                   );
//                 }
//
//                 print("Purchase  Button Clicked====${purchaseParam.productDetails.id}");
//                 print("Purchase  Button Clicked====${purchaseParam.applicationUserName}");
//
//                 for(int i=0; i < _purchases.length; i++) {
//                   if(productDetails.id == _purchases[i].productID) {
//                     ///TODO: call API for sending data to server
//
//                     return;
//                   }
//                 }
//                 _inAppPurchase.buyNonConsumable(
//                     purchaseParam: purchaseParam);
//
//                 // if (productDetails.id == _kMaxId) {
//                 //   _inAppPurchase.buyConsumable(
//                 //       purchaseParam: purchaseParam,
//                 //       autoConsume: _kAutoConsume || Platform.isIOS);
//                 // } else {
//                 //   _inAppPurchase.buyNonConsumable(
//                 //       purchaseParam: purchaseParam);
//                 // }
//               },
//             ));
//       },
//     ));
//
//     return Card(
//         child:
//         Column(children: <Widget>[productHeader, Divider()] + productList));
//   }
//
//   Card _buildConsumableBox() {
//     if (_loading) {
//       return Card(
//           child: (ListTile(
//               leading: CircularProgressIndicator(),
//               title: Text('Fetching consumables...'))));
//     }
//     if (!_isAvailable || _notFoundIds.contains(_kMaxId)) {
//       return Card();
//     }
//     final ListTile consumableHeader =
//     ListTile(title: Text('Purchased consumables'));
//     final List<Widget> tokens = _consumables.map((String id) {
//       return GridTile(
//         child: IconButton(
//           icon: Icon(
//             Icons.stars,
//             size: 42.0,
//             color: Colors.orange,
//           ),
//           splashColor: Colors.yellowAccent,
//           onPressed: () {
//             // =>
//             //     consume(id)
//           },
//         ),
//       );
//     }).toList();
//     return Card(
//         child: Column(children: <Widget>[
//           consumableHeader,
//           Divider(),
//           GridView.count(
//             crossAxisCount: 5,
//             children: tokens,
//             shrinkWrap: true,
//             padding: EdgeInsets.all(16.0),
//           )
//         ]));
//   }
//
//   Widget _buildRestoreButton() {
//     if (_loading) {
//       return Container();
//     }
//
//     return Padding(
//       padding: const EdgeInsets.all(4.0),
//       child: Row(
//         mainAxisSize: MainAxisSize.max,
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           TextButton(
//             child: Text('Restore purchases'),
//             style: TextButton.styleFrom(
//               backgroundColor: Theme.of(context).primaryColor,
//               primary: Colors.white,
//             ),
//             onPressed: () {
//               print("InAppPurchase Restore button clicked");
//               _inAppPurchase.restorePurchases();
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget getSubscriptionSubList(item) {
//     // log("ImageUrl===${GlobalInstance.apiBaseUrl+item['icon']['path'].toString().substring(1)}");
//     return Container(
//       margin: EdgeInsets.only(bottom: 16.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           Container(
//             margin: EdgeInsets.only(left: 0.0, right: 8),
//             child: SvgPicture.network(
//               GlobalInstance.apiBaseUrl+item['icon']['path'].toString().substring(1),
//               fit: BoxFit.cover,
//               height: 32.0,
//               width: 32.0,
//               placeholderBuilder: (context) {
//                 return Container(
//                   height: 32,
//                   color: AppColor.WHITE_COLOR,
//                   child: Center(
//                     child: CircularProgressIndicator(),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Expanded(
//             child: Text(
//               '${item['txt']['en']['feature']}',
//               style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   color: AppColor.WHITE_COLOR,
//                   fontSize: TextSize.subjectTitle
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   //Company detail
//   void getSubscriptionList() async {
//     _progressHUD.state.show();
//     FocusScope.of(context).requestFocus(FocusNode());
//     var response = await request.getAuthRequest("auth/product");
//     _progressHUD.state.dismiss();
//
//     if (response != null) {
//       setState(() {
//         subscriptionList = response;
//       });
//     }
//   }
//
//   Future sendSubscriptionReceiptData({serverVerificationData, localVerificationData}) async {
//     _progressHUD.state.show();
//     var requestJson = {
//       "serverVerificationData": serverVerificationData,
//       "localVerificationData": localVerificationData
//     };
//     var requestParam = json.encode(requestJson);
//     var response = await request.postRequest("auth/apple/create-subscription", requestParam);
//     _progressHUD.state.dismiss();
//
//     return response != null;
//     // if (response != null) {
//     //   return true;
//     // } else {
//     //   return false;
//     // }
//   }
//
//   GooglePlayPurchaseDetails _getOldSubscription(ProductDetails productDetails, Map<String, PurchaseDetails> purchases) {
//     // This is just to demonstrate a subscription upgrade or downgrade.
//     // This method assumes that you have only 2 subscriptions under a group, 'subscription_silver' & 'subscription_gold'.
//     // The 'subscription_silver' subscription can be upgraded to 'subscription_gold' and
//     // the 'subscription_gold' subscription can be downgraded to 'subscription_silver'.
//     // Please remember to replace the logic of finding the old subscription Id as per your app.
//     // The old subscription is only required on Android since Apple handles this internally
//     // by using the subscription group feature in iTunesConnect.
//     GooglePlayPurchaseDetails oldSubscription = purchases[productDetails.id] as GooglePlayPurchaseDetails;
//     // if (productDetails.id == _kMaxId && purchases[_kMaxId] != null) {
//     //   oldSubscription = purchases[_kMaxId] as GooglePlayPurchaseDetails;
//     // } else if (productDetails.id == _kPlusId && purchases[_kPlusId] != null) {
//     //   oldSubscription = purchases[_kPlusId] as GooglePlayPurchaseDetails;
//     // }
//     return oldSubscription;
//   }
// }
//
//
// /// Example implementation of the
// /// [`SKPaymentQueueDelegate`](https://developer.apple.com/documentation/storekit/skpaymentqueuedelegate?language=objc).
// ///
// /// The payment queue delegate can be implementated to provide information
// /// needed to complete transactions.
// class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
//   @override
//   bool shouldContinueTransaction(SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
//     return true;
//   }
//
//   @override
//   bool shouldShowPriceConsent() {
//     return false;
//   }
// }