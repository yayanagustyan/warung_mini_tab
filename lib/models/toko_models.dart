class TokoModel {
  TokoModel({
    required this.tkId,
    required this.tkName,
    required this.tkEmail,
    required this.tkPhone,
    required this.tkAddress,
  });
  late final String tkId;
  late final String tkName;
  late final String tkEmail;
  late final String tkPhone;
  late final String tkAddress;

  TokoModel.fromJson(Map<String, dynamic> json) {
    tkId = json['tk_id'].toString();
    tkName = json['tk_name'].toString();
    tkEmail = json['tk_email'].toString();
    tkPhone = json['tk_phone'].toString();
    tkAddress = json['tk_address'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['tk_id'] = tkId;
    data['tk_name'] = tkName;
    data['tk_email'] = tkEmail;
    data['tk_phone'] = tkPhone;
    data['tk_address'] = tkAddress;
    return data;
  }

  static List<TokoModel> fromJsonList(List list) {
    if (list.isEmpty) return List.empty();
    return list.map((item) => TokoModel.fromJson(item)).toList();
  }
}
