import 'dart:async';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warung_mini_tab/common/global_widgets.dart';
import 'package:warung_mini_tab/common/helper.dart';
import 'package:warung_mini_tab/common/my_colors.dart';
import 'package:warung_mini_tab/core/printer_service/printer_service.dart';

class PrinterScreen extends StatefulWidget {
  const PrinterScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PrinterScreenState();
}

class _PrinterScreenState extends State<PrinterScreen> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  List<BluetoothDevice> _devices = [];
  TestPrint testPrint = TestPrint();

  bool isLoading = false;

  String devId = "";

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    bool? isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      wLog("ERROR");
    }

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            wLog("bluetooth device state: connected");
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            wLog("bluetooth device state: disconnected");
          });
          break;
        case BlueThermalPrinter.DISCONNECT_REQUESTED:
          setState(() {
            wLog("bluetooth device state: disconnect requested");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_OFF:
          setState(() {
            wLog("bluetooth device state: bluetooth turning off");
          });
          break;
        case BlueThermalPrinter.STATE_OFF:
          setState(() {
            wLog("bluetooth device state: bluetooth off");
          });
          break;
        case BlueThermalPrinter.STATE_ON:
          setState(() {
            wLog("bluetooth device state: bluetooth on");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_ON:
          setState(() {
            wLog("bluetooth device state: bluetooth turning on");
          });
          break;
        case BlueThermalPrinter.ERROR:
          setState(() {
            wLog("bluetooth device state: error");
          });
          break;
        default:
          wLog(state);
          break;
      }
    });

    if (!mounted) return;
    setState(() {
      _devices = devices;
      isLoading = true;
    });

    var s = await openSession();

    Future.delayed(const Duration(seconds: 1)).then((value) {
      if (isConnected == true) {
        setState(() {
          devId = s.get('printer_id') ?? "";
        });
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  deviceItem() {
    List<Widget> ele = [];

    for (var dev in _devices) {
      ele.add(
        Card(
          elevation: 5,
          child: GestureDetector(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dev.name.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(dev.address.toString()),
                    ],
                  ),
                  if (!isLoading && dev.address == devId)
                    buttonSubmit(
                      text: "Disconnect",
                      onPressed: () => _disconnect(dev),
                      width: 100,
                      fontSize: 12.sp,
                      height: 32,
                      backgroundColor: colorSecondary,
                    ),
                  if (!isLoading && devId == "")
                    buttonSubmit(
                      text: "Connect",
                      onPressed: () => _connect(dev),
                      width: 100,
                      fontSize: 12.sp,
                      height: 32,
                      backgroundColor: colorGreen,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // ele.add(
    //   ElevatedButton(
    //     style: ElevatedButton.styleFrom(
    //         backgroundColor: _connected ? Colors.red : Colors.green),
    //     onPressed: _connected ? _disconnect : _connect,
    //     child: Text(
    //       _connected ? 'Disconnect' : 'Connect',
    //       style: const TextStyle(color: Colors.white),
    //     ),
    //   ),
    // );

    return ele;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Printer Settings'),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              initPlatformState();
            },
            label: const Row(
              children: [
                Icon(Icons.refresh),
                SizedBox(width: 5),
                Text("Refresh"),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              padding: const EdgeInsets.all(5),
              children: deviceItem(),
            ),
          ),
        ),
        if (isLoading) loadingWidget(context),
      ],
    );
  }

  void _connect(BluetoothDevice device) {
    // _disconnect();
    setState(() {
      isLoading = true;
    });
    bluetooth.isConnected.then((isConnected) {
      if (isConnected == false) {
        bluetooth.connect(device).then((value) {
          setState(() {
            devId = device.address.toString();
            device.connected = true;
            setCookie("printer_name", device.name);
            setCookie("printer_id", device.address);
            isLoading = false;
          });
          showToast("Printer terhubung", context: context);
          testPrint.connnectedMessage();
        }).catchError((error) {
          wLog(error.message);

          setState(() {
            devId = "";
            device.connected = false;
            setCookie("printer_name", null);
            setCookie("printer_id", null);
            isLoading = false;
          });
          showToast("Gagal menyambung printer", context: context);
        });
      } else {
        _disconnect(device);
      }
      wLog(isConnected);
    });
  }

  void _disconnect(BluetoothDevice device) {
    bluetooth.isConnected.then((isConnected) {
      if (isConnected == true) {
        bluetooth.disconnect().then((value) {
          setState(() {
            devId = "";
            device.connected = false;
            setCookie("printer_name", null);
            setCookie("printer_id", null);
            isLoading = false;
          });
          wLog("DISKONEK");
          showToast("Printer dikonek", context: context);
        });
      }
    });
  }
}
