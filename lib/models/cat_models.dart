class CatModel {
  CatModel({
    required this.catId,
    required this.catName,
  });
  late final String catId;
  late final String catName;

  CatModel.fromJson(Map<String, dynamic> json) {
    catId = json['cat_id'].toString();
    catName = json['cat_name'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['cat_id'] = catId;
    data['cat_name'] = catName;
    return data;
  }

  static List<CatModel> fromJsonList(List list) {
    if (list.isEmpty) return List.empty();
    return list.map((item) => CatModel.fromJson(item)).toList();
  }
}
