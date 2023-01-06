import 'package:shared_preferences/shared_preferences.dart';

class InspectionPreferences{
  static const String INSPECTION_DETAIL_LIST = 'inspection_detail_list';
  static const String INSPECTION_DATA = 'inspection_data';
  static const String INSPECTION_CHILD_DATA = 'inspection_child_data';
  static const String INSPECTION_DEF_ID = 'inspection_def_id';
  static const String INSPECTION_INDEX = 'inspection_index';
  static const String INSPECTION_VESSEL_INDEX = 'inspection_vessel_index';
  static const String  INSPECTION_CHAPTER_DETAIL_LIST = 'inspection_chapter_detail_list';
  static const String INSPECTION_VESSEL_NAME = 'inspection_vessel_name';

  static const String INSPECTION_VESSEL_CHILD_DATA = "inspection_vessel_child_data";
  static const String INSPECTION_BOW_CHILD_DATA = "inspection_bow_child_data";

  static Future<SharedPreferences> getInstance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  static Future<String> getPreferenceData(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> setPreferenceData(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }

  static Future<void> setInspectionId(String key, int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(key, value);
  }

  static Future<int> getInspectionId(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  static Future<void> clearPreferenceData(key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.remove(key);
  }
}