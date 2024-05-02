import 'dart:async';
import 'dart:io';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:warung_mini_tab/common/my_colors.dart';
import 'package:warung_mini_tab/ui/splash/splash_screen.dart';

import 'common/helper.dart';
import 'networks/http.dart';
import 'networks/socket/ssl_override.dart';

void main() {
  // runApp(const MyApp());

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
    };
    dio.interceptors.add(LogInterceptor());

    WidgetsFlutterBinding.ensureInitialized();
    if (Platform.isAndroid) {
      // await Firebase.initializeApp();
    }

    HttpOverrides.global = MyHttpOverrides();
    WidgetsFlutterBinding.ensureInitialized();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: []);
    // await SystemChrome.setPreferredOrientations(
    //   [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft],
    // );

    Directory directory =
        await path_provider.getApplicationDocumentsDirectory();
    Hive.init(directory.path);

    await initializeDateFormatting('id_ID', null)
        .then((_) => runApp(const MyApp()));
  }, (Object error, StackTrace stack) {
    wLog(error.toString());
    wLog(stack);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final heigh = MediaQuery.of(context).size.height;
    return ScreenUtilInit(
      designSize: Size(width, heigh),
      minTextAdapt: true,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          title: "",
          theme: ThemeData(
            primarySwatch: primary,
            fontFamily: "Poppins",
          ),
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
