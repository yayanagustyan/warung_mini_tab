class OrderDetailModel {
  OrderDetailModel({
    required this.ordId,
    required this.ordTrId,
    required this.ordMenuId,
    required this.ordMenuName,
    required this.ordQty,
    required this.ordPrice,
    required this.ordSubTotal,
  });
  String? ordId;
  String? ordTrId;
  String? ordMenuId;
  String? ordMenuName;
  String? ordQty;
  String? ordPrice;
  String? ordSubTotal;

  OrderDetailModel.fromJson(Map<String, dynamic> json) {
    ordId = json['ord_id'].toString();
    ordTrId = json['ord_tr_id'].toString();
    ordMenuId = json['ord_menu_id'].toString();
    ordMenuName = json['ord_menu_name'].toString();
    ordQty = json['ord_qty'].toString();
    ordPrice = json['ord_price'].toString();
    ordSubTotal = json['ord_sub_total'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['ord_id'] = ordId;
    data['ord_tr_id'] = ordTrId;
    data['ord_menu_id'] = ordMenuId;
    data['ord_menu_name'] = ordMenuName;
    data['ord_qty'] = ordQty;
    data['ord_price'] = ordPrice;
    data['ord_sub_total'] = ordSubTotal;
    return data;
  }

  static List<OrderDetailModel> fromJsonList(List list) {
    if (list.isEmpty) return List.empty();
    return list.map((item) => OrderDetailModel.fromJson(item)).toList();
  }
}
