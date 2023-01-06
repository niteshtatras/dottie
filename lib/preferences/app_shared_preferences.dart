import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:dottie_inspector/utils/custom_toast.dart';
import 'package:dottie_inspector/webServices/AllRequest.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PreferenceHelper {
  static const String TOKEN = 'token';
  static const String USER_NAME = 'username';
  static const String FIRST_NAME = 'firstname';
  static const String LAST_NAME = 'lastname';
  static const String NICK_NAME = 'nickname';
  static const String USER_AVATAR = 'avatar';
  static const String PASSWORD = 'password';
  static const String CLIENT_ID = 'clientid';
  static const String LOCATION_ID = 'locationid';
  static const String LOCATION_IMAGE = 'location_image';
  static const String LOCATION_IMAGE_ID = 'location_image_id';
  static const String WATER_BODIES = 'water_bodies';
  static const String WATER_SELECTED_BODIES = 'water_selected_bodies';
  static const String WATER_VESSEL_BODIES = 'water_vessel_bodies';
  static const String WATER_VESSEL_BODIES_ITEM = 'water_vessel_bodies_item';
  static const String WATER_BODIES_COUNT = 'water_bodies_count';
  static const String EQUIPMENT_ITEMS = 'equipment_items';
  static const String ANSWER_LIST = 'answers_list';
  static const String GENERAL_EQUIPMENT_ITEMS = 'general_equipment_items';
  static const String EQUIPMENT_VESSEL_ITEMS = 'equipment_vessel_items';
  static const String WATER_ID = 'water_id';
  static const String GAS_METER_DETAIL = 'gas_meter_detail';
  static const String GAS_METER_LIST = 'gas_meter_list';

  static const String INSPECTION_LIST = 'inspectionlist';
  static const String INSPECTION_QUESTION_LIST = 'inspectionquestionlist';
  static const String INSPECTION_ITEM = 'inspectionitem';
  static const String INSPECTION_EQUIPMENT_ITEM = 'inspectionequipmentitem';
  static const String INSPECTION_ID = 'inspectionid';
  static const String FILTER_CASING = 'filter_casing';
  static const String AUTOMATIC_COVER_MOTOR = 'automatic_cover_motor';
  static const String LIGHT_ID = 'light_id';

  static const String REFRESH_TOKEN = 'refresh_token';
  static const String PDF_TOKEN = 'pdftoken';
  static const String LAST_REFRESH = 'last_refresh';
  static const String REFRESH_END_POINT = 'unauth/token/refresh';
  static const int REFRESH_INTERVAL = 300000;

  static const String INSPECTION_NAME = 'inspection_name';
  static const String INSPECTION_CUSTOMER_NAME = 'inspection_customer_name';
  static const String INSPECTION_SERVICE_LOCATION = 'inspection_service_location';

  static const String SELL_INFORMATION = 'sell_information';
  static const String PRODUCT_ID = 'productId';
  static const String PRODUCT_NAME = 'productName';
  static const String PRODUCT_PRICE = 'productPrice';
  static const String PRODUCT_TRANSACTION_DATE = 'product_transaction_date';

  static const String TEMPLATE_LIST = 'template_list';

  static const String LANGUAGE = 'lang';
  static const String BUSINESS_HOUR = 'business_hour';
  static const String DATE_FORMAT = 'date_format';
  static const String TIME_FORMAT = 'time_format';
  static const String ROLES = 'role';
  static const String THEME_MODE = 'theme_mode';

  // static const String IS_SERVER_INSPECTION_ID = 'isserverinspectionid';
  // static const String IS_CLIENT_SERVER_ID = 'isclientserverid';
  // static const String IS_SERVICE_SERVER_ID = 'isserviceserverid';

  static Future<SharedPreferences> getInstance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  static Future<Null> saveUserPreferenceData(
      Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    log("RefreshToken====${userData[REFRESH_TOKEN]}");
    prefs.setString(TOKEN, userData[TOKEN]);
    prefs.setString(USER_NAME, userData[USER_NAME] ?? "");
    prefs.setString(REFRESH_TOKEN, userData[REFRESH_TOKEN]);
  }

  static Future<Null> saveProfilePreferenceData(userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString(USER_NAME, userData[USER_NAME]);
    prefs.setString(FIRST_NAME, userData[FIRST_NAME]);
    prefs.setString(LAST_NAME, userData[LAST_NAME]);
    prefs.setString(NICK_NAME, userData[NICK_NAME] ?? "");
    prefs.setString(USER_AVATAR, userData[USER_AVATAR]);
  }

  static Future<void> clearUserPreferenceData(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // user
    prefs.remove(TOKEN);
    prefs.remove(USER_NAME);
    prefs.remove(PASSWORD);


//    CustomToast.showColoredToast('Session time-out');
//    CustomToast.showToastMessage('Logged in to another device using same credentials');
  }

  static Future<void> setIntData(String key, int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(key, value);
  }

  static Future<int> getIntData(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  static Future<void> setBoolData(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(key, value);
  }

  static Future<bool> getBoolData(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  static Future<String> getToken({int mainType}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token;

    int type = mainType ?? 0;
    if(type == 0) {
      int lastRefresh = prefs.getInt(LAST_REFRESH);
      var now = new DateTime.now().millisecondsSinceEpoch;
      print("LastRefresh=====$lastRefresh");
      print("Now=====$now");
      print("Condition1=====${(now - lastRefresh)}");
      print("Condition2=====${(now - lastRefresh) > REFRESH_INTERVAL}");
      if (lastRefresh == null || ((now - lastRefresh) > REFRESH_INTERVAL)) {
        token = await getNewToken();
      } else {
        token = prefs.getString(TOKEN);
      }
      // token = await getNewToken();
    } else {
      token = prefs.getString(TOKEN);
    }
    return token;
  }

  static Future<void> setToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(TOKEN, token);
  }

  static Future<String> getPreferenceData(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> setPreferenceData(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }

  static Future<void> setSellInformationData(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(key, value);
  }

  static Future<bool> getSellInformationData(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  static Future<void> setRoleData(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(ROLES, value);
  }

  static Future<bool> getRoleData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(ROLES);
  }

  static Future<void> clearPreferenceData(key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.remove(key);
  }

  static Future getNewToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String refreshToken = await PreferenceHelper.getPreferenceData(PreferenceHelper.REFRESH_TOKEN);

    log("GetNewToken====>>>>${AllHttpRequest.apiUrl}$REFRESH_END_POINT");
    log("RefreshToken====>>>>$refreshToken");
    // set up POST request arguments
    String url = AllHttpRequest.apiUrl+REFRESH_END_POINT??"";
    var requestJson = {"refresh_token": "$refreshToken"};
    print(requestJson);

    Map<String, String> headers = {
      "Accept":"application/json",
      "Content-Type":"application/json"
    };

    var responseData = await http.post(Uri.parse(url), body: json.encode(requestJson), headers: headers);
    print(responseData.request.headers);
    print(responseData.request);
    print(responseData.statusCode);
    log('get Response body: ${responseData.body}');

    if (responseData.statusCode == 200) {
      // If the call to the server was successful, parse the JSON.
      var response = json.decode(responseData.body);
      log('Refresh_Token: ${responseData.body}');
      if (response['success']!=null && !response['success']) {
        CustomToast.showToastMessage('${response['reason']}');
      } else {
        prefs.setString(TOKEN, response[TOKEN]);
        prefs.setString(REFRESH_TOKEN, response[REFRESH_TOKEN]);
        prefs.setInt(LAST_REFRESH, DateTime.now().millisecondsSinceEpoch);
        return response[TOKEN];
      }
    }
  }
}
