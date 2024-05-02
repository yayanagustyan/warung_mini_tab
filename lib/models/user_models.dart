class UserModel {
  UserModel({
    required this.usrId,
    required this.usrName,
  });
  late final String usrId;
  late final String usrName;

  UserModel.fromJson(Map<String, dynamic> json) {
    usrId = json['usr_id'].toString();
    usrName = json['usr_full_name'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['usr_id'] = usrId;
    data['usr_full_name'] = usrName;
    return data;
  }

  static List<UserModel> fromJsonList(List list) {
    if (list.isEmpty) return List.empty();
    return list.map((item) => UserModel.fromJson(item)).toList();
  }
}
