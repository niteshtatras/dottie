import 'dart:developer';

import 'package:dottie_inspector/database/database_helper.dart';
import 'package:dottie_inspector/res/string.dart';

class CountryStateListEntry {
  static var dbHelper = DatabaseHelper.instance;

  static void insertCountryDataIntoLocalDB() async {
    try{
      var countryRecord = await dbHelper.getCountryRecordCount();
      var count = countryRecord == null ? 0 : countryRecord[0]['NUM'];
      if(count == 0) {
        await dbHelper.insertCountryData("""
          ${StringData.countryQueryString}
        """);
      } else {
        log("CountryRecord====$count");
      }

    } catch (e) {
      log("insertCountryDataIntoLocalDBStackTrace===$e");
    }
  }

  static void insertStateDataIntoLocalDB() async {
    try{
      var stateRecord = await dbHelper.getStateRecordCount();
      var count = stateRecord == null ? 0 : stateRecord[0]['NUM'];
      if(count == 0) {
        await dbHelper.insertStateData("""
          ${StringData.stateQueryString}
        """);

        await dbHelper.getStateRecordCount();
      } else {
        log("StateRecord====$count");
      }

    } catch (e) {
      log("insertStateDataIntoLocalDBStackTrace===$e");
    }
  }
}