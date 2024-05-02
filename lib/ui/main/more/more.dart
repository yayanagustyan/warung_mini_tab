import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:warung_mini_tab/common/global_widgets.dart';
import 'package:warung_mini_tab/common/text_fields.dart';
import 'package:warung_mini_tab/core/printer_service/printer_service.dart';
import 'package:warung_mini_tab/core/routes.dart';
import 'package:warung_mini_tab/ui/main/home/home.dart';
import 'package:warung_mini_tab/ui/main/more/printer_screen.dart';

import '../../../common/helper.dart';
import '../../../common/my_behavior.dart';
import '../../../common/my_colors.dart';
import '../../../models/menu_models.dart';
import '../../../providers/base_provider.dart';
import '../../../providers/db_provider.dart';

class MorePage extends StatefulWidget {
  const MorePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MorePageState();
  }
}

class _MorePageState extends State<MorePage> {
  // String _nama = "";

  final caccess = TextEditingController();

  bool isLoading = false;
  var base = BaseProvider();
  Uint8List? base64;

  String resulttext = "";
  String printerName = "";

  String lastSync = "none";
  String lastSend = "none";

  showLoading() {
    setState(() {
      isLoading = true;
    });
  }

  hideLoading() {
    setState(() {
      isLoading = false;
    });
  }

  PackageInfo packageInfo = PackageInfo(
    appName: '',
    packageName: '',
    version: '',
    buildNumber: '',
  );

  String uniqueId = "Unknown";

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      packageInfo = info;
    });
  }

  syncronize() async {
    resulttext = "";
    showLoading();
    base.menus().then(
      (value) async {
        List<MenuModel> menus = MenuModel.fromJsonList(value['data']);
        await DBProvider.db.deleteAllMenus().then((value) async {
          for (var item in menus) {
            DBProvider.db.insertMenu(item);
          }
          resulttext += "Data terbaru berhasil disimpan\n";
          setState(() {
            lastSync =
                dateTimeFormat(getCurrentDateTime(), "dd MMM yyyy hh:mm");
            setCookie("lastSync", lastSync);
          });
        });
        var tt = formatDateTime(DateTime.now().toString(), patern: "hh:mm");
        wLog(tt);
      },
    ).then((value) {
      hideLoading();
      showdialog();
    });
  }

  sendData() {
    setState(() {
      isLoading = true;
    });
    DBProvider.db.getPaidOrder().then((value) {
      if (value['data'].length > 0) {
        BaseProvider().sendData(jsonEncode(value)).then((value) {
          wLog(jsonEncode(value));
          setState(() {
            lastSend =
                dateTimeFormat(getCurrentDateTime(), "dd MMM yyyy hh:mm");
            setCookie("lastSend", lastSend);
          });
          DBProvider.db.deleteAllOrder().then((value) {
            showToast("Data berhasil dikirim", context: context);
            gotoPageRemove(context, const HomePage());
          });
        });
      } else {
        showToast("Tidak ada data yang dikirim", context: context);
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  clearAllData() {
    caccess.clear();
    showDialog(
      context: context,
      builder: (c) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(10),
          titlePadding: const EdgeInsets.all(10),
          title: const Text("Hapus Semua Data?"),
          content: SizedBox(
            width: MediaQuery.of(context).size.width / 4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Semua data pesanan dalam aplikasi akan dibersihkan dan tidak bisa dikembalikan. Masukkan kode akses Anda untuk menghapus!",
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 14.sp),
                ),
                const SizedBox(height: 15),
                TextFields(
                  controller: caccess,
                  hint: "Kode Akses",
                  capitalize: TextCapitalization.characters,
                ),
                const SizedBox(height: 15),
                buttonSubmit(
                  text: "Bersihkan",
                  radius: 5,
                  backgroundColor: colorWhite,
                  sideColor: colorPrimary,
                  onPressed: () {
                    setCookie("lastId", "");
                    removeFocus(context);
                    if (caccess.text == "DEL123ADMIN") {
                      DBProvider.db.deleteAllOrder().then((value) {
                        showToast("data berhasil dihapus", context: context);
                        backStep(context);
                        sendData();
                      });
                    } else {
                      showToast("Kode akses salah", context: context);
                    }
                  },
                ),
              ],
            ),
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
          title: const Text("Berhasil"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(resulttext),
              buttonSubmit(
                text: "OK",
                onPressed: () => backStep(context),
                radius: 5,
                backgroundColor: colorWhite,
                sideColor: colorPrimary,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    // _createLogs();
    _setSession();
    _initPackageInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: colorWhiteBg,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text("Pengaturan"),
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                child: ScrollConfiguration(
                  behavior: MyBehavior(),
                  child: ListView(
                    padding: const EdgeInsets.only(top: 10),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 8,
                        ),
                        child: GestureDetector(
                          onTap: () => syncronize(),
                          child: Card(
                            child: Container(
                                padding: const EdgeInsets.all(15),
                                child: Row(
                                  children: [
                                    const Icon(Icons.sync),
                                    const SizedBox(width: 15),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text("Sinkronisasi data"),
                                        Text(
                                          "Terakhir Sinkronisasi : ${lastSync == "null" ? "-" : lastSync}",
                                          style: TextStyle(fontSize: 12.sp),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 8,
                        ),
                        child: GestureDetector(
                          onTap: () => sendData(),
                          child: Card(
                            child: Container(
                                padding: const EdgeInsets.all(15),
                                child: Row(
                                  children: [
                                    const Icon(Icons
                                        .transfer_within_a_station_outlined),
                                    const SizedBox(width: 15),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text("Kirim Data"),
                                        Text(
                                          "Terakhir Kirim : ${lastSend == "null" ? "-" : lastSend}",
                                          style: TextStyle(fontSize: 12.sp),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 8,
                        ),
                        child: GestureDetector(
                          onTap: () => gotoPage(context, const PrinterScreen())
                              .then((value) => _setSession()),
                          child: Card(
                            child: Container(
                                width: double.maxFinite,
                                padding: const EdgeInsets.all(15),
                                child: Row(
                                  children: [
                                    const Icon(Icons.print_outlined),
                                    const SizedBox(width: 15),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text("Printer"),
                                        Text(
                                          printerName,
                                          style: TextStyle(fontSize: 12.sp),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 8,
                        ),
                        child: GestureDetector(
                          onTap: () => clearAllData(),
                          child: Card(
                            child: Container(
                                padding: const EdgeInsets.all(15),
                                child: Row(
                                  children: [
                                    const Icon(Icons.delete_outline),
                                    const SizedBox(width: 15),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text("Bersihkan Data"),
                                        Text(
                                          "Bersihkan semua data pesanan",
                                          style: TextStyle(fontSize: 12.sp),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isLoading) loadingWidget(context),
      ],
    );
  }

  _setSession() async {
    lastSync = await getCookies("lastSync");
    lastSend = await getCookies("lastSend");

    var login = await openSession();
    TestPrint().cekPrinter().then((value) {
      setState(() {
        if (value == true) {
          printerName = login.get('printer_name');
        } else {
          printerName = "No Printer Set";
        }
      });
    });
  }
}

Widget backgroundHeader() {
  return Container(
    transform: Matrix4.translationValues(-95.0, -170.0, 0.0),
    padding: const EdgeInsets.only(top: 10),
    height: 300.0,
    width: 350.0,
    decoration: const BoxDecoration(
      color: colorSecondary,
      shape: BoxShape.circle,
    ),
    child: Container(
      transform: Matrix4.translationValues(95.0, 170.0, 0.0),
      child: const Padding(
        padding: EdgeInsets.only(top: 50, left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pengaturan",
                  style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
