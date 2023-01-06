
import 'dart:developer';
import 'dart:io';

import 'package:dottie_inspector/model/inspection_data_model.dart';
import 'package:dottie_inspector/model/state_data_model.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/utils/globalInstance.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AllHttpRequest extends StatelessWidget {

  // static String apiUrl= GlobalInstance.apiBaseUrl;
  static String apiUrl= "https://inspectordottie.com/";
  // static String apiUrl= "https://dev.inspectordottie.com/";

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Future<List<InspectionModelData>> getInspectionDataListFromAPI() async {
    List<InspectionModelData> inspectionList = [];
    var response = await http.get(Uri.parse(""));

    if(response != null) {
      final data = json.decode(response.body);

      var inspectionData = InspectionModelData.fromMap(data).toMap();
      // inspectionList.add(inspectionData);
    }

    return inspectionList;
  }

  Future login(funName,body) async {
    // final String token = await PreferenceHelper.getToken();

    print(body);
    // set up POST request arguments
    String url = AllHttpRequest.apiUrl+funName;
    print(url);

    // make POST request
    var response = await http.post(Uri.parse(url), body: body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON.
      print('get Response body: ${response.body}');
//      CustomToast.showToastMessage("get Response body: ${response.body}");
      return json.decode(response.body);
    } else if (response.statusCode == 422) {
      // If the call to the server was successful, parse the JSON.
      print('get Response body: ${response.body}');
//      CustomToast.showToastMessage("get Response body: ${response.body}");
      return json.decode(response.body);
    } else {
      print("failed");
      return false;
    }
  }

  Future postRequest(funName,body) async {
    try{
      final String token = await PreferenceHelper.getToken();

      print("postRequest Type===${body.runtimeType}");
      // print(body);
      // set up POST request arguments
      String url = "${AllHttpRequest.apiUrl}$funName";
      // print("postRequest BaseUrl===${AllHttpRequest.apiUrl}");
      print("postRequest FullUrl===$url");
      Map<String, String> headers = {
        "Accept":"application/json",
        "Content-Type":"application/json",
        'Authorization':'Bearer $token'
      };

      // make POST request
      var response = await http.post(Uri.parse(url), body: body, headers: headers);
      print(response.request.headers);
      print(response.request);
      print(response.statusCode);
      print('get Response body: ${response.body}');
//    return json.decode(response.body);
      if (response.statusCode == 200) {
        // If the call to the server was successful, parse the JSON.
        return json.decode(response.body);
      } else if (response.statusCode == 422 || response.statusCode == 202) {
        // If the call to the server was successful, parse the JSON.
        return json.decode(response.body);
      } else if(response.statusCode == 500){
//      return json.decode(response.body);
        return json.decode(response.body);
      } else {
        return json.decode(response.body);
      }
    }catch (e) {
      log("StackTracePostRequest====>>>>$e");
    }
  }

  Future postHazardRequest(funName,body) async {
    final String token = await PreferenceHelper.getToken();

    try{
      print("Type===${body.runtimeType}");
      print(body);
      // set up POST request arguments
      String url = "${AllHttpRequest.apiUrl}$funName";
      print(url);
      Map<String, String> headers = {
        "Accept":"application/json",
        "Content-Type":"application/json",
        'Authorization':'Bearer $token'
      };

      // make POST request
      var response = await http.post(Uri.parse(url), body: body, headers: headers);
      print(response.request.headers);
      print(response.statusCode);
      print('get Response body: ${response.body}');
//    return json.decode(response.body);
      if (response.statusCode == 200) {
        // If the call to the server was successful, parse the JSON.
        return json.decode(response.body);
      } else if (response.statusCode == 422 || response.statusCode == 202) {
        // If the call to the server was successful, parse the JSON.
        return json.decode(response.body);
      } else if(response.statusCode == 500){
//      return json.decode(response.body);
        return json.decode(response.body);
      } else {
        return json.decode(response.body);
      }
    }catch (e) {
      if(e is SocketException) {
        return {"success": false, "reason": "Socket Connection"};
      } else if(e is TimeoutException) {
        return {"success": false, "reason": "Request time out"};
      } else {
        print(e);
      }
    }
  }

  Future postUnAuthRequest(funName,body) async {
    print(body);
    // set up POST request arguments
    String url = AllHttpRequest.apiUrl+funName;
    print(url);
    Map<String, String> headers = {
      "Accept":"application/json",
      "Content-Type":"application/json",
    };

    // make POST request
    var response = await http.post(Uri.parse(url), body: body, headers: headers);
    print(response.statusCode);
    print('post Response body: ${response.body}');
//    return json.decode(response.body);
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON.
      return json.decode(response.body);
    } else if (response.statusCode == 422 || response.statusCode == 400) {
      // If the call to the server was successful, parse the JSON.
      return json.decode(response.body);
    } else {
      print("failed");
      return null;
    }
  }

  Future patchRequest(funName,body) async {
    final String token = await PreferenceHelper.getToken();

    print(body);
    // set up PATCH request arguments
    String url = "${AllHttpRequest.apiUrl}$funName";
    print(url);
    Map<String, String> headers = {
      "Accept":"application/json",
      "Content-Type":"application/json",
      'Authorization':'Bearer $token'
    };

    // make PATCH request
    var response = await http.patch(Uri.parse(url), body: body, headers: headers);
    print(response.statusCode);
    print(response.headers);
    print('patch Response body: ${response.body}');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 422 || response.statusCode == 202) {
      // If the call to the server was successful, parse the JSON.
      return json.decode(response.body);
    } else {
      print("failed");
      return json.decode(response.body);
    }
  }

  Future getUnAuthRequest(funName) async {
    // set up Get request arguments
    final String url = AllHttpRequest.apiUrl+funName;
    print(url);
//    CustomToast.showToastMessage("Url=====$url");
    // make POST request
    var response = await http.get(Uri.parse(url));
    print(response.statusCode);
    print('get Response body: ${response.body}');
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON.
//      CustomToast.showToastMessage("get Response body: ${response.body}");
      return json.decode(response.body);
    } else if(response.statusCode == 201 || response.statusCode == 422) {
      return json.decode(response.body);
    } else {
      print("failed");
      return false;
    }
  }

  Future getAuthRequest(funName) async {
    final String token = await PreferenceHelper.getToken();
    try{
      // set up Get request arguments
      final String url = AllHttpRequest.apiUrl+funName;
      log("url====$url");
      Map<String, String> headers = {
        'Authorization' : '$token'
      };
      print("Token $token");
      // make POST request
      var response = await http.get(Uri.parse(url), headers: {'Authorization':'Bearer $token'});
      // print("Request Header == ${response.request.headers}");
      print("Status Code == ${response.statusCode}");

      if (response.statusCode == 200) {
        // If the call to the server was successful, parse the JSON.
        log('get Response body: ${response.body}');
        return json.decode(response.body);
      } else {
        print("failed");
        // If the call to the server was successful, parse the JSON.
        // print('get Response body: ${response.body}');
        return json.decode(response.body);
      }
    }catch (e) {
      if(e is SocketException) {
        return {"success": false, "reason": "Socket Connection"};
      } else if(e is TimeoutException) {
        return {"success": false, "reason": "Request time out"};
      } else {
        print(e);
      }
    }
  }

  Future deleteAuthRequest(funName) async {
    final String token = await PreferenceHelper.getToken();

    // set up Get request arguments
    final String url = AllHttpRequest.apiUrl+funName;
    print(url);

    // make POST request
    var response = await http.delete(Uri.parse(url), headers: {'Authorization':'Bearer $token'});
    print("Request Header == ${response.request.headers}");
    print("Status Code == ${response.statusCode}");

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON.
      print('get Response body: ${response.body}');
      return json.decode(response.body);
    } else {
      print("failed");
      // If the call to the server was successful, parse the JSON.
      print('get Response body: ${response.body}');
      return json.decode(response.body);
    }
  }

  Future deleteAnswerRequest(funName) async {
    final String token = await PreferenceHelper.getToken();

    // set up Get request arguments
    final String url = AllHttpRequest.apiUrl+funName;
    print(url);

    // make POST request
    var response = await http.delete(Uri.parse(url), headers: {'Authorization':'Bearer $token'});
    print("Request Header == ${response.request.headers}");
    print("Status Code == ${response.statusCode}");

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON.
      print('get Response body: ${response.body}');
      return json.decode(response.body);
    } else if (response.statusCode == 202) {
      // If the call to the server was successful, parse the JSON.
      print('get Response body: ${response.body}');
      return response;
    } else {
      print("failed");
      // If the call to the server was successful, parse the JSON.
      print('get Response body: ${response.body}');
      return json.decode(response.body);
    }
  }

  Future deleteAuthImageRequest(funName) async {
    final String token = await PreferenceHelper.getToken();

    // set up Get request arguments
    final String url = AllHttpRequest.apiUrl+funName;
    print(url);

    // make POST request
    var response = await http.delete(Uri.parse(url), headers: {'Authorization':'Bearer $token'});
    print("Request Header == ${response.request.headers}");
    print("Status Code == ${response.statusCode}");

//    return response.statusCode;
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON.
      print('get Response body: ${response.body}');
      return json.decode(response.body);
    } else if(response.statusCode == 202) {
      return null;
    }/* if (response.statusCode == 400) {
      return json.decode(response.body);
    } */else {
      print("failed");
      // If the call to the server was successful, parse the JSON.
      print('get Response body: ${response.body}');
      return json.decode(response.body);
    }
  }

  Future uploadResource(funName, image, requestParam) async {

    final String token = await PreferenceHelper.getToken();

    print("Resource request data: $image");
    print("URL: ${AllHttpRequest.apiUrl+funName}");

    var request = http.MultipartRequest('POST', Uri.parse(AllHttpRequest.apiUrl+funName));
    request.headers.addAll({
      'Authorization':'Bearer $token',
      'Content-Type': 'multipart/form-data'
    });

    var pic = await http.MultipartFile.fromPath("photo", image);
    //add multipart to request
    request.files.add(pic);
//    request.fields.addAll(requestParam);

    try {
      var streamResponse = await request.send();

//      var response = await http.Response.fromStream(streamResponse);
//      if (response.statusCode != 200) {
//        print("Image upload status code is not : 200");
//        return null;
//      }
      var responseData = await streamResponse.stream.bytesToString();
      var resultData = json.decode(responseData);
      print("ResultData====$resultData");

     /* if (responseData.statusCode == 200) {
        // If the call to the server was successful, parse the JSON.
        print('get Response body: ${response.body}');
        return json.decode(response.body);
      } else {
        print("failed");
        // If the call to the server was successful, parse the JSON.
        print('get Response body: ${response.body}');
        return json.decode(response.body);
      }*/

//      final Map<String, dynamic> responseData = json.decode(response.body);
      return resultData;
    } catch(e){
      print(e);
      return null;
    }
  }

  Future uploadOnlyResource(funName, image) async {

    final String token = await PreferenceHelper.getToken();

    print("Resource request data: $image");
    log("URL===>>>${AllHttpRequest.apiUrl+funName}");


    var request = http.MultipartRequest(
        'POST',
        Uri.parse(AllHttpRequest.apiUrl+funName)
    );
    request.headers.addAll({
      'Authorization':'Bearer $token',
      'Content-Type': 'multipart/form-data'
    });
    print("Request Header == $token");

    var pic = await http.MultipartFile.fromPath("photo", image);
    //add multipart to request
    request.files.add(pic);

    try {
      var streamResponse = await request.send();

      var responseData = await streamResponse.stream.bytesToString();
      var resultData = json.decode(responseData);
      print("ResultData====$resultData");

      return resultData;
    } catch(e){
      print("Exception====$e");
      return null;
    }
  }

  Future getLocationRequest(funName) async {
    // set up Get request arguments
    final String url = funName;
    print(url);
//    CustomToast.showToastMessage("Url=====$url");
    // make POST request
    var response = await http.get(Uri.parse(url));
    print(response.statusCode);
    print('get Response body: ${response.body}');
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON.
//      CustomToast.showToastMessage("get Response body: ${response.body}");
      return json.decode(response.body);
    } else if(response.statusCode == 201 || response.statusCode == 422) {
      return json.decode(response.body);
    } else {
      print("failed");
      return false;
    }
  }

  Future uploadMultipartImage(funName, imagePath, noteImagePath, answer) async {
    final String token = await PreferenceHelper.getToken();
    print("URL == ${AllHttpRequest.apiUrl+funName}");

    var request = http.MultipartRequest('POST', Uri.parse(AllHttpRequest.apiUrl+funName));
    request.headers.addAll({
      'Authorization':'Bearer $token',
      'Content-Type': 'multipart/form-data'
    });
    request.fields['answer'] = answer;

    List<http.MultipartFile> newList = [];
    File imageFile = File(imagePath.toString());
    String fileName = imagePath.split("/").last;
    var stream = http.ByteStream(imageFile.openRead());
    var length = await imageFile.length();
    var multipartFile = new http.MultipartFile("photo", stream.cast(), length, filename: fileName);
    newList.add(multipartFile);

    if(noteImagePath != null) {
//      File imageFile1 = File(noteImagePath.toString());
      String fileName1 = noteImagePath.path.split("/").last;
      var stream1 = http.ByteStream(noteImagePath.openRead());
      var length1 = await noteImagePath.length();
      var multipartFile1 = new http.MultipartFile(
          "annotation", stream1.cast(), length1, filename: fileName1);
      newList.add(multipartFile1);
    }
    print("99999");
    request.files.addAll(newList);

    print("aaaaaa");

    try {
      var streamResponse = await request.send();

      var responseData = await streamResponse.stream.bytesToString();
      var resultData = json.decode(responseData);
      print("ResultData====$resultData");

      return resultData;
    } catch(e){
      print(e);
      return null;
    }
  }

  Future uploadMultipartLocalImage(funName, imagePath, noteImagePath, answer) async {
    final String token = await PreferenceHelper.getToken();
    print("URL == ${AllHttpRequest.apiUrl+funName}");

    var request = http.MultipartRequest('POST', Uri.parse(AllHttpRequest.apiUrl+funName));
    request.headers.addAll({
      'Authorization':'Bearer $token',
      'Content-Type': 'multipart/form-data'
    });
    request.fields['answer'] = answer;

    log("ImagePath ===== ${imagePath.runtimeType}");
    log("AnnotationImagePath ===== ${noteImagePath.runtimeType}");

    List<http.MultipartFile> newList = [];
    if(imagePath != null) {
      if (imagePath != "null") {
        File imageFile = File(imagePath.toString());
        String fileName = imagePath.split("/").last;
        var stream = http.ByteStream(imageFile.openRead());
        var length = await imageFile.length();
        var multipartFile = new http.MultipartFile("photo", stream.cast(), length, filename: fileName);
        newList.add(multipartFile);
      }
    }

    try {
      if (noteImagePath != null) {
        if (noteImagePath != "null") {
          File imageFile1;
          String fileName1;
          if(noteImagePath.runtimeType == String) {
            imageFile1 = File(noteImagePath.toString());
            fileName1 = basenameWithoutExtension(imageFile1.path);
          } else {
            imageFile1 = noteImagePath;
            fileName1 = basenameWithoutExtension(imageFile1.path);
          }

          var stream1 = http.ByteStream(imageFile1.openRead());
          var length1 = await imageFile1.length();
          var multipartFile1 = new http.MultipartFile(
              "annotation", stream1.cast(), length1, filename: fileName1);
          newList.add(multipartFile1);
        }
      }
    } catch (e) {
      log("Annotation Image issue====$e");
    }
    request.files.addAll(newList);

    try {
      var streamResponse = await request.send();

      var responseData = await streamResponse.stream.bytesToString();
      var resultData = json.decode(responseData);
      print("ResultData====$resultData");

      return resultData;
    } catch(e){
      print(e);
      return null;
    }
  }

  Future uploadProfileResource(funName, image, parameterName) async {

    final String token = await PreferenceHelper.getToken();

    print("Resource request data: $image");
    log("URL===>>>${AllHttpRequest.apiUrl+funName}");


    var request = http.MultipartRequest(
        'POST',
        Uri.parse(AllHttpRequest.apiUrl+funName)
    );
    request.headers.addAll({
      'Authorization':'Bearer $token',
      'Content-Type': 'multipart/form-data'
    });
    print("Request Header == $token");

    var pic = await http.MultipartFile.fromPath("$parameterName", image);
    //add multipart to request
    request.files.add(pic);

    try {
      var streamResponse = await request.send();

      var responseData = await streamResponse.stream.bytesToString();
      var resultData = json.decode(responseData);
      print("ResultData====$resultData");

      return resultData;
    } catch(e){
      print("Exception====$e");
      return null;
    }
  }

  Future registerNewUserWithImage(funName, body) async {
    final String token = await PreferenceHelper.getToken();
    print("URL == ${AllHttpRequest.apiUrl+funName}");

    var imagePath = body['avatar'];
    var request = http.MultipartRequest('POST', Uri.parse(AllHttpRequest.apiUrl+funName));
    request.headers.addAll({
      'Authorization':'Bearer $token',
      'Content-Type': 'multipart/form-data'
    });
    request.fields['firstname'] = body['firstname'];
    request.fields['lastname'] = body['lastname'];
    request.fields['email'] = body['email'];
    request.fields['password'] = body['password'];

    File imageFile = File(imagePath.toString());
    String fileName = imagePath.split("/").last;
    var stream = http.ByteStream(imageFile.openRead());
    var length = await imageFile.length();
    var multipartFile = new http.MultipartFile("avatar", stream.cast(), length, filename: fileName);

    request.files.add(multipartFile);

    try {
      var streamResponse = await request.send();

      var responseData = await streamResponse.stream.bytesToString();
      var resultData = json.decode(responseData);
      print("ResultData====$resultData");

      return resultData;
    } catch(e){
      print(e);
      return null;
    }
  }

  Future<List<StateDataModel>> getStateList() async {
    List<StateDataModel> stateList = [];
    try{
      // set up Get request arguments
      final String url = AllHttpRequest.apiUrl+"unauth/states/IN";
      print(url);

      // make POST request
      var response = await http.get(Uri.parse(url));
      print("Status Code == ${response.statusCode}");

      var data = json.decode(response.body);
      print("Response == $data");
      for(int i=0; i<data.length; i++) {
        stateList.add(StateDataModel.fromJson(data[i]));
      }

      print("StateList == $stateList");

      return stateList;
    }catch (e) {
      log("StackTrace====$e");
      return stateList;
    }
  }
}
