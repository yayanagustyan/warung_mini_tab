class HistoryModel {
  HistoryModel({
    required this.trId,
    required this.trTime,
    required this.trJml,
    required this.trTotal,
  });
  late final String trId;
  late final String trTime;
  late final String trJml;
  late final String trTotal;

  HistoryModel.fromJson(Map<String, dynamic> json) {
    trId = json['tr_id'].toString();
    trTime = json['tr_time'].toString();
    trJml = json['jml'].toString();
    trTotal = json['tr_total'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['tr_id'] = trId;
    data['tr_time'] = trTime;
    data['jml'] = trJml;
    data['tr_total'] = trTotal;
    return data;
  }

  static List<HistoryModel> fromJsonList(List list) {
    if (list.isEmpty) return List.empty();
    return list.map((item) => HistoryModel.fromJson(item)).toList();
  }
}
