import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warung_mini_tab/common/global_widgets.dart';
import 'package:warung_mini_tab/common/helper.dart';
import 'package:warung_mini_tab/common/my_colors.dart';
import 'package:warung_mini_tab/core/routes.dart';
import 'package:warung_mini_tab/models/order_detail_models.dart';
import 'package:warung_mini_tab/providers/db_provider.dart';
import 'package:warung_mini_tab/ui/main/home/pages/order_screen.dart';

import '../../../../models/order_list_models.dart';

class OrdersListScreeen extends StatefulWidget {
  const OrdersListScreeen({super.key});

  @override
  State<StatefulWidget> createState() => _OrdersListScreeenState();
}

class _OrdersListScreeenState extends State<OrdersListScreeen> {
  List<OrderListModel> orders = [];
  List<OrderListModel> filtered = [];
  String periode = getCurrentDate();

  getData(String date) {
    date = date == "" ? getCurrentDate() : date;
    setState(() {
      periode = date;
    });
    DBProvider.db.getSumaryOrder(date).then((value) {
      setState(() {
        orders = OrderListModel.fromJsonList(value);
        filtered = orders;
      });
    });
  }

  moreText(OrderListModel ord) {
    var text = "";
    if (ord.details != null) {
      text =
          ord.details!.length > 2 ? "+${ord.details!.length - 2} lainnya" : "";
    }
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 12.sp),
    );
  }

  dtlItem(OrderListModel items, {bool showall = false}) {
    List<Widget> ele = [];
    if (items.details != null) {
      int jml = 0;
      if (items.details!.length > 2) {
        jml = 2;
      } else {
        jml = items.details!.length;
      }
      for (var i = 0; i < jml; i++) {
        OrderDetailModel item = items.details![i];
        int batas = 10;
        if (showall) {
          batas = 15;
        }
        int limit = 0;
        if (item.ordMenuName!.length > batas) {
          limit = batas;
        } else {
          limit = item.ordMenuName!.length;
        }

        if (showall) {
          jml = items.details!.length;
        }

        ele.add(Table(
          columnWidths: const {
            0: FlexColumnWidth(6),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(4),
          },
          children: [
            TableRow(children: [
              Text(
                item.ordMenuName.toString().substring(0, limit),
                style: TextStyle(fontSize: 12.sp),
              ),
              Text(
                nF(item.ordQty!),
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: 12.sp),
              ),
              Text(
                nF(item.ordPrice!),
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: 12.sp),
              ),
            ])
          ],
        ));
      }
    }
    return ele;
  }

  orderItems() {
    List<Widget> ele = [];
    for (var ord in filtered) {
      ele.add(
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "#${ord.trId!}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: ord.trPaid == "1" ? colorGreen10 : colorRed10,
                        border: Border.all(
                          color: ord.trPaid == "1" ? colorGreen50 : colorRed50,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 1,
                        horizontal: 5,
                      ),
                      child: Text(
                        ord.trPaid == "1" ? "Paid" : "Unpaid",
                        style: TextStyle(
                          color: ord.trPaid == "1" ? colorGreen : colorRed100,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateFormat(ord.trDate.toString(), "EE, dd MMM yy"),
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    Text(
                      ord.trTime!,
                      style: TextStyle(fontSize: 12.sp),
                    ),
                  ],
                ),
                const Divider(color: colorDarkGrey),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: dtlItem(ord),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Stack(
                      children: [
                        Positioned(
                          top: -3,
                          child: Container(
                            color: colorWhite,
                            width: MediaQuery.of(context).size.width / 5.8,
                            height: 30,
                            child: moreText(ord),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Divider(color: colorDarkGrey),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total",
                                  style: TextStyle(fontSize: 13.sp),
                                ),
                                Text(
                                  nF(ord.trTotal!),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            ord.trPaid == "0"
                                ? buttonSubmit(
                                    text: "Bayar",
                                    onPressed: () => gotoPage(
                                      context,
                                      OrderScreen(
                                        custName: "",
                                        transId: ord.trId!,
                                        disc: ord.trDiscount!,
                                        tanggal: ord.trDate!,
                                      ),
                                    ).then((value) => getData("")),
                                    height: 30,
                                    fontSize: 11.sp,
                                    radius: 5,
                                    textColor: colorRed100,
                                    backgroundColor: colorRed10,
                                    sideColor: colorRed20,
                                  )
                                : buttonSubmit(
                                    text: "Rincian",
                                    onPressed: () => showDetails(ord),
                                    height: 30,
                                    fontSize: 11.sp,
                                    radius: 5,
                                    textColor: colorGreen,
                                    backgroundColor: colorGreen10,
                                    sideColor: colorGreen20,
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    for (var i = 0; i < 20; i++) {
      // ele.add(Card(child: Text("test")));
    }
    return ele;
  }

  showDetails(OrderListModel ord) {
    showDialog(
      context: context,
      builder: (c) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(10),
          contentPadding:
              const EdgeInsets.only(left: 10, right: 10, bottom: 10),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Rincian Pesanan",
                style: TextStyle(fontSize: 16.sp),
              ),
              InkWell(
                onTap: () => backStep(context),
                child: const Icon(Icons.close),
              ),
            ],
          ),
          content: SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "#${ord.trId!}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateFormat(ord.trDate!, "EEE, dd MMM yy"),
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    Text(
                      ord.trTime!,
                      style: TextStyle(fontSize: 12.sp),
                    ),
                  ],
                ),
                const Divider(color: colorDarkGrey),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: dtlItem(ord, showall: true),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Divider(color: colorDarkGrey),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total",
                              style: TextStyle(fontSize: 16.sp),
                            ),
                            Text(
                              nF(ord.trTotal!),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String pageCat = "2";
  List<Map<String, String>> categs = [
    {"code": "2", "name": "Semua"},
    {"code": "1", "name": "Lunas"},
    {"code": "0", "name": "Belum Lunas"}
  ];

  filterOrder(String cat) {
    setState(() {
      filtered = [];
      pageCat = cat;
      for (var ord in orders) {
        if (ord.trPaid == cat) {
          filtered.add(ord);
        }
      }
      if (cat == "2") {
        filtered = orders;
      }
    });
  }

  categories() {
    List<Widget> ele = [];

    for (var el in categs) {
      ele.add(GestureDetector(
        onTap: () => filterOrder(el['code'].toString()),
        child: Container(
          margin: const EdgeInsets.only(top: 10, right: 10),
          decoration: BoxDecoration(
            color: pageCat == el['code'] ? colorGreen20 : colorGrey20,
            border: Border.all(
                color: pageCat == el['code'] ? colorGreen : Colors.grey),
            borderRadius: BorderRadius.circular(100.sp),
          ),
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          child: Center(
              child: Text(
            el['name'].toString(),
            style: TextStyle(
              color: pageCat == el['code'] ? colorGreen : Colors.grey,
            ),
          )),
        ),
      ));
    }

    return ele;
  }

  _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2021),
      lastDate: DateTime.now(),
    ).then((value) => getData(dateFormat(value.toString(), "yyyy-MM-dd")));
  }

  @override
  void initState() {
    super.initState();
    getData("");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorWhiteBg,
      appBar: AppBar(title: const Text("Daftar Pesanan")),
      body: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 40,
                width: MediaQuery.of(context).size.width / 2,
                child: ListView(
                  padding: const EdgeInsets.only(left: 10),
                  scrollDirection: Axis.horizontal,
                  children: categories(),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                alignment: Alignment.centerRight,
                height: 40,
                width: MediaQuery.of(context).size.width / 5,
                child: buttonSubmit(
                  text: periode,
                  onPressed: () => _showDatePicker(),
                  height: 30,
                  fontSize: 12.sp,
                  radius: 5,
                  backgroundColor: colorWhite,
                  sideColor: colorPrimary,
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 40),
            padding: const EdgeInsets.all(10),
            child: filtered.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Tidak ada data pada periode ini"),
                  )
                : GridView.count(
                    crossAxisCount: 5,
                    children: orderItems(),
                  ),
          ),
        ],
      ),
    );
  }
}
