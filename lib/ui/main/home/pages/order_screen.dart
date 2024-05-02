import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warung_mini_tab/common/global_widgets.dart';
import 'package:warung_mini_tab/common/helper.dart';
import 'package:warung_mini_tab/common/my_behavior.dart';
import 'package:warung_mini_tab/common/my_colors.dart';
import 'package:warung_mini_tab/common/text_fields.dart';
import 'package:warung_mini_tab/core/printer_service/printer_service.dart';
import 'package:warung_mini_tab/core/routes.dart';
import 'package:warung_mini_tab/models/menu_models.dart';
import 'package:warung_mini_tab/providers/db_provider.dart';
import 'package:warung_mini_tab/ui/main/home/pages/products.dart';
import 'package:warung_mini_tab/ui/main/more/scanner_screen.dart';

import '../../../../models/order_detail_models.dart';
import '../../../../models/order_models.dart';

class OrderScreen extends StatefulWidget {
  final String custName;
  final String transId;
  final String disc;
  final String tanggal;
  const OrderScreen({
    Key? key,
    required this.custName,
    required this.transId,
    required this.disc,
    required this.tanggal,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String orderid = "";
  List<OrderDetailModel> orders = [];
  double total = 0;
  double grandTotal = 0;
  double grandTotalT = 0;
  bool saved = false;
  String custName = "";
  String discount = "0";

  final cnama = TextEditingController();

  List<TextEditingController> cjmls = [];
  List<String> _qtys = [];

  final cari = TextEditingController();
  final cbayar = TextEditingController();
  final cdisc = TextEditingController();
  final cmetod = TextEditingController();

  saveOrder() {
    setState(() {
      custName = cnama.text;
    });
    if (orders.isNotEmpty) {
      DBProvider.db.getOrderId(orderid).then((value) {
        wLog(value);
        if (value.isEmpty) {
          saveData();
        } else {
          updateData(value.first);
        }
        setState(() {
          custName = "";
        });
      });
    }
  }

  checkOut() {
    setState(() {
      discount = cdisc.text.replaceAll(".", "");
      grandTotal = total - double.parse(discount);
    });
    removeFocus(context);
    saveOrder();
    showBSheet();
  }

  updateData(OrderModel order) {
    var upd = {
      "tr_date":
          formatDateTime(DateTime.now().toString(), patern: "yyyy-MM-dd"),
      "tr_time": formatDateTime(DateTime.now().toString(), patern: "hh:mm"),
      "tr_total": grandTotal.toString(),
      "tr_cust_name": custName,
      "tr_discount": discount,
    };
    DBProvider.db.updateOrder(upd, orderid).then((value) {
      DBProvider.db.deleteAllOrderID(orderid).then((value) {
        for (var item in orders) {
          DBProvider.db.insertOrderDetail(item);
        }
        setState(() {
          saved = true;
        });
      });
    });
  }

  saveData() {
    DBProvider.db.insertOrder(OrderModel(
      trId: orderid,
      trDate: formatDateTime(DateTime.now().toString(), patern: "yyyy-MM-dd"),
      trTime: formatDateTime(DateTime.now().toString(), patern: "hh:mm"),
      trPaid: "0",
      trPayment: "",
      trTax: "11",
      trAdditional: "0",
      trTotal: grandTotal.toString(),
      trDiscount: discount,
      trCustName: custName,
    ));
    for (var i = 0; i < orders.length; i++) {
      // orders[i].ordId = (getUniq() + i).toString();
      DBProvider.db.insertOrderDetail(orders[i]);
    }
    setState(() {
      saved = true;
    });
    setCookie("lastId", orderid);
  }

  deleteOrder(String orderId) {
    DBProvider.db.deleteOrderId(orderId);
    DBProvider.db.deleteAllOrderID(orderId).then((value) {
      wLog(value);
      backStep(context);
      showToast("Pesanan berhasil dihapus", context: context);
    });
  }

  getMaxid() async {
    if (widget.transId.isNotEmpty) {
      DBProvider.db.getOrderDetail(widget.transId).then((value) {
        setState(() {
          orders = value;
          orderid = widget.transId;
          saved = true;
          Future.delayed(const Duration(milliseconds: 10)).then((value) {
            for (var i = 0; i < orders.length; i++) {
              cjmls.add(TextEditingController());
              cjmls[i].text = orders[i].ordQty!;
            }
          });
        });
        hitung();
      });
    } else {
      final lastId = await cookiesExist("lastId");
      wLog("LASTID $lastId");
      var jml = 1;
      var dd =
          "T${formatDateTime(DateTime.now().toString(), patern: "MMddHHmmss")}";
      if (lastId) {
        final last = await getCookies("lastId");
        wLog(last);
        wLog(dd);
        var arr = last.split(dd);
        if (arr.length > 1) {
          jml = int.parse(last.split(dd)[1]) + 1;
        }
        wLog(arr.toList());
        wLog(jml);
      }
      setState(() {
        if (jml < 10) {
          orderid = "000$jml";
        } else if (jml < 100) {
          orderid = "00$jml";
        } else if (jml < 1000) {
          orderid = "0$jml";
        } else {
          orderid = jml.toString();
        }
        orderid = dd; //+ orderid;
        // orderid = DateTime.now().millisecond.toString();
      });
    }
  }

  Widget orderItem(OrderDetailModel item, int index) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(color: colorWhite),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          index == 0
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  child: Text(
                    "Daftar Pesanan",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              : Container(),
          SizedBox(height: index == 0 ? 10 : 0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.ordMenuName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Text(
                          "${nF(item.ordPrice!, useSymbol: true)} x ${item.ordQty}",
                          style: TextStyle(
                            color: colorText,
                            fontSize: 14.spMin,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: Text(
                            nF(
                                (double.parse(item.ordPrice.toString()) *
                                        double.parse(item.ordQty.toString()))
                                    .toString(),
                                useSymbol: true),
                            style: TextStyle(
                              color: colorText,
                              fontSize: 14.spMin,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  // InkWell(
                  //   onTap: () => subQty(item),
                  //   child: CircleAvatar(
                  //     backgroundColor: colorSecondary,
                  //     radius: 12,
                  //     child: Icon(
                  //       item.ordQty == "1" ? Icons.close : Icons.remove,
                  //       color: colorWhite,
                  //       size: 15,
                  //     ),
                  //   ),
                  // ),
                  SizedBox(
                    width: 50,
                    child: TextFields(
                      controller: cjmls[index],
                      hint: "0",
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      padding: EdgeInsets.zero,
                      inputAction: TextInputAction.done,
                      radius: 5,
                      // isSelect: true,
                      onTap: () => cjmls[index].selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: cjmls[index].value.text.length,
                      ),
                      onChanged: (val) {
                        changeQty(item, val);
                      },
                      onSubmit: (val) => removeFocus(context),
                    ),
                  ),
                  InkWell(
                    onTap: () => delItem(item),
                    child: const Padding(
                      padding: EdgeInsets.only(bottom: 10, left: 5),
                      child: CircleAvatar(
                        backgroundColor: colorSecondary,
                        radius: 12,
                        child: Icon(Icons.close, color: colorWhite, size: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(
            height: 1,
            thickness: 1,
            color: colorGrey,
          ),
        ],
      ),
    );
  }

  hitung() {
    double subtotal = 0;
    for (var item in orders) {
      // int qty = int.parse(item.ordQty.toString());
      // double prc = double.parse(item.ordPrice.toString());

      subtotal += double.parse(item.ordSubTotal.toString());
      wLog("hitung subt ${item.ordSubTotal}");
    }
    setState(() {
      cdisc.text = nF(widget.disc);
      total = subtotal;
      grandTotal = total - double.parse(widget.disc);
      grandTotalT = grandTotal;
    });
  }

  changeQty(OrderDetailModel order, String jml) {
    DBProvider.db.getProductId(order.ordMenuId!).then((value) {
      setState(() {
        if (jml.isEmpty) {
          jml = "0";
        }
        var prc = value.prodPricePcs;
        var subtotal = double.parse(prc.toString()) * double.parse(jml);

        double qty = double.parse(jml);

        if (value.prodBoxQty.toString() != "null" &&
            value.prodBoxQty.toString() != "0.0") {
          double perbox = double.parse(value.prodBoxQty.toString());
          if (qty == perbox || (qty % perbox == 0)) {
            prc = value.prodPriceBox;
            subtotal = double.parse(prc.toString()) * (qty / perbox);

            wLog(qty % perbox);
          }
        }

        if (value.prodOthQty.toString() != "null" &&
            value.prodOthQty.toString() != "0.0") {
          double perd = double.parse(value.prodOthQty.toString());
          if (qty == perd || (qty % perd == 0)) {
            prc = value.prodPriceOth;
            subtotal = double.parse(prc.toString()) * (qty / perd);
          }
        }
        if (value.prodPriceDoz.toString() != "null" &&
            value.prodPriceDoz.toString() != "0.0") {
          if (jml == "12" || (qty % 12 == 0)) {
            prc = value.prodPriceDoz;
            subtotal = double.parse(prc.toString()) * (qty / 12);
          }
        }

        wLog("actual price $prc");
        wLog("actual qty $jml");
        wLog("actual subt $subtotal");
        wLog(value.toJson());

        order.ordQty = jml;
        order.ordSubTotal = subtotal.toString();
        saved = false;
      });
      hitung();
    });
  }

  addQty(OrderDetailModel order) {
    wLog(order.ordQty);
    int awal = int.parse(order.ordQty.toString());
    setState(() {
      order.ordQty = (awal + 1).toString();
      order.ordSubTotal =
          ((awal + 1) * double.parse(order.ordPrice.toString())).toString();
      saved = false;
    });
    hitung();
  }

  subQty(OrderDetailModel order) {
    int awal = int.parse(order.ordQty.toString());
    setState(() {
      if (awal > 1) {
        order.ordQty = (awal - 1).toString();
        order.ordSubTotal =
            ((awal - 1) * double.parse(order.ordPrice.toString())).toString();
      } else {
        delItem(order);
      }
      saved = false;
    });
    hitung();
  }

  delItem(OrderDetailModel item) {
    for (var i = 0; i < orders.length; i++) {
      if (item.ordMenuId == orders[i].ordMenuId) {
        setState(() {
          orders.removeAt(i);
        });
        hitung();
      }
    }
  }

  addItem(MenuModel menu) {
    bool ada = false;
    for (var item in orders) {
      wLog("${menu.prodId!} VS ${item.ordMenuId}");
      if (menu.prodId == item.ordMenuId) {
        setState(() {
          ada = true;
        });
      }
    }
    wLog(ada);

    if (!ada) {
      var id = getUniqueId() + orderid + menu.prodId.toString();
      setState(() {
        orders.insert(
          0,
          OrderDetailModel(
            ordId: id,
            ordTrId: orderid,
            ordMenuId: menu.prodId,
            ordMenuName: menu.prodName,
            ordQty: "1",
            ordPrice: menu.prodPricePcs,
            ordSubTotal: menu.prodPricePcs,
          ),
        );
        if (cjmls.isNotEmpty) {
          for (var i = 0; i < orders.length; i++) {
            cjmls[i].text = _qtys[i];
            orders[i].ordQty = _qtys[i];
          }
        } else {
          cjmls.add(TextEditingController());
          Future.delayed(const Duration(milliseconds: 10)).then((value) {
            cjmls[0].text = "1";
          });
          wLog("DISINI");
        }
        saved = false;
      });
      hitung();
    }
  }

  payment() {
    double bayar = _typed.isNotEmpty ? double.parse(_typed) : 0;
    if (bayar < grandTotal) {
      showToast("Jumlah Pembayaran Kurang", context: context);
    } else {
      backStep(context);
      double sisa = bayar - grandTotal;
      var data = {
        "tr_paid": "1",
        "tr_payment": bayar.toString(),
      };
      var disc = cdisc.text.replaceAll(".", "");
      DBProvider.db.updateOrder(data, orderid).then((value) {
        showFinal(sisa.toStringAsFixed(0), disc);
      });
    }
  }

  doneAndPrint(String sisa, String disc) {
    TestPrint().printStruk(orderid, sisa, disc).then((value) {
      if (value == false) {
        showToast("Printer tidak terhubung", context: context);
      } else {
        backStep(context);
        backStep(context);
      }
    });
  }

  showFinal(String sisa, String disc) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            contentPadding: const EdgeInsets.all(10),
            titlePadding: const EdgeInsets.all(10),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            title: Stack(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                      onTap: () {
                        backStep(context);
                        backStep(context);
                      },
                      child: const Icon(Icons.close)),
                ),
                const Text('Transaksi Selesai'),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total belanja Anda'),
                      Text(
                        nF(total.toString(), useSymbol: true),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Potongan'),
                      Text(
                        nF(disc.toString(), useSymbol: true),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Kembalian'),
                      Text(
                        nF(sisa.toString(), useSymbol: true),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 5, color: colorBlack70),
                  const SizedBox(height: 10),
                  const Text('Apakah ingin cetak struk pembelian?'),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 6,
                        child: buttonSubmit(
                          onPressed: () => doneAndPrint(sisa, disc),
                          text: 'Cetak',
                          radius: 5,
                          backgroundColor: colorSecondary,
                          height: 35,
                          fontSize: 14.sp,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        flex: 4,
                        child: buttonSubmit(
                          onPressed: () {
                            backStep(context);
                            backStep(context);
                          },
                          text: 'Tidak',
                          radius: 5,
                          backgroundColor: colorWhite,
                          sideColor: colorPrimary,
                          height: 35,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getMaxid();
    custName = widget.custName;
    cdisc.text = "0";
  }

  showCustName() {
    cnama.clear();
    showDialog(
      context: context,
      builder: (c) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(15),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Masukkan Nama Pembeli"),
              TextFields(
                controller: cnama,
                hint: "Masukkan Nama Pembeli",
                capitalize: TextCapitalization.words,
              ),
              buttonSubmit(
                text: "Simpan",
                onPressed: () {
                  setState(() {
                    discount = cdisc.text.replaceAll(".", "");
                    grandTotal = total - double.parse(discount);
                  });

                  if (cnama.text.isNotEmpty) {
                    saveOrder();
                    backStep(context);
                    backStep(context);
                  } else {
                    removeFocus(context);
                    showToast("Silahkan isi nama pembeli", context: context);
                  }
                },
                radius: 5,
                backgroundColor: colorWhite,
                sideColor: colorSecondary,
              ),
            ],
          ),
        );
      },
    );
  }

  showdialog() {
    showDialog(
      context: context,
      builder: (c) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(10),
          titlePadding: const EdgeInsets.all(10),
          title: const Text("Pesanan Belum disimpan"),
          content: SizedBox(
            width: MediaQuery.of(context).size.width / 3,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Apakah Anda ingin menghapus pesanan ini?"),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 4,
                      child: buttonSubmit(
                        text: "Ya",
                        radius: 10,
                        height: 40,
                        backgroundColor: colorWhite,
                        textColor: colorPrimary,
                        onPressed: () {
                          deleteOrder(orderid);
                          backStep(context);
                        },
                      ),
                    ),
                    Flexible(
                      flex: 6,
                      child: buttonSubmit(
                        text: "Simpan",
                        radius: 10,
                        height: 40,
                        backgroundColor: colorPrimary,
                        onPressed: () {
                          backStep(context);
                          showCustName();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _typed = "";
  bool numpadShow = false;
  Widget numpad(String code) {
    return Expanded(
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          if (code == "BACKSPACE") {
            _typed = _typed.isNotEmpty
                ? (_typed.substring(0, _typed.length - 1))
                : _typed;
          } else if (code == "OK") {
            payment();
          } else {
            _typed += code;
          }
          cbayar.text = _typed.isNotEmpty ? nF(_typed) : nF("0");
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            // border: Border.all(color: colorPrimary),
            color: colorWhite,
            borderRadius: BorderRadius.circular(5),
          ),
          margin: const EdgeInsets.only(right: 2, left: 2),
          height: MediaQuery.of(context).size.width / 20,
          // width: MediaQuery.of(context).size.width / 4,
          child: code == "BACKSPACE"
              ? const Icon(Icons.keyboard_backspace, color: colorPrimary)
              : code == "SPASI"
                  ? const Icon(Icons.space_bar_outlined, color: colorPrimary)
                  // : code == "OK"
                  //     ? const Icon(Icons.check_outlined, color: colorWhite)
                  : Text(
                      code,
                      style: TextStyle(
                        color: colorPrimary,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
        ),
      ),
    );
  }

  orditems() {
    List<Widget> ele = [];

    List<OrderDetailModel> items = [];
    // if (orders.length > 2) {
    //   for (var i = 0; i < 2; i++) {
    //     items.add(orders[i]);
    //   }
    //   pjg = true;
    // } else {
    items = orders;
    // }

    for (var item in items) {
      ele.add(Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.ordMenuName!),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${item.ordQty!} pcs"),
                Text(nF(item.ordSubTotal!)),
              ],
            ),
          ],
        ),
      ));
    }
    // ele.add(Container(
    //   margin: const EdgeInsets.symmetric(vertical: 10),
    //   decoration: const BoxDecoration(
    //     border: Border(bottom: BorderSide(color: colorPrimary)),
    //   ),
    // ));

    // ele.add(Row(
    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //   children: [
    //     const Text("Subtotal"),
    //     Text(nF(total.toString())),
    //   ],
    // ));
    // ele.add(Row(
    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //   children: [
    //     const Text("Potongan"),
    //     Text(nF(discount.toString())),
    //   ],
    // ));
    // ele.add(Row(
    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //   children: [
    //     Text(
    //       "Total",
    //       style: TextStyle(fontSize: 16.sp),
    //     ),
    //     Text(
    //       nF(grandTotal.toString()),
    //       style: TextStyle(
    //         fontSize: 20.sp,
    //         fontWeight: FontWeight.bold,
    //       ),
    //     ),
    //   ],
    // ));

    return ele;
  }

  showBSheet() {
    setState(() {
      cbayar.text = "0";
      _typed = "";
    });
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        useSafeArea: true,
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width / 2,
        ),
        // constraints: BoxConstraints.loose(
        //   Size(
        //     MediaQuery.of(context).size.width,
        //     MediaQuery.of(context).size.height,
        //   ),
        // ),
        context: context,
        builder: (c) {
          return Container(
            margin: const EdgeInsets.only(bottom: 30),
            padding: const EdgeInsets.all(10),
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: colorWhite,
              border: Border.all(color: colorPrimary),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
                bottom: Radius.circular(10),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Pembayaran",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      onTap: () => backStep(context),
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Detail Transaksi",
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            width: MediaQuery.of(context).size.width / 4,
                            decoration: BoxDecoration(
                              color: colorWhiteBg,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height / 3),
                            child: ListView(
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              children: orditems(),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                                top: 10, bottom: 10, right: 15),
                            padding: const EdgeInsets.only(top: 10),
                            decoration: const BoxDecoration(
                              border:
                                  Border(top: BorderSide(color: colorPrimary)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Subtotal"),
                                    Text(nF(total.toString())),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Potongan"),
                                    Text(nF(discount.toString())),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Total",
                                      style: TextStyle(fontSize: 16.sp),
                                    ),
                                    Text(
                                      nF(grandTotal.toString()),
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Text(
                          //   "Metode Bayar",
                          //   textAlign: TextAlign.center,
                          //   style: TextStyle(fontSize: 14.sp),
                          // ),
                          // Container(
                          //   width: MediaQuery.of(context).size.width / 4,
                          //   padding: const EdgeInsets.only(top: 0, bottom: 5),
                          //   child: TextFields(
                          //     controller: cmetod,
                          //     isSelect: true,
                          //     hint: "Cash",
                          //     padding: EdgeInsets.zero,
                          //   ),
                          // ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 4,
                            child: TextFields(
                              padding: EdgeInsets.zero,
                              controller: cbayar,
                              hint: "Jumlah Pembayaran",
                              isSelect: true,
                              onTap: () {},
                              prefixIcon: const Text("Rp."),
                              textAlign: TextAlign.end,
                              enableBorder: false,
                              textStyle: TextStyle(fontSize: 32.sp),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 4,
                            margin: const EdgeInsets.only(
                                left: 2, right: 2, bottom: 5),
                            child: buttonSubmit(
                              text: "Uang Pass",
                              onPressed: () {
                                setState(() {
                                  _typed = grandTotal.toString();
                                });
                                cbayar.text = nF(grandTotal.toString());
                              },
                              radius: 5,
                              backgroundColor: colorWhite,
                              sideColor: colorPrimary,
                              fontSize: 14.sp,
                              height: 35,
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 4,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                numpad("1"),
                                numpad("2"),
                                numpad("3"),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 4,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                numpad("4"),
                                numpad("5"),
                                numpad("6"),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 4,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                numpad("7"),
                                numpad("8"),
                                numpad("9"),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 4,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                numpad("BACKSPACE"),
                                numpad("0"),
                                numpad("OK"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  showBSheet1() {
    setState(() {
      cbayar.text = "0";
      _typed = "";
    });
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        useSafeArea: true,
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width / 3,
        ),
        // constraints: BoxConstraints.loose(
        //   Size(
        //     MediaQuery.of(context).size.width,
        //     MediaQuery.of(context).size.height,
        //   ),
        // ),
        context: context,
        builder: (c) {
          return Wrap(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 30),
                padding: const EdgeInsets.all(10),
                width: double.maxFinite,
                decoration: BoxDecoration(
                  color: colorWhite,
                  border: Border.all(color: colorPrimary),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                    bottom: Radius.circular(10),
                  ),
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        onTap: () => backStep(context),
                        child: const Icon(Icons.close),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Text(
                            "Total Belanja",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5, bottom: 5),
                            child: Text(
                              nF(grandTotal.toString(), useSymbol: true),
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                color: colorPrimary,
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 5, color: colorPrimary),
                        const SizedBox(height: 5),
                        Text(
                          "Jumlah Pembayaran",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextFields(
                          padding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 10,
                          ),
                          controller: cbayar,
                          hint: "Jumlah Pembayaran",
                          isSelect: true,
                          onTap: () {},
                          prefixIcon: const Text("Rp."),
                          textAlign: TextAlign.center,
                          textStyle: TextStyle(fontSize: 32.sp),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              left: 2, right: 2, bottom: 5),
                          child: buttonSubmit(
                            text: "Uang Pass",
                            onPressed: () {},
                            radius: 5,
                            backgroundColor: colorWhite,
                            sideColor: colorPrimary,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            numpad("1"),
                            numpad("2"),
                            numpad("3"),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            numpad("4"),
                            numpad("5"),
                            numpad("6"),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            numpad("7"),
                            numpad("8"),
                            numpad("9"),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            numpad("BACKSPACE"),
                            numpad("0"),
                            numpad("OK"),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  Future<bool> _onBackPressed() {
    removeFocus(context);
    if (!saved && orders.isNotEmpty) {
      showdialog();
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: colorWhiteBg,
        appBar: AppBar(
          backgroundColor: colorWhiteBg,
          elevation: 0,
          iconTheme: const IconThemeData(color: colorPrimary),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Pesanan",
                style: TextStyle(color: colorPrimary),
              ),
            ],
          ),
          actions: [
            Center(
              child: InkWell(
                radius: 5,
                borderRadius: BorderRadius.circular(100),
                onTap: () => deleteOrder(orderid),
                child: const Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    "HAPUS",
                    style: TextStyle(color: colorPrimary),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 7,
                child: SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFields(
                        controller: cari,
                        hint: "Tambah Item",
                        radius: 10,
                        suffixIcon: InkWell(
                            onTap: () {
                              gotoPage(
                                context,
                                ScannerScreen(
                                  result: (value) async {
                                    backStep(context);
                                    cari.text = value;
                                    await DBProvider.db
                                        .searchMenu(value)
                                        .then((value) {
                                      for (var item in value) {
                                        addItem(item);
                                      }
                                      if (value.isEmpty) {
                                        showToast("Barang tidak ditemukan",
                                            context: context);
                                      }
                                    });
                                  },
                                  title: "Scan Barcode",
                                ),
                              );
                            },
                            child: const Icon(Icons.qr_code_2_outlined)),
                        readOnly: true,
                        onTap: () {
                          removeFocus(context);
                          setState(() {
                            _qtys = [];
                            _qtys.add("1");
                            for (var ord in orders) {
                              _qtys.add(ord.ordQty!);
                            }
                          });
                          gotoPage(context,
                                  Products(fromPage: "order", order: orders))
                              .then((value) {
                            wLog(value);
                            if (value != null) {
                              for (var item in value) {
                                addItem(item);
                              }
                            }
                          });
                        },
                      ),
                      Flexible(
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: colorWhite,
                            ),
                            padding: const EdgeInsets.all(10),
                            width: double.infinity,
                            child: orders.isEmpty
                                ? ScrollConfiguration(
                                    behavior: MyBehavior(),
                                    child: ListView(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      children: const [
                                        SizedBox(height: 80),
                                        Icon(
                                          Icons.shopping_cart_outlined,
                                          size: 150,
                                          color: colorGrey,
                                        ),
                                        Center(
                                          child: Text(
                                            "Belum ada pesanan",
                                            style:
                                                TextStyle(color: colorBlack60),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.only(
                                      top: 0,
                                      left: 0,
                                      right: 0,
                                      bottom: 200,
                                    ),
                                    itemCount: orders.length,
                                    itemBuilder: (c, i) {
                                      cjmls.add(TextEditingController());
                                      return orderItem(orders[i], i);
                                    },
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 4,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: colorWhite,
                    ),
                    padding: const EdgeInsets.all(10),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Ringkasan Pesanan",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("No. BON"),
                            Text(
                              "#$orderid",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Tanggal"),
                            Text(
                              dateFormat(widget.tanggal, "dd MMM yyyy"),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: colorGrey, height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Total"),
                            Text(
                              nF(total.toString(), useSymbol: true),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.spMin,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Flexible(flex: 7, child: Text("Potongan")),
                            Flexible(
                              flex: 5,
                              child: TextFields(
                                controller: cdisc,
                                hint: "0",
                                keyboardType: TextInputType.number,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                textAlign: TextAlign.end,
                                radius: 5,
                                inputAction: TextInputAction.done,
                                onTap: () {
                                  cdisc.selection = TextSelection(
                                    baseOffset: 0,
                                    extentOffset: cdisc.value.text.length,
                                  );
                                },
                                onChanged: (val) {
                                  var nums = "0";
                                  if (val.isNotEmpty) {
                                    nums = cdisc.text.replaceAll(".", "");
                                    cdisc.text = nF(nums);
                                  } else {
                                    cdisc.text = nF("0");
                                  }
                                  setState(() {
                                    grandTotalT = total - double.parse(nums);
                                  });
                                },
                                onSubmit: (c) => removeFocus(context),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Flexible(
                              flex: 7,
                              child: Text(
                                "Grand Total",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Flexible(
                              flex: 5,
                              child: Text(
                                nF(grandTotalT.toString(), useSymbol: true),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.spMin,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  flex: 3,
                                  child: buttonSubmit(
                                    text: "",
                                    onPressed: () {
                                      showCustName();
                                    },
                                    radius: 5,
                                    width:
                                        MediaQuery.of(context).size.width / 4.5,
                                    backgroundColor: colorWhite,
                                    sideColor: colorSecondary,
                                    withIcon: true,
                                    icon: const Icon(
                                      Icons.add_shopping_cart_outlined,
                                      color: colorPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  flex: 7,
                                  child: buttonSubmit(
                                    text: "Bayar",
                                    onPressed: () => checkOut(),
                                    radius: 5,
                                    width:
                                        MediaQuery.of(context).size.width / 1.6,
                                    backgroundColor: colorSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
