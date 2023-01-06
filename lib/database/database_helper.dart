import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final _databaseName = "dottie_inspector.db";
  static final _databaseVersion = 18;

  static const PENDING_TABLE = "pending";
  static const ANSWER_TABLE = "answer";
  static const DELETE_ANSWER_TABLE = "deleteanswer";
  static const SIMPLE_LIST_TABLE = "simplelist";
  static const BODY_OF_WATER_TABLE = "bodyofwater";
  static const VESSEL_TABLE = "vessel";
  static const EQUIPMENT_TABLE = "equipment";
  static const TEMPLATE_LIST_TABLE = "templatelist";
  static const INSPECTION_LIST_TABLE = "inspectionlist";
  static const CUSTOMER_LIST_TABLE = "customerlist";
  static const COMPANY_DETAIL_TABLE = "companydetail";
  static const PROFILE_DETAIL_TABLE = "profiledetail";
  static const STATE_LIST_TABLE = "statelist";
  static const TEMPLATE_DETAIL_TABLE = "templatedetail";
  static const CUSTOMER_DETAIL_TABLE = "customerdetail";
  static const INSPECTION_ID_TABLE = "inspectionidtable";
  static const STARTED_INSPECTION_TABLE = "startedinspectiontable";
  static const CUSTOMER_GENERAL_TABLE = "customergeneraltable";
  static const SERVICE_GENERAL_TABLE = "servicegeneraltable";
  static const LOCATION_IMAGE_TABLE = "locationimage";
  static const STATE_TABLE = "state";
  static const COUNTRY_TABLE = "country";

  ///Pending Table Name
  static const PROXY_ID = 'proxyid';
  static const INSPECTION_ID = 'inspectionid';
  static const INSPECTION_DEF_ID = 'inspectiondefid';
  static const QUESTION_ID = 'questionid';
  static const URL = 'url';
  static const VERB = 'verb';
  static const PAYLOAD = 'payload';
  static const IMAGE_PATH = 'imagepath';
  static const NOTA_IMAGE_PATH = 'notaimagepath';
  static const IMAGE_ID = 'image_id';
  static const INDEX = 'pending_index';
  static const STATUS = 'status';

  ///ANSWER TABLE
  static const ANSWER_ID = 'answerid';
  static const ANSWER_SERVER_ID = 'answerserverid';
  static const EQUIPMENT_ID = 'equipmentid';
  static const VESSEL_ID = 'vesselid';
  static const BODY_OF_WATER_ID = 'bodyofwaterid';
  static const SIMPLE_LIST_ID = 'simplelistid';
  static const ANSWER = 'answer';
  static const IMAGE_URL = 'imageurl';
  static const IMAGE_FILE_URL = 'imagefileurl';

  ///Simple list table
  static const SIMPLE_LIST_ID_P = "simplelistidp";
  static const SIMPLE_LIST_ID_OPTION = "simplelistid";
  static const SLUG = "slug";
  static const SVG_ICON = "svgicon";
  static const LEFT = "lft";
  static const RIGHT = "rgt";
  static const IS_LIST = "isList";
  static const LABEL = "label";

  ///Body Of Water table
  static const BODY_OF_WATER_ID_LOCAL = "bodyofwateridlocal";
  static const BODY_OF_WATER_ID_SERVER = "bodyofwaterid";
  static const SERVICE_ADDRESS_ID = "serviceaddressid";

  ///Vessel table
  static const VESSEL_ID_LOCAL = "vesselidlocal";
  static const VESSEL_ID_SERVER = "vesselid";
  static const VESSEL_NAME = "vesselname";
  static const VESSEL_TYPE = "vesseltype";
  static const UNITS = "units";
  static const WIDTH = "width";
  static const LENGTH = "length";
  static const DEPTH = "depth";
  static const VOLUME = "volume";

  ///Equipment table
  static const EQUIPMENT_ID_LOCAL = "equipmentidlocal";
  static const EQUIPMENT_ID_SERVER = "equipmentid";
  static const EQUIPMENT_TYPE_ID = "equipmenttypeid";
  static const EQUIPMENT_GROUP_ID = "equipmentgroupid";
  static const EQUIPMENT_DESCRIPTION = "equipmentdescription";
  static const COMMENTS = "comments";

  ///Common Column
  static const LAST_UPDATED = "lastUpdated";

  ///Template & Customer Table
  static const TEMPLATE_ID = "templateid";
  static const CUSTOMER_ID = "customerid";

  ///Inspection table
  static const INSPECTION_LOCAL_ID = "inspectionlocalid";
  static const INSPECTION_SERVER_ID = "inspectionserverid";
  static const IS_INSPECTION_SERVER_ID = "isinspectionserverid";

  ///Customer General table
  static const CUSTOMER_LOCAL_ID = "customerlocalid";
  static const CUSTOMER_SERVER_ID = "customerserverid";
  static const IS_CUSTOMER_SERVER_ID = "iscustomerserverid";

  ///Customer General table
  static const SERVICE_LOCAL_ID = "servicelocalid";
  static const SERVICE_SERVER_ID = "serviceserverid";
  static const IS_SERVICE_SERVER_ID = "isserviceserverid";

  ///State table
  static const STATE_ID = "stateid";
  static const COUNTRY_CODE = "countrycode";
  static const STATE_CODE = "statecode";
  static const STATE_NAME = "statename";

  ///State table
  static const COUNTRY_NAME = "countryname";
  static const COUNTRY_DIAL_CODE = "dialcode";
  static const COUNTRY_FLAG = "flag";
  static const COUNTRY_MIXED_CASE = "mixedcase";
  static const COUNTRY_CODE_3 = "countrycode3";
  static const COUNTRY_POSTAL_CODE_REGEX = "postalcoderegex";

  // database
  static Database _database;

  // private constructor
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  factory DatabaseHelper() => instance;

  // asking for database
  Future<Database> get database async {
    if(_database != null) return _database;

    // create a database if one doesn't exist
    _database = await _initDB();
    return _database;
  }

  // function to return a database
  _initDB() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, _databaseName);
    log('db location : '+path);

    return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade
    );
  }

  // create a database since it doesn't exist
  Future _onCreate(Database db, int version) async {
    await createPendingTable(db);
    await createAnswerTable(db);
    await createSimpleListTable(db);
    await createBodyOfWaterTable(db);
    await createVesselTable(db);
    await createEquipmentTable(db);
    await createDeleteAnswerTable(db);
    ///Fully Offline Mode
    await createTemplateListTable(db);
    await createInspectionListTable(db);
    await createCustomerListTable(db);
    await createCompanyDetailTable(db);
    await createProfileDetailTable(db);
    await createStateListTable(db);

    await createTemplateDetailTable(db);
    await createCustomerDetailTable(db);

    await createInspectionIdTable(db);
    await createStartedInspectionTable(db);

    await createCustomerGeneralTable(db);
    await createServiceAddressTable(db);

    await createLocationImageTable(db);
    await createCountryTable(db);
    await createStateTable(db);

    await alterTableContent(db, "create");

    // await createSimpleListTable(db);

    // ///Remove
    // await createSimpleListTable(db);
    // await createBodyOfWaterTable(db);
    // await createVesselTable(db);
    // await createEquipmentTable(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    log("OnUpgrade====OldVersion==$oldVersion and NewVersion===$newVersion");

    if(oldVersion < newVersion) {
      await createSimpleListTable(db);
      await createBodyOfWaterTable(db);
      await createVesselTable(db);
      await createEquipmentTable(db);
      await createDeleteAnswerTable(db);
      await createTemplateListTable(db);
      await createInspectionListTable(db);
      await createCustomerListTable(db);
      await createCompanyDetailTable(db);
      await createProfileDetailTable(db);
      await createStateListTable(db);

      await createTemplateDetailTable(db);
      await createCustomerDetailTable(db);

      await createInspectionIdTable(db);
      await createStartedInspectionTable(db);

      await createCustomerGeneralTable(db);
      await createServiceAddressTable(db);

      await createLocationImageTable(db);
      await createCountryTable(db);
      await createStateTable(db);

      log("Alteration Done");
      await alterTableContent(db, "upgrade");
    }
  }

  ///Pending Table
  Future createPendingTable(db) async {
    await db.execute('''DROP TABLE IF EXISTS $PENDING_TABLE''');
    await db.execute(
        '''
          CREATE TABLE $PENDING_TABLE(
            $PROXY_ID INTEGER PRIMARY KEY,
            $INSPECTION_ID INTEGER NOT NULL,
            $INSPECTION_DEF_ID INTEGER,
            $SIMPLE_LIST_ID INTEGER,
            $IMAGE_ID INTEGER,
            $EQUIPMENT_ID INTEGER,
            $VESSEL_ID INTEGER,
            $BODY_OF_WATER_ID INTEGER,
            $QUESTION_ID INTEGER NOT NULL,
            $URL VARCHAR(255) NOT NULL,
            $VERB VARCHAR(10) NOT NULL,
            $PAYLOAD TEXT NOT NULL,
            $IMAGE_PATH VARCHAR(255) NOT NULL,
            $NOTA_IMAGE_PATH VARCHAR(255)
          );
      '''
    );
  }

  ///Answer Table
  Future createAnswerTable(db) async {
    await db.execute('''DROP TABLE IF EXISTS $ANSWER_TABLE''');
    await db.execute(
        '''
        CREATE TABLE $ANSWER_TABLE(
          $ANSWER_ID INTEGER PRIMARY KEY,
          $PROXY_ID INTEGER NOT NULL,
          $INSPECTION_ID INTEGER NOT NULL,
          $INSPECTION_DEF_ID INTEGER,
          $IMAGE_ID INTEGER,
          $QUESTION_ID INTEGER NOT NULL,
          $EQUIPMENT_ID INTEGER,
          $VESSEL_ID INTEGER,
          $BODY_OF_WATER_ID INTEGER,
          $SIMPLE_LIST_ID INTEGER NOT NULL,
          $ANSWER TEXT,
          $IMAGE_URL VARCHAR(255) NOT NULL,
          $PAYLOAD TEXT NOT NULL 
        );
      '''
    );
  }

  ///Answer Table
  Future createDeleteAnswerTable(db) async {
    await db.execute('''DROP TABLE IF EXISTS $DELETE_ANSWER_TABLE''');
    await db.execute(
        '''
        CREATE TABLE $DELETE_ANSWER_TABLE(
          $ANSWER_ID INTEGER PRIMARY KEY,
          $ANSWER_SERVER_ID INTEGER,
          $QUESTION_ID INTEGER NOT NULL,
          $EQUIPMENT_ID INTEGER,
          $VESSEL_ID INTEGER,
          $BODY_OF_WATER_ID INTEGER,
          $SIMPLE_LIST_ID INTEGER NOT NULL,
          $ANSWER TEXT,
          $IMAGE_URL VARCHAR(255) NOT NULL,
          $INSPECTION_ID INTEGER
        );
      '''
    );
  }

  ///Simple list Table
  Future createSimpleListTable(db) async {
    await db.execute('''DROP TABLE IF EXISTS $SIMPLE_LIST_TABLE''');
    await db.execute(
        '''
        CREATE TABLE $SIMPLE_LIST_TABLE(
          $SIMPLE_LIST_ID_P INTEGER PRIMARY KEY,
          $SIMPLE_LIST_ID_OPTION INTEGER,
          $SLUG TEXT,
          $SVG_ICON TEXT,
          $LEFT INTEGER,
          $RIGHT INTEGER,
          $IS_LIST TEXT,
          $LABEL TEXT
        );
      '''
    );
  }

  ///Body Of Water Table
  Future createBodyOfWaterTable(db) async {
    await db.execute('''DROP TABLE IF EXISTS $BODY_OF_WATER_TABLE''');
    await db.execute(
        '''
        CREATE TABLE $BODY_OF_WATER_TABLE(
          $BODY_OF_WATER_ID_LOCAL INTEGER PRIMARY KEY,
          $BODY_OF_WATER_ID_SERVER INTEGER,
          $URL VARCHAR(255) NOT NULL,
          $VERB VARCHAR(10) NOT NULL,
          $PAYLOAD TEXT NOT NULL,
          $SERVICE_ADDRESS_ID INTEGER
        );
      '''
    );
  }

  ///Vessel Table
  Future createVesselTable(db) async {
    await db.execute('''DROP TABLE IF EXISTS $VESSEL_TABLE''');
    await db.execute(
        '''
        CREATE TABLE $VESSEL_TABLE(
          $VESSEL_ID_LOCAL INTEGER PRIMARY KEY,
          $VESSEL_ID_SERVER INTEGER,
          $BODY_OF_WATER_ID_LOCAL INTEGER,
          $BODY_OF_WATER_ID_SERVER INTEGER,
          $VESSEL_NAME TEXT,
          $VESSEL_TYPE TEXT,
          $URL VARCHAR(255) NOT NULL,
          $VERB VARCHAR(10) NOT NULL,
          $PAYLOAD TEXT NOT NULL,
          $UNITS INTEGER,
          $WIDTH TEXT,
          $LENGTH TEXT,
          $DEPTH TEXT,
          $VOLUME TEXT
        );
      '''
    );
  }

  ///Equipment Table
  Future createEquipmentTable(db) async {
    await db.execute('''DROP TABLE IF EXISTS $EQUIPMENT_TABLE''');
    await db.execute(
        '''
        CREATE TABLE $EQUIPMENT_TABLE(
          $EQUIPMENT_ID_LOCAL INTEGER PRIMARY KEY,
          $EQUIPMENT_ID_SERVER INTEGER,
          $EQUIPMENT_TYPE_ID INTEGER,
          $VESSEL_ID_LOCAL INTEGER,
          $VESSEL_ID_SERVER INTEGER,
          $EQUIPMENT_GROUP_ID INTEGER,
          $EQUIPMENT_DESCRIPTION TEXT,
          $URL VARCHAR(255) NOT NULL,
          $VERB VARCHAR(10) NOT NULL,
          $PAYLOAD TEXT NOT NULL,
          $COMMENTS TEXT
        );
      '''
        
        ///Server.replace("$EQUIPMENT_ID_LOCAL", "$EQUIPMENT_ID_SERVER");
    );
  }

  ///Template List
  Future createTemplateListTable(db) async {
    await db.execute('''DROP TABLE IF EXISTS $TEMPLATE_LIST_TABLE''');
    await db.execute(
        '''
        CREATE TABLE $TEMPLATE_LIST_TABLE(
          $PROXY_ID INTEGER PRIMARY KEY,
          $PAYLOAD TEXT
        );
      '''
    );
  }

  ///Inspection List
  Future createInspectionListTable(db) async {
    await db.execute('''DROP TABLE IF EXISTS $INSPECTION_LIST_TABLE''');
    await db.execute(
        '''
        CREATE TABLE $INSPECTION_LIST_TABLE(
          $PROXY_ID INTEGER PRIMARY KEY,
          $PAYLOAD TEXT
        );
      '''
    );
  }

  ///Customer List
  Future createCustomerListTable(db) async {
    await db.execute('''DROP TABLE IF EXISTS $CUSTOMER_LIST_TABLE''');
    await db.execute(
        '''
        CREATE TABLE $CUSTOMER_LIST_TABLE(
          $PROXY_ID INTEGER PRIMARY KEY,
          $PAYLOAD TEXT
        );
      '''
    );
  }

  ///Company Detail
  Future createCompanyDetailTable(db) async {
    await db.execute('''DROP TABLE IF EXISTS $COMPANY_DETAIL_TABLE''');
    await db.execute(
        '''
        CREATE TABLE $COMPANY_DETAIL_TABLE(
          $PROXY_ID INTEGER PRIMARY KEY,
          $PAYLOAD TEXT
        );
      '''
    );
  }

  ///Profile Detail
  Future createProfileDetailTable(db) async {
    await db.execute('''DROP TABLE IF EXISTS $PROFILE_DETAIL_TABLE''');
    await db.execute(
        '''
        CREATE TABLE $PROFILE_DETAIL_TABLE(
          $PROXY_ID INTEGER PRIMARY KEY,
          $PAYLOAD TEXT
        );
      '''
    );
  }

  ///State List
  Future createStateListTable(db) async {
    await db.execute('''DROP TABLE IF EXISTS $STATE_LIST_TABLE''');
    await db.execute(
        '''
        CREATE TABLE $STATE_LIST_TABLE(
          $PROXY_ID INTEGER PRIMARY KEY,
          $PAYLOAD TEXT
        );
      '''
    );
  }

  ///Template Detail
  Future createTemplateDetailTable(db) async {
    await db.execute('''DROP TABLE IF EXISTS $TEMPLATE_DETAIL_TABLE''');
    await db.execute(
        '''
        CREATE TABLE $TEMPLATE_DETAIL_TABLE(
          $PROXY_ID INTEGER PRIMARY KEY,
          $TEMPLATE_ID INTEGER,
          $LAST_UPDATED VARCHAR(255),
          $PAYLOAD TEXT
        );
      '''
    );
  }

  ///Customer Detail
  Future createCustomerDetailTable(db) async {
    await db.execute('''DROP TABLE IF EXISTS $CUSTOMER_DETAIL_TABLE''');
    await db.execute(
        '''
        CREATE TABLE $CUSTOMER_DETAIL_TABLE(
          $PROXY_ID INTEGER PRIMARY KEY,
          $CUSTOMER_ID INTEGER,
          $LAST_UPDATED VARCHAR(255),
          $PAYLOAD TEXT
        );
      '''
    );
  }

  ///Inspection Id Table
  Future createInspectionIdTable(db) async {
    await db.execute('''DROP TABLE IF EXISTS $INSPECTION_ID_TABLE''');
    await db.execute(
        '''
        CREATE TABLE $INSPECTION_ID_TABLE(
          $PROXY_ID INTEGER PRIMARY KEY,
          $INSPECTION_LOCAL_ID INTEGER,
          $INSPECTION_SERVER_ID INTEGER,
          $IS_INSPECTION_SERVER_ID INTEGER,
          $INSPECTION_DEF_ID INTEGER,
          $SERVICE_ADDRESS_ID INTEGER,
          $URL VARCHAR(255) NOT NULL,
          $VERB VARCHAR(10) NOT NULL,
          $PAYLOAD TEXT
        );
      '''
    );
  }

  ///Started inspection detail
  Future createStartedInspectionTable(db) async {
    await db.execute('''DROP TABLE IF EXISTS $STARTED_INSPECTION_TABLE''');
    await db.execute(
        '''
        CREATE TABLE $STARTED_INSPECTION_TABLE(
          $PROXY_ID INTEGER PRIMARY KEY,
          $INSPECTION_ID INTEGER,
          $LAST_UPDATED VARCHAR(255),
          $PAYLOAD TEXT
        );
      '''
    );
  }

  ///Customer General Table
  Future createCustomerGeneralTable(db) async {
    await db.execute('''DROP TABLE IF EXISTS $CUSTOMER_GENERAL_TABLE''');
    await db.execute(
        '''
        CREATE TABLE $CUSTOMER_GENERAL_TABLE(
          $PROXY_ID INTEGER PRIMARY KEY,
          $CUSTOMER_LOCAL_ID INTEGER,
          $CUSTOMER_SERVER_ID INTEGER,
          $INSPECTION_DEF_ID INTEGER,
          $IS_CUSTOMER_SERVER_ID INTEGER,
          $URL VARCHAR(255) NOT NULL,
          $VERB VARCHAR(10) NOT NULL,
          $PAYLOAD TEXT
        );
      '''
    );
  }

  ///Service General Table
  Future createServiceAddressTable(db) async {
    await db.execute('''DROP TABLE IF EXISTS $SERVICE_GENERAL_TABLE''');
    await db.execute(
        '''
        CREATE TABLE $SERVICE_GENERAL_TABLE(
          $PROXY_ID INTEGER PRIMARY KEY,
          $SERVICE_LOCAL_ID INTEGER,
          $SERVICE_SERVER_ID INTEGER,
          $CUSTOMER_LOCAL_ID INTEGER,
          $CUSTOMER_SERVER_ID INTEGER,
          $INSPECTION_DEF_ID INTEGER,
          $IS_SERVICE_SERVER_ID INTEGER,
          $URL VARCHAR(255) NOT NULL,
          $VERB VARCHAR(10) NOT NULL,
          $PAYLOAD TEXT
        );
      '''
    );
  }

  ///Location Image Table
  Future createLocationImageTable(db) async {
    await db.execute('''DROP TABLE IF EXISTS $LOCATION_IMAGE_TABLE''');
    await db.execute(
        '''
        CREATE TABLE $LOCATION_IMAGE_TABLE(
          $PROXY_ID INTEGER PRIMARY KEY,
          $SERVICE_LOCAL_ID INTEGER,
          $SERVICE_SERVER_ID INTEGER,
          $CUSTOMER_LOCAL_ID INTEGER,
          $CUSTOMER_SERVER_ID INTEGER,
          $URL VARCHAR(255) NOT NULL,
          $VERB VARCHAR(10) NOT NULL,
          $IMAGE_PATH VARCHAR(255) NOT NULL,
          $PAYLOAD TEXT
        );
      '''
    );
  }

  ///Country Table
  Future createCountryTable(db) async {
    await db.execute('''DROP TABLE IF EXISTS $COUNTRY_TABLE''');
    await db.execute(
        '''
        CREATE TABLE $COUNTRY_TABLE(
          $COUNTRY_CODE VARCHAR(2) PRIMARY KEY,
          $COUNTRY_CODE_3 VARCHAR(3),
          $COUNTRY_NAME VARCHAR(80) NOT NULL,
          $COUNTRY_MIXED_CASE VARCHAR(80),
          $COUNTRY_FLAG VARCHAR(10),
          $COUNTRY_DIAL_CODE VARCHAR(20),
          $COUNTRY_POSTAL_CODE_REGEX VARCHAR(512)
        );
      '''
    );
  }

  ///State Table
  Future createStateTable(db) async {
    await db.execute('''DROP TABLE IF EXISTS $STATE_TABLE''');
    await db.execute(
        '''
        CREATE TABLE $STATE_TABLE(
          $STATE_ID INTEGER PRIMARY KEY,
          $COUNTRY_CODE VARCHAR(2) NOT NULL,
          $STATE_CODE VARCHAR(2),
          $STATE_NAME VARCHAR(80) NOT NULL,
          FOREIGN KEY($COUNTRY_CODE) REFERENCES $COUNTRY_TABLE($COUNTRY_CODE)
        );
      '''
    );
  }

  ///Alter table
  Future alterTableContent(db, type) async {
    try{
      log("table alter start from $type");

      ///Body Of Water Table
      if(await getTableInfo(BODY_OF_WATER_TABLE, CUSTOMER_LOCAL_ID, db) == 0) {
        await db.execute('''ALTER TABLE $BODY_OF_WATER_TABLE ADD COLUMN $CUSTOMER_LOCAL_ID INTEGER''');
      }
      if(await getTableInfo(BODY_OF_WATER_TABLE, SERVICE_LOCAL_ID, db) == 0) {
        await db.execute('''ALTER TABLE $BODY_OF_WATER_TABLE ADD COLUMN $SERVICE_LOCAL_ID INTEGER''');
      }

      ///Vessel Table
      if(await getTableInfo(VESSEL_TABLE, BODY_OF_WATER_ID_SERVER, db) == 0) {
        await db.execute('''ALTER TABLE $VESSEL_TABLE ADD COLUMN $BODY_OF_WATER_ID_SERVER INTEGER''');
      }
      if(await getTableInfo(VESSEL_TABLE, BODY_OF_WATER_ID_LOCAL, db) == 0) {
        await db.execute('''ALTER TABLE $VESSEL_TABLE ADD COLUMN $BODY_OF_WATER_ID_LOCAL INTEGER''');
      }
      if(await getTableInfo(VESSEL_TABLE, CUSTOMER_LOCAL_ID, db) == 0) {
        await db.execute('''ALTER TABLE $VESSEL_TABLE ADD COLUMN $CUSTOMER_LOCAL_ID INTEGER''');
      }
      if(await getTableInfo(VESSEL_TABLE, SERVICE_LOCAL_ID, db) == 0) {
        await db.execute('''ALTER TABLE $VESSEL_TABLE ADD COLUMN $SERVICE_LOCAL_ID INTEGER''');
      }

      ///Equipment Table
      if(await getTableInfo(EQUIPMENT_TABLE, VESSEL_ID_SERVER, db) == 0) {
        await db.execute('''ALTER TABLE $EQUIPMENT_TABLE ADD COLUMN $VESSEL_ID_SERVER INTEGER''');
      }
      if(await getTableInfo(EQUIPMENT_TABLE, VESSEL_ID_LOCAL, db) == 0) {
        await db.execute('''ALTER TABLE $EQUIPMENT_TABLE ADD COLUMN $VESSEL_ID_LOCAL INTEGER''');
      }
      if(await getTableInfo(EQUIPMENT_TABLE, CUSTOMER_LOCAL_ID, db) == 0) {
        await db.execute('''ALTER TABLE $EQUIPMENT_TABLE ADD COLUMN $CUSTOMER_LOCAL_ID INTEGER''');
      }
      if(await getTableInfo(EQUIPMENT_TABLE, SERVICE_LOCAL_ID, db) == 0) {
        await db.execute('''ALTER TABLE $EQUIPMENT_TABLE ADD COLUMN $SERVICE_LOCAL_ID INTEGER''');
      }

      ///Pending Table
      if(await getTableInfo(PENDING_TABLE, INDEX, db) == 0) {
        await db.execute('''ALTER TABLE $PENDING_TABLE ADD COLUMN $INDEX INTEGER''');
      }
      if(await getTableInfo(PENDING_TABLE, STATUS, db) == 0) {
        await db.execute('''ALTER TABLE $PENDING_TABLE ADD COLUMN $STATUS INTEGER''');
      }
      if(await getTableInfo(PENDING_TABLE, INSPECTION_LOCAL_ID, db) == 0) {
        await db.execute('''ALTER TABLE $PENDING_TABLE ADD COLUMN $INSPECTION_LOCAL_ID INTEGER''');
      }

      ///Answer Table
      if(await getTableInfo(ANSWER_TABLE, IMAGE_FILE_URL, db) == 0) {
        await db.execute('''ALTER TABLE $ANSWER_TABLE ADD COLUMN $IMAGE_FILE_URL TEXT''');
      }

      ///Delete Answer Table
      if(await getTableInfo(DELETE_ANSWER_TABLE, INSPECTION_ID, db) == 0) {
        await db.execute('''ALTER TABLE $DELETE_ANSWER_TABLE ADD COLUMN $INSPECTION_ID INTEGER''');
      }

      ///Inspection Table
      if(await getTableInfo(INSPECTION_ID_TABLE, SERVICE_LOCAL_ID, db) == 0) {
        await db.execute('''ALTER TABLE $INSPECTION_ID_TABLE ADD COLUMN $SERVICE_LOCAL_ID INTEGER''');
      }
      if(await getTableInfo(INSPECTION_ID_TABLE, IS_INSPECTION_SERVER_ID, db) == 0) {
        await db.execute('''ALTER TABLE $INSPECTION_ID_TABLE ADD COLUMN $IS_INSPECTION_SERVER_ID INTEGER''');
      }

      ///Customer Table
      if(await getTableInfo(CUSTOMER_GENERAL_TABLE, IS_CUSTOMER_SERVER_ID, db) == 0) {
        await db.execute('''ALTER TABLE $INSPECTION_ID_TABLE ADD COLUMN $IS_CUSTOMER_SERVER_ID INTEGER''');
      }

      ///Service Table
      if(await getTableInfo(SERVICE_GENERAL_TABLE, IS_SERVICE_SERVER_ID, db) == 0) {
        await db.execute('''ALTER TABLE $INSPECTION_ID_TABLE ADD COLUMN $IS_SERVICE_SERVER_ID INTEGER''');
      }

      ///Customer Detail Table
      if(await getTableInfo(CUSTOMER_DETAIL_TABLE, LAST_UPDATED, db) == 0) {
        await db.execute('''ALTER TABLE $CUSTOMER_DETAIL_TABLE ADD COLUMN $LAST_UPDATED VARCHAR(255)''');
      }

      ///Template Detail Table
      if(await getTableInfo(TEMPLATE_DETAIL_TABLE, LAST_UPDATED, db) == 0) {
        await db.execute('''ALTER TABLE $TEMPLATE_DETAIL_TABLE ADD COLUMN $LAST_UPDATED VARCHAR(255)''');
      }

      ///Started Inspection Detail Table
      if(await getTableInfo(STARTED_INSPECTION_TABLE, LAST_UPDATED, db) == 0) {
        await db.execute('''ALTER TABLE $STARTED_INSPECTION_TABLE ADD COLUMN $LAST_UPDATED VARCHAR(255)''');
      }

      ///Location Image Table
      // if(await getTableInfo(LOCATION_IMAGE_TABLE, IS_CUSTOMER_SERVER_ID, db) == 0) {
      //   await db.execute('''ALTER TABLE $LOCATION_IMAGE_TABLE ADD COLUMN $IS_CUSTOMER_SERVER_ID INTEGER''');
      // }
      // if(await getTableInfo(LOCATION_IMAGE_TABLE, IS_SERVICE_SERVER_ID, db) == 0) {
      //   await db.execute('''ALTER TABLE $LOCATION_IMAGE_TABLE ADD COLUMN $IS_SERVICE_SERVER_ID INTEGER''');
      // }

    } catch (e) {
      log("Alter table error $e");
    }
  }

  ///Pending Table Queries
  Future<int> insertPendingUrl1(pendingData, {equipmentId, vesselId}) async {
    Database db = await instance.database;
    log("PendingData====$pendingData");

    var fetchOneRecord;

    fetchOneRecord = await db.query("$PENDING_TABLE",
        where: '$INSPECTION_DEF_ID = ? AND $INSPECTION_ID = ? AND $QUESTION_ID = ?',
        whereArgs: [
          pendingData['inspectiondefid'],
          pendingData['inspectionid'],
          pendingData['questionid']
        ]);

    log("PendingResultResponse====$fetchOneRecord");
    var result;
    if(fetchOneRecord != null && fetchOneRecord.length > 0) {
      result = await db.update('$PENDING_TABLE', pendingData,
          where: '$INSPECTION_DEF_ID = ? AND $INSPECTION_ID = ? AND $QUESTION_ID = ?',
          whereArgs: [
            pendingData['inspectiondefid'],
            pendingData['inspectionid'],
            pendingData['questionid']
          ]);
      result = fetchOneRecord[0]['proxyid'];
      // print("UpdatedReturn===>>>$result");
    } else {
      result =  await db.rawInsert(
          "INSERT INTO $PENDING_TABLE ($INSPECTION_ID, $INSPECTION_DEF_ID, $SIMPLE_LIST_ID, $IMAGE_ID, $QUESTION_ID, $URL, $VERB, $PAYLOAD, $IMAGE_PATH, $NOTA_IMAGE_PATH)"
              " VALUES ('${pendingData['inspectionid']}', '${pendingData['inspectiondefid']}', '${pendingData['simplelistid']}', '${pendingData['image_id']}', '${pendingData['questionid']}', '${pendingData['url']}', '${pendingData['verb']}', '${pendingData['payload']}', '${pendingData['imagepath']}', '${pendingData['notaimagepath']}')"
      );
    }
    getAllPendingEndPoints();
    return result;
  }

  Future<int> insertPendingUrl(pendingData) async {
    Database db = await instance.database;
    // log("PendingData====$pendingData");

    var fetchOneRecord = await getPendingRecord(
        pendingData[INSPECTION_ID],
        pendingData[INSPECTION_DEF_ID],
        pendingData[QUESTION_ID],
        pendingData[VESSEL_ID],
        pendingData[EQUIPMENT_ID]
    );

    // log("PendingResultResponse====$fetchOneRecord");
    var result;
    if(fetchOneRecord != null && fetchOneRecord.length > 0) {
      if(pendingData[VESSEL_ID] != null && pendingData[EQUIPMENT_ID] != null) {
        result = await db.update('$PENDING_TABLE', pendingData,
            where: '$VESSEL_ID = ? AND $EQUIPMENT_ID = ? AND $INSPECTION_DEF_ID = ? AND $INSPECTION_ID = ? AND $QUESTION_ID = ?',
            whereArgs: [
              pendingData[VESSEL_ID],
              pendingData[EQUIPMENT_ID],
              pendingData[INSPECTION_DEF_ID],
              pendingData[INSPECTION_ID],
              pendingData[QUESTION_ID]
            ]);
        result = fetchOneRecord[0]['proxyid'];
        // print("UpdatedReturn===>>>$result");
      } else if(pendingData[VESSEL_ID] != null) {
        result = await db.update('$PENDING_TABLE', pendingData,
            where: '$VESSEL_ID = ? AND $INSPECTION_DEF_ID = ? AND $INSPECTION_ID = ? AND $QUESTION_ID = ?',
            whereArgs: [
              pendingData[VESSEL_ID],
              pendingData[INSPECTION_DEF_ID],
              pendingData[INSPECTION_ID],
              pendingData[QUESTION_ID]
            ]);
        result = fetchOneRecord[0]['proxyid'];
        // print("UpdatedReturn===>>>$result");
      } else if(pendingData[EQUIPMENT_ID] != null) {
        result = await db.update('$PENDING_TABLE', pendingData,
            where: '$EQUIPMENT_ID = ? AND $INSPECTION_DEF_ID = ? AND $INSPECTION_ID = ? AND $QUESTION_ID = ?',
            whereArgs: [
              pendingData[EQUIPMENT_ID],
              pendingData[INSPECTION_DEF_ID],
              pendingData[INSPECTION_ID],
              pendingData[QUESTION_ID]
            ]);
        result = fetchOneRecord[0]['proxyid'];
        // print("UpdatedReturn===>>>$result");
      } else {
        result = await db.update('$PENDING_TABLE', pendingData,
            where: '$INSPECTION_DEF_ID = ? AND $INSPECTION_ID = ? AND $QUESTION_ID = ?',
            whereArgs: [
              pendingData[INSPECTION_DEF_ID],
              pendingData[INSPECTION_ID],
              pendingData[QUESTION_ID]
            ]);
        result = fetchOneRecord[0]['proxyid'];
        // print("UpdatedReturn===>>>$result");
      }
    } else {
      result =  await db.rawInsert(
          "INSERT INTO $PENDING_TABLE ($INSPECTION_ID, $INSPECTION_DEF_ID, $EQUIPMENT_ID, $VESSEL_ID, $BODY_OF_WATER_ID, $SIMPLE_LIST_ID, $IMAGE_ID, $QUESTION_ID, $URL, $VERB, $PAYLOAD, $IMAGE_PATH, $NOTA_IMAGE_PATH)"
              " VALUES ('${pendingData['inspectionid']}', '${pendingData['inspectiondefid']}', '${pendingData[EQUIPMENT_ID]}', '${pendingData[VESSEL_ID]}', '${pendingData[BODY_OF_WATER_ID]}', '${pendingData['simplelistid']}', '${pendingData['image_id']}', '${pendingData['questionid']}', '${pendingData['url']}', '${pendingData['verb']}', '${pendingData['payload']}', '${pendingData['imagepath']}', '${pendingData['notaimagepath']}')"
      );
    }
    // getAllPendingEndPoints();
    return result;
  }

  Future getPendingRecord(inspectionid, inspectiondefid, questionid, vesselId, equipmentId) async {
    var fetchPendingRecord;
    Database db = await instance.database;

    if(vesselId != null && equipmentId != null) {
      fetchPendingRecord = await db.query("$PENDING_TABLE",
          where: '$VESSEL_ID = ? AND $EQUIPMENT_ID = ? AND $INSPECTION_DEF_ID = ? AND $INSPECTION_ID = ? AND $QUESTION_ID = ?',
          whereArgs: [
            vesselId,
            equipmentId,
            inspectiondefid,
            inspectionid,
            questionid
          ]);
    } else if(vesselId != null) {
      fetchPendingRecord = await db.query("$PENDING_TABLE",
          where: '$VESSEL_ID = ? AND $INSPECTION_DEF_ID = ? AND $INSPECTION_ID = ? AND $QUESTION_ID = ?',
          whereArgs: [
            vesselId,
            inspectiondefid,
            inspectionid,
            questionid
          ]);
    } else if(equipmentId != null) {
      fetchPendingRecord = await db.query("$PENDING_TABLE",
          where: '$EQUIPMENT_ID = ? AND $INSPECTION_DEF_ID = ? AND $INSPECTION_ID = ? AND $QUESTION_ID = ?',
          whereArgs: [
            equipmentId,
            inspectiondefid,
            inspectionid,
            questionid
          ]);
    } else {
      fetchPendingRecord = await db.query("$PENDING_TABLE",
          where: '$INSPECTION_DEF_ID = ? AND $INSPECTION_ID = ? AND $QUESTION_ID = ?',
          whereArgs: [
            inspectiondefid,
            inspectionid,
            questionid
          ]);
    }

    return fetchPendingRecord;
  }

  Future<List> getAllPendingEndPoints() async {
    Database db = await instance.database;
    var result = await db.query("$PENDING_TABLE");

    // log("getAllPendingEndPoints===>>Result===>>${result.toList()}");
    return result;
  }

  Future<List> getAllPendingAnswer() async {
    Database db = await instance.database;
    var result = await db.query("$ANSWER_TABLE");
    return result;
  }

  Future<int> deletePendingRequest(proxyid) async {
    Database db = await instance.database;
    var result = await db.delete("$PENDING_TABLE", where: "$PROXY_ID = ?", whereArgs: [proxyid]);

    return result;
  }

  Future deleteAllPendingRequest() async  {
    Database db = await instance.database;
    await db.delete(PENDING_TABLE);
  }

  Future<int> deleteAnswerRequest(proxyid) async {
    Database db = await instance.database;
    var result = await db.delete("$ANSWER_TABLE", where: "$PROXY_ID = ?", whereArgs: [proxyid]);

    return result;
  }

  Future deleteAnswerTableData() async  {
    Database db = await instance.database;
    await db.delete(ANSWER_TABLE);
  }

  Future deleteAllTableData(tableName) async {
    Database db = await instance.database;
    await db.delete(tableName);
  }

  Future<int> insertUpdateAnswerRecord(pendingAnswers) async {
    log("Hello111");
    var result;
    try {
      Database db = await instance.database;
      // log("PendingAnswerData====$pendingAnswers");
      var fetchOneRecord;
      if(pendingAnswers[VESSEL_ID] != null && pendingAnswers[EQUIPMENT_ID] != null) {
        fetchOneRecord = await db.query("$ANSWER_TABLE",
            where: '$PROXY_ID = ? AND $VESSEL_ID = ? AND $EQUIPMENT_ID = ? AND $INSPECTION_DEF_ID = ? AND $INSPECTION_ID = ? AND $QUESTION_ID = ?',
            whereArgs: [
              pendingAnswers[PROXY_ID],
              pendingAnswers[VESSEL_ID],
              pendingAnswers[EQUIPMENT_ID],
              pendingAnswers[INSPECTION_DEF_ID],
              pendingAnswers[INSPECTION_ID],
              pendingAnswers[QUESTION_ID]
            ]);
      } else if(pendingAnswers[VESSEL_ID] != null) {
        fetchOneRecord = await db.query("$ANSWER_TABLE",
            where: '$PROXY_ID = ? AND $VESSEL_ID = ? AND $INSPECTION_DEF_ID = ? AND $INSPECTION_ID = ? AND $QUESTION_ID = ?',
            whereArgs: [
              pendingAnswers[PROXY_ID],
              pendingAnswers[VESSEL_ID],
              pendingAnswers[INSPECTION_DEF_ID],
              pendingAnswers[INSPECTION_ID],
              pendingAnswers[QUESTION_ID]
            ]);
      } else if(pendingAnswers[EQUIPMENT_ID] != null) {
        fetchOneRecord = await db.query("$ANSWER_TABLE",
            where: '$PROXY_ID = ? AND $EQUIPMENT_ID = ? AND $INSPECTION_DEF_ID = ? AND $INSPECTION_ID = ? AND $QUESTION_ID = ?',
            whereArgs: [
              pendingAnswers[PROXY_ID],
              pendingAnswers[EQUIPMENT_ID],
              pendingAnswers[INSPECTION_DEF_ID],
              pendingAnswers[INSPECTION_ID],
              pendingAnswers[QUESTION_ID]
            ]);
      } else {
        fetchOneRecord = await db.query("$ANSWER_TABLE",
            where: '$PROXY_ID = ? AND $INSPECTION_DEF_ID = ? AND $INSPECTION_ID = ? AND $QUESTION_ID = ?',
            whereArgs: [
              pendingAnswers[PROXY_ID],
              pendingAnswers[INSPECTION_DEF_ID],
              pendingAnswers[INSPECTION_ID],
              pendingAnswers[QUESTION_ID]
            ]);
      }

      // log("SingleAnswerResponse====$fetchOneRecord");
      if (fetchOneRecord != null && fetchOneRecord.length > 0) {
        print("resulttest01====>");
        if(pendingAnswers[VESSEL_ID] != null && pendingAnswers[EQUIPMENT_ID] != null) {
          result = await db.update('$ANSWER_TABLE', pendingAnswers,
              where: '$PROXY_ID = ? AND $VESSEL_ID = ? AND $EQUIPMENT_ID = ? AND $INSPECTION_DEF_ID = ? AND $INSPECTION_ID = ? AND $QUESTION_ID = ?',
              whereArgs: [
                pendingAnswers[PROXY_ID],
                pendingAnswers[VESSEL_ID],
                pendingAnswers[EQUIPMENT_ID],
                pendingAnswers[INSPECTION_DEF_ID],
                pendingAnswers[INSPECTION_ID],
                pendingAnswers[QUESTION_ID]
              ]);
        } else if(pendingAnswers[VESSEL_ID] != null) {
          print("resulttest02====>");
          result = await db.update('$ANSWER_TABLE', pendingAnswers,
              where: '$PROXY_ID = ? AND $VESSEL_ID = ? AND $INSPECTION_DEF_ID = ? AND $INSPECTION_ID = ? AND $QUESTION_ID = ?',
              whereArgs: [
                pendingAnswers[PROXY_ID],
                pendingAnswers[VESSEL_ID],
                pendingAnswers[INSPECTION_DEF_ID],
                pendingAnswers[INSPECTION_ID],
                pendingAnswers[QUESTION_ID]
              ]);
        } else if(pendingAnswers[EQUIPMENT_ID] != null) {
          print("resulttest03====>");
          result = await db.update('$ANSWER_TABLE', pendingAnswers,
              where: '$PROXY_ID = ? AND $EQUIPMENT_ID = ? AND $INSPECTION_DEF_ID = ? AND $INSPECTION_ID = ? AND $QUESTION_ID = ?',
              whereArgs: [
                pendingAnswers[PROXY_ID],
                pendingAnswers[EQUIPMENT_ID],
                pendingAnswers[INSPECTION_DEF_ID],
                pendingAnswers[INSPECTION_ID],
                pendingAnswers[QUESTION_ID]
              ]);
        } else {
          print("resulttest04====>");
          result = await db.update('$ANSWER_TABLE', pendingAnswers,
              where: '$PROXY_ID = ? AND $INSPECTION_DEF_ID = ? AND $INSPECTION_ID = ? AND $QUESTION_ID = ?',
              whereArgs: [
                pendingAnswers[PROXY_ID],
                pendingAnswers[INSPECTION_DEF_ID],
                pendingAnswers[INSPECTION_ID],
                pendingAnswers[QUESTION_ID]
              ]);
          result = fetchOneRecord[0][PROXY_ID];
        }
        // print("AnswerUpdatedResult====>>>>$result");
      } else {
        print("resulttest05====>");
        result = await db.rawInsert(
            "INSERT INTO $ANSWER_TABLE ($PROXY_ID, $INSPECTION_DEF_ID, $INSPECTION_ID, $QUESTION_ID, $EQUIPMENT_ID, $VESSEL_ID, $BODY_OF_WATER_ID, $SIMPLE_LIST_ID, $ANSWER, $IMAGE_URL, $IMAGE_FILE_URL, $PAYLOAD)"
                " VALUES ('${pendingAnswers[PROXY_ID]}', '${pendingAnswers[INSPECTION_DEF_ID]}', '${pendingAnswers[INSPECTION_ID]}', '${pendingAnswers[QUESTION_ID]}', '${pendingAnswers[EQUIPMENT_ID]}', '${pendingAnswers[VESSEL_ID]}', '${pendingAnswers[BODY_OF_WATER_ID]}', '${pendingAnswers[SIMPLE_LIST_ID]}','${pendingAnswers[ANSWER]}','${pendingAnswers[IMAGE_URL]}','${pendingAnswers[IMAGE_FILE_URL]}','${pendingAnswers[PAYLOAD]}')"
        );
      }
      print("resulttest====>>$result");
    } catch (e) {
      log("insertUpdateAnswerRecordStackTrace====>>>>$e");
    }
    return result;
  }

  Future getAnswerRecord(pendingAnswers) async  {
    var result;
    try {
      Database db = await instance.database;
      // log("PendingAnswerData====$pendingAnswers");
      var fetchOneRecord;
      if(pendingAnswers[VESSEL_ID] != null && pendingAnswers[EQUIPMENT_ID] != null) {
        fetchOneRecord = await db.query("$ANSWER_TABLE",
            where: '$PROXY_ID = ? AND $VESSEL_ID = ? AND $EQUIPMENT_ID = ? AND $INSPECTION_DEF_ID = ? AND $INSPECTION_ID = ? AND $QUESTION_ID = ?',
            whereArgs: [
              pendingAnswers[PROXY_ID],
              pendingAnswers[VESSEL_ID],
              pendingAnswers[EQUIPMENT_ID],
              pendingAnswers[INSPECTION_DEF_ID],
              pendingAnswers[INSPECTION_ID],
              pendingAnswers[QUESTION_ID]
            ]);
      } else if(pendingAnswers[VESSEL_ID] != null) {
        fetchOneRecord = await db.query("$ANSWER_TABLE",
            where: '$PROXY_ID = ? AND $VESSEL_ID = ? AND $INSPECTION_DEF_ID = ? AND $INSPECTION_ID = ? AND $QUESTION_ID = ?',
            whereArgs: [
              pendingAnswers[PROXY_ID],
              pendingAnswers[VESSEL_ID],
              pendingAnswers[INSPECTION_DEF_ID],
              pendingAnswers[INSPECTION_ID],
              pendingAnswers[QUESTION_ID]
            ]);
      } else if(pendingAnswers[EQUIPMENT_ID] != null) {
        fetchOneRecord = await db.query("$ANSWER_TABLE",
            where: '$PROXY_ID = ? AND $EQUIPMENT_ID = ? AND $INSPECTION_DEF_ID = ? AND $INSPECTION_ID = ? AND $QUESTION_ID = ?',
            whereArgs: [
              pendingAnswers[PROXY_ID],
              pendingAnswers[EQUIPMENT_ID],
              pendingAnswers[INSPECTION_DEF_ID],
              pendingAnswers[INSPECTION_ID],
              pendingAnswers[QUESTION_ID]
            ]);
      } else {
        fetchOneRecord = await db.query("$ANSWER_TABLE",
            where: '$PROXY_ID = ? AND $INSPECTION_DEF_ID = ? AND $INSPECTION_ID = ? AND $QUESTION_ID = ?',
            whereArgs: [
              pendingAnswers[PROXY_ID],
              pendingAnswers[INSPECTION_DEF_ID],
              pendingAnswers[INSPECTION_ID],
              pendingAnswers[QUESTION_ID]
            ]);
      }

      log("FetchOneRecord==$fetchOneRecord");
    } catch (e) {
      // log("insertUpdateAnswerRecord StackTrace====>>>>$e");
    }
    return result;
  }

  Future fetchAnswerRecord(
      {inspectionDefId,
      inspectionId,
      questionId,
      bodyOfWaterId,
      vesselId,
      equipmentId}) async {
    try{
      Database db = await instance.database;
      log("inspectionDefId===${inspectionDefId.runtimeType}, "
          "InspectionId===${inspectionId.runtimeType}, questionId===${questionId.runtimeType}, "
          "bodyOfWaterId===${bodyOfWaterId.runtimeType}, vesselId===${vesselId.runtimeType}, "
          "equipmentId===${equipmentId.runtimeType}");

      var result;
      if(bodyOfWaterId == null && vesselId == null && equipmentId == null) {
        result = await db.rawQuery('''
              select * from $ANSWER_TABLE
              where $INSPECTION_DEF_ID = "$inspectionDefId"
              and $INSPECTION_ID = "$inspectionId"
              and $QUESTION_ID = "$questionId" 
          ''');
      } else if(vesselId == null && equipmentId == null) {
        result = await db.rawQuery('''
              select * from $ANSWER_TABLE
              where $INSPECTION_DEF_ID = "$inspectionDefId"
              and $INSPECTION_ID = "$inspectionId"
              and $QUESTION_ID = "$questionId" 
              and $BODY_OF_WATER_ID = "$bodyOfWaterId" 
          ''');
      }  else if(equipmentId == null) {
        result = await db.rawQuery('''
              select * from $ANSWER_TABLE
              where $INSPECTION_DEF_ID = "$inspectionDefId"
              and $INSPECTION_ID = "$inspectionId"
              and $QUESTION_ID = "$questionId" 
              and $BODY_OF_WATER_ID = "$bodyOfWaterId" 
              and $VESSEL_ID = "$vesselId" 
          ''');
      } else {
        result = await db.rawQuery('''
              select * from $ANSWER_TABLE
              where $INSPECTION_DEF_ID = "$inspectionDefId"
              and $INSPECTION_ID = "$inspectionId"
              and $QUESTION_ID = "$questionId" 
              and $BODY_OF_WATER_ID = "$bodyOfWaterId" 
              and $VESSEL_ID = "$vesselId" 
              and $EQUIPMENT_ID = "$equipmentId" 
          ''');
      }

      log("fetchAnswerRecordResultDetail====$result");

      return result;
    } catch(e) {
      log("fetchAnswerRecordStackTrace===$e");
    }

    return null;
  }

  Future deleteAnswerRecord(
      {inspectionDefId,
        inspectionId,
        questionId,
        bodyOfWaterId,
        vesselId,
        equipmentId}) async {
    try{
      Database db = await instance.database;

      var result;
      if(bodyOfWaterId == null && vesselId == null && equipmentId == null) {
        result = await db.rawQuery('''
              delete from $ANSWER_TABLE
              where $INSPECTION_DEF_ID = "$inspectionDefId"
              and $INSPECTION_ID = "$inspectionId"
              and $QUESTION_ID = "$questionId" 
          ''');
      } else if(vesselId == null && equipmentId == null) {
        result = await db.rawQuery('''
              delete from $ANSWER_TABLE
              where $INSPECTION_DEF_ID = "$inspectionDefId"
              and $INSPECTION_ID = "$inspectionId"
              and $QUESTION_ID = "$questionId" 
              and $BODY_OF_WATER_ID = "$bodyOfWaterId" 
          ''');
      }  else if(equipmentId == null) {
        result = await db.rawQuery('''
              delete from $ANSWER_TABLE
              where $INSPECTION_DEF_ID = "$inspectionDefId"
              and $INSPECTION_ID = "$inspectionId"
              and $QUESTION_ID = "$questionId" 
              and $BODY_OF_WATER_ID = "$bodyOfWaterId" 
              and $VESSEL_ID = "$vesselId" 
          ''');
      } else {
        result = await db.rawQuery('''
              delete from $ANSWER_TABLE
              where $INSPECTION_DEF_ID = "$inspectionDefId"
              and $INSPECTION_ID = "$inspectionId"
              and $QUESTION_ID = "$questionId" 
              and $BODY_OF_WATER_ID = "$bodyOfWaterId" 
              and $VESSEL_ID = "$vesselId" 
              and $EQUIPMENT_ID = "$equipmentId" 
          ''');
      }

      log("fetchAnswerRecordResultDetail====$result");

      return result;
    } catch(e) {
      log("fetchAnswerRecordStackTrace===$e");
    }

    return null;
  }

  Future allAnswerRecord() async {
    Database db = await instance.database;

    var result = await db.rawQuery('''
          select * from $ANSWER_TABLE 
      ''');

    return result;
  }

  Future<int> deleteBooleanChildrenData({
    vesselId,
    equipmentId,
    inspectiondefid,
    inspectionid,
    questionid
  }) async {
    Database db = await instance.database;
    var result;

    if(vesselId != null && equipmentId != null) {
      result = await db.delete("$PENDING_TABLE",
          where: '$VESSEL_ID = ? AND $EQUIPMENT_ID = ? AND $INSPECTION_DEF_ID = ? AND $INSPECTION_ID = ? AND $QUESTION_ID = ?',
          whereArgs: [
            vesselId,
            equipmentId,
            inspectiondefid,
            inspectionid,
            questionid
          ]);
    } else if(vesselId != null) {
      result = await db.delete("$PENDING_TABLE",
          where: '$VESSEL_ID = ? AND $INSPECTION_DEF_ID = ? AND $INSPECTION_ID = ? AND $QUESTION_ID = ?',
          whereArgs: [
            vesselId,
            inspectiondefid,
            inspectionid,
            questionid
          ]);
    } else if(equipmentId != null) {
      result = await db.delete("$PENDING_TABLE",
          where: '$EQUIPMENT_ID = ? AND $INSPECTION_DEF_ID = ? AND $INSPECTION_ID = ? AND $QUESTION_ID = ?',
          whereArgs: [
            equipmentId,
            inspectiondefid,
            inspectionid,
            questionid
          ]);
    } else {
      result = await db.delete("$PENDING_TABLE",
          where: '$INSPECTION_DEF_ID = ? AND $INSPECTION_ID = ? AND $QUESTION_ID = ?',
          whereArgs: [
            inspectiondefid,
            inspectionid,
            questionid
          ]);
    }
    return result;
  }

  ///*** Start
  /// * Only for Single and Multiple selection block
  ///***
  Future insertSingleMultiplePendingRecord(pendingData) async {
    Database db = await instance.database;
    // log("PendingData====$pendingData");
    var result;

    result =  await db.rawInsert(
        "INSERT INTO $PENDING_TABLE ($INSPECTION_ID, $INSPECTION_DEF_ID, $EQUIPMENT_ID, $VESSEL_ID, $BODY_OF_WATER_ID, $SIMPLE_LIST_ID, $IMAGE_ID, $QUESTION_ID, $URL, $VERB, $PAYLOAD, $IMAGE_PATH, $NOTA_IMAGE_PATH)"
            " VALUES ('${pendingData[INSPECTION_ID]}', '${pendingData[INSPECTION_DEF_ID]}', '${pendingData[EQUIPMENT_ID]}', '${pendingData[VESSEL_ID]}', '${pendingData[BODY_OF_WATER_ID]}', '${pendingData[SIMPLE_LIST_ID]}', '${pendingData[IMAGE_ID]}', '${pendingData[QUESTION_ID]}', '${pendingData[URL]}', '${pendingData[VERB]}', '${pendingData[PAYLOAD]}', '${pendingData[IMAGE_PATH]}', '${pendingData[NOTA_IMAGE_PATH]}')"
    );
    getAllPendingEndPoints();
    return result;
  }

  Future getMultiplePendingResult(inspectionid, questionid, simplelistid, vesselId, equipmentId) async {
    Database db = await instance.database;
    var fetchPendingRecord;

    if(vesselId != null && equipmentId != null) {
      fetchPendingRecord = await db.query("$PENDING_TABLE",
          where: '$VESSEL_ID = ? AND $EQUIPMENT_ID = ? AND $SIMPLE_LIST_ID = ? AND $INSPECTION_ID = ? AND $QUESTION_ID = ?',
          whereArgs: [
            vesselId,
            equipmentId,
            simplelistid,
            inspectionid,
            questionid
          ]);
    } else if(vesselId != null) {
      fetchPendingRecord = await db.query("$PENDING_TABLE",
          where: '$VESSEL_ID = ? AND $SIMPLE_LIST_ID = ? AND $INSPECTION_ID = ? AND $QUESTION_ID = ?',
          whereArgs: [
            vesselId,
            simplelistid,
            inspectionid,
            questionid
          ]);
    } else if(equipmentId != null) {
      fetchPendingRecord = await db.query("$PENDING_TABLE",
          where: '$EQUIPMENT_ID = ? AND $SIMPLE_LIST_ID = ? AND $INSPECTION_ID = ? AND $QUESTION_ID = ?',
          whereArgs: [
            equipmentId,
            simplelistid,
            inspectionid,
            questionid
          ]);
    } else {
      fetchPendingRecord = await db.query("$PENDING_TABLE",
          where: '$SIMPLE_LIST_ID = ? AND $INSPECTION_ID = ? AND $QUESTION_ID = ?',
          whereArgs: [
            simplelistid,
            inspectionid,
            questionid
          ]);
    }

    return fetchPendingRecord;
  }

  Future getSinglePendingResult(inspectionid, questionid, vesselId, equipmentId) async {
    Database db = await instance.database;
    var fetchPendingRecord;

    if(vesselId != null && equipmentId != null) {
      fetchPendingRecord = await db.rawQuery('''
        select * from $PENDING_TABLE where $VESSEL_ID = $vesselId and 
        $EQUIPMENT_ID = $equipmentId AND $INSPECTION_ID = $inspectionid AND $QUESTION_ID = $questionid 
      ''');
    }

    if(vesselId != null && equipmentId != null) {
      fetchPendingRecord = await db.query("$PENDING_TABLE",
          where: '$VESSEL_ID = ? AND $EQUIPMENT_ID = ? AND $INSPECTION_ID = ? AND $QUESTION_ID = ?',
          whereArgs: [
            vesselId,
            equipmentId,
            inspectionid,
            questionid
          ]);
    } else if(vesselId != null) {
      fetchPendingRecord = await db.query("$PENDING_TABLE",
          where: '$VESSEL_ID = ? AND $INSPECTION_ID = ? AND $QUESTION_ID = ?',
          whereArgs: [
            vesselId,
            inspectionid,
            questionid
          ]);
    } else if(equipmentId != null) {
      fetchPendingRecord = await db.query("$PENDING_TABLE",
          where: '$EQUIPMENT_ID = ? AND $INSPECTION_ID = ? AND $QUESTION_ID = ?',
          whereArgs: [
            equipmentId,
            inspectionid,
            questionid
          ]);
    } else {
      fetchPendingRecord = await db.query("$PENDING_TABLE",
          where: '$INSPECTION_ID = ? AND $QUESTION_ID = ?',
          whereArgs: [
            inspectionid,
            questionid
          ]);
    }

    return fetchPendingRecord;
  }

///***  End
///***  Only for Single and Multiple selection block
///***

///***  Begin
///***  SIMPLE List Table Queries
///***
  Future insertAllSimpleListRecord(simpleListData) async {
    var result;
    try {
      Database db = await instance.database;
      log("PendingData====$simpleListData");

      // Billed on the 1st of the month for prior month's service
      var fetchOneRecord = await db.query("$SIMPLE_LIST_TABLE",
          where: '$SIMPLE_LIST_ID = ?',
          whereArgs: [
            simpleListData[SIMPLE_LIST_ID]
          ]);

      if(fetchOneRecord != null && fetchOneRecord.length > 0) {
        print("Record already available");
      } else {
        var labelData = "${simpleListData[LABEL].toString().replaceAll("'", '##').replaceAll('"', "@@")}";
        result = await db.rawInsert(
            "INSERT INTO $SIMPLE_LIST_TABLE ($SIMPLE_LIST_ID_OPTION, $SLUG, $SVG_ICON, $LEFT, $RIGHT, $IS_LIST, $LABEL)"
                " VALUES ('${simpleListData[SIMPLE_LIST_ID_OPTION]}', '${simpleListData[SLUG]}', '${simpleListData[SVG_ICON]}', '${simpleListData[LEFT]}', '${simpleListData[RIGHT]}', '${simpleListData[IS_LIST]}', '$labelData')"
        );
      }
    } catch (e) {
      log("Stacktrace===$e");
    }

    return result;
  }

  Future insertSimpleListRecordIntoLocalDb(simpleListData) async {
    var result;
    try {
      Database db = await instance.database;

      await db.delete(SIMPLE_LIST_TABLE, where: "$SIMPLE_LIST_ID_OPTION = ?", whereArgs: ["${simpleListData['$SIMPLE_LIST_ID_OPTION']}"]);

      var labelData = "${simpleListData[LABEL].toString().replaceAll("'", '##').replaceAll('"', "@@")}";
      result = await db.rawInsert(
          "INSERT INTO $SIMPLE_LIST_TABLE ($SIMPLE_LIST_ID_OPTION, $SLUG, $SVG_ICON, $LEFT, $RIGHT, $IS_LIST, $LABEL)"
              " VALUES ('${simpleListData[SIMPLE_LIST_ID_OPTION]}', '${simpleListData[SLUG]}', '${simpleListData[SVG_ICON]}', '${simpleListData[LEFT]}', '${simpleListData[RIGHT]}', '${simpleListData[IS_LIST]}', '$labelData')"
      );
    } catch (e) {
      log("Stacktrace===$e");
    }

    return result;
  }
  Future getCheckSingleSimpleList() async {
    Database db = await instance.database;
    var result = await db.query("$SIMPLE_LIST_TABLE", where: "simplelistid = ?", whereArgs: ["615"]);

    // log("getSingleSimpleList===>>Result===>>${result.toList()}");
    return result;
  }

  Future getSingleSimpleList() async {
    Database db = await instance.database;
    var result = await db.query("$SIMPLE_LIST_TABLE");

    log("getSingleSimpleList===>>Result===>>${result.toList()}");
    return result;
  }

  Future getTotalCountSimpleList() async {
    Database db = await instance.database;
    var result = await db.rawQuery("SELECT COUNT(*) as NUM FROM $SIMPLE_LIST_TABLE");

    log("Length===>>Result===>>$result");
    return result;
  }

  Future fetchAllSimpleList() async {
    Database db = await instance.database;
    var result = await db.rawQuery("select * from $SIMPLE_LIST_TABLE");
    log("fetchAllSimpleList===>>Result===>>${result.toList()}");

    return result;
  }

  Future getSelectedSimpleList(id) async {
    Database db = await instance.database;
    var result = await db.rawQuery(
      "WITH parent AS ("
        "SELECT lft,rgt"
        " FROM $SIMPLE_LIST_TABLE"
        " WHERE simplelistid=$id"
      ")"
      "SELECT "
      "simplelist.simplelistid, "
      "simplelist.svgicon, "
      "simplelist.lft, "
      "simplelist.label, "
      "simplelist.rgt "
      "FROM parent "
      "INNER JOIN simplelist "
      "ON simplelist.lft BETWEEN parent.lft AND parent.rgt "
      "ORDER BY simplelist.lft"
    );

    // log("getSingleSimpleList===>>Result===>>${result.toList()}");
    return result;
  }

  Future getMultiListData([simpleListId="719"]) async {
    Database db = await instance.database;
    var result = await db.rawQuery('''
        select $SIMPLE_LIST_TABLE.* 
        from $SIMPLE_LIST_TABLE child 
        inner join $SIMPLE_LIST_TABLE parent 
        on child.lft between parent.lft and parent.rgt 
        inner join $SIMPLE_LIST_TABLE 
        on parent.simplelistid=$SIMPLE_LIST_TABLE.simplelistid  
        where 
        child.simplelistid=$simpleListId 
        order by parent.lft
    ''');

    // result = result.map((element) => Map<String, dynamic>.of(element)).toList();
    //
    // var transformedData = adjacencyTransform(result);
    // JsonEncoder encoder = JsonEncoder.withIndent('  ');
    // log("DbResult === ${encoder.convert(transformedData)}");
    // log("DbResultType === ${transformedData.runtimeType}");
    return result;
  }

  Future deleteSimpleListTable() async {
    Database db = await instance.database;
    await db.delete(SIMPLE_LIST_TABLE);
  }

  /// Begin
  /// Body of water items
  ///
  Future insertBodyOfWaterData(bodyData) async {
    var result;
    try {
      Database db = await instance.database;

      log("BodyData====${bodyData['bodyofwaterid']}");
      result = await db.rawInsert(
          "INSERT INTO $BODY_OF_WATER_TABLE ($BODY_OF_WATER_ID_SERVER, $PAYLOAD, $VERB, $URL, $CUSTOMER_LOCAL_ID, $SERVICE_LOCAL_ID, $SERVICE_ADDRESS_ID)"
              " VALUES ('${bodyData[BODY_OF_WATER_ID_SERVER]}', '${bodyData[PAYLOAD]}', '${bodyData[VERB]}', '${bodyData[URL]}', '${bodyData[CUSTOMER_LOCAL_ID]}', '${bodyData[SERVICE_LOCAL_ID]}', '${bodyData[SERVICE_ADDRESS_ID]}')"
      );
    } catch (e) {
      log("Stacktrace===$e");
    }

    return result;
  }

  Future deleteBodyOfWaterData() async  {
    Database db = await instance.database;
    await db.delete(BODY_OF_WATER_TABLE);
  }

  Future<List> getPendingBodyOfWaterData() async {
    Database db = await instance.database;
    var result = await db.query("$BODY_OF_WATER_TABLE");

    log("BodyOfWaterData=====$result");
    return result;
  }

  Future<List> getSingleBodyOfWaterRecord(id) async {
    var result;
    try {
      Database db = await instance.database;
      result = await db.query(BODY_OF_WATER_TABLE,
          where: '$BODY_OF_WATER_ID_LOCAL = ?',
          whereArgs: [int.parse("$id")]
      );

      print("Record===$result");
    } catch(e) {
      log("BodyOfWaterDBIssue====$e");
    }
    return result;
  }

  Future updateBodyOfWaterRecord(id, bodyOfWaterId) async {
    Database db = await instance.database;
    var result = await db.rawUpdate('''
        UPDATE $BODY_OF_WATER_TABLE 
        SET $BODY_OF_WATER_ID_SERVER = ? 
        WHERE $BODY_OF_WATER_ID_LOCAL = ? 
      ''',
      ['$bodyOfWaterId', '$id']
    );

    return result;
  }

  /// Begin
  /// Vessel items
  ///
  Future insertVesselsData(vesselData) async {
    var result;
    try {
      Database db = await instance.database;

      result = await db.rawInsert(
          "INSERT INTO $VESSEL_TABLE ($VESSEL_ID_SERVER, $BODY_OF_WATER_ID_LOCAL, $BODY_OF_WATER_ID_SERVER, $VESSEL_NAME, $CUSTOMER_LOCAL_ID, $SERVICE_LOCAL_ID, $VESSEL_TYPE, $UNITS, $PAYLOAD, $VERB, $URL)"
              " VALUES ('${vesselData[VESSEL_ID_SERVER]}', '${vesselData[BODY_OF_WATER_ID_LOCAL]}', '${vesselData[BODY_OF_WATER_ID_SERVER]}', '${vesselData[VESSEL_NAME]}', '${vesselData[CUSTOMER_LOCAL_ID]}', '${vesselData[SERVICE_LOCAL_ID]}', '${vesselData['vesseltypeloc']}', '${vesselData[UNITS]}', '${vesselData[PAYLOAD]}', '${vesselData[VERB]}', '${vesselData[URL]}')"
      );
    } catch (e) {
      log("Stacktrace===$e");
    }

    return result;
  }

  Future deleteVesselsData() async  {
    Database db = await instance.database;
    await db.delete(VESSEL_TABLE);
  }

  Future<List> getAllPendingVesselData() async {
    Database db = await instance.database;
    var result = await db.query("$VESSEL_TABLE");

    log("vesselData=====$result");
    return result;
  }

  Future<List> getSingleVesselRecord(id) async {
    var result;
    try {
      Database db = await instance.database;
      result = await db.query(VESSEL_TABLE,
          where: '$VESSEL_ID_LOCAL = ?',
          whereArgs: [int.parse("$id")]
      );
    }catch (e){
      log("DatabaseIssue====$e");
    }

    print("Record===$result");
    return result;
  }

  Future updateVesselRecord(id, vesselId) async {
    Database db = await instance.database;
    var result = await db.rawUpdate('''
        UPDATE $VESSEL_TABLE 
        SET $VESSEL_ID_SERVER = ? 
        WHERE $VESSEL_ID_LOCAL = ? 
      ''',
      ['$vesselId', '$id']
    );

    return result;
  }

  /// Begin
  /// Equipment items
  ///
  Future insertEquipmentData(equipmentData) async {
    var result;
    try {
      Database db = await instance.database;

      result = await db.rawInsert(
          "INSERT INTO $EQUIPMENT_TABLE ($EQUIPMENT_ID_SERVER, $VESSEL_ID_LOCAL, $VESSEL_ID_SERVER, $CUSTOMER_LOCAL_ID, $SERVICE_LOCAL_ID, $EQUIPMENT_TYPE_ID, $EQUIPMENT_GROUP_ID, $EQUIPMENT_DESCRIPTION, $COMMENTS, $PAYLOAD, $VERB, $URL)"
              " VALUES ('${equipmentData[EQUIPMENT_ID_SERVER]}', '${equipmentData[VESSEL_ID_LOCAL]}', '${equipmentData[VESSEL_ID_SERVER]}', '${equipmentData[CUSTOMER_LOCAL_ID]}', '${equipmentData[SERVICE_LOCAL_ID]}', '${equipmentData[EQUIPMENT_TYPE_ID]}', '${equipmentData[EQUIPMENT_GROUP_ID]}', '${equipmentData[EQUIPMENT_DESCRIPTION]}', '${equipmentData[COMMENTS]}',  '${equipmentData[PAYLOAD]}',  '${equipmentData[VERB]}', '${equipmentData[URL]}')"
      );
    } catch (e) {
      log("Stacktrace===$e");
    }

    return result;
  }

  Future deleteEquipmentsData() async  {
    Database db = await instance.database;
    await db.delete(EQUIPMENT_TABLE);
  }

  Future<List> getAllPendingEquipmentData() async {
    Database db = await instance.database;
    var result = await db.query("$EQUIPMENT_TABLE");

    log("EquipmentData=====$result");
    return result;
  }

  Future<List> getSingleEquipmentRecord(id) async {
    var result;
    try {
      Database db = await instance.database;
      result = await db.query(EQUIPMENT_TABLE,
          where: '$EQUIPMENT_ID_LOCAL = ?',
          whereArgs: [int.parse("$id")]
      );

      // print("Record===$result");
    } catch (e) {
      log("EquipmentIssue====$e");
    }
    return result;
  }

  Future updateEquipmentRecord(id, equipmentId) async {
    Database db = await instance.database;
    var result = await db.rawUpdate('''
        UPDATE $EQUIPMENT_TABLE 
        SET $EQUIPMENT_ID_SERVER = ? 
        WHERE $EQUIPMENT_ID_LOCAL = ? 
      ''',
      ['$equipmentId', '$id']
    );

    return result;
  }

  ///Delete Answer Record
  Future insertRecordIntoDeleteTable(deleteAnswerRecord) async {
    var result;
    try {
      Database db = await instance.database;

      result = await db.rawInsert(
          "INSERT INTO $DELETE_ANSWER_TABLE ($ANSWER_SERVER_ID, $INSPECTION_ID, $QUESTION_ID, $VESSEL_ID, $EQUIPMENT_ID, $BODY_OF_WATER_ID, $SIMPLE_LIST_ID, $ANSWER, $IMAGE_URL)"
              " VALUES ('${deleteAnswerRecord[EQUIPMENT_ID_SERVER]}', '${deleteAnswerRecord[INSPECTION_ID]}', '${deleteAnswerRecord[QUESTION_ID]}', '${deleteAnswerRecord[VESSEL_ID]}', '${deleteAnswerRecord[EQUIPMENT_ID]}', '${deleteAnswerRecord[BODY_OF_WATER_ID]}', '${deleteAnswerRecord[SIMPLE_LIST_ID]}', '${deleteAnswerRecord[ANSWER]}', '${deleteAnswerRecord[IMAGE_URL]}')"
      );
    } catch (e) {
      log("Stacktrace===$e");
    }

    return result;
  }

  Future<List> getAllDeleteAnswerData() async {
    Database db = await instance.database;
    var result = await db.query("$DELETE_ANSWER_TABLE");

    log("EquipmentData=====$result");
    return result;
  }

  Future deleteDeleteAnswerTableData() async  {
    Database db = await instance.database;
    await db.delete(DELETE_ANSWER_TABLE);
  }

  Future<int> deleteAnswerRequestWithId(answerId) async {
    Database db = await instance.database;
    var result = await db.delete("$DELETE_ANSWER_TABLE", where: "$ANSWER_SERVER_ID = ?", whereArgs: [answerId]);

    return result;
  }

  Map<String, dynamic> adjacencyTransform(List<dynamic> nsResult) {
    try {
      int ix = 0;
      void build(Map<String, dynamic> container) {
        container["children"] = [];
        if (container["rgt"] - container["lft"] < 2) {
          return;
        }

        while ((++ix < nsResult.length) &&
            (nsResult[ix]["lft"] > container["lft"]) &&
            (nsResult[ix]["rgt"] < container["rgt"])) {

          try {
            var entries = nsResult[ix]['label'].toString()
                .substring(1,nsResult[ix]['label'].length-1)
                .split(RegExp(r',\s?'))
                .map((e) => e.split(RegExp(r':\s?')))
                .map((e) => MapEntry(e.first, e.last));
            var result = Map.fromEntries(entries);

            var newData = jsonDecode(json.encode(result));
            nsResult[ix]['label'] = newData;
          } catch(e) {
            log("StackTraceMapEntryMultiple====$e");
          }
          container["children"].add(nsResult[ix]);
          build(nsResult[ix]);
        }

        if (ix < nsResult.length) {
          ix--;
        }
      }

      if (nsResult.length > 0) {
        build(nsResult[0]);
        return nsResult[0];
      }
    } catch(e) {
      log("StackTrace====$e");
    }

    return {"children":[]};
  }

  Future getTableInfo(tableName, columnName, [database]) async {
    try{
      Database db = database == null ? await instance.database : database;

      // if(db == null) {
      //   db = await instance.database;
      // }

      // var result = await db.rawQuery('''PRAGMA table_info($tableName)''');

      var result = await db.rawQuery("SELECT count(*) as columnName FROM pragma_table_info('$tableName') where name='$columnName'");
      // log("checkImageUrlField ==== ${result[0]['name']}");

      log("getTableInfo Result====$result");
      int count = Sqflite.firstIntValue(result);
      log("getTableInfo Count====$count");
      return count ?? 0;
    } catch (e) {
      log("getTableInfoStackTrace====$e");
      return 0;
    }

    // return 0;
  }

  ///Inspection ID Table Method
  Future insertInspectionId(inspectionData) async {
    var result;
    var inspectionId = 1;
    try {
      Database db = await instance.database;
      log("inspectionData===$inspectionData");

      if("${inspectionData['$IS_INSPECTION_SERVER_ID']}" == "0") {
        var highestRecord = await db.rawQuery("SELECT COUNT(1) as NUM FROM $INSPECTION_ID_TABLE");
        inspectionId = highestRecord == null ? 1 : (int.parse("${highestRecord[0]['NUM']}") + 1);
      } else {
        inspectionId = int.parse("${inspectionData['$INSPECTION_SERVER_ID'] ?? 1}");
      }
      result = await db.rawInsert(
          "INSERT INTO $INSPECTION_ID_TABLE ($INSPECTION_LOCAL_ID, $IS_INSPECTION_SERVER_ID, $INSPECTION_SERVER_ID, $SERVICE_ADDRESS_ID, $SERVICE_LOCAL_ID, $URL, $VERB, $INSPECTION_DEF_ID, $PAYLOAD)"
              " VALUES ('$inspectionId', '${inspectionData['$IS_INSPECTION_SERVER_ID']}', '${inspectionData['$INSPECTION_SERVER_ID']}', '${inspectionData['$SERVICE_ADDRESS_ID']}', '${inspectionData['$SERVICE_LOCAL_ID']}', '${inspectionData['$URL']}', '${inspectionData['$VERB']}', '${inspectionData['$INSPECTION_DEF_ID']}', '${inspectionData['$PAYLOAD']}')"
      );
    }catch(e) {
      log("insertInspectionIdStackTrace====$e");
    }

    return inspectionId;
  }

  Future getInspectionIdLocalRecord() async {
    var result;
    try {
      Database db = await instance.database;
      result = await db.query(INSPECTION_ID_TABLE,
          where: '$IS_INSPECTION_SERVER_ID = ?',
          whereArgs: [0]
      );

      print("Record===$result");
    } catch(e) {
      log("getInspectionIdLocalRecordIssues====$e");
    }
    return result;
  }

  Future fetchInspectionIdRecord() async {
    try{
      Database db = await instance.database;

      var highestRecord = await db.rawQuery("SELECT COUNT(1) as NUM FROM $INSPECTION_ID_TABLE");

      log("HighestRecord====$highestRecord");
      log("HighestRecordType====${highestRecord.runtimeType}");
      log("HighestRecordType====${int.parse("${highestRecord[0]["NUM"]}") + 1}");
    } catch(e) {
      log("StackTraceFetchRecord===$e");
    }
  }

  Future<List> getInspectionIdData() async {
    Database db = await instance.database;
    var result = await db.query("$INSPECTION_ID_TABLE");

    log("getInspectionIdData=====$result");
    return result;
  }

  Future<List> getSingleInspectionIdRecord(id) async {
    var result;
    try {
      Database db = await instance.database;
      result = await db.query(INSPECTION_ID_TABLE,
          where: '$INSPECTION_LOCAL_ID = ?',
          whereArgs: [int.parse("$id")]
      );

      print("Record===$result");
    } catch(e) {
      log("getSingleInspectionIdRecordIssues====$e");
    }
    return result;
  }

  Future updateInspectionIdDataRecord(inspectionLocalId, inspectionServerId) async {
    Database db = await instance.database;
    var result = await db.rawUpdate('''
        UPDATE $INSPECTION_ID_TABLE 
        SET $INSPECTION_SERVER_ID = ? 
        WHERE $INSPECTION_LOCAL_ID = ? 
      ''',
        ['$inspectionServerId', '$inspectionLocalId']
    );

    return result;
  }

  Future deleteInspectionIdTableData() async  {
    Database db = await instance.database;
    await db.delete(INSPECTION_ID_TABLE);
  }

  ///Template List Table Method
  Future insertTemplateListData(templateListData) async {
    var result;
    try {
      Database db = await instance.database;
      // log("templateListData===$templateListData");
      await db.delete(TEMPLATE_LIST_TABLE);

      result = await db.rawInsert(
          "INSERT INTO $TEMPLATE_LIST_TABLE ($PAYLOAD)"
              " VALUES ('${templateListData['payload']}')"
      );
    }catch(e) {
      log("insertTemplateListDataStackTrace====$e");
    }

    return result;
  }

  Future<List> getAllTemplateListData() async {
    Database db = await instance.database;
    var result = await db.query("$TEMPLATE_LIST_TABLE");

    // log("getAllTemplateListData=====$result");
    return result;
  }

  ///Template Detail
  Future insertTemplateDetailData(templateData) async {
    var result;
    try {
      Database db = await instance.database;
      // log("templateListData===$templateData");
      await db.delete(TEMPLATE_DETAIL_TABLE, where: "$TEMPLATE_ID = ?", whereArgs: [templateData['templateid']]);

      result = await db.rawInsert(
          "INSERT INTO $TEMPLATE_DETAIL_TABLE ($TEMPLATE_ID, $LAST_UPDATED, $PAYLOAD)"
              " VALUES ('${templateData['templateid']}', '${templateData[LAST_UPDATED]}', '${templateData['payload']}')"
      );

      log("result===$result");
    }catch(e) {
      log("insertTemplateListDataStackTrace====$e");
    }

    return result;
  }

  Future fetchLastUpdatedTemplateDetail(templateId) async {
    var result;
    try {
      Database db = await instance.database;
      // log("templateListData===$templateData");
      result = await db.query("$TEMPLATE_DETAIL_TABLE", where: "$TEMPLATE_ID = ?", whereArgs: [templateId]);

      // log("result===$result");
    }catch(e) {
      log("insertTemplateListDataStackTrace====$e");
    }

    return result;
  }

  Future<List> getSingleTemplateData(id) async {
    Database db = await instance.database;
    var result = await db.query("$TEMPLATE_DETAIL_TABLE", where: "$TEMPLATE_ID = ?", whereArgs: [id]);

    // log("getSingleTemplateData=====${result.length>0}");
    return result;
  }

  Future<List> getAllTemplateData() async {
    Database db = await instance.database;
    var result = await db.query("$TEMPLATE_DETAIL_TABLE");

    log("getAllTemplateData=====$result");
    return result;
  }

  ///Inspection List Table Method
  Future insertInspectionListData(inspectionListData) async {
    var result;
    try {
      // log("inspectionListData===$inspectionListData");
      Database db = await instance.database;

      await db.delete(INSPECTION_LIST_TABLE);

      result = await db.rawInsert(
          "INSERT INTO $INSPECTION_LIST_TABLE ($PAYLOAD)"
              " VALUES ('${inspectionListData['payload']}')"
      );
    }catch(e) {
      log("insertInspectionListDataStackTrace====$e");
    }

    return result;
  }

  Future<List> getAllInspectionListData() async {
    Database db = await instance.database;
    var result = await db.query("$INSPECTION_LIST_TABLE");

    // log("getAllInspectionListData=====$result");
    return result;
  }

  ///Customer List Table Method
  Future insertCustomerListData(customerListData) async {
    var result;
    try {
      // log("insertCustomerListData===$customerListData");
      Database db = await instance.database;

      await db.delete(CUSTOMER_LIST_TABLE);

      result = await db.rawInsert(
          "INSERT INTO $CUSTOMER_LIST_TABLE ($PAYLOAD)"
              " VALUES ('${customerListData['payload']}')"
      );
    }catch(e) {
      log("insertCustomerListDataStackTrace====$e");
    }

    return result;
  }

  Future<List> getAllCustomerListData() async {
    Database db = await instance.database;
    var result = await db.query("$CUSTOMER_LIST_TABLE");

    log("getAllCustomerListData=====$result");
    return result;
  }

  ///Customer Detail
  Future insertCustomerDetailData(customerData) async {
    var result;
    try {
      Database db = await instance.database;
      log("templateListData===$customerData");
      await db.delete(CUSTOMER_DETAIL_TABLE, where: "$CUSTOMER_ID = ?", whereArgs: [customerData['customerid']]);

      result = await db.rawInsert(
          "INSERT INTO $CUSTOMER_DETAIL_TABLE ($CUSTOMER_ID, $LAST_UPDATED, $PAYLOAD)"
              " VALUES ('${customerData['customerid']}', '${customerData['$LAST_UPDATED']}', '${customerData['payload']}')"
      );
    } catch(e) {
      log("insertCustomerDetailData====$e");
    }

    return result;
  }

  Future<List> getSingleCustomerData(id) async {
    Database db = await instance.database;
    var result = await db.query("$CUSTOMER_DETAIL_TABLE", where: "$CUSTOMER_ID = ?", whereArgs: [id]);

    // log("getSingleCustomerData=====$result");
    return result;
  }

  ///Company Detail Table Method
  Future insertCompanyDetailData(companyData) async {
    var result;
    try {
      log("companyData===$companyData");
      Database db = await instance.database;

      await db.delete(COMPANY_DETAIL_TABLE);

      result = await db.rawInsert(
          "INSERT INTO $COMPANY_DETAIL_TABLE ($PAYLOAD)"
              " VALUES ('${companyData['payload']}')"
      );
    }catch(e) {
      log("insertCompanyDetailData====$e");
    }

    return result;
  }

  Future<List> getCompanyDetailData() async {
    Database db = await instance.database;
    var result = await db.query("$COMPANY_DETAIL_TABLE");

    // log("getCompanyDetailData=====$result");
    return result;
  }

  ///Profile Detail Table Method
  Future insertProfileDetailData(profileData) async {
    var result;
    try {
      log("profileData===$profileData");
      Database db = await instance.database;

      await db.delete(PROFILE_DETAIL_TABLE);

      result = await db.rawInsert(
          "INSERT INTO $PROFILE_DETAIL_TABLE ($PAYLOAD)"
              " VALUES ('${profileData['payload']}')"
      );
    }catch(e) {
      log("insertProfileDetailData====$e");
    }

    return result;
  }

  Future<List> getProfileDetailData() async {
    Database db = await instance.database;
    var result = await db.query("$PROFILE_DETAIL_TABLE");

    // log("getProfileDetailData=====$result");
    return result;
  }

  ///State List Table Method
  Future insertStateListData(stateLisData) async {
    var result;
    try {
      log("stateLisData===$stateLisData");
      Database db = await instance.database;

      await db.delete(STATE_LIST_TABLE);

      result = await db.rawInsert(
          "INSERT INTO $STATE_LIST_TABLE ($PAYLOAD)"
              " VALUES ('${stateLisData['payload']}')"
      );
    }catch(e) {
      log("insertStateListData====$e");
    }

    return result;
  }

  Future<List> getStateListData() async {
    Database db = await instance.database;
    var result = await db.query("$STATE_LIST_TABLE");

    log("getProfileDetailData=====$result");
    return result;
  }

  ///Started Inspection Detail
  Future insertStartedInspectionDetailData(inspectionData) async {
    var result;
    try {
      Database db = await instance.database;
      // log("templateListData===$templateData");
      await db.delete(STARTED_INSPECTION_TABLE, where: "$INSPECTION_ID = ?", whereArgs: [inspectionData['inspectionid']]);

      result = await db.rawInsert(
          "INSERT INTO $STARTED_INSPECTION_TABLE ($INSPECTION_ID, $LAST_UPDATED, $PAYLOAD)"
              " VALUES ('${inspectionData['inspectionid']}', '${inspectionData[LAST_UPDATED]}', '${inspectionData['payload']}')"
      );

      log("insertStartedInspectionDetailData===Result===$result");
    }catch(e) {
      log("insertTemplateListDataStackTrace====$e");
    }

    return result;
  }

  Future<List> getSingleStartedInspectionData(id) async {
    Database db = await instance.database;
    var result = await db.query("$STARTED_INSPECTION_TABLE", where: "$INSPECTION_ID = ?", whereArgs: [id]);

    // log("getSingleStartedInspectionData=====$result");
    return result;
  }

  ///Customer General Table Method
  Future insertCustomerGeneralData(customerData) async {
    var customerId = 1;
    try {
      Database db = await instance.database;
      log("customerData===$customerData");

      if("${customerData['$IS_CUSTOMER_SERVER_ID']}" == "0") {
        var highestRecord = await db.rawQuery("SELECT COUNT(1) as NUM FROM $CUSTOMER_GENERAL_TABLE");
        customerId = highestRecord == null ? 1 : (int.parse("${highestRecord[0]['NUM']}") + 1);
      } else {
        customerId = int.parse("${customerData['$CUSTOMER_SERVER_ID'] ?? 1}");
      }
      await db.rawInsert(
          "INSERT INTO $CUSTOMER_GENERAL_TABLE ($CUSTOMER_LOCAL_ID, $CUSTOMER_SERVER_ID, $IS_CUSTOMER_SERVER_ID, $INSPECTION_DEF_ID, $URL, $VERB, $PAYLOAD)"
              " VALUES ('$customerId', '${customerData['$CUSTOMER_SERVER_ID']}', '${customerData['$IS_CUSTOMER_SERVER_ID']}', '${customerData['$INSPECTION_DEF_ID']}', '${customerData['$URL']}', '${customerData['$VERB']}', '${customerData['$PAYLOAD']}')"
      );
    }catch(e) {
      log("insertCustomerGeneralDataStackTrace====$e");
    }

    return customerId;
  }

  Future updateCustomerGeneralDetail({customerLocalId, payload}) async {
    Database db = await instance.database;
    var result;
    try{
      result = await db.rawUpdate('''
            UPDATE $CUSTOMER_GENERAL_TABLE 
            SET $PAYLOAD = ? 
            WHERE $CUSTOMER_LOCAL_ID = ? 
          ''',
          ['$payload', '$customerLocalId']
      );
    }catch(e) {
      log("updateCustomerGeneralDetailStackTrace====$e");
    }

    return result;
  }

  Future fetchCustomerGeneralRecord() async {
    try{
      Database db = await instance.database;

      var highestRecord = await db.rawQuery("SELECT COUNT(1) as NUM FROM $CUSTOMER_GENERAL_TABLE");

      log("HighestRecord====$highestRecord");
      log("HighestRecordType====${highestRecord.runtimeType}");
      log("HighestRecordType====${int.parse("${highestRecord[0]["NUM"]}") + 1}");
    } catch(e) {
      log("StackTraceFetchCustomerGeneralRecord===$e");
    }
  }

  Future<List> getCustomerGeneralData() async {
    Database db = await instance.database;
    var result = await db.query("$CUSTOMER_GENERAL_TABLE");

    log("getCustomerGeneralData=====$result");
    return result;
  }

  Future<List> getSingleCustomerGeneralRecord(id) async {
    var result;
    try {
      Database db = await instance.database;
      result = await db.query(CUSTOMER_GENERAL_TABLE,
          where: '$CUSTOMER_LOCAL_ID = ?',
          whereArgs: [int.parse("$id")]
      );

      print("getSingleCustomerGeneralRecord===$result");
    } catch(e) {
      log("getSingleCustomerGeneralRecordIssues====$e");
    }
    return result;
  }

  Future updateCustomerGeneralDataRecord(customerLocalId, customerServerId) async {
    Database db = await instance.database;
    var result;
    try{
        result = await db.rawUpdate('''
            UPDATE $CUSTOMER_GENERAL_TABLE 
            SET $CUSTOMER_SERVER_ID = ? 
            WHERE $CUSTOMER_LOCAL_ID = ? 
          ''',
          ['$customerServerId', '$customerLocalId']
         );
    }catch(e) {
      log("updateCustomerGeneralDataRecordStackTrace====$e");
    }

    return result;
  }

  Future deleteCustomerGeneralTableData() async  {
    Database db = await instance.database;
    await db.delete(CUSTOMER_GENERAL_TABLE);
  }

  Future deleteSingleCustomerGeneralTableData(clientId) async  {
    Database db = await instance.database;
    var result = await db.delete("$CUSTOMER_GENERAL_TABLE", where: "$CUSTOMER_LOCAL_ID = ?", whereArgs: [clientId]);

    return result;
  }

  ///Service General Table Method
  Future insertServiceGeneralData(serviceData) async {
    var serviceId = 1;
    // try {
      Database db = await instance.database;
      log("serviceData===$serviceData");

      if("${serviceData['$IS_SERVICE_SERVER_ID']}" == "0") {
        var highestRecord = await db.rawQuery("SELECT COUNT(1) as NUM FROM $SERVICE_GENERAL_TABLE");
        serviceId = highestRecord == null ? 1 : (int.parse("${highestRecord[0]['NUM']}") + 1);
      } else {
        serviceId = int.parse("${serviceData['$SERVICE_SERVER_ID'] ?? 1}");
      }

      await db.rawInsert(
          "INSERT INTO $SERVICE_GENERAL_TABLE ($SERVICE_LOCAL_ID, $SERVICE_SERVER_ID, $IS_SERVICE_SERVER_ID, $CUSTOMER_LOCAL_ID, $CUSTOMER_SERVER_ID, $INSPECTION_DEF_ID, $URL, $VERB, $PAYLOAD)"
              " VALUES ('$serviceId', '${serviceData['$SERVICE_SERVER_ID']}', '${serviceData['$IS_SERVICE_SERVER_ID']}', '${serviceData['$CUSTOMER_LOCAL_ID']}', '${serviceData['$CUSTOMER_SERVER_ID']}', '${serviceData['$INSPECTION_DEF_ID']}', '${serviceData['$URL']}', '${serviceData['$VERB']}', '${serviceData['$PAYLOAD']}')"
      );
    // }catch(e) {
    //   log("insertServiceGeneralDataStackTrace====$e");
    // }

    return serviceId;
  }

  Future fetchServiceGeneralRecord() async {
    try{
      Database db = await instance.database;

      var highestRecord = await db.rawQuery("SELECT COUNT(1) as NUM FROM $SERVICE_GENERAL_TABLE");

      log("HighestRecord====$highestRecord");
      log("HighestRecordType====${highestRecord.runtimeType}");
      log("HighestRecordType====${int.parse("${highestRecord[0]["NUM"]}") + 1}");
    } catch(e) {
      log("StackTraceFetchServiceGeneralRecord===$e");
    }
  }

  Future<List> getServiceGeneralData() async {
    Database db = await instance.database;
    var result = await db.query("$SERVICE_GENERAL_TABLE");

    log("getServiceGeneralData=====$result");
    return result;
  }

  Future<List> getSingleServiceGeneralRecord(id) async {
    var result;
    try {
      Database db = await instance.database;
      result = await db.query(SERVICE_GENERAL_TABLE,
          where: '$SERVICE_LOCAL_ID = ?',
          whereArgs: [int.parse("$id")]
      );

      print("Record===$result");
    } catch(e) {
      log("getSingleServiceGeneralRecordIssues====$e");
    }
    return result;
  }

  Future updateServiceGeneralDetail({serviceLocalId, payload}) async {
    Database db = await instance.database;
    var result;
    try{
      result = await db.rawUpdate('''
            UPDATE $SERVICE_GENERAL_TABLE 
            SET $PAYLOAD = ? 
            WHERE $SERVICE_LOCAL_ID = ? 
          ''',
          ['$payload', '$serviceLocalId']
      );
    }catch(e) {
      log("updateCustomerGeneralDetailStackTrace====$e");
    }

    return result;
  }

  Future updateServiceGeneralDataRecord(serviceLocalId, serviceServerId) async {
    Database db = await instance.database;
    var result;
    try{
      result = await db.rawUpdate('''
            UPDATE $SERVICE_GENERAL_TABLE 
            SET $SERVICE_SERVER_ID = ? 
            WHERE $SERVICE_LOCAL_ID = ? 
          ''',
          ['$serviceServerId', '$serviceLocalId']
      );
    }catch(e) {
      log("updateServiceGeneralDataRecordStackTrace====$e");
    }

    return result;
  }

  Future deleteServiceGeneralTableData() async  {
    Database db = await instance.database;
    await db.delete(SERVICE_GENERAL_TABLE);
  }

  ///Location Image Table Method
  Future insertLocationImageData(imageData) async {
    var result;
    try{
      Database db = await instance.database;
      log("imageData===$imageData");

      result = await db.rawInsert(
          "INSERT INTO $LOCATION_IMAGE_TABLE ($SERVICE_LOCAL_ID, $SERVICE_SERVER_ID, $CUSTOMER_LOCAL_ID, $CUSTOMER_SERVER_ID, $URL, $VERB, $PAYLOAD, $IMAGE_PATH)"
              " VALUES ('${imageData['$SERVICE_LOCAL_ID']}', '${imageData['$SERVICE_SERVER_ID']}', '${imageData['$CUSTOMER_LOCAL_ID']}', '${imageData['$CUSTOMER_SERVER_ID']}', '${imageData['$URL']}', '${imageData['$VERB']}', '${imageData['$PAYLOAD']}', '${imageData['$IMAGE_PATH']}')"
      );
    }catch(e){
      log("insertLocationImageDataStackTrace===$e");
    }

    return result;
  }

  Future deleteLocationImageData(imageId) async {
    Database db = await instance.database;
    var result = await db.delete("$LOCATION_IMAGE_TABLE", where: "$PROXY_ID = ?", whereArgs: [imageId]);

    return result;
  }

  Future<List> getLocationImageData() async {
    Database db = await instance.database;
    var result = await db.query("$LOCATION_IMAGE_TABLE");

    log("getLocationImageData=====$result");
    return result;
  }

  Future deleteLocationImageTableData() async  {
    Database db = await instance.database;
    await db.delete(LOCATION_IMAGE_TABLE);
  }

  ///Country insert record
  Future insertCountryData(countryDataQuery) async {
    var result;
    try {
      // log("countryDataQuery===$countryDataQuery");
      Database db = await instance.database;

      result = await db.rawInsert("$countryDataQuery");
    }catch(e) {
      log("insertCountryDataStackTrace====$e");
    }

    return result;
  }

  Future getCountryRecordCount() async {
    Database db = await instance.database;
    var result = await db.rawQuery("SELECT COUNT(*) as NUM FROM $COUNTRY_TABLE");

    log("Length===>>Result===>>$result");
    return result;
  }

  Future fetchCountryRecord() async {
    Database db = await instance.database;
    var result = await db.rawQuery("SELECT * FROM $COUNTRY_TABLE where $COUNTRY_CODE='AM'");

    log("fetchCountryRecord==>>$result");
    return result;
  }

  Future fetchAllCountryRecord() async {
    Database db = await instance.database;
    var result = await db.rawQuery("SELECT * FROM $COUNTRY_TABLE");

    log("fetchAllCountryRecord==>>$result");
    return result;
  }

  ///State insert record
  Future insertStateData(stateDataQuery) async {
    var result;
    try {
      // log("stateDataQuery===$stateDataQuery");
      Database db = await instance.database;

      result = await db.rawInsert("$stateDataQuery");
    }catch(e) {
      log("insertStateListDataStackTrace====");
    }

    return result;
  }

  Future getStateRecordCount() async {
    Database db = await instance.database;
    var result = await db.rawQuery("SELECT COUNT(*) as NUM FROM $STATE_TABLE");

    log("Length===>>Result===>>$result");
    return result;
  }

  Future fetchAllStateRecord() async {
    Database db = await instance.database;
    var result = await db.rawQuery("SELECT * FROM $STATE_TABLE");

    log("fetchAllStateRecord==>>$result");
    return result;
  }

  Future deleteStateTableInfo() async {
    Database db = await instance.database;

    await db.delete(STATE_TABLE);
  }

  Future getTableSchema() async {
    try{
      Database db = await instance.database;

      // if(db == null) {
      //   db = await instance.database;
      // }

      var result = await db.rawQuery('''PRAGMA table_info($INSPECTION_LIST_TABLE)''');

      // var result = await db.rawQuery("SELECT count(*) as columnName FROM pragma_table_info('$STATE_TABLE') where name='$STATE_CODE'");
      // log("checkImageUrlField ==== ${result[0]['name']}");

      log("getTableInfo Result====$result");
      int count = Sqflite.firstIntValue(result);
      log("getTableInfo Count====$count");
      return count ?? 0;
    } catch (e) {
      log("getTableInfoStackTrace====$e");
      return 0;
    }
  }

  Future fetchStateRecord({String countryCode="US"}) async {
    String query = '''
       select stateid, statecode, statename from state where countrycode = '$countryCode' order by statename
    ''';

    Database db = await instance.database;

    var result = await db.rawQuery(query);

    // log("fetchStateRecordResult====$result");

    return result;
  }

  Future dropStateTable() async {
    Database db = await instance.database;
    db.rawQuery("DROP TABLE $STATE_TABLE");
  }
}