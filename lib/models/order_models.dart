class OrderModel {
  OrderModel({
    required this.trId,
    required this.trDate,
    required this.trTime,
    required this.trPaid,
    required this.trPayment,
    required this.trAdditional,
    required this.trTax,
    required this.trTotal,
    required this.trDiscount,
    required this.trCustName,
  });
  String? trId;
  String? trDate;
  String? trTime;
  String? trPaid;
  String? trPayment;
  String? trAdditional;
  String? trTax;
  String? trTotal;
  String? trDiscount;
  String? trCustName;

  OrderModel.fromJson(Map<String, dynamic> json) {
    trId = json['tr_id'].toString();
    trDate = json['tr_date'].toString();
    trTime = json['tr_time'].toString();
    trPaid = json['tr_paid'].toString();
    trPayment = json['tr_payment'].toString();
    trAdditional = json['tr_additional'].toString();
    trTax = json['tr_tax'].toString();
    trTotal = json['tr_total'].toString();
    trDiscount = json['tr_discount'].toString();
    trCustName = json['tr_cust_name'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['tr_id'] = trId;
    data['tr_date'] = trDate;
    data['tr_time'] = trTime;
    data['tr_paid'] = trPaid;
    data['tr_payment'] = trPayment;
    data['tr_additional'] = trAdditional;
    data['tr_tax'] = trTax;
    data['tr_total'] = trTotal;
    data['tr_discount'] = trDiscount;
    data['tr_cust_name'] = trCustName;
    return data;
  }

  static List<OrderModel> fromJsonList(List list) {
    if (list.isEmpty) return List.empty();
    return list.map((item) => OrderModel.fromJson(item)).toList();
  }
}
