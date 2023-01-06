// To parse this JSON data, do
//
//     final inspectionModelData = inspectionModelDataFromMap(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

List<InspectionModelData> inspectionModelDataFromMap(String str) => List<InspectionModelData>.from(json.decode(str).map((x) => InspectionModelData.fromMap(x)));

String inspectionModelDataToMap(List<InspectionModelData> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class InspectionModelData {
  InspectionModelData({
    @required this.inspectionid,
    @required this.template,
    @required this.pdftoken,
    @required this.started,
    @required this.completed,
    @required this.client,
    @required this.serviceaddress,
    @required this.photo,
  });

  final int inspectionid;
  final Template template;
  final String pdftoken;
  final DateTime started;
  final DateTime completed;
  final Client client;
  final Serviceaddress serviceaddress;
  final Photo photo;

  InspectionModelData copyWith({
    int inspectionid,
    Template template,
    String pdftoken,
    DateTime started,
    DateTime completed,
    Client client,
    Serviceaddress serviceaddress,
    Photo photo,
  }) =>
      InspectionModelData(
        inspectionid: inspectionid ?? this.inspectionid,
        template: template ?? this.template,
        pdftoken: pdftoken ?? this.pdftoken,
        started: started ?? this.started,
        completed: completed ?? this.completed,
        client: client ?? this.client,
        serviceaddress: serviceaddress ?? this.serviceaddress,
        photo: photo ?? this.photo,
      );

  factory InspectionModelData.fromMap(Map<String, dynamic> json) => InspectionModelData(
    inspectionid: json["inspectionid"],
    template: templateValues.map[json["template"]],
    pdftoken: json["pdftoken"],
    started: DateTime.parse(json["started"]),
    completed: json["completed"] == null ? null : DateTime.parse(json["completed"]),
    client: Client.fromMap(json["client"]),
    serviceaddress: Serviceaddress.fromMap(json["serviceaddress"]),
    photo: json["photo"] == null ? null : Photo.fromMap(json["photo"]),
  );

  Map<String, dynamic> toMap() => {
    "inspectionid": inspectionid,
    "template": templateValues.reverse[template],
    "pdftoken": pdftoken,
    "started": started.toIso8601String(),
    "completed": completed == null ? null : completed.toIso8601String(),
    "client": client.toMap(),
    "serviceaddress": serviceaddress.toMap(),
    "photo": photo == null ? null : photo.toMap(),
  };
}

class Client {
  Client({
    @required this.clientid,
    @required this.name,
  });

  final int clientid;
  final Name name;

  Client copyWith({
    int clientid,
    Name name,
  }) =>
      Client(
        clientid: clientid ?? this.clientid,
        name: name ?? this.name,
      );

  factory Client.fromMap(Map<String, dynamic> json) => Client(
    clientid: json["clientid"],
    name: nameValues.map[json["name"]],
  );

  Map<String, dynamic> toMap() => {
    "clientid": clientid,
    "name": nameValues.reverse[name],
  };
}

enum Name { NISHIT_VERMA, MANNU_VERMA, LEONARD_TRANS, JUAN_GUZMAN, JHONNY_RIGHTS }

final nameValues = EnumValues({
  "Jhonny Rights": Name.JHONNY_RIGHTS,
  "Juan Guzman": Name.JUAN_GUZMAN,
  "Leonard Trans": Name.LEONARD_TRANS,
  "Mannu Verma": Name.MANNU_VERMA,
  "Nishit Verma": Name.NISHIT_VERMA
});

class Photo {
  Photo({
    @required this.imageid,
    @required this.path,
    @required this.width,
    @required this.height,
    @required this.size,
  });

  final int imageid;
  final String path;
  final int width;
  final int height;
  final int size;

  Photo copyWith({
    int imageid,
    String path,
    int width,
    int height,
    int size,
  }) =>
      Photo(
        imageid: imageid ?? this.imageid,
        path: path ?? this.path,
        width: width ?? this.width,
        height: height ?? this.height,
        size: size ?? this.size,
      );

  factory Photo.fromMap(Map<String, dynamic> json) => Photo(
    imageid: json["imageid"],
    path: json["path"],
    width: json["width"],
    height: json["height"],
    size: json["size"],
  );

  Map<String, dynamic> toMap() => {
    "imageid": imageid,
    "path": path,
    "width": width,
    "height": height,
    "size": size,
  };
}

class Serviceaddress {
  Serviceaddress({
    @required this.addressid,
    @required this.street1,
    @required this.street2,
    @required this.city,
    @required this.statecode,
    @required this.countrycode,
  });

  final int addressid;
  final String street1;
  final dynamic street2;
  final City city;
  final Statecode statecode;
  final Countrycode countrycode;

  Serviceaddress copyWith({
    int addressid,
    String street1,
    dynamic street2,
    City city,
    Statecode statecode,
    Countrycode countrycode,
  }) =>
      Serviceaddress(
        addressid: addressid ?? this.addressid,
        street1: street1 ?? this.street1,
        street2: street2 ?? this.street2,
        city: city ?? this.city,
        statecode: statecode ?? this.statecode,
        countrycode: countrycode ?? this.countrycode,
      );

  factory Serviceaddress.fromMap(Map<String, dynamic> json) => Serviceaddress(
    addressid: json["addressid"],
    street1: json["street1"],
    street2: json["street2"],
    city: cityValues.map[json["city"]],
    statecode: statecodeValues.map[json["statecode"]],
    countrycode: countrycodeValues.map[json["countrycode"]],
  );

  Map<String, dynamic> toMap() => {
    "addressid": addressid,
    "street1": street1,
    "street2": street2,
    "city": cityValues.reverse[city],
    "statecode": statecodeValues.reverse[statecode],
    "countrycode": countrycodeValues.reverse[countrycode],
  };
}

enum City { KUJU, MOUNTAIN_VIEW, LA, HAZARIBAGH, SAN_FRANCISCO, ANEW_INSURANCE_AGENCY, GOOGLEPLEX_PATIO, HAZARD, NEW_JERSEY, CUPERTINO, GOOGLE_ANDROID_BUILDING }

final cityValues = EnumValues({
  "Anew Insurance Agency": City.ANEW_INSURANCE_AGENCY,
  "Cupertino": City.CUPERTINO,
  "Googleplex - Patio": City.GOOGLEPLEX_PATIO,
  "Google - Android Building": City.GOOGLE_ANDROID_BUILDING,
  "Hazard": City.HAZARD,
  "Hazaribagh": City.HAZARIBAGH,
  "Kuju": City.KUJU,
  "LA": City.LA,
  "Mountain View": City.MOUNTAIN_VIEW,
  "New Jersey": City.NEW_JERSEY,
  "San Francisco": City.SAN_FRANCISCO
});

enum Countrycode { IN, US }

final countrycodeValues = EnumValues({
  "IN": Countrycode.IN,
  "US": Countrycode.US
});

enum Statecode { JH, CA, AK, AZ, WI, KY, NJ }

final statecodeValues = EnumValues({
  "AK": Statecode.AK,
  "AZ": Statecode.AZ,
  "CA": Statecode.CA,
  "JH": Statecode.JH,
  "KY": Statecode.KY,
  "NJ": Statecode.NJ,
  "WI": Statecode.WI
});

enum Template { MAINTENANCE_BID, REAL_ESTATE, GENERAL_SAFETY, SIMPLE_INSPECTION, REPAIR_COSTS_INSPECTION }

final templateValues = EnumValues({
  "General Safety ": Template.GENERAL_SAFETY,
  "Maintenance Bid ": Template.MAINTENANCE_BID,
  "Real Estate": Template.REAL_ESTATE,
  "Repair Costs Inspection": Template.REPAIR_COSTS_INSPECTION,
  "Simple Inspection": Template.SIMPLE_INSPECTION
});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
