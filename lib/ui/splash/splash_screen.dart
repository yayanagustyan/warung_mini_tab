import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:warung_mini_tab/common/global_widgets.dart';
import 'package:warung_mini_tab/common/helper.dart';
import 'package:warung_mini_tab/common/my_colors.dart';
import 'package:warung_mini_tab/core/routes.dart';
import 'package:warung_mini_tab/providers/base_provider.dart';
import 'package:warung_mini_tab/ui/auth/account.dart';
import 'package:warung_mini_tab/ui/main/home/home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLoading = true;
  String appName = "";
  String packageName = "";
  String version = "";
  String buildNumber = "";
  String needUpdate = "0";
  String messages = "";
  String url = "";

  checkLogin() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      isLoading = true;
      appName = packageInfo.appName;
      packageName = packageInfo.packageName;
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;

      wLog(packageName);
      wLog(version);
      wLog(buildNumber);
    });

    var data = {"app_id": packageName, "app_version": buildNumber};
    BaseProvider().appVersion(jsonEncode(data)).then((value) {
      wLog(value);
      needUpdate = value['data'][0]['need_update'].toString();
      setState(() {
        messages = value['data'][0]['app_update_msg'].toString();
        url = value['data'][0]['url_update'].toString();
      });

      Future.delayed(const Duration(seconds: 2)).then((value) {
        if (needUpdate == "1") {
          showUpdateDialog();
        } else {
          openSession().then((s) {
            bool isLogin = s.get("login_status") == "1";
            if (isLogin) {
              gotoPageRemove(context, const HomePage());
            } else {
              gotoPageRemove(context, const LoginScreen());
            }
            setState(() {
              isLoading = false;
            });
          });
        }
      });
    });
  }

  showUpdateDialog() {
    showDialog(
      barrierDismissible: false,
      barrierColor: colorBlack60,
      context: context,
      builder: (c) {
        return AlertDialog(
          insetPadding: const EdgeInsets.all(15),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          titlePadding: const EdgeInsets.all(10),
          contentPadding: const EdgeInsets.all(10),
          title: const Text(
            "Ada pembaruan aplikasi nih!",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                textAlign: TextAlign.start,
                messages.replaceAll("<br>", '\n'),
              ),
              const SizedBox(height: 15),
              buttonSubmit(
                text: "Perbarui",
                onPressed: () {
                  _launchUrl();
                  SystemNavigator.pop();
                },
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

  Future<void> _launchUrl() async {
    final urls = Uri.parse(url);
    if (!await launchUrl(urls)) {
      throw Exception('Could not launch $urls');
    }
  }

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorWhite,
      body: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: colorGrey),
                  ),
                  child: Image.asset("assets/images/warung_white.png"),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Loading data.."),
              const SizedBox(height: 15),
              const CircularProgressIndicator(
                backgroundColor: colorBgBlue,
                valueColor: AlwaysStoppedAnimation<Color>(colorSecondary),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text("Version $version"),
            ),
          ),
        ],
      ),
    );
  }
}
