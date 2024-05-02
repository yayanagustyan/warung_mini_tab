import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:warung_mini_tab/common/global_widgets.dart';
import 'package:warung_mini_tab/common/helper.dart';
import 'package:warung_mini_tab/common/my_colors.dart';
import 'package:warung_mini_tab/common/text_fields.dart';
import 'package:warung_mini_tab/core/routes.dart';
import 'package:warung_mini_tab/models/toko_models.dart';
import 'package:warung_mini_tab/models/user_models.dart';
import 'package:warung_mini_tab/providers/base_provider.dart';
import 'package:warung_mini_tab/ui/main/home/home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final cemail = TextEditingController();
  final cpass = TextEditingController();

  final ctoko = TextEditingController();
  final cphone = TextEditingController();
  final caddress = TextEditingController();
  final ctemail = TextEditingController();
  final ctpass = TextEditingController();

  bool isLoading = false;
  String errorInfo = "";

  void enterFullScreen() async {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp],
    );
  }

  doRegister() {
    setState(() {
      isLoading = true;
      errorInfo = "";
    });
    removeFocus(context);

    var data = {
      "tk_name": ctoko.text,
      "tk_address": caddress.text,
      "tk_phone": cphone.text,
      "tk_email": ctemail.text,
      "tk_pass": ctpass.text,
    };
    if (ctoko.text.isEmpty ||
        caddress.text.isEmpty ||
        ctemail.text.isEmpty ||
        ctpass.text.isEmpty) {
      setState(() {
        isLoading = false;
        errorInfo = "Data belum lengkap";
      });
      showToast("Data belum lengkap", context: context);
    } else {
      BaseProvider().register(jsonEncode(data)).then((value) {
        setState(() {
          isLoading = false;
          errorInfo = "";
        });

        if (value['code'] != 200) {
          setState(() {
            errorInfo = value['message'].toString();
          });
        } else {
          selectTab("1");
          showSuccess();
        }
      });
    }
  }

  showSuccess() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (v) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width / 4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: const Text("Berhasil"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Akun toko Anda berhasil disimpan, silahkan login dengan email dan password yang telah anda buat!",
              ),
              const SizedBox(height: 15),
              buttonSubmit(
                text: "OK",
                onPressed: () => backStep(context),
                radius: 5,
                backgroundColor: colorSecondary,
              ),
            ],
          ),
        );
      },
    );
  }

  doLogin(String level) {
    setState(() {
      isLoading = true;
      errorInfo = "";
    });
    removeFocus(context);
    var data = {
      "username": cemail.text,
      "password": cpass.text,
      "level": level
    };

    if (level == "kasir") {
      BaseProvider().login(jsonEncode(data)).then((value) {
        if (value['data'].length > 0) {
          wLog("ada");
          wLog(value);

          UserModel user = UserModel.fromJson(value['data'][0]);
          wLog(user.usrName);

          setCookie("login_id", user.usrId);
          setCookie("login_name", user.usrName);
          setCookie("login_status", "1");
          setCookie("login_level", level);

          gotoPageRemove(context, const HomePage());
        } else {
          wLog("gak ada");
          setState(() {
            isLoading = false;
            errorInfo = "User dan password tidak ditemukan";
          });
        }
      });
    } else {
      BaseProvider().weblogin(jsonEncode(data)).then((value) {
        if (value['data'].length > 0) {
          wLog("ada");
          wLog(value);

          TokoModel user = TokoModel.fromJson(value['data'][0]);

          setCookie("login_id", user.tkId);
          setCookie("login_name", user.tkName);
          setCookie("login_status", "1");
          setCookie("login_level", level);

          gotoPageRemove(context, const HomePage());
        } else {
          wLog("gak ada");
          setState(() {
            isLoading = false;
            errorInfo = "User dan password tidak ditemukan";
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    enterFullScreen();
  }

  String page = "1";

  loginWidget() {
    return Container(
      transform: Matrix4.translationValues(0, 40, 0),
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        // border: Border.all(color: colorPrimary),
        color: colorWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.0, 1.0), //(x,y)
            blurRadius: 5.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          const Text("Masuk untuk memulai transaksi"),
          const SizedBox(height: 10),
          TextFields(
            key: const Key("lemail"),
            controller: cemail,
            hint: "Masukkan Email",
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: colorBlack40,
            ),
            keyboardType: TextInputType.text,
            inputAction: TextInputAction.done,
            onSubmit: (val) => removeFocus(context),
          ),
          TextFields(
            key: const Key("lpass"),
            controller: cpass,
            hint: "Masukkan Password",
            showObscureSwitch: true,
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: colorBlack40,
            ),
            inputAction: TextInputAction.done,
            onSubmit: (val) => removeFocus(context),
          ),
          const SizedBox(height: 10),
          buttonSubmit(
            text: "Masuk Sebagai Kasir",
            onPressed: () => doLogin("kasir"),
            radius: 5,
            backgroundColor: colorSecondary,
          ),
          const SizedBox(height: 5),
          buttonSubmit(
            text: "Masuk Sebagai Admin",
            onPressed: () => doLogin("admin"),
            radius: 5,
            backgroundColor: colorWhite,
            sideColor: colorSecondary,
          ),
          const SizedBox(height: 5),
          Center(
            child: Text(
              errorInfo,
              style: const TextStyle(color: colorRed100),
            ),
          ),
        ],
      ),
    );
  }

  registerWidget() {
    return Container(
      transform: Matrix4.translationValues(0, 40, 0),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        // border: Border.all(color: colorPrimary),
        color: colorWhite,
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.0, 1.0), //(x,y)
            blurRadius: 5.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          const Text("Lengkapi data toko Anda untuk bergabung bersama Kami"),
          const SizedBox(height: 10),
          TextFields(
            key: const Key("namatoko"),
            controller: ctoko,
            hint: "Masukkan Nama Toko",
            prefixIcon: const Icon(
              Icons.store_outlined,
              color: colorBlack40,
            ),
            capitalize: TextCapitalization.words,
            keyboardType: TextInputType.text,
            inputAction: TextInputAction.done,
            onSubmit: (val) => removeFocus(context),
          ),
          TextFields(
            key: const Key("alamattoko"),
            controller: caddress,
            hint: "Masukkan Alamat Toko",
            prefixIcon: const Icon(
              Icons.location_on_outlined,
              color: colorBlack40,
            ),
            capitalize: TextCapitalization.sentences,
            keyboardType: TextInputType.text,
            inputAction: TextInputAction.done,
            onSubmit: (val) => removeFocus(context),
          ),
          TextFields(
            key: const Key("phonetoko"),
            controller: cphone,
            hint: "Masukkan No Telp",
            prefixIcon: const Icon(
              Icons.phone_outlined,
              color: colorBlack40,
            ),
            keyboardType: TextInputType.phone,
            inputAction: TextInputAction.done,
            onSubmit: (val) => removeFocus(context),
          ),
          const Divider(height: 50),
          TextFields(
            key: const Key("emailtoko"),
            controller: ctemail,
            hint: "Masukkan Email",
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: colorBlack40,
            ),
            keyboardType: TextInputType.emailAddress,
            inputAction: TextInputAction.done,
            onSubmit: (val) => removeFocus(context),
          ),
          TextFields(
            controller: ctpass,
            hint: "Masukkan Password",
            showObscureSwitch: true,
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: colorBlack40,
            ),
            inputAction: TextInputAction.done,
            onSubmit: (val) => removeFocus(context),
          ),
          const SizedBox(height: 10),
          buttonSubmit(
            text: "Daftar",
            onPressed: () => doRegister(),
            radius: 5,
            backgroundColor: colorSecondary,
          ),
          const SizedBox(height: 5),
          Text(
            errorInfo,
            style: const TextStyle(color: colorRed100),
          ),
        ],
      ),
    );
  }

  selectTab(tab) {
    setState(() {
      page = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: colorWhiteBg,
          body: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 50),
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: colorWhiteBg),
                      color: colorWhite,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset(
                        "assets/images/warung_white.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: colorWhite,
                  ),
                  width: double.infinity,
                  // padding: const EdgeInsets.all(15),
                  margin: EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: MediaQuery.of(context).size.width * 0.2),
                  child: Stack(
                    children: [
                      if (page == "1") loginWidget(),
                      if (page == "2") registerWidget(),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => selectTab("1"),
                            child: Container(
                              alignment: Alignment.center,
                              width: 100,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(5),
                                ),
                                color: page == "1"
                                    ? colorWhite
                                    : Colors.transparent,
                                boxShadow: page == "1"
                                    ? [
                                        const BoxShadow(
                                          color: Colors.grey,
                                          offset: Offset(0.0, -3.5), //(x,y)
                                          blurRadius: 5.0,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Text(
                                "Masuk",
                                style: TextStyle(
                                  fontWeight: page == "1"
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color:
                                      page == "1" ? colorBlack100 : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => selectTab("2"),
                            child: Container(
                              alignment: Alignment.center,
                              // width: 100,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(5),
                                ),
                                color: page == "2"
                                    ? colorWhite
                                    : Colors.transparent,
                                boxShadow: page == "2"
                                    ? [
                                        const BoxShadow(
                                          color: Colors.grey,
                                          offset: Offset(0.0, -3.5), //(x,y)
                                          blurRadius: 5.0,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Text(
                                "Daftar Toko",
                                style: TextStyle(
                                  fontWeight: page == "2"
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color:
                                      page == "2" ? colorBlack100 : Colors.grey,
                                ),
                              ),
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
        ),
        if (isLoading)
          loadingWidget(context, width: MediaQuery.of(context).size.width / 3),
      ],
    );
  }
}
