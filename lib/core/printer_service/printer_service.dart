import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:warung_mini_tab/common/helper.dart';
import 'package:warung_mini_tab/models/order_detail_models.dart';
import 'package:warung_mini_tab/providers/db_provider.dart';

import 'printer_enum.dart';

///Test printing
class TestPrint {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  connnectedMessage() async {
    bluetooth.isConnected.then((isConnected) {
      wLog(isConnected);
      if (isConnected == true) {
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printCustom(
            "Printer Connected", Size.medium.val, PAlign.center.val);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printCustom("----------------------------------------",
            Size.medium.val, PAlign.center.val);
        // bluetooth.paperCut();
        //some printer not supported (sometime making image not centered)
        //bluetooth.drawerPin2(); // or you can use bluetooth.drawerPin5();
      }
    });
  }

  Future<bool?> cekPrinter() async {
    bool? connect = await bluetooth.isConnected;
    return connect;
  }

  Future<bool?> printStruk(String orderId, String sisa, String disc,
      {ori = true}) async {
    String sname = await getCookies("store_name");
    String saddress = await getCookies("store_address");
    String kasir = await getCookies("login_name");

    var now = dateTimeFormat(getCurrentDateTime(), "dd MMM yyyy HH:mm");
    bool? connect = await bluetooth.isConnected;
    String total = "0";
    String tunai = "0";
    String kembali = "0";

    if (connect == true) {
      DBProvider.db.getOrderDId(orderId).then((value) {
        bluetooth.printNewLine();

        bluetooth.printCustom(sname, Size.boldLarge.val, PAlign.center.val);
        bluetooth.printCustom(
            "======================", Size.bold.val, PAlign.center.val);
        bluetooth.printCustom(saddress, Size.bold.val, PAlign.center.val);
        bluetooth.printCustom("================================", Size.bold.val,
            PAlign.center.val);

        if (!ori) {
          bluetooth.printCustom("DUPLIKAT", Size.medium.val, PAlign.center.val);
          bluetooth.printCustom("================================",
              Size.bold.val, PAlign.center.val);
        }

        bluetooth.printCustom(now, Size.medium.val, PAlign.left.val);
        bluetooth.printLeftRight(
            kasir.toUpperCase(), "#$orderId", Size.medium.val);
        bluetooth.printCustom("================================", Size.bold.val,
            PAlign.center.val);

        var dt = value['data'][0];

        total = dt['tr_total'].toString();
        tunai = dt['tr_payment'].toString().isEmpty
            ? "0"
            : dt['tr_payment'].toString();
        disc = dt['tr_discount'].toString();

        if (tunai != "0") {
          kembali = (double.parse(tunai) - double.parse(total)).toString();
        }

        for (var item in value['details']) {
          OrderDetailModel mns = OrderDetailModel.fromJson(item);
          String mn = mns.ordMenuName.toString();
          String namamenu = mn;
          if (mn.length > 11) {
            namamenu = mn.substring(0, 11);
          }

          int qty = int.parse(mns.ordQty.toString());
          String subt = (mns.ordSubTotal.toString());

          String qtys = qty < 10 ? " $qty" : qty.toString();

          bluetooth.printLeftRight(
              "$qtys $namamenu", nF(subt), Size.medium.val);
        }

        bluetooth.printCustom("================================", Size.bold.val,
            PAlign.center.val);
        bluetooth.printLeftRight(
            "Potongan", "-${nF(disc.toString())}", Size.medium.val);
        bluetooth.printLeftRight("Total", nF(total), Size.medium.val);
        bluetooth.printLeftRight("Tunai", nF(tunai), Size.medium.val);
        bluetooth.printCustom(
            "----------------", Size.bold.val, PAlign.right.val);
        bluetooth.printLeftRight("Kembali", nF(kembali), Size.medium.val);
        bluetooth.printCustom("================================", Size.bold.val,
            PAlign.center.val);
        bluetooth.printCustom("Terima kasih telah berbelanja di warung Kami.",
            Size.bold.val, PAlign.center.val);
        bluetooth.printQRcode(orderId, 200, 200, PAlign.center.val);
        bluetooth.printNewLine();
        bluetooth.printCustom("--------------------------------", Size.bold.val,
            PAlign.center.val);
        bluetooth.printNewLine();
      });
    } else {
      setCookie("printer_name", null);
      setCookie("printer_id", null);
    }
    return connect;
  }

  sample() async {
    //image max 300px X 300px

    ///image from File path
    String filename = 'yourlogo.png';
    ByteData bytesData = await rootBundle.load("assets/images/bell_icon.png");
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = await File('$dir/$filename').writeAsBytes(bytesData.buffer
        .asUint8List(bytesData.offsetInBytes, bytesData.lengthInBytes));

    ///image from Asset
    ByteData bytesAsset = await rootBundle.load("assets/images/bell_icon.png");
    Uint8List imageBytesFromAsset = bytesAsset.buffer
        .asUint8List(bytesAsset.offsetInBytes, bytesAsset.lengthInBytes);

    ///image from Network
    var response = await http.get(Uri.parse(
        "https://raw.githubusercontent.com/kakzaki/blue_thermal_printer/master/example/assets/images/yourlogo.png"));
    Uint8List bytesNetwork = response.bodyBytes;
    Uint8List imageBytesFromNetwork = bytesNetwork.buffer
        .asUint8List(bytesNetwork.offsetInBytes, bytesNetwork.lengthInBytes);

    bluetooth.isConnected.then((isConnected) {
      if (isConnected == true) {
        bluetooth.printNewLine();
        bluetooth.printCustom("HEADER", Size.boldMedium.val, PAlign.center.val);
        bluetooth.printNewLine();
        bluetooth.printImage(file.path); //path of your image/logo
        bluetooth.printNewLine();
        bluetooth.printImageBytes(imageBytesFromAsset); //image from Asset
        bluetooth.printNewLine();
        bluetooth.printImageBytes(imageBytesFromNetwork); //image from Network
        bluetooth.printNewLine();
        bluetooth.printLeftRight(
            "Bayam Oseng 1x", "Rp. 35.000", Size.medium.val);
        bluetooth.printLeftRight("LEFT", "RIGHT", Size.bold.val);
        bluetooth.printLeftRight("LEFT", "RIGHT", Size.bold.val,
            format:
                "%-15s %15s %n"); //15 is number off character from left or right
        bluetooth.printNewLine();
        bluetooth.printLeftRight("LEFT", "RIGHT", Size.boldMedium.val);
        bluetooth.printLeftRight("LEFT", "RIGHT", Size.boldLarge.val);
        bluetooth.printLeftRight("LEFT", "RIGHT", Size.extraLarge.val);
        bluetooth.printNewLine();
        bluetooth.print3Column("Col1", "Col2", "Col3", Size.bold.val);
        bluetooth.print3Column("Col1", "Col2", "Col3", Size.bold.val,
            format:
                "%-10s %10s %10s %n"); //10 is number off character from left center and right
        bluetooth.printNewLine();
        bluetooth.print4Column("Col1", "Col2", "Col3", "Col4", Size.bold.val);
        bluetooth.print4Column("Col1", "Col2", "Col3", "Col4", Size.bold.val,
            format: "%-8s %7s %7s %7s %n");
        bluetooth.printNewLine();
        bluetooth.printLeftRight("Stevilka:", "18000001", Size.bold.val,
            charset: "windows-1250");
        bluetooth.printCustom("Body left", Size.bold.val, PAlign.left.val);
        bluetooth.printCustom("Body right", Size.medium.val, PAlign.right.val);
        bluetooth.printNewLine();
        bluetooth.printCustom("Thank You", Size.bold.val, PAlign.center.val);
        bluetooth.printNewLine();
        bluetooth.printQRcode(
            "Insert Your Own Text to Generate", 200, 200, PAlign.center.val);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth
            .paperCut(); //some printer not supported (sometime making image not centered)
        //bluetooth.drawerPin2(); // or you can use bluetooth.drawerPin5();
      }
    });
  }

//   sample(String pathImage) async {
//     //SIZE
//     // 0- normal size text
//     // 1- only bold text
//     // 2- bold with medium text
//     // 3- bold with large text
//     //ALIGN
//     // 0- ESC_ALIGN_LEFT
//     // 1- ESC_ALIGN_CENTER
//     // 2- ESC_ALIGN_RIGHT
//
// //     var response = await http.get("IMAGE_URL");
// //     Uint8List bytes = response.bodyBytes;
//     bluetooth.isConnected.then((isConnected) {
//       if (isConnected == true) {
//         bluetooth.printNewLine();
//         bluetooth.printCustom("HEADER", 3, 1);
//         bluetooth.printNewLine();
//         bluetooth.printImage(pathImage); //path of your image/logo
//         bluetooth.printNewLine();
// //      bluetooth.printImageBytes(bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
//         bluetooth.printLeftRight("LEFT", "RIGHT", 0);
//         bluetooth.printLeftRight("LEFT", "RIGHT", 1);
//         bluetooth.printLeftRight("LEFT", "RIGHT", 1, format: "%-15s %15s %n");
//         bluetooth.printNewLine();
//         bluetooth.printLeftRight("LEFT", "RIGHT", 2);
//         bluetooth.printLeftRight("LEFT", "RIGHT", 3);
//         bluetooth.printLeftRight("LEFT", "RIGHT", 4);
//         bluetooth.printNewLine();
//         bluetooth.print3Column("Col1", "Col2", "Col3", 1);
//         bluetooth.print3Column("Col1", "Col2", "Col3", 1,
//             format: "%-10s %10s %10s %n");
//         bluetooth.printNewLine();
//         bluetooth.print4Column("Col1", "Col2", "Col3", "Col4", 1);
//         bluetooth.print4Column("Col1", "Col2", "Col3", "Col4", 1,
//             format: "%-8s %7s %7s %7s %n");
//         bluetooth.printNewLine();
//         String testString = " čĆžŽšŠ-H-ščđ";
//         bluetooth.printCustom(testString, 1, 1, charset: "windows-1250");
//         bluetooth.printLeftRight("Številka:", "18000001", 1,
//             charset: "windows-1250");
//         bluetooth.printCustom("Body left", 1, 0);
//         bluetooth.printCustom("Body right", 0, 2);
//         bluetooth.printNewLine();
//         bluetooth.printCustom("Thank You", 2, 1);
//         bluetooth.printNewLine();
//         bluetooth.printQRcode("Insert Your Own Text to Generate", 200, 200, 1);
//         bluetooth.printNewLine();
//         bluetooth.printNewLine();
//         bluetooth.paperCut();
//       }
//     });
//   }
}
