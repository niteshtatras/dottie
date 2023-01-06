import 'dart:convert';
import 'dart:developer';

import 'package:dottie_inspector/database/database_helper.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';

class BackgroundServices{

  static void callbackDispatcher() async {
    // final dbHelper = DatabaseHelper.instance;
    // Workmanager().executeTask((task, inputData) async {
    //   print("callbackDispatcher");
    //   print("Task====$task");
    //   print("InputData====$inputData");
    //   try{
    //     var pendingList = await dbHelper.getAllPendingEndPoints();
    //
    //     log("PENDING LIST====${pendingList.toList()}");
    //     log("TYPE=====${pendingList.runtimeType}");
    //     if(pendingList != null) {
    //       for (int i = 0; i < pendingList.toList().length; i++) {
    //         sendPendingRequestToServer(pendingList[i]);
    //       }
    //     }
    //   }catch (e){
    //     log("StackTrace===$e");
    //   }
    //   return Future.value(true);
    // });
  }

  static Future sendPendingVesselBodyEquipmentData(payload, endPoint) async {
    try{
      var response;
      var requestJson = json.decode(json.encode(payload));

      AllHttpRequest request = new AllHttpRequest();

      response = await request.postRequest(
          "$endPoint",
          requestJson
      );

      return response;
    } catch(e) {
      log("sendPendingVesselBodyEquipmentData==StackTrace====$e");
    }
  }

  static Future sendInspectionIdData(requestParameter, endPoint) async {
    try{
      var response;
      var requestJson = json.decode(json.encode(requestParameter));

      AllHttpRequest request = new AllHttpRequest();

      response = await request.postRequest(
        "$endPoint",
        requestJson
      );

      return response;
    } catch(e) {
      log("sendDeleteAnswerData==StackTrace====$e");
    }
  }

  static Future sendDeleteAnswerData(inspectionId, answerId) async {
    try{
      var response;

      AllHttpRequest request = new AllHttpRequest();

      response = await request.deleteAnswerRequest(
          "auth/inspection/$inspectionId/answer/$answerId",
      );

      return response;
    } catch(e) {
      log("sendDeleteAnswerData==StackTrace====$e");
    }
  }

  static Future uploadOnlyResourceRecord(endPoint, image) async {
    try{
      var response;
      AllHttpRequest request = new AllHttpRequest();

      response = await request.uploadOnlyResource(
          "$endPoint",
        image,
      );

      return response;
    } catch(e) {
      log("sendDeleteAnswerData==StackTrace====$e");
    }
  }

  static Future sendPendingRequestToServer(pendingData, [endPointLoc]) async {
    try {
      final dbHelper = DatabaseHelper.instance;
      var requestParameter = pendingData['payload'];

      var endPoint = endPointLoc == null ? "${pendingData['url']}" : endPointLoc;
      var verb = "${pendingData['verb']}";
      var imagePath = "${pendingData['imagepath']}";
      var noteImagePath = "${pendingData['notaimagepath']}";
      var response;

      AllHttpRequest request = new AllHttpRequest();
      switch (verb) {
        case "POST":
          var requestJson = json.decode(json.encode(requestParameter));

          response = await request.postRequest(
              "$endPoint",
              requestJson
          );
          if (response != null) {
            try{
              if (response['success'] != null && !response['success']) {
                log("Post Failed");
              } else {
                dbHelper.deletePendingRequest("${pendingData['proxyid']}");
                dbHelper.deleteAnswerRequest("${pendingData['proxyid']}");
              }
            }catch(e){
              log("PostStackTrace===$e");
            }
          }
          return response;

        case "MULTIPART":
          response = await request.uploadMultipartLocalImage(
              endPoint,
              imagePath,
              noteImagePath,
              requestParameter
          );
          if (response != null) {
            try {
              if (response['success'] != null && !response['success']) {
                log("Multipart Failed");
              } else {
                dbHelper.deletePendingRequest("${pendingData['proxyid']}");
              }
            }catch(e){
              log("MultipartStackTrace===$e");
            }
          }
          return response;

        case "SIGNATURE":
          response = await request.uploadOnlyResource(
              endPoint,
              imagePath
          );
          if (response != null) {
            try {
              if (response['success'] != null && !response['success']) {
                log("Signature Failed");
              } else {
                PreferenceHelper.clearPreferenceData(PreferenceHelper.PDF_TOKEN);
                PreferenceHelper.setPreferenceData(PreferenceHelper.PDF_TOKEN, "${response['pdftoken']}");
                dbHelper.deletePendingRequest("${pendingData['proxyid']}");
              }
            }catch(e){
              log("SignatureStackTrace===$e");
            }
          }
          return response;

        case "PATCH":
          var requestJson = json.decode(json.encode(requestParameter));
          response = await request.patchRequest(
              endPoint,
              requestJson
          );
          if (response != null) {
            try {
              if (response['success'] != null && !response['success']) {
                log("Patch Failed");
              } else {
                dbHelper.deletePendingRequest("${pendingData['proxyid']}");
                PreferenceHelper.clearPreferenceData(PreferenceHelper.PDF_TOKEN);
                PreferenceHelper.setPreferenceData(PreferenceHelper.PDF_TOKEN, "${response['pdftoken']}");
              }
            } catch(e){
              log("PatchStackTrace===$e");
            }
          }
          return response;
      }
    } catch (e) {
      log("StackTrace123====>>>>$e");
    }
  }
}