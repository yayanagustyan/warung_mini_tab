class MenuModel {
  MenuModel({
    required this.prodId,
    required this.prodCode,
    required this.prodName,
    required this.prodStock,
    required this.prodPricePcs,
    required this.prodPriceDoz,
    required this.prodBoxQty,
    required this.prodPriceBox,
    required this.prodOthQty,
    required this.prodPriceOth,
  });
  String? prodId;
  String? prodCode;
  String? prodName;
  String? prodStock;
  String? prodPricePcs;
  String? prodPriceDoz;
  String? prodBoxQty;
  String? prodPriceBox;
  String? prodOthQty;
  String? prodPriceOth;

  MenuModel.fromJson(Map<String, dynamic> json) {
    prodId = json['prod_id'].toString();
    prodCode = json['prod_code'].toString();
    prodName = json['prod_name'].toString();
    prodStock = json['prod_stock'].toString();
    prodPricePcs = json['prod_price_pcs'].toString();
    prodPriceDoz = json['prod_price_doz'].toString();
    prodBoxQty = json['prod_box_qty'].toString();
    prodPriceBox = json['prod_price_box'].toString();
    prodOthQty = json['prod_oth_qty'].toString();
    prodPriceOth = json['prod_price_oth'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['prod_id'] = prodId;
    data['prod_code'] = prodCode;
    data['prod_name'] = prodName;
    data['prod_stock'] = prodStock;
    data['prod_price_pcs'] = prodPricePcs;
    data['prod_price_doz'] = prodPriceDoz;
    data['prod_box_qty'] = prodBoxQty;
    data['prod_price_box'] = prodPriceBox;
    data['prod_oth_qty'] = prodOthQty;
    data['prod_price_oth'] = prodPriceOth;
    return data;
  }

  static List<MenuModel> fromJsonList(List list) {
    if (list.isEmpty) return List.empty();
    return list.map((item) => MenuModel.fromJson(item)).toList();
  }
}
