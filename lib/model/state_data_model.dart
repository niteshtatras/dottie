class StateDataModel {
  int value;
  String abbr;
  String label;

  StateDataModel({this.value, this.abbr, this.label});

  StateDataModel.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    abbr = json['abbr'];
    label = json['label'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['value'] = this.value;
    data['abbr'] = this.abbr;
    data['label'] = this.label;
    return data;
  }
}