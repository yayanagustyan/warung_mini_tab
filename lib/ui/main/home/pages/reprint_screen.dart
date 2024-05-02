import 'package:flutter/material.dart';
import 'package:warung_mini_tab/common/global_widgets.dart';
import 'package:warung_mini_tab/common/helper.dart';
import 'package:warung_mini_tab/common/my_colors.dart';
import 'package:warung_mini_tab/common/text_fields.dart';
import 'package:warung_mini_tab/core/printer_service/printer_service.dart';
import 'package:warung_mini_tab/models/order_detail_models.dart';
import 'package:warung_mini_tab/providers/db_provider.dart';
import 'package:warung_mini_tab/ui/main/widgets/dotted_dash.dart';

class ReprintScreen extends StatefulWidget {
  const ReprintScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ReprintScreenState();
}

class _ReprintScreenState extends State<ReprintScreen> {
  final corderId = TextEditingController();

  List<OrderDetailModel> orders = [];
  String orderId = "";
  String total = "0";
  String tunai = "0";
  String kembali = "0";
  String disc = "0";
  String tanggal = "";
  String custName = "";
  String kasir = "";

  bool found = false;
  bool srcd = false;

  getOrderId(String orderid) {
    removeFocus(context);
    String code = "T${corderId.text}";
    if (code.isNotEmpty) {
      DBProvider.db.getOrderDId(code).then((value) {
        setState(() {
          srcd = true;
          if (value['data'].length > 0) {
            found = true;
            var dt = value['data'][0];
            orderId = code;
            total = dt['tr_total'].toString();
            tunai = dt['tr_payment'].toString().isEmpty
                ? "0"
                : dt['tr_payment'].toString();
            disc = dt['tr_discount'].toString();

            if (tunai != "0") {
              kembali = (double.parse(tunai) - double.parse(total)).toString();
            }
            wLog(tunai);

            tanggal =
                "${dateFormat(dt['tr_date'], "dd MMM yyyy")} ${dt['tr_time']}";
            custName = dt['tr_cust_name'];
            orders = OrderDetailModel.fromJsonList(value['details']);
          } else {
            found = false;
          }
        });
      });
    }
  }

  List<Widget> notfound() {
    List<Widget> ele = [];

    ele.add(const Text("Data tidak ditemukan"));

    return ele;
  }

  List<Widget> orderItem() {
    List<Widget> ele = [];

    final boxWidth = MediaQuery.of(context).size.width / 2;
    ele.add(Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DottedDash(boxWidth: boxWidth, rowCount: 2),
    ));

    ele.add(Text(tanggal));
    ele.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(kasir.toUpperCase()),
        Text("#$orderId"),
      ],
    ));
    ele.add(Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DottedDash(boxWidth: boxWidth, rowCount: 2),
    ));

    for (var ord in orders) {
      ele.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("${ord.ordQty} ${ord.ordMenuName}", maxLines: 1),
          Text(nF(ord.ordSubTotal.toString())),
        ],
      ));
    }
    ele.add(Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DottedDash(boxWidth: boxWidth, rowCount: 2),
    ));
    ele.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Potongan", maxLines: 1),
        Text("-${nF(disc.toString())}"),
      ],
    ));
    ele.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Total", maxLines: 1),
        Text(nF(total.toString())),
      ],
    ));
    ele.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Tunai", maxLines: 1),
        Text(nF(tunai.toString())),
      ],
    ));
    ele.add(Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.centerRight,
        width: MediaQuery.of(context).size.width / 6,
        child: DottedDash(boxWidth: MediaQuery.of(context).size.width / 6),
      ),
    ));
    ele.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Kembali", maxLines: 1),
        Text(nF(kembali.toString())),
      ],
    ));
    ele.add(Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DottedDash(boxWidth: boxWidth, rowCount: 2),
    ));

    return !srcd ? [] : ele;
  }

  getKasir() async {
    var cs = await getCookies("login_name");
    setState(() {
      kasir = cs;
    });
  }

  @override
  void initState() {
    super.initState();
    getKasir();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text("Reprint Struk"),
          ),
          body: Stack(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 80),
                  width: MediaQuery.of(context).size.width / 2,
                  padding: const EdgeInsets.all(10),
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 100),
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: srcd && !found ? notfound() : orderItem(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 7,
                      child: TextFields(
                        controller: corderId,
                        title: "Order ID",
                        radius: 10,
                        inputAction: TextInputAction.search,
                        keyboardType: TextInputType.number,
                        onSubmit: (s) => getOrderId(s),
                        suffixIcon: InkWell(
                          onTap: () => getOrderId(corderId.text),
                          child: const Icon(Icons.search_outlined),
                        ),
                        prefixIcon: const Text("#T"),
                      ),
                    ),
                    if (found)
                      Flexible(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 30, horizontal: 15),
                          child: buttonSubmit(
                            text: "Cetak",
                            withIcon: true,
                            icon: const Icon(Icons.print_outlined,
                                color: colorWhite),
                            onPressed: () {
                              TestPrint().printStruk(orderId, kembali, disc,
                                  ori: false);
                            },
                            radius: 10,
                            backgroundColor: colorSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
