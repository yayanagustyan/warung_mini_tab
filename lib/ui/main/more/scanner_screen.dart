import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:warung_mini_tab/common/global_widgets.dart';
import 'package:warung_mini_tab/common/my_colors.dart';

// ignore: must_be_immutable
class ScannerScreen extends StatefulWidget {
  Function(String) result;
  String title;
  ScannerScreen({
    Key? key,
    required this.result,
    required this.title,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  Barcode? scanResult;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String codeBefore = "";
  TextEditingController input = TextEditingController();
  TextEditingController generate = TextEditingController();

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  Future<bool> _onBackPressed() async {
    Navigator.pop(context, "**back**");
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: colorWhite,
        appBar: AppBar(
          backgroundColor: colorBlack100,
          title: Text(widget.title),
        ),
        body: Column(
          children: <Widget>[
            Expanded(flex: 3, child: _buildQrView()),
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.black,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        button(
                          onTap: () async {
                            await controller?.flipCamera();
                            setState(() {});
                          },
                          icon: FutureBuilder(
                            future: controller?.getCameraInfo(),
                            builder: (context, snapshot) {
                              if (snapshot.data != null) {
                                if (describeEnum(snapshot.data!) == "back") {
                                  return const Icon(
                                    Icons.camera_alt_outlined,
                                    color: colorWhite,
                                  );
                                } else {
                                  return const Icon(
                                    Icons.camera_front,
                                    color: colorWhite,
                                  );
                                }
                              } else {
                                return const Icon(
                                  Icons.camera_alt_outlined,
                                  color: colorWhite,
                                );
                              }
                            },
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            await controller?.resumeCamera();
                            setState(() {
                              codeBefore = "";
                              scanResult = null;
                            });
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: colorWhite,
                                border: Border.all(
                                  color: colorWhite,
                                ),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.qr_code_2_outlined,
                                  size: 35,
                                  color: colorBlack60,
                                ),
                              ),
                            ),
                          ),
                        ),
                        button(
                          onTap: () async {
                            await controller?.toggleFlash();
                            setState(() {});
                          },
                          icon: FutureBuilder(
                            future: controller?.getFlashStatus(),
                            builder: (context, snapshot) {
                              if (snapshot.data == false ||
                                  snapshot.data == null) {
                                return const Icon(
                                  Icons.flash_off,
                                  color: colorWhite,
                                );
                              } else {
                                return const Icon(
                                  Icons.flash_auto,
                                  color: colorWhite,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget button({required VoidCallback onTap, required Widget icon}) {
    return InkWell(
      onTap: () async {
        onTap();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(
              color: colorWhite,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: icon,
        ),
      ),
    );
  }

  Widget _buildQrView() {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: colorPrimary,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      // if (scanData.code.toString() != codeBefore) {
      //QTNotif.showToast(text: scanData.code.toString());
      controller.pauseCamera();
      setState(() {
        widget.result(scanData.code.toString());
        scanResult = scanData;
        codeBefore = scanData.code.toString();
      });
      // }
    });
  }

  void _onPermissionSet(QRViewController ctrl, bool p) {
    if (!p) {
      showToast("No Permission", context: context);
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
