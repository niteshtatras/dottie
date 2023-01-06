import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dottie_inspector/database/database_helper.dart';
import 'package:dottie_inspector/inspectionPreferences/inspection_preferences.dart';
import 'package:dottie_inspector/pages/backgroundServices/background_services.dart';
import 'package:dottie_inspector/deadCode/inspection_overview_page.dart';
import 'package:dottie_inspector/pages/welcome/welcome_navigation_screen.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/SlideRightRoute.dart';
import 'package:dottie_inspector/utils/inspection_utils.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import 'custom_toast.dart';

class HelperClass {
  static const String INSPECTION_ID = "1";

  static const double ELEVATION = 0.0;
  static const double ELEVATION_1 = 1.0;
  static const List<String> txtfields = ['title','helpertext','reporttag','section'];
  final void Function() onOkButtonClick;

  HelperClass(this.onOkButtonClick);

  static bool isEmailAddressValid(String email) {
    bool emailValid =
        RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
    return emailValid;
  }

  static bool isMobileValid(String mobile) {
    RegExp exp = new RegExp(
      r"^(?:[+0]9)?[0-9]{10}$",
    );
    return exp.hasMatch(mobile.trim());
  }

  static String replaceAll(String string) {
    return string.replaceAll(RegExp(r"\s+\b|\b\s"), "");
    // we trim to remove trailing white spaces
  }

  // Minimum eight characters, at least one letter, one number and one special character:
  static bool validatePassword(String value) {
    return RegExp(
                r"^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&^=+-])[A-Za-z\d@$!%*#?&^=+-]{6,}$")
            .hasMatch(value)
        ? true
        : false;
  }

  static String getTimeFormat(String currentDate) {
    var formatter = DateFormat('d MMM, yyyy');
    String formatted = formatter.format(DateTime.parse(currentDate));
    return formatted;
  }

  static String getFileNameFormat(String currentDate) {
    var formatter = DateFormat('dd_MM_hh_mm_ss');
    String formatted = formatter.format(DateTime.parse(currentDate));
    return formatted;
  }

  static String getTransactionFormat(String currentDate) {
    var formatter = DateFormat('m/d/yyyy');
    String formatted = formatter.format(DateTime.parse(currentDate));
    return formatted;
  }

  static String getTimeWithTimeFormat(String currentDate) {
    var formatter = DateFormat('d MMM yyyy, HH:mm');
    String formatted = formatter.format(DateTime.parse(currentDate));
    return formatted;
  }

  static String getDateWithOutTimeFormat(String currentDate) {
    var formatter = DateFormat('dd MMM yyyy');
    String formatted = formatter.format(DateTime.parse(currentDate));
    return formatted;
  }

  static String getInspectionDateFormat(String currentDate) {
    var formatter = DateFormat('dd-MM-yyyy');
    String formatted = formatter.format(DateTime.parse(currentDate));
    return formatted;
  }

  static String getCompletedDateFormat() {
    return DateTime.now().toUtc().toIso8601String();
  }

  static String getDateWithOutTimeComma(String currentDate) {
    var formatter = DateFormat('d MMM, yyyy');
    String formatted = formatter.format(DateTime.parse(currentDate));
    return formatted;
  }

  static String getTimeFormatDay(String currentDate) {
    var formatter = DateFormat('EEEE, d MMM, yyyy');
    String formatted = formatter.format(DateTime.parse(currentDate));
    return formatted;
  }

  static String formatHHMMSS(int seconds) {
    int hours = (seconds / 3600).truncate();
    seconds = (seconds % 3600).truncate();
    int minutes = (seconds / 60).truncate();

    String hoursStr = (hours).toString().padLeft(2, '0');
    String minutesStr = (minutes).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    if (hours == 0) {
      return "$minutesStr:$secondsStr";
    }

    return "$hoursStr:$minutesStr:$secondsStr";
  }

  static launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  static Widget getNoDataFountText(String msg) {
    return Container(
      margin: EdgeInsets.only(top: 150.0),
      child: Center(
        child: Text(
          msg,
//          style: Styles.noRecordFound,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  static Widget getNoDataFountWidgetWithEqual(String msg) {
    return Container(
      margin: EdgeInsets.only(top: 50.0, bottom: 50.0),
      child: Center(
        child: Text(
          msg,
          style: TextStyle(
            color: AppColor.GREY_COLOR,
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
            height: 1.3,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  static String getUsNumberFormatPrice(String price) {
    RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    Function mathFunc = (Match match) => '${match[1]},';
    String result = price.replaceAllMapped(reg, mathFunc);
    return result;
  }

  static displayDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        content: Text(
          message,
          style: TextStyle(
            color: AppColor.TYPE_PRIMARY,
            fontSize: 16.0,
          ),
        ),
        actions: <Widget>[
          CupertinoDialogAction(
              child: const Text('OK'),
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context, 'Cancel');
              }),
        ],
      ),
      barrierDismissible: true,
    );
  }

  static void displayDrawerDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        content: Text(
          message,
          style: TextStyle(
            color: AppColor.TYPE_PRIMARY,
            fontSize: 16.0,
          ),
        ),
        actions: <Widget>[
          CupertinoDialogAction(
              child: const Text('Cancel'),
              isDefaultAction: true,
              onPressed: () {
//                  return Future.value(true);
                Navigator.pop(context, 'Cancel');
              }),
          CupertinoDialogAction(
              child: const Text('Yes'),
              onPressed: () {
//                  return Future.value(true);
                Navigator.of(context).pop(true);
              }),
        ],
      ),
      barrierDismissible: true,
    );
//    Navigator.of(context).pop(false);
  }

  static showSnackBar1(context, message) {
    return SnackBar(
      content: Text(
        '$message',
        style: TextStyle(
            color: AppColor.WHITE_COLOR,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.normal,
            fontSize: TextSize.bodyText),
      ),
      backgroundColor: AppColor.THEME_PRIMARY,
      duration: Duration(seconds: 2),
    );
  }

  static Widget getMeterScaleWidget(color) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          getMeterWidget(16.0, 2.0, 16.0, color.withOpacity(0.2)),
          getMeterWidget(8.0, 2.0, 24.0, color.withOpacity(0.3)),
          getMeterWidget(8.0, 2.0, 24.0, color.withOpacity(0.4)),
          getMeterWidget(8.0, 2.0, 24.0, color.withOpacity(0.5)),
          getMeterWidget(16.0, 2.0, 16.0, color.withOpacity(0.6)),
          getMeterWidget(8.0, 2.0, 24.0, color.withOpacity(0.7)),
          getMeterWidget(8.0, 2.0, 24.0, color.withOpacity(0.8)),
          getMeterWidget(8.0, 2.0, 24.0, color.withOpacity(0.9)),
          getMeterWidget(32.0, 3.0, 0.0, color.withOpacity(1.0)),
          getMeterWidget(8.0, 2.0, 24.0, color.withOpacity(0.9)),
          getMeterWidget(8.0, 2.0, 24.0, color.withOpacity(0.8)),
          getMeterWidget(8.0, 2.0, 24.0, color.withOpacity(0.7)),
          getMeterWidget(16.0, 2.0, 16.0, color.withOpacity(0.6)),
          getMeterWidget(8.0, 2.0, 24.0, color.withOpacity(0.5)),
          getMeterWidget(8.0, 2.0, 24.0, color.withOpacity(0.4)),
          getMeterWidget(8.0, 2.0, 24.0, color.withOpacity(0.3)),
          getMeterWidget(16.0, 2.0, 16.0, color.withOpacity(0.2)),
        ],
      ),
    );
  }

  static Widget getMeterWidget(height, width, top, color) {
    return Container(
        margin: EdgeInsets.only(right: 8.0, top: top),
        child: Image.asset(
          'assets/ic_line.png',
          width: width,
          height: height,
          fit: BoxFit.cover,
          color: color,
        ));
  }

  static String getEmailLabelText(index) {
    switch (index) {
      case 0:
        return "Personal";

      case 1:
        return "Work";

      default:
        return "Other";
    }
  }

  static int getEmailLabelIndex(tag) {
    switch (tag.toString().toLowerCase()) {
      case "personal":
        return 0;

      case "work":
        return 1;

      case "other":
        return 2;

      default:
        return 2;
    }
  }

  static String getLabelText(index) {
    switch (index) {
      case 0:
        return "Home";

      case 1:
        return "Mobile";

      case 2:
        return "Work";

      case 3:
        return "Primary";

      default:
        return "Other";
    }
  }

  static int getLabelIndex(tag) {
    switch (tag.toString().toLowerCase()) {
      case "home":
        return 0;

      case "mobile":
        return 1;

      case "work":
        return 2;

      case "primary":
        return 3;

      case "other":
        return 4;

      default:
        return 4;
    }
  }

  static void launchChapter(context) {
    Navigator.push(context, SlideRightRoute(page: InspectionOverviewPage()));
  }

  static void gotoNextPage(context, pageName) {
    Navigator.push(context, SlideRightRoute(page: pageName));
  }

  static Future<Map> getInspectionItem(List questionList) async {
    for (int i = 0; i < questionList.length; i++) {
      var type = questionList[i]['type'];

      Map inspectionItemDetail;
      if (type.toString().toLowerCase().startsWith("vessel")) {
        var name = questionList[i]['vesseltype']['label'];
        if (name.toLowerCase().startsWith("pool")) {
          inspectionItemDetail = {
            "type": "pool",
            "id": "${questionList[i]['id']}",
            "index": i,
            "bodyofwaterid": "${questionList[i]['bodyofwaterid']}",
            "name": "${questionList[i]['name']}"
          };
          return inspectionItemDetail;
        } else if (name.toLowerCase().startsWith("spa")) {
          inspectionItemDetail = {
            "type": "spa",
            "id": "${questionList[i]['id']}",
            "index": i,
            "bodyofwaterid": "${questionList[i]['bodyofwaterid']}",
            "name": "${questionList[i]['name']}"
          };
          return inspectionItemDetail;
        } else if (name.toLowerCase().startsWith("water feature")) {
          inspectionItemDetail = {
            "type": "water feature",
            "id": "${questionList[i]['id']}",
            "index": i,
            "bodyofwaterid": "${questionList[i]['bodyofwaterid']}",
            "name": "${questionList[i]['name']}"
          };
          return inspectionItemDetail;
        }
      } else if (type.toString().toLowerCase().startsWith("equipment")) {
        var name = questionList[i]['equipmenttype']['equipmenttype'] ?? '';
        if (name.toLowerCase().startsWith("water pump")) {
          inspectionItemDetail = {
            "type": "water pump",
            "id": "${questionList[i]['id']}",
            "index": i,
            "name": questionList[i]['name'] == ''
                ? name
                : "${questionList[i]['name']}"
          };
          return inspectionItemDetail;
        } else if (name.toLowerCase().startsWith("filter")) {
          inspectionItemDetail = {
            "type": "filter",
            "id": "${questionList[i]['id']}",
            "index": i,
            "name": questionList[i]['name'] == ''
                ? name
                : "${questionList[i]['name']}"
          };
          return inspectionItemDetail;
        } else if (name.toLowerCase().startsWith("lights")) {
          inspectionItemDetail = {
            "type": "lights",
            "id": "${questionList[i]['id']}",
            "index": i,
            "name": questionList[i]['name'] == ''
                ? name
                : "${questionList[i]['name']}"
          };
          return inspectionItemDetail;
        } else if (name.toLowerCase().startsWith("heat pump")) {
          inspectionItemDetail = {
            "type": "heat pump",
            "id": "${questionList[i]['id']}",
            "index": i,
            "name": questionList[i]['name'] == ''
                ? name
                : "${questionList[i]['name']}"
          };
          return inspectionItemDetail;
        } else if (name.toLowerCase().startsWith("gas meter")) {
          inspectionItemDetail = {
            "type": "gas meter",
            "id": "${questionList[i]['id']}",
            "index": i,
            "name": questionList[i]['name'] == ''
                ? name
                : "${questionList[i]['name']}"
          };
          return inspectionItemDetail;
        } else if (name.toLowerCase().startsWith("heater")) {
          inspectionItemDetail = {
            "type": "heater",
            "id": "${questionList[i]['id']}",
            "index": i,
            "name": questionList[i]['name'] == ''
                ? name
                : "${questionList[i]['name']}"
          };
          return inspectionItemDetail;
        } else if (name.toLowerCase().startsWith("automation")) {
          inspectionItemDetail = {
            "type": "automation",
            "id": "${questionList[i]['id']}",
            "index": i,
            "name": questionList[i]['name'] == ''
                ? name
                : "${questionList[i]['name']}"
          };
          return inspectionItemDetail;
        } else if (name.toLowerCase().startsWith("sanitation")) {
          inspectionItemDetail = {
            "type": "sanitation",
            "id": "${questionList[i]['id']}",
            "index": i,
            "name": questionList[i]['name'] == ''
                ? name
                : "${questionList[i]['name']}"
          };
          return inspectionItemDetail;
        } else if (name.toLowerCase().startsWith("covers")) {
          inspectionItemDetail = {
            "type": "automatic",
            "id": "${questionList[i]['id']}",
            "index": i,
            "name": questionList[i]['name'] == ''
                ? name
                : "${questionList[i]['name']}"
          };
          return inspectionItemDetail;
        } else if (name.toLowerCase().startsWith("valves")) {
          inspectionItemDetail = {
            "type": "valves",
            "id": "${questionList[i]['id']}",
            "index": i,
            "name": questionList[i]['name'] == ''
                ? name
                : "${questionList[i]['name']}"
          };
          return inspectionItemDetail;
        } else if (name.toLowerCase().startsWith("fill valve")) {
//          var equipmentDescription = questionList[i]['equipmentdescription'];

          inspectionItemDetail = {
            "type": "fill valve",
            "id": "${questionList[i]['id']}",
            "index": i,
            "name": questionList[i]['name'] == ''
                ? name
                : "${questionList[i]['name']}"
          };
          return inspectionItemDetail;
        }
      } else {
        var name = questionList[i]['name'];
        if (name.toLowerCase().startsWith("body of water")) {
          var vesselName = '';
          if (questionList[i]['vessels'].length > 0) {
            for (int j = 0; j < questionList[i]['vessels'].length; j++) {
              vesselName = vesselName +
                  (vesselName.isEmpty ? "" : " & ") +
                  questionList[i]['vessels'][j]['vesselname'];
            }
          }

          inspectionItemDetail = {
            "type": "body of water",
            "id": "${questionList[i]['id']}",
            "index": i,
            "vesselName": "$vesselName",
            "name": "${questionList[i]['name']}"
          };
          return inspectionItemDetail;
        } else if (name.toLowerCase().startsWith("electrical")) {
          inspectionItemDetail = {
            "type": "electrical",
            "id": "${questionList[i]['id']}",
            "index": i,
            "name": "${questionList[i]['name']}"
          };
          return inspectionItemDetail;
        } else if (name.toLowerCase().startsWith("safety")) {
          inspectionItemDetail = {
            "type": "safety",
            "id": "${questionList[i]['id']}",
            "index": i,
            "name": "${questionList[i]['name']}"
          };
          return inspectionItemDetail;
        } else if (name.toLowerCase().startsWith("maintenance")) {
          inspectionItemDetail = {
            "type": "maintenance",
            "id": "${questionList[i]['id']}",
            "index": i,
            "name": "${questionList[i]['name']}"
          };
          return inspectionItemDetail;
        }
      }
    }
    return null;
  }

  static Future<String> getResizeImage(image) async {
    File imageFile;

    Uint8List m = File(image.path).readAsBytesSync();
    ui.Image x = await decodeImageFromList(m);
    ByteData bytes = await x.toByteData();
    print('height is ${x.height}'); //height of original image
    print('width is ${x.width}'); //width of original image

    print('array is $m');
    print('original image size is ${bytes.lengthInBytes}');

    ui
        .instantiateImageCodec(m, targetHeight: 300, targetWidth: 300)
        .then((codec) {
      codec.getNextFrame().then((frameInfo) async {
        ui.Image i = frameInfo.image;
        print('image width is ${i.width}'); //height of resized image
        print('image height is ${i.height}'); // width of resized

        print('image ${frameInfo.image}'); //width of resized
        /*setState(() {
            isPhotoTaken = true;
            imagePath = frameInfo
          });// image*/
        ByteData bytes = await i.toByteData();
        var img1 =
            await File(image.path).writeAsBytes(bytes.buffer.asUint32List());
        print('resized image size is ${bytes.lengthInBytes}');
        print(img1.path);
        print("END OF IMAGE===>${img1.path}");
        imageFile = img1;
        return img1.path;
      });
    });
    return null;
  }

  static Future<File> writeImageTemp(
      String base64Image, String imageName) async {
    final dir = await getTemporaryDirectory();
    await dir.create(recursive: true);
    final tempFile = File(path.join(dir.path, imageName));
    await tempFile.writeAsBytes(base64.decode(base64Image));
    return tempFile;
  }

  static Future<File> getFile(ByteData data, String fileName) async {
    final buffer = data.buffer;
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    var filePath =
        tempPath + fileName; // file_01.tmp is dump file, can be anything
    return new File(filePath).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  static Future<File> getCompressedImageFile(File image) async {
    File compressedFile;
    int mainImageLength = await image.length();
    print("MainImageLength=====>>>>${await image.length() / (1024 * 1024)}");

    if (mainImageLength > 6291456) {
      compressedFile = await FlutterNativeImage.compressImage(image.path, quality: 30);
    } else if (mainImageLength > 2097152) {
      compressedFile = await FlutterNativeImage.compressImage(image.path, quality: 50);
    } else {
      compressedFile = image;
    }
    print(
        "CompressedImageLength=====>>>>${await compressedFile.length() / (1024 * 1024)}");

    return compressedFile;
  }

  static void getInspectionData(keyName, keyValue, data, Function(Map) onCallback) {
    for(Map item in data) {
      print("DataID===${item['inspectiondefid']}");
      if(item[keyName] == keyValue) {
        print("IF CONDITION");
        onCallback(item);
        return;
//        break;
//        return resultData;
      }
      if(item.containsKey('children')){
        print("Inside===Children");
        getInspectionData(keyName, keyValue, item['children'], onCallback);
      }
    }

    /* for(int i=0; i<data.length; i++) {
       print("I===$i, DataID===${data[i]['inspectiondefid']}");
       if(data[i][keyName] == keyValue) {
         print("IF CONDITION===$i");
         return data[i];
       }

       if(data[i].containsKey('children')){
         print("Inside===$i");
         getInspectionData(keyName, keyValue, data[i]['children']);
       }
     }
*/
    return;
  }

  static Map getMoreInspectionData(keyName, keyValue, data) {
    for(int i=0; i<data.length; i++) {
      if(data[i]['$keyName'] == keyValue) {
        return data[i];
      }

      if(data[i].containsKey('children')){
        getMoreInspectionData(keyName, keyValue, data[i]['children']);
      }
    }
    return null;
  }

  static Map<String, dynamic> adjacencyTransform(List<Map<String, dynamic>> nsResult) {
    int ix=0;
    void build (Map<String, dynamic> container) {

      container["children"]=[];
      if(container["rgt"] - container["lft"] < 2) {
        return;
      }

      while((++ix < nsResult.length) && (nsResult[ix]["lft"] > container["lft"]) && (nsResult[ix]["rgt"] < container["rgt"])) {
        container["children"].add(nsResult[ix]);
        build(nsResult[ix]);
      }

      if(ix<nsResult.length) {
        ix--;
      }
    };

    if(nsResult.length > 0) {
      build(nsResult[0]);
      return nsResult[0];
    }

    return {"children":[]};
  }
///-------------------------------------------------------------------------------------////
  //////////////////////////////////////////////////////////////////////////////////////
//  /*
//   * Using an inspection definition, an inspection id, and an array of vessels and equipment,
//   * this method returns an inspection "flow" array and an array of indexes into the "flow" array
//   * which correspond to sections.
//   */
//  static Map<String,List<Object>> unroll(int inspectionid, inspectiondef, bodies, equipment, answers) {
//    List<Map<String,dynamic>> flow=[];
//    List<int> chapters=[];
//
//    /*
//     * This is a recursive, private function.
//     *
//     * It builds the "flow" and "chapters" arrays.
//     */
//    void build(Map<String, dynamic> container,[Map<String,dynamic> context= const {}]) {
//      container["children"].forEach((raw) {
//        var child=applyContext(raw,context);
//        var candidates=[];
//        var temp;
//        switch(child["blocktype"]) {
//        // These blocks can be copied over as-is
//          case "customer":
//          case "inspection setup":
//          case "service address":
//          case "signature":
//          case "vessel inventory":
//            flow.add(removeChildren(child));
//            build(child,context);
//            break;
//
//        // This block can be copied as-is -- but also add the index to "chapters"
//          case "section":
//            chapters.add(flow.length);
//            flow.add(removeChildren(child));
//            build(child,context);
//            break;
//
//        // Copy this block. Then do all its children once for every body of water,
//        // keeping the particular body of water in the "context" parameter.
//          case "bodyofwater":
//            flow.add(removeChildren(child));
//            bodies.forEach((body) {
//              build(child,{...context,"bodyofwater":body});
//            });
//            break;
//
//        // Our list of equipment to include in the "flow" depends on our current context
//        // Filter the complete list of equipment accordingly
//          case "equipment inventory":
//            flow.add(removeChildren(child));
//
//            if(child.containsKey('vesselid')) {
//              // In a vessel context, return the equipment that belong to that vessel
//              candidates=equipment.where((item) {
//                return item["vessel"].contains(child["vesselid"]);
//              }).toList();
//            } else if (child.containsKey('bodyofwaterid')) {
//              // In a body of water context, return the equipment that belong to that body of water
//              candidates=equipment.where((item) {
//                return item["bodyofwater"].contains(child["bodyofwaterid"]);
//              }).toList();
//            } else {
//              // In a generic context, return the equipment that does not belong to either a vessel or body of water
//              candidates=equipment.where((item) {
//                return ((item["bodyofwater"].length == 0) && (item["vessel"].length == 0));
//              }).toList();
//            }
//
//            candidates.forEach((equipment) {
//              build(child,{...context,"equipment":equipment});
//            });
//            break;
//
//        // "Group" blocks don't go into the flow.
//        // But if their conditions match the current context, their children do
//          case "group":
//            if(child["blockscope"] != null) {
//
//              // If the context includes a vessel and the group defines a vesseltype
//              if (
//              child["blockscope"].containsKey("vesseltype")
//                  && context.containsKey("vessel")
//                  && child["blockscope"]["vesseltype"].contains(context["vessel"]["vesseltype"]["simplelistid"])
//              ) {
//                build(child,context);
//
//                // If the context includes a piece of equipment and the group defines an equipment type
//              } else if (
//              child["blockscope"].containsKey("equipmenttype")
//                  && context.containsKey("equipment")
//                  && child["blockscope"]["equipmenttype"].contains(context["equipment"]["equipmenttype"]["simplelistid"])
//              ) {
//                build(child,context);
//              }
//            }
//            break;
//
//          case "question":
//            temp = nameSubstitute(child, context);
//            temp = addEndpoints(temp, inspectionid);
//            temp = applyAnswers(temp, answers);
//            flow.add(temp);
//
//            /**
//             * Now that we are applying answer data to questions, we can evaluate the "childrenif" attribute
//             * and add those questions to the flow, depending on the answer.
//             *
//             * The if stanza reads:
//             * - If blockscope is not null
//             * - and blockscope has the "childrenif" key
//             * - and one of the items in "childrenif" matches one of the simplelistids in one of the answers
//             *
//             * For Booleans, we expect one item in each of "childrenif" and "answer" -- but this code allows "childrenif"
//             * on "select one" and "select multiples", too.
//             */
//                   /* if(child["blockscope"] != null) {
//                      if(child["blockscope"].containsKey("childrenif")){
//                        if(child["blockscope"]["childrenif"].any((simplelistid){
//                          return temp["answers"].any((answer) {
//                            return answer["simplelistid"] == simplelistid;
//                          });
//                        })) {
//                          // "temp" is a copy of child, and that copy is added by reference to "flow"
//                          // Removing "children" from "temp" removes "children" from the copy that's in the "flow" array
//                          if(temp.containsKey("children")) {
//                            temp.remove("children");
//                          }
//
//                          // But "child" still has the "children" array, so we can use it.
//                          build(child,context);
//                        }
//                      }
//                    }*/
//            /*if(child["blockscope"] != null
//                && child["blockscope"].containsKey("childrenif")
//                && child["blockscope"]["childrenif"].any((simplelistid) {
//              return temp["answers"].any((answer) {
//                return answer["simplelistid"] == simplelistid;
//              });
//            })
//            ) {
//              // "temp" is a copy of child, and that copy is added by reference to "flow"
//              // Removing "children" from "temp" removes "children" from the copy that's in the "flow" array
//              if(temp.containsKey("children")) {
//                temp.remove("children");
//              }
//
//              // But "child" still has the "children" array, so we can use it.
//              build(child,context);
//            }*/
//            break;
//
//        // The "vessel" block doesn't have a screen in the "flow"
//        // But its children are to be repeated for each vessel in the current "bodyofwater" context.
//          case "vessel":
//            if(context.containsKey("bodyofwater")) {
//              context["bodyofwater"]["vessels"].forEach((vessel) {
//                build(child,{...context,"vessel":vessel});
//              });
//            }
//            break;
//
//          default:
//          // "Switch" statements should have a "default" -- but there's nothing meaningful
//          // to do here, in our case.
//            break;
//        }
//
//      });
//    };
//
//    if((inspectiondef != null) && inspectiondef.containsKey("children")) {
//      build(inspectiondef);
//    }
//
//    return {
//      "chapters":chapters,
//      "flow":flow
//    };
//  }
//
//  static Map<String,dynamic> applyAnswers(Map<String,dynamic> node,List<Map<String,dynamic>> answers) {
//    if(node.containsKey("equipmentid")) {
//      node["answers"]=answers.where((answer) {
//        return (
//            answer["questionid"] == node["questionid"]
//                && answer["equipmentid"] == node["equipmentid"]
//                && answer["vesselid"] == null
//                && answer["bodyofwaterid"] == null
//        );
//      });
//    } else if(node.containsKey("vesselid")) {
//      node["answers"]=answers.where((answer) {
//        return (
//            answer["questionid"]==node["questionid"]
//                && answer["equipmentid"] == null
//                && answer["vesselid"] == node["vesselid"]
//                && answer["bodyofwaterid"] == null
//        );
//      });
//    } else if(node.containsKey("bodyofwaterid")) {
//      node["answers"]=answers.where((answer) {
//        return (
//            answer["questionid"]==node["questionid"]
//                && answer["equipmentid"] == null
//                && answer["vesselid"] == null
//                && answer["bodyofwaterid"] == node["bodyofwaterid"]
//        );
//      });
//    } else {
//      node["answers"]=answers.where((answer) {
//        return (
//            answer["questionid"]==node["questionid"]
//                && answer["equipmentid"] == null
//                && answer["vesselid"] == null
//                && answer["bodyofwaterid"] == null
//        );
//      });
//    }
//
//    return node;
//  }
//
//  static Map<String,dynamic> applyContext(Map<String,dynamic> node,Map<String,dynamic> context) {
//    var newnode = new Map<String,dynamic>.from(node);
//    if(context.containsKey("equipment")) {
//      newnode["equipmentid"]=context["equipment"]["equipmentid"];
//    } else if(context.containsKey("vessel")) {
//      newnode["vesselid"]=context["vessel"]["vesselid"];
//    } else if(context.containsKey("bodyofwater")) {
//      newnode["bodyofwaterid"]=context["bodyofwater"]["bodyofwaterid"];
//    }
//
//    return newnode;
//  }
//
//  /*
//   * Remove "children" array. It's redundant for the "flow" array.
//   */
//  static Map<String,dynamic> removeChildren(Map<String,dynamic> node) {
//    var newnode = new Map<String,dynamic>.from(node);
//    if(newnode.containsKey("children")) {
//      newnode.remove("children");
//    }
//
//    return newnode;
//  }
//
//  /*
//   * Make copies of the text fields, and then substitute tokens, if present.
//   */
//  static Map<String,dynamic> nameSubstitute(node,context) {
//    var txt,name,type,lang;
//    var newnode = new Map<String,dynamic>.from(node);
//
//    // Replace "equipment" tokens
//    if(context.containsKey("equipment")) {
//      type=context["equipment"]["equipmenttype"]["equipmenttype"];
//      name=context["equipment"]["equipmentdescription"] ?? type;
//      txt=new Map<String,dynamic>();
//      newnode["txt"].forEach((myKey,myValue) {
//        txt[myKey]=new Map<String,dynamic>();
//        txtfields.forEach((fieldname) {
//          if(
//          newnode["txt"][myKey].containsKey(fieldname)
//              && (newnode["txt"][myKey][fieldname] != null)
//          ) {
//            txt[myKey][fieldname]=newnode["txt"][myKey][fieldname].replaceAll('\${equipmentname}',name);
//            txt[myKey][fieldname]=txt[myKey][fieldname].replaceAll('\${equipmentdesc}',name);
//            txt[myKey][fieldname]=txt[myKey][fieldname].replaceAll('\${equipmenttype}',type);
//          } else {
//            txt[myKey][fieldname]=null;
//          }
//        });
//      });
//      newnode["txt"]=txt;
//    }
//
//    // Replace "vessel" tokens
//    if(context.containsKey("vessel")) {
//      type=context["vessel"]["vesseltype"]["label"];
//      name=context["vessel"]["vesselname"] ?? type;
//      txt=new Map<String,dynamic>();
//      newnode["txt"].forEach((myKey,myValue) {
//        txt[myKey]=new Map<String,dynamic>();
//        txtfields.forEach((fieldname) {
//          if(
//          newnode["txt"][myKey].containsKey(fieldname)
//              && (newnode["txt"][myKey][fieldname] != null)
//          ) {
//            txt[myKey][fieldname]=newnode["txt"][myKey][fieldname].replaceAll('\${vesselname}',name);
//            txt[myKey][fieldname]=txt[myKey][fieldname].replaceAll('\${vesseltype}',type);
//          } else {
//            txt[myKey][fieldname]=null;
//          }
//        });
//      });
//      newnode["txt"]=txt;
//    }
//
//    return newnode;
//  }
//
//  /*
//   * Add endpoints to our node according to our current context
//   *
//   * This will actually modify "node" in-place, so we technically don't need to return anything,
//   * but it's convenient to return the result. If for no other reason than to say, "this is the result."
//   */
//  static Map<String,dynamic> addEndpoints(node,inspectionid) {
//    var hasItem=['boolean','dropdown','select multiple','select one'].contains(node["questiontype"]);
//
//    if(node.containsKey("equipmentid")) {
//      node["endpoint"]='/auth/inspection/$inspectionid/${node["questionid"]}/equipment/${node["equipmentid"]}';
//    } else if(node.containsKey("vesselid")) {
//      node["endpoint"]='/auth/inspection/$inspectionid/${node["questionid"]}/vessel/${node["vesselid"]}';
//    } else if(node.containsKey("bodyofwaterid")) {
//      node["endpoint"]='/auth/inspection/$inspectionid/${node["questionid"]}/bow/${node["bodyofwaterid"]}';
//    } else {
//      node["endpoint"]='/auth/inspection/$inspectionid/${node["questionid"]}';
//    }
//
//    if(hasItem) {
//      node["endpoint"] += '/item/{{simplelistid}}';
//    }
//
//    return node;
//  }
  //////////////////////////////////////////////////////////////////////////////////////////////
///-----------------------------------------------------------------------------------------////
///-----------------------------------------------------------------------------------------////
///******************************************************************************************///
  /* Using an inspection definition, an inspection id, and an array of vessels and equipment,
   * this method returns an inspection "flow" array and an array of indexes into the "flow" array
   * which correspond to sections.
   */
  static Map<String,List<Object>> unroll(int inspectionid,
//      Map<String,dynamic> inspectiondef,List<Map<String,dynamic>> bodies,List<Map<String,dynamic>> equipment) {
      Map<String,dynamic> inspectiondef, bodies, List<dynamic> equipment, answers) {
    List<Map<String,dynamic>> flow=[];
    List<int> chapters=[];

    log("All Vessel===$bodies");
    /*
     * This is a recursive, private function.
     *
     * It builds the "flow" and "chapters" arrays.
     */
    void build(Map<String, dynamic> container,[Map<String,dynamic> context= const {}]) {
      container["children"].forEach((child) {
        var candidates=[];
        var temp;
        switch(child["blocktype"]) {
        // These blocks can be copied over as-is
          case "customer":
          case "inspection setup":
          case "service address":
          case "signature":
            flow.add(applyContext(childlessCopy(child, context), context));
//            flow.add(childlessCopy(child,context));
//             print("customer, inspection setup, service address, signature");
            build(child,context);
            break;

          case "vessel inventory":
            // print("vessel inventory");
            child["vesseltype"] = findVesselTypes(child, "vesseltype");
            print("This vessel inventory should consider only these vessel types: ${child["vesseltype"]}");
            flow.add(applyContext(childlessCopy(child, context), context));
//            flow.add(childlessCopy(child,context));
            build(child,context);
            break;

        // This block can be copied as-is -- but also add the index to "chapters"
          case "section":
          case "card":
            chapters.add(flow.length);
//            flow.add(childlessCopy(child,context));
//             flow.add(nameSubstitute(child, context));
//             flow.add(applyContext(childlessCopy(child, context), context));
            flow.add(nameSubstitute(applyContext(childlessCopy(child, context), context), context));

            build(child,context);
            break;

        // Copy this block. Then do all its children once for every body of water,
        // keeping the particular body of water in the "context" parameter.
          case "bodyofwater":
            // flow.add(applyContext(childlessCopy(nameSubstitute(child, context), context), context));
            flow.add(applyContext(childlessCopy(child, context), context));
//            flow.add(childlessCopy(child,context));

            bodies.forEach((body) {
              // log("aaaa=$body");
              build(child,{...context,"bodyofwater":body});
            });
            break;

        // Our list of equipment to include in the "flow" depends on our current context
        // Filter the complete list of equipment accordingly
          case "equipment inventory":
//            flow.add(childlessCopy(child,context));
//             print("equipments inventory");
            child["equipmenttype"]=findTypes(child);
            print("This equipment inventory should consider only these equipment types: ${child["equipmenttype"]}");
            flow.add(applyContext(childlessCopy(child, context), context));

            if(equipment.length > 0) {
              if (context.containsKey('vessel')) {
                // In a vessel context, return the equipment that belong to that vessel
                candidates = equipment.where((item) {
                  return item["vessel"].contains(context["vessel"]["vesselid"]) ? true : false;
                }).toList();
              } else if (context.containsKey('bodyofwater')) {
                // In a body of water context, return the equipment that belong to that body of water
                candidates = equipment.where((item) {
                  return item["bodyofwater"].contains(
                      context["bodyofwater"]["bodyofwaterid"]);
                }).toList();
              } else {
                // In a generic context, return the equipment that does not belong to either a vessel or body of water
                candidates = equipment.where((item) {
                  return ((item["bodyofwater"].length == 0) &&
                      (item["vessel"].length == 0));
                }).toList();
              }
            }

            candidates.sort((A,B) {
              var a=child["equipmenttype"].indexOf(A["equipmenttype"]["simplelistid"]);
              var b=child["equipmenttype"].indexOf(B["equipmenttype"]["simplelistid"]);

              return (a-b).sign;
            });

            candidates.forEach((equipment) {
              build(child,{...context,"equipment":equipment});
            });
            break;

        // "Group" blocks don't go into the flow.
        // But if their conditions match the current context, their children do
          case "group":
            // print("group");
            if(child["blockscope"] != null) {

              // print("group===aaaaa");
              // log("groupContext===$context");
              // If the context includes a vessel and the group defines a vesseltype
              if (
              child["blockscope"].containsKey("vesseltype")
                  && context.containsKey("vessel")
                  && child["blockscope"]["vesseltype"].contains(context["vessel"]["vesseltype"]["simplelistid"])
              ) {
                // print("group===bbbbb");
                build(child,context);

                // If the context includes a piece of equipment and the group defines an equipment type
              } else if (
              child["blockscope"].containsKey("equipmenttype")
                  && context.containsKey("equipment")
                  && child["blockscope"]["equipmenttype"].contains(context["equipment"]["equipmenttype"]["simplelistid"])
              ) {
                // print("group===ccccc");
                build(child,context);
              }
            }
            break;

          case "question":
//            flow.add(addEndpoints(nameSubstitute(child,context),inspectionid,context));
//            temp = applyContext(addEndpoints(nameSubstitute(child,context),inspectionid,context), context);
//            temp = applyAnswers(temp, []);

            // print("question");
            try{
              temp = nameSubstitute(child, context);
              temp = addEndpoints(temp, inspectionid, context);
              temp = applyContext(temp, context);
              temp = applyAnswers(temp, answers);
              // log("Answer Array=====$temp");
              flow.add(temp);

              /**
               * Now that we are applying answer data to questions, we can evaluate the "childrenif" attribute
               * and add those questions to the flow, depending on the answer.
               *
               * The if stanza reads:
               * - If blockscope is not null
               * - and blockscope has the "childrenif" key
               * - and one of the items in "childrenif" matches one of the simplelistids in one of the answers
               *
               * For Booleans, we expect one item in each of "childrenif" and "answer" -- but this code allows "childrenif"
               * on "select one" and "select multiples", too.
               */
              /*if(child['blockscope'] != null
                && child['blockscope'].containsKey('childrenif')
                && child['blockscope']['childrenif'].any((simplelistid) {
                return true;
            }))*/
              // print("Answers===>>>>${temp['answers']}");
              ///Comment start for answers
              if(child["answerscope"] != null
                  && child["answerscope"].containsKey("childrenif")
                  && child["answerscope"]["childrenif"].any((simplelistid) {
                    if(temp['answers'] != null) {
                      return temp["answers"].any((answer) {
                        return "${answer["simplelistid"]}" == "$simplelistid" ? true : false;
                      }) ? true : false;
                    } else {
                      return false;
                    }
                  })
              )
                ///Comment end for answers
              {
                // "temp" is a copy of child, and that copy is added by reference to "flow"
                // Removing "children" from "temp" removes "children" from the copy that's in the "flow" array
                // if(temp.containsKey("children")) {
                //   temp.remove("children");
                // }

                // But "child" still has the "children" array, so we can use it.
                build(child,context);
              } else {
                // print("Answer Array=====Else");
              }
            }catch (e) {
              print("question error====$e");
            }
            break;


        // The "vessel" block doesn't have a screen in the "flow"
        // But its children are to be repeated for each vessel in the current "bodyofwater" context.
          case "vessel":
            // print("vessel");
            if(context.containsKey("bodyofwater")) {
              context["bodyofwater"]["vessels"].forEach((vessel) {
                // print("VesselContext====$vessel");

                build(child,{...context,"vessel":vessel});
              });
            }
            break;

          default:
          // "Switch" statements should have a "default" -- but there's nothing meaningful
          // to do here, in our case.
            break;
        }

      });
    }

    if((inspectiondef != null) && inspectiondef.containsKey("children")) {
      build(inspectiondef);
    }

    return {
      "chapters":chapters,
      "flow":flow
    };
  }

  /*
   *Return a list of every equipmenttype (or vesseltype) referenced by any group under the given node
   **/
  static List<int> findVesselTypes(Map<String,dynamic> node, [String category="equipmenttype"]) {

    Set<int>types=new Set<int>();

    void find(Map<String, dynamic> node) {
      node["children"].forEach((child) {
        if (
          (child["blocktype"]=="group")
          && (child["blockscope"] != null)
          && (child["blockscope"].containsKey(category))
        ) {
          child["blockscope"][category].forEach((item) {
            types.add(item);
          });
        }
        find(child);
      });
    }
    find(node);

    return types.toList();
  }

  /*
   *Return a list of every equipmenttype (or vesseltype) referenced by any group under the given node
   **/
  static List<dynamic> findTypes(Map<String,dynamic> node,
      [String category="equipmenttype", String member="onlyone"]) {

    /**
     * By using LinkedHashMap, we can de-duplicate the same equipmenttype appearing more than once,
     * but still preserve the order they appear in.
     **/
    LinkedHashMap types=new LinkedHashMap<int,dynamic>();
    List result = [];

    void find(Map<String, dynamic> node) {
      node["children"].forEach((child) {
        if (
        (child["blocktype"]=="group")
            && (child["blockscope"] != null)
            && (child["blockscope"].containsKey(category))
        ) {
          child["blockscope"][category].forEach((item) {
            types[item]={
              "equipmenttypeid": item,
              "onlyone": child["blockscope"].containsKey(member)?(
                  child["blockscope"][member].any((onlyone) {
                    return (onlyone==item)?true:false;
                  })
              ):false
            };
          });
        }
        find(child);
      });
    }
    find(node);

    types.forEach((key,value) {
      result.add(value);
    });
    log("$result");

    return result;

    /*void find(Map<String, dynamic> node) {
      node["children"].forEach((child) {
        if (
          (child["blocktype"]=="group")
          && (child["blockscope"] != null)
          && (child["blockscope"].containsKey(category))
        ) {
          child["blockscope"][category].forEach((item) {
            types.add(item);
          });
        }
        find(child);
      });
    }
    find(node);

    return types.toList();*/
  }

  /*
   * Make a copy of the template item, minus any "children" item (if present).
   */
  static Map<String,dynamic> childlessCopy(Map<String,dynamic> node,Map<String,dynamic> context) {
    var newNode = nameSubstitute(node,context);
    if(newNode.containsKey("children")) {
      newNode.remove("children");
    }

    return newNode;
  }

  /*
   * Make copies of the text fields, and then substitute tokens, if present.
   */
  static Map<String,dynamic> nameSubstitute(node,context) {
    var txt,name,type,lang;
    // print("Node====$node");
    var newnode = new Map<String,dynamic>.from(node);
    // log("Node====$newnode");

    // Replace "equipment" tokens
    if(context.containsKey("equipment")) {
      type=context["equipment"]["equipmenttype"]["equipmenttype"];
      name=context["equipment"]["equipmentdescription"] ?? type;
      txt=new Map<String,dynamic>();
      newnode["txt"].forEach((myKey,myValue) {
        txt[myKey]=new Map<String,dynamic>();
        txtfields.forEach((fieldname) {
          if(
          newnode["txt"][myKey].containsKey(fieldname)
              && (newnode["txt"][myKey][fieldname] != null)
          ) {
            txt[myKey][fieldname]=newnode["txt"][myKey][fieldname].replaceAll('\${equipmentname}',name);
            txt[myKey][fieldname]=txt[myKey][fieldname].replaceAll('\${equipmentdesc}',name);
            txt[myKey][fieldname]=txt[myKey][fieldname].replaceAll('\${equipmenttype}',type);
          } else {
            txt[myKey][fieldname]=null;
          }
        });
      });
      newnode["txt"]=txt;
    }

    // Replace "vessel" tokens
    if(context.containsKey("vessel")) {
      type=context["vessel"]["vesseltype"]["label"];
      name=context["vessel"]["vesselname"] ?? type;
      txt=new Map<String,dynamic>();
      newnode["txt"].forEach((myKey,myValue) {
        txt[myKey]=new Map<String,dynamic>();
        txtfields.forEach((fieldname) {
          if(
          newnode["txt"][myKey].containsKey(fieldname)
              && (newnode["txt"][myKey][fieldname] != null)
          ) {
            txt[myKey][fieldname]=newnode["txt"][myKey][fieldname].replaceAll('\${vesselname}',name);
            txt[myKey][fieldname]=txt[myKey][fieldname].replaceAll('\${vesseltype}',type);
          } else {
            txt[myKey][fieldname]=null;
          }
        });
      });
      newnode["txt"]=txt;
    }

    // Replace "body of water" tokens
    /*if(context.containsKey("bodyofwater")) {
      type=context["vessel"]["vesseltype"]["label"];
      name=context["vessel"]["vesselname"] ?? type;
      txt=new Map<String,dynamic>();
      newnode["txt"].forEach((myKey,myValue) {
        txt[myKey]=new Map<String,dynamic>();
        txtfields.forEach((fieldname) {
          if(
          newnode["txt"][myKey].containsKey(fieldname)
              && (newnode["txt"][myKey][fieldname] != null)
          ) {
            txt[myKey][fieldname]=newnode["txt"][myKey][fieldname].replaceAll('\${vesselname}',name);
            txt[myKey][fieldname]=txt[myKey][fieldname].replaceAll('\${vesseltype}',type);
          } else {
            txt[myKey][fieldname]=null;
          }
        });
      });
      newnode["txt"]=txt;
    }*/
    return newnode;
  }

  static Map<String,dynamic> applyAnswers(node, answers) {
    try{
      // log("mainAnswers====>>>>>$answers");
      // log("Node====>>>>>$node");
      if(answers != null){
        if(answers.length > 0){
          if(node.containsKey("equipmentid")) {
            node["answers"]=answers.where((answer) {
              // log("EquipmentAnswer====>>>>>$answer");
              return (
                  "${answer["questionid"]}"=="${node["questionid"]}"
                      && "${answer["equipmentid"]}" == "${node["equipmentid"]}"
                      && (answer["vesselid"] == null
                          || "${answer["vesselid"]}" == "${node["vesselid"]}")
                      && (answer["bodyofwaterid"] == null
                          || "${answer["bodyofwaterid"]}" == "${node["bodyofwaterid"]}")
              );
            }).toList();
          } else if(node.containsKey("vesselid")) {
            node["answers"]=answers.where((answer) {
              // log("VesselAnswer====>>>>>$answer");
              return (
                  "${answer["questionid"]}"=="${node["questionid"]}"
                      && (answer["equipmentid"] == null
                          || "${answer["equipmentid"]}" == "${node["equipmentid"]}")
                      && "${answer["vesselid"]}" == "${node["vesselid"]}"
                      && (answer["bodyofwaterid"] == null
                          || "${answer["bodyofwaterid"]}" == "${node["bodyofwaterid"]}")
              );
            }).toList();
          } else if(node.containsKey("bodyofwaterid")) {
            node["answers"]=answers.where((answer) {
              return (
                  "${answer["questionid"]}"=="${node["questionid"]}"
                      && (answer["equipmentid"] == null
                          || "${answer["equipmentid"]}" == "${node["equipmentid"]}")
                      && (answer["vesselid"] == null
                          || "${answer["vesselid"]}" == "${node["vesselid"]}")
                      && "${answer["bodyofwaterid"]}" == "${node["bodyofwaterid"]}"
              );
            }).toList();
          } else {
            node["answers"]=answers.where((answer) {
              // var result = "${answer["questionid"]}"=="${node["questionid"]}"
              //     && answer["equipmentid"] == null
              //     && answer["vesselid"] == null
              //     && answer["bodyofwaterid"] == null;
              // log("NodeQuestionId===>>>${node["questionid"]} &&& AnswerQuestionId===>>>>${answer['questionid']}");
              // log("Result==>>>$result");
              // log("===================");
              return (
                  "${answer["questionid"]}"=="${node["questionid"]}"
                      && answer["equipmentid"] == null
                      && answer["vesselid"] == null
                      && answer["bodyofwaterid"] == null
              );
            }).toList();

            // log("Answers1111==QuestionId===${node["questionid"]}==>>>${node['answers']}");
          }
        } else {
          node['answers'] = [];
        }
      }
      return node;
    } catch (e){
      print("applyAnswersError====$e");
    }

    return null;
  }

  static Map<String,dynamic> applyContext(Map<String,dynamic> node, Map<String,dynamic> context) {
    var newNode = Map<String,dynamic>.from(node);
    // log("applyContext=====$context");
    if(context.containsKey("equipment")) {
      newNode["equipmentid"]=context["equipment"]["equipmentid"];
      newNode["equipmentname"]=context["equipment"]["equipmentdescription"];
    }
    if(context.containsKey("vessel")) {
      newNode["vesselid"]=context["vessel"]["vesselid"];
      newNode["vesselname"]=context["vessel"]["vesselname"];
    }
    if(context.containsKey("bodyofwater")) {
      newNode["bodyofwaterid"]=context["bodyofwater"]["bodyofwaterid"];
    }

    return newNode;
  }

  /*
   * Add endpoints to our node according to our current context
   *
   * This will actually modify "node" in-place, so we technically don't need to return anything,
   * but it's convenient to return the result. If for no other reason than to say, "this is the result."
   */
  static Map<String,dynamic> addEndpoints(node, inspectionid, context) {
    var hasItem=['boolean','dropdown','select multiple','select one','multi-list'].contains(node["questiontype"]);

    inspectionid = inspectionid != null ? "{{inspectionid}}" : null;

    if(context.containsKey("equipment")) {
     if(context["equipment"]["equipmentgeneralid"] == null) {
       node["endpoint"]='auth/inspection/'+'$inspectionid'+'/'+'${node["questionid"]}'+'/equipment/'+'${context["equipment"]["equipmentid"]}';
     } else {
       node["endpoint"]='auth/inspection/'+'$inspectionid'+'/'+'${node["questionid"]}'+'/equipment/'+'{{equipmentid}}';
     }

      // node["endpoint"]='auth/inspection/'+'$inspectionid'+'/'+'${node["questionid"]}'+'/equipment/'+'{{equipmentid}}';
    } else if(context.containsKey("vessel")) {
      if(context["vessel"]["vesselgeneralid"] == null) {
        node["endpoint"]='auth/inspection/'+'$inspectionid'+'/'+'${node["questionid"]}'+'/vessel/'+'${context["vessel"]["vesselid"]}';
      } else {
        node["endpoint"] = 'auth/inspection/' + '$inspectionid' + '/' + '${node["questionid"]}' + '/vessel/' + '{{vesselid}}';
      }
      // node["endpoint"] = 'auth/inspection/' + '$inspectionid' + '/' + '${node["questionid"]}' + '/vessel/' + '{{vesselid}}';
    } else if(context.containsKey("bodyofwater")) {
      if(context["bodyofwater"]["bodyofwatergeneralid"] != 0) {
        node["endpoint"]='auth/inspection/'+'$inspectionid'+'/'+'${node["questionid"]}'+'/bow/'+'${context["bodyofwater"]["bodyofwaterid"]}';
      } else {
        node["endpoint"]='auth/inspection/'+'$inspectionid'+'/'+'${node["questionid"]}'+'/bow/'+'{{bodyofwaterid}}';
      }
      // node["endpoint"]='auth/inspection/'+'$inspectionid'+'/'+'${node["questionid"]}'+'/bow/'+'{{bodyofwaterid}}';
    } else {
      if(inspectionid != null && node["questiontype"] == "include maintenance"){
        node["endpoint"]='auth/inspection/'+'$inspectionid'+'/'+'maint';
      } else if(inspectionid != null){
        node["endpoint"]='auth/inspection/'+'$inspectionid'+'/'+'${node["questionid"]}';
      }
    }

    if(hasItem) {
      node["endpoint"] = '${node["endpoint"]}/item/{simplelistid}';
    }

    return node;
  }

  static Future openUnroll(answer) async {
    try{
      ///Children Inspection Data
      var localChildData = await InspectionPreferences.getPreferenceData(InspectionPreferences.INSPECTION_CHILD_DATA);
      var childrenTemplateData = json.decode(localChildData);
      // print("All Children List====>>>>$childrenTemplateData");

      ///Selected Vessel List
      var localWaterBodiesListData = await PreferenceHelper.getPreferenceData(PreferenceHelper.WATER_SELECTED_BODIES);
      var waterBodiesTemplateData = localWaterBodiesListData != null
          ? json.decode(localWaterBodiesListData)
          : [];
      // print("All Equipment List====>>>>$waterBodiesTemplateData");

      ///Previous selected equipments
      var previousSelectedEquipmentListData = await PreferenceHelper.getPreferenceData(PreferenceHelper.EQUIPMENT_ITEMS);
      List prevSelectedEquipmentList = previousSelectedEquipmentListData != null
          ? json.decode(previousSelectedEquipmentListData)
          : [];
      // print("All Equipment List====>>>>$prevSelectedEquipmentList");

      ///Inspection Id
      var inspectionLocalId = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ID);
      // print("InspectionId=====>>>>$inspectionLocalId");

      ///Answer List
      var previousAnswersListData = await PreferenceHelper.getPreferenceData(PreferenceHelper.ANSWER_LIST);
      List prevAnswersList = previousAnswersListData != null
          ? json.decode(previousAnswersListData)
          : [];

      if(answer != null) {
        prevAnswersList.add(answer);
      }
      // print("All Answer List====>>>>$prevAnswersList");

      /*** Set the answer list to shared preferences ***/
      PreferenceHelper.clearPreferenceData(PreferenceHelper.ANSWER_LIST);
      PreferenceHelper.setPreferenceData(PreferenceHelper.ANSWER_LIST, json.encode(prevAnswersList));

      ///Start unroll
      var transformedData = HelperClass.unroll(int.parse(inspectionLocalId), childrenTemplateData, waterBodiesTemplateData, prevSelectedEquipmentList, prevAnswersList);
      const JsonEncoder encoder = JsonEncoder.withIndent('  ');
      // log("TransformedData====>>>>${encoder.convert(transformedData)}");

      ///Save inspection data
      InspectionPreferences.clearPreferenceData(InspectionPreferences.INSPECTION_DATA);
      InspectionPreferences.setPreferenceData(
          InspectionPreferences.INSPECTION_DATA,
          json.encode(transformedData['flow'])
      );

      return true;
    }catch (e){
      print("StackTrace=====$e");
      return false;
    }
  }

  static Future submitInspection(context, inspectionId) async {
    // var inspectionId = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ID);
    // set up POST request arguments
    String url = AllHttpRequest.apiUrl+"auth/inspection/$inspectionId";
    final String token = await PreferenceHelper.getToken();

    Map<String, String> headers = {
      "Accept":"application/json",
      "Content-Type":"application/json",
      'Authorization':'Bearer $token'
    };

    var requestJson = {
      "completed": HelperClass.getCompletedDateFormat()
    };
    print("Request====$requestJson");
    var responseData = await http.patch(Uri.parse(url), body: json.encode(requestJson), headers: headers);

    print(responseData.request.headers);
    print(responseData.request);
    print(responseData.statusCode);
    print('get Response body: ${responseData.body}');

    if (responseData.statusCode == 200) {
      // If the call to the server was successful, parse the JSON.
      var response = json.decode(responseData.body);
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage('${response['reason']}');
        return false;
      } else {
        print("Completed====>>>$response");
        return true;
      }
    }
  }

  static Future completeInspection(dbHelper) async {
    var result;
    try {
      var inspectionId = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ID);
      var requestJson = {
        "completed": HelperClass.getCompletedDateFormat()
      };

      var endPoint =  "auth/inspection/{{inspectionid}}";

      result = await dbHelper.insertPendingUrl({
        "url": '$endPoint',
        "verb":'PATCH',
        "inspectionid": inspectionId,
        "inspectiondefid": 0,
        "simplelistid": null,
        "image_id": null,
        "questionid": "",
        "payload": json.encode(requestJson),
        "imagepath": "null",
        "notaimagepath": null
      });
      print("Result ==== $result");
    } catch (e){
      log("CompleteInspectionStackTrace====$e");
    }
    return result;
  }

  static void checkInternetConnection(context) {

  }

  static void callbackDispatcher() async {
    final dbHelper = DatabaseHelper.instance;
    print("Main Call()");
   /* Workmanager().executeTask((task, inputData) async {
      print("callbackDispatcher");
      print("Task====$task");
      print("InputData====$inputData");
      try{
        var pendingList = await dbHelper.getAllPendingEndPoints();

        log("PENDING LIST====${pendingList.toList()}");
        log("TYPE=====${pendingList.runtimeType}");
        if(pendingList != null) {
          for (int i = 0; i < pendingList.toList().length; i++) {
            BackgroundServices.sendPendingRequestToServer(pendingList[i]);
          }
        }
      }catch (e){
        log("StackTrace===$e");
      }
      return Future.value(true);
    });*/
  }

  static void printDatabaseResult() async {
    var dbHelper = DatabaseHelper.instance;
    var pendingList = await dbHelper.getAllPendingEndPoints();
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');

    log("PENDING LIST====>>>>(${encoder.convert(pendingList)})}");
    log("TYPE=====${pendingList.runtimeType}");

    // var pendingAnswerList = await dbHelper.getAllPendingAnswer();
    // log("PENDING ANSWER LIST====>>>>(${encoder.convert(pendingAnswerList)})}");

    // log("Max====>>>>${encoder.convert(result)}");

    // var previousAnswersListData = await PreferenceHelper.getPreferenceData(PreferenceHelper.ANSWER_LIST);
    // List prevAnswersList = previousAnswersListData != null
    //     ? json.decode(previousAnswersListData)
    //     : [];
    //
    // log("All Answer List====>>>>${encoder.convert(prevAnswersList)}");
  }

  static String getSectionText(inspectionData) {
    String section;
    if(inspectionData.containsKey("equipmentname")) {
      section = inspectionData['equipmentname'];
    } else if(inspectionData.containsKey("vesselname")) {
      section = inspectionData['vesselname'];
    } else {
      section = "";
    }

    return section;
  }

  static Future<bool> internetConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }

  static void showSnackBar(context, message) {
    try{
      SnackBar snackBar = SnackBar(
        content: Text(
          "$message",
          style: TextStyle(
              color: AppColor.WHITE_COLOR,
              fontWeight: FontWeight.w500,
              fontSize: TextSize.subjectTitle
          ),
        ),
        backgroundColor: AppColor.THEME_PRIMARY,
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      log("SnackBar Error==$e");
    }
  }

  static void openSnackBar(context, {Function tryAgain}) async {
    try{
      SnackBar snackBar = SnackBar(
        content: Text("No internet connection", style: TextStyle(color: AppColor.WHITE_COLOR, fontWeight: FontWeight.w500, fontSize: TextSize.subjectTitle),),
        backgroundColor: AppColor.BLACK_COLOR,
        action: SnackBarAction(
          label: "Try Again",
          onPressed: (){
            tryAgain();
          },
          textColor: AppColor.ACCENT_COLOR,
        ),

      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      print(e);
    }
  }

  static void cancelInspection(context) async {
    try {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => WelcomeNavigationScreen(),
        ),
        ModalRoute.withName(WelcomeNavigationScreen.tag),
      );
    } catch(e) {
      log("cancelInspection====$e");
    }
  }
}

enum drawerMenu { home, inspections, customers, settings }
