import 'package:flutter/material.dart';
import 'package:warung_mini_tab/core/routes.dart';
import 'package:warung_mini_tab/ui/auth/account.dart';

import '../common/config.dart';
import '../common/helper.dart';

class Auth {
  static Auth instance = Auth();

  getToken() async {
    var login = await openSession();
    String token = login.get("login_token");
    return token;
  }

  getHeaders() async {
    var login = await openSession();
    String basicAuth = "";
    String token = login.get("login_token").toString();

    return {
      'Content-Type': 'application/json',
      'Authorization': basicAuth,
      'Auth-Login': token,
      'envy': getEnvy(),
    };
  }

  doLogout(BuildContext context) async {
    setCookie("login_status", "0");
    gotoPageRemove(context, const LoginScreen());
  }

  // Future<UserModel> getUserInfo() async {
  //   var info = await getCookies("login_info");
  //   List<UserModel> users = UserModel.fromJsonList(jsonDecode(info));
  //   return users[0];
  // }
}
