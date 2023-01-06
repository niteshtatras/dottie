import 'dart:convert';
import 'dart:developer';

import 'package:dottie_inspector/inspectionPreferences/inspection_preferences.dart';
import 'package:dottie_inspector/pages/dynamicInspection/dynamic_boolean_page.dart';
import 'package:dottie_inspector/pages/dynamicInspection/dynamic_dimension_page.dart';
import 'package:dottie_inspector/pages/dynamicInspection/dynamic_general_page.dart';
import 'package:dottie_inspector/pages/dynamicInspection/dynamic_inspection_photo.dart';
import 'package:dottie_inspector/pages/dynamicInspection/dynamic_multi_list_page.dart';
import 'package:dottie_inspector/pages/dynamicInspection/dynamic_multiple_selection_page.dart';
import 'package:dottie_inspector/pages/dynamicInspection/dynamic_quantity_page.dart';
import 'package:dottie_inspector/pages/dynamicInspection/dynamic_repair_cost.dart';
import 'package:dottie_inspector/pages/dynamicInspection/dynamic_side_note_page.dart';
import 'package:dottie_inspector/pages/dynamicInspection/dynamic_signature_block.dart';
import 'package:dottie_inspector/pages/dynamicInspection/dynamic_single_selection_page.dart';
import 'package:dottie_inspector/pages/inspectionMain/inspection_adding_customer.dart';
import 'package:dottie_inspector/pages/inspectionMain/inspection_location_page.dart';
import 'package:dottie_inspector/pages/inspectionMain/reorderScreen/water_bodies_creating_page.dart';
import 'package:dottie_inspector/pages/inspectionMain/vesselEquipmentInventory/vessel_equipment_inventory_selection_screen.dart';
import 'package:dottie_inspector/pages/inspectionMain/vesselInventory/vessel_inventory_selection_screen.dart';
import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:flutter/cupertino.dart';

class InspectionUtils {
  static Future getInspectionBlockType(type, inspectionData) async {
    switch(type) {
      case "label":
        return DynamicGeneralPage(
          inspectionData: inspectionData
        );
        break;

      case "multi-list":
        return DynamicMultipleSelectionPage(
            inspectionData: inspectionData
        );
        break;

      case "boolean":
      case "include maintenance":
        return DynamicBooleanPage(
            inspectionData: inspectionData
        );
        break;

      case "select one":
        return DynamicSingleSelectionPage(
            inspectionData: inspectionData
        );
        break;

      case "select multiple":
        return DynamicMultipleSelectionPage(
            inspectionData: inspectionData
        );
        break;

      case "text":
        return DynamicSideNotePage(
            inspectionData: inspectionData
        );
        break;

      case "photo":
        return DynamicPhotoPage(
            inspectionData: inspectionData
        );
        break;
    }
  }

  static Future getInspectionBlockTypeData(inspectionData, index) async {
    var blockType = inspectionData['blocktype'];
    var questionType = inspectionData['questiontype'];
    var lastIndex = index ?? 0;

    switch(blockType) {
      case "customer":
        return InspectionAddCustomer();
        break;

      case "service address":
        return InspectionLocationPage();
        break;

      case "vessel inventory":
        return VesselInventorySelectionPage(
          inspectionData: inspectionData,
        );
        break;

      case "bodyofwater":
        return WaterBodiesCreatePage();
        break;

      case "section":
        return getInspectionQuestionTypeData(questionType, inspectionData, lastIndex);
        break;

      case "equipment inventory":
        return VesselEquipmentInventorySelectionPage(
          inspectionData: inspectionData,
        );
        break;

      case "group":
        return null;
        break;

      case "inspection":
        return getInspectionQuestionTypeData(questionType, inspectionData, lastIndex);
        break;

      case "inspection setup":
        return getInspectionQuestionTypeData(questionType, inspectionData, lastIndex);
        break;

      case "question":
        return getInspectionQuestionTypeData(questionType, inspectionData, lastIndex);
        break;

      case "signature":
        return DynamicSignaturePage(
          inspectionData: inspectionData,
          lastIndex: lastIndex
        );
        break;

      case "vessel":
        return getInspectionQuestionTypeData(questionType, inspectionData, lastIndex);
        break;
    }

    return null;
  }

  static Future getInspectionQuestionTypeData(type, inspectionData, lastIndex) async {
    switch(type) {
      case "boolean":
      case "include maintenance":
        return DynamicBooleanPage(
          inspectionData: inspectionData,
          lastIndex: lastIndex
        );
        break;

        /// repair cost
      case "repair cost":
        return DynamicRepairCostPage(
            inspectionData: inspectionData,
            lastIndex: lastIndex
        );
        break;

      case "dimensions":
        return DynamicDimensionPage(
          inspectionData: inspectionData,
            lastIndex: lastIndex
        );
        break;

      case "label":
        return DynamicGeneralPage(
          inspectionData: inspectionData,
        );
        break;

      case "multi-list":
        return DynamicMultiListPage(
          inspectionData: inspectionData,
            lastIndex: lastIndex
        );
        break;

      case "photo":
        return DynamicPhotoPage(
          inspectionData: inspectionData,
            lastIndex: lastIndex
        );
        break;

      case "quantity":
        return DynamicQuantityPage(
          inspectionData: inspectionData,
            lastIndex: lastIndex
        );
        break;

      case "select multiple":
        return DynamicMultipleSelectionPage(
          inspectionData: inspectionData,
            lastIndex: lastIndex
        );
        break;

      case "select one":
        return DynamicSingleSelectionPage(
          inspectionData: inspectionData,
            lastIndex: lastIndex
        );
        break;

      case "text":
        return DynamicSideNotePage(
          inspectionData: inspectionData,
            lastIndex: lastIndex
        );
        break;
    }
  }

  static decrementIndex(index) {
    InspectionPreferences.clearPreferenceData(InspectionPreferences.INSPECTION_INDEX);
    InspectionPreferences.setInspectionId(
        InspectionPreferences.INSPECTION_INDEX,
        --index
    );
  }

  static Future<Map<String, dynamic>> getPreviousData() async {
    Map<String, dynamic> allPreviousData = {};
    try{
      ///Children Inspection Data
      var localChildData = await InspectionPreferences.getPreferenceData(InspectionPreferences.INSPECTION_CHILD_DATA);
      var childrenTemplateData = localChildData != null
          ? json.decode(localChildData)
          : {};
      // print("All Children List====>>>>$childrenTemplateData");

      ///Selected Vessel List
      var localWaterBodiesListData = await PreferenceHelper.getPreferenceData(PreferenceHelper.WATER_SELECTED_BODIES);
      var waterBodiesTemplateData = localWaterBodiesListData != null
          ? json.decode(localWaterBodiesListData)
          : [];

      ///Previous selected equipments
      var previousSelectedEquipmentListData = await PreferenceHelper.getPreferenceData(PreferenceHelper.EQUIPMENT_ITEMS);
      List prevSelectedEquipmentList = previousSelectedEquipmentListData != null
          ? json.decode(previousSelectedEquipmentListData)
          : [];
      // print("All Equipment List====>>>>$prevSelectedEquipmentList");

      var previousAnswersListData = await PreferenceHelper.getPreferenceData(PreferenceHelper.ANSWER_LIST);
      List prevAnswersList = previousAnswersListData != null
          ? json.decode(previousAnswersListData)
          : [];

      ///Inspection Id
      var inspectionLocalId = await PreferenceHelper.getPreferenceData(PreferenceHelper.INSPECTION_ID);

      allPreviousData = {
        "inspectionDef": childrenTemplateData,
        "bodyofwaterlist": waterBodiesTemplateData,
        "equipmentlist": prevSelectedEquipmentList,
        "answerlist": prevAnswersList,
        "inspectionid": inspectionLocalId
      };
    } catch (e) {
      log("StackTrace==getPreviousData==$e");
    }

    return allPreviousData;
  }
}