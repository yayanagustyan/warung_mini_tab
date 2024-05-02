import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warung_mini_tab/common/my_colors.dart';
import 'package:warung_mini_tab/core/routes.dart';
import 'package:warung_mini_tab/ui/main/home/pages/order_screen.dart';
import 'package:warung_mini_tab/ui/main/home/pages/reprint_screen.dart';

import '../../../../models/order_models.dart';
import '../../../../providers/db_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<OrderModel> orders = [];
  getOrders() async {
    DBProvider.db.getCart().then((value) {
      setState(() {
        orders = value;
      });
    });
  }

  gridItem() {
    List<Widget> ele = [];

    for (var item in orders) {
      ele.add(
        InkWell(
          onTap: () {
            backStep(context);
            gotoPage(
              context,
              OrderScreen(
                custName: item.trCustName!,
                transId: item.trId!,
                disc: item.trDiscount!,
                tanggal: item.trDate!,
              ),
            );
          },
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colorSecondary,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                    border: Border.all(color: colorSecondary),
                  ),
                  child: Text(
                    "#${item.trId!}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: colorWhite),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return ele;
  }

  @override
  void initState() {
    super.initState();
    getOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorWhiteBg,
      appBar: AppBar(
        title: const Text("Daftar Pesanan"),
        actions: [
          InkWell(
            onTap: () => gotoPage(context, const ReprintScreen()),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Text("Cetak Ulang"),
              ),
            ),
          ),
        ],
      ),
      body: orders.isEmpty
          ? Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Belum ada pesanan",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: colorText,
                    ),
                  ),
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 150,
                    color: colorGrey,
                  ),
                ],
              ),
            )
          : GridView.count(
              crossAxisCount: 10,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              padding: const EdgeInsets.all(10),
              children: gridItem(),
            ),
    );
  }
}
