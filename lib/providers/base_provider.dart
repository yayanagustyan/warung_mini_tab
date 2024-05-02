import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../auth/auth.dart';
import '../common/config.dart';
import '../common/helper.dart';

class BaseProvider extends ChangeNotifier {
  final _serverUrl = getApiUrl();
  final Dio _dio = Dio();

  dynamic resp;
  get response => resp;

  Future<dynamic> category() async {
    _dio.options.headers.addAll(await Auth.instance.getHeaders());
    var response = await _dio.get('$_serverUrl/categories');
    if (response.statusCode == 200) {
      final result = response.data;
      resp = result;
      return resp;
    } else {
      throw Exception();
    }
  }

  Future<dynamic> menus() async {
    _dio.options.headers.addAll(await Auth.instance.getHeaders());
    var response = await _dio.post('$_serverUrl/product', data: {});
    if (response.statusCode == 200) {
      final result = response.data;
      resp = result;
      return resp;
    } else {
      throw Exception();
    }
  }

  Future<dynamic> menuByCat(String data) async {
    _dio.options.headers.addAll(await Auth.instance.getHeaders());
    var response = await _dio.post('$_serverUrl/menu/by_cat', data: data);
    if (response.statusCode == 200) {
      final result = response.data;
      resp = result;
      return resp;
    } else {
      throw Exception();
    }
  }

  Future<dynamic> register(String data) async {
    _dio.options.headers.addAll(await Auth.instance.getHeaders());
    var response = await _dio.post('$_serverUrl/account/register', data: data);
    if (response.statusCode == 200) {
      final result = response.data;
      resp = result;
      return resp;
    } else {
      throw Exception();
    }
  }

  Future<dynamic> login(String data) async {
    _dio.options.headers.addAll(await Auth.instance.getHeaders());
    var response = await _dio.post('$_serverUrl/account/login', data: data);
    if (response.statusCode == 200) {
      final result = response.data;
      resp = result;
      return resp;
    } else {
      throw Exception();
    }
  }

  Future<dynamic> weblogin(String data) async {
    _dio.options.headers.addAll(await Auth.instance.getHeaders());
    var response = await _dio.post('$_serverUrl/web/login', data: data);
    if (response.statusCode == 200) {
      final result = response.data;
      resp = result;
      return resp;
    } else {
      throw Exception();
    }
  }

  Future<dynamic> params() async {
    _dio.options.headers.addAll(await Auth.instance.getHeaders());
    var response = await _dio.get('$_serverUrl/params');
    if (response.statusCode == 200) {
      final result = response.data;
      resp = result;
      return resp;
    } else {
      throw Exception();
    }
  }

  Future<dynamic> appVersion(String data) async {
    _dio.options.headers.addAll(await Auth.instance.getHeaders());
    var response = await _dio.post('$_serverUrl/apps/version', data: data);
    if (response.statusCode == 200) {
      final result = response.data;
      resp = result;
      return resp;
    } else {
      wLog(response);
      // throw Exception();
    }
  }

  Future<dynamic> sendData(String data) async {
    _dio.options.headers.addAll(await Auth.instance.getHeaders());
    var response = await _dio.post('$_serverUrl/send/data', data: data);
    if (response.statusCode == 200) {
      final result = response.data;
      resp = result;
      return resp;
    } else {
      throw Exception();
    }
  }
}
