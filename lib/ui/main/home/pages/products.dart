import 'package:flutter/material.dart';
import 'package:warung_mini_tab/common/global_widgets.dart';
import 'package:warung_mini_tab/common/helper.dart';
import 'package:warung_mini_tab/common/my_colors.dart';
import 'package:warung_mini_tab/common/text_fields.dart';
import 'package:warung_mini_tab/core/routes.dart';
import 'package:warung_mini_tab/models/order_detail_models.dart';
import 'package:warung_mini_tab/ui/main/more/scanner_screen.dart';

import '../../../../models/cat_models.dart';
import '../../../../models/menu_models.dart';
import '../../../../providers/db_provider.dart';

class Products extends StatefulWidget {
  final String fromPage;
  final List<OrderDetailModel> order;
  const Products({Key? key, required this.fromPage, required this.order})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  List<MenuModel> menus = [];
  List<MenuModel> shown = [];
  List<CatModel> categs = [];
  List<String> mncheck = [];
  List<MenuModel> choosen = [];

  String selected = "0";

  final cari = TextEditingController();

  getProducts() {
    DBProvider.db.getAllMenus().then((value) {
      setState(() {
        menus = value;
        shown = menus;
      });
      setSelected();
    });
  }

  addItem(MenuModel item) {
    removeFocus(context);
    final index = mncheck.indexOf(item.prodId.toString());
    setState(() {
      if (index == -1) {
        mncheck.add(item.prodId.toString());
        choosen.add(item);
      }
    });
    backNdone();
  }

  backNdone() {
    backStep(context, item: choosen);
  }

  menuItem(int index) {
    MenuModel item = shown[index];
    // bool isCheck = false;
    // for (var it in mncheck) {
    //   if (it == item.prodId) {
    //     isCheck = true;
    //   }
    // }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: colorBgGrey)),
        color: colorWhite,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 7,
            child: Text(
              item.prodName.toString(),
              style: const TextStyle(overflow: TextOverflow.ellipsis),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              nF(shown[index].prodPricePcs.toString()),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  setSelected() {
    setState(() {
      if (widget.order.isNotEmpty) {
        for (var item in widget.order) {
          mncheck.add(item.ordMenuId.toString());
        }

        for (var mn in menus) {
          for (var ord in widget.order) {
            if (ord.ordMenuId == mn.prodId) {
              choosen.add(mn);
            }
          }
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorWhiteBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorWhiteBg,
        iconTheme: const IconThemeData(color: colorPrimary),
        title: const Text(
          "Produk",
          style: TextStyle(color: colorPrimary),
        ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      // floatingActionButton: widget.fromPage == "home"
      //     ? null
      //     : FloatingActionButton.extended(
      //         backgroundColor: colorSecondary,
      //         onPressed: () => backNdone(),
      //         label: Text("${mncheck.length} dipilih | Selesai?"),
      //       ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextFields(
              controller: cari,
              hint: "Cari Produk",
              radius: 10,
              suffixIcon: InkWell(
                onTap: () => gotoPage(
                  context,
                  ScannerScreen(
                    result: (value) async {
                      backStep(context);
                      cari.text = value;
                      await DBProvider.db.searchMenu(value).then((value) {
                        setState(() {
                          shown = value;
                        });
                        if (shown.isEmpty) {
                          showToast("Barang tidak ditemukan", context: context);
                        }
                      });
                    },
                    title: "Scan Barcode",
                  ),
                ),
                child: const Icon(Icons.qr_code_2_outlined),
              ),
              onChanged: (val) async {
                if (val.isEmpty) {
                  getProducts();
                } else {
                  await DBProvider.db.searchMenu(val).then((value) {
                    wLog(value);
                    setState(() {
                      shown = value;
                    });
                  });
                }
              },
            ),
          ),
          Expanded(
            child: shown.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("Tidak ada data"),
                  )
                : ListView.builder(
                    itemCount: shown.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () => addItem(shown[index]),
                        child: menuItem(index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
