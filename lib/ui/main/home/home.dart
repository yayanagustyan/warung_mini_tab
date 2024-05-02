import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:warung_mini_tab/common/global_widgets.dart';
import 'package:warung_mini_tab/core/routes.dart';
import 'package:warung_mini_tab/models/history_model.dart';
import 'package:warung_mini_tab/providers/base_provider.dart';
import 'package:warung_mini_tab/ui/main/home/pages/cart_screen.dart';
import 'package:warung_mini_tab/ui/main/home/pages/order_screen.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:warung_mini_tab/ui/main/more/more.dart';

import '../../../common/helper.dart';
import '../../../common/my_colors.dart';
import '../../../providers/db_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  String point = "0";
  String nama = "";
  String level = "";
  String version = "";
  // String _isLogin = "0";
  // int _current = 0;
  String cookies = "";
  String total = "0";
  String jml = "0";
  String qty = "0";
  String cart = "0";
  String mns = "0";
  String cat = "0";
  String pcs = "1000";

  double width = 100.0, height = 100.0;
  late Offset position;
  double xPosition = 100;
  double yPosition = 100;

  List<HistoryModel> history = [];
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void enterFullScreen() async {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft],
    );
  }

  getDash() async {
    enterFullScreen();
    await DBProvider.db.getDash().then((value) {
      wLog(value);
      setState(() {
        total = value[0]['total'].toString();
        jml = value[0]['jml'].toString();
        cart = value[0]['cart'].toString();
        qty = (value[0]['qty'] + 1).toString();
        mns = value[0]['mns'].toString();
        cat = value[0]['cat'].toString();
        pcs = value[0]['pcs'].toString();
      });
    });

    await DBProvider.db.history().then((value) {
      wLog(jsonEncode(value));
      setState(() {
        history = HistoryModel.fromJsonList(value);
      });
    });

    BaseProvider().params().then((value) {
      setCookie("store_name", value['data'][0]['store_name']);
      setCookie("store_address", value['data'][0]['store_address']);
      setCookie("store_image", value['data'][0]['store_image']);
    });

    var nm = await getCookies("login_name");
    var lv = await getCookies("login_level");
    setState(() {
      nama = nm;
      level = lv.capitalize();
    });

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      version = packageInfo.version;

      wLog(version);
    });
  }

  showNotifSync() {
    showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(10),
          titlePadding: const EdgeInsets.all(10),
          title: const Text("Sinkronisasi Data"),
          content: SizedBox(
            width: MediaQuery.of(context).size.width / 4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Hallo, Silahkan lakukan sinkronisasi data terlebih dahulu untuk melanjutkan. Terimakasih!",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                buttonSubmit(
                  text: "OK",
                  radius: 5,
                  onPressed: () {
                    backStep(context);
                    gotoPage(context, const MorePage());
                  },
                )
              ],
            ),
          ),
        );
      }),
    );
  }

  checkLastSync() async {
    var ls = "";
    if (await cookiesExist("lastSync")) {
      ls = await getCookies("lastSync");
      ls = dateCustomFormat(ls, "dd MMM yyyy", "yyyy-MM-dd");
      if (ls != getCurrentDate()) {
        showNotifSync();
      }
    } else {
      showNotifSync();
    }
  }

  @override
  void initState() {
    super.initState();
    DBProvider.db.initDB();

    getDash();
    checkLastSync();

    position = const Offset(250.0, 200.0);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    setState(() {});
  }

  Widget dashCard(String title, String value) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.all(5),
        height: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              nF(value, useSymbol: true),
              style: const TextStyle(
                fontSize: 22,
                color: colorPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget homeMenuItem(BuildContext context, String code) {
    return GestureDetector(
      onTap: () {},
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    width: double.maxFinite,
                    child: dashCard("Pendapatan Hari Ini", total),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 3,
                          child: SizedBox(
                            child: Stack(
                              children: [
                                buttonSubmit(
                                  backgroundColor: colorSecondary,
                                  radius: 10,
                                  text: "",
                                  withIcon: true,
                                  icon: const Icon(
                                    Icons.shopping_cart_outlined,
                                    color: colorWhite,
                                  ),
                                  onPressed: () =>
                                      gotoPage(context, const CartScreen()),
                                ),
                                if (cart != "0")
                                  Positioned(
                                    top: 2,
                                    right: 17,
                                    child: CircleAvatar(
                                      radius: 10,
                                      child: Text(
                                        cart,
                                        style: TextStyle(fontSize: 12.sp),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          flex: 5,
                          child: buttonSubmit(
                            text: "Transaksi Baru",
                            backgroundColor: colorSecondary,
                            radius: 10,
                            onPressed: () => showCustName(),
                            withIcon: true,
                            icon: const Icon(
                              Icons.add,
                              color: colorWhite,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
              Expanded(
                  child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 10,
                child: Container(
                  height: MediaQuery.of(context).size.height - 120,
                  padding: const EdgeInsets.all(15),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: histories(),
                    ),
                  ),
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _line() {
    return Container(
      height: 1.5,
      width: 150,
      color: colorPrimary,
    );
  }

  showCustName() {
    gotoPage(
      context,
      OrderScreen(
        custName: "custName",
        transId: "",
        disc: "0",
        tanggal: getCurrentDate(),
      ),
    );
  }

  List<Widget> histories() {
    List<Widget> ele = [];

    ele.add(
      const Text(
        "Histori Penjualan",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    ele.add(_line());
    ele.add(const SizedBox(height: 15));

    if (history.isEmpty) {
      ele.add(const Padding(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Text(
          "Belum ada transaksi untuk hari ini",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: colorBlack40,
          ),
        ),
      ));
    }

    for (var his in history) {
      ele.add(
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: colorSecondary),
            borderRadius: BorderRadius.circular(5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          margin: const EdgeInsets.only(bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "#${his.trId}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("${his.trJml} barang"),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(his.trTime, style: TextStyle(fontSize: 12.sp)),
                  Text(
                    nF(his.trTotal),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return ele;
  }

  Widget backgroundHeader(String name) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 15),
          height: 220,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: colorWhiteBg,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 0, left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        scaffoldKey.currentState!.openDrawer();
                      },
                      child: const CircleAvatar(
                        backgroundColor: colorSecondary,
                        child: Icon(Icons.menu, size: 30, color: colorWhite),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Halo ${getFirstName(name)}, ",
                          style: const TextStyle(
                            fontSize: 32,
                            color: colorPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "Semangat jualannya ya...",
                          style: TextStyle(
                            fontSize: 14,
                            color: colorPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            decoration: const BoxDecoration(
              color: colorSecondary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(150),
              ),
            ),
            height: 150,
            width: 150,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key("value"),
      onVisibilityChanged: (VisibilityInfo info) {
        var visiblePercentage = info.visibleFraction * 100;
        if (visiblePercentage == 100) {
          wLog("OKE");
          getDash();
        }
      },
      child: WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: colorWhiteBg,
          resizeToAvoidBottomInset: false,
          drawer: Drawer(
            width: 200,
            backgroundColor: colorWhite,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(15),
              ),
            ),
            child: sidebar(context, scaffoldKey, version, nama, level),
          ),
          body: Stack(
            children: <Widget>[
              Container(
                color: colorWhiteBg,
                child: Stack(
                  children: [
                    backgroundHeader(nama),
                    Container(
                      margin:
                          const EdgeInsets.only(top: 100, left: 10, right: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          homeMenuItem(context, ""),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() {
    return Future.value(true);
  }
}
