import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:warung_mini_tab/common/helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:warung_mini_tab/models/order_list_models.dart';

import '../models/menu_models.dart';
import '../models/order_detail_models.dart';
import '../models/order_models.dart';

class DBProvider {
  late Database _database;
  static final DBProvider db = DBProvider._();

  DBProvider._();

  Future<Database> get database async {
    // If database exists, return database
    // if (_database == null)  _database  = ;

    // If database don't exists, create one
    _database = await initDB();

    return _database;
  }

  // Create the database and the Employee table
  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'warung3.db');

    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      Batch batch = db.batch();
      batch.execute('CREATE TABLE Product('
          'prod_id TEXT PRIMARY KEY,'
          'prod_code TEXT,'
          'prod_name TEXT,'
          'prod_stock REAL,'
          'prod_price_pcs REAL,'
          'prod_price_doz REAL,'
          'prod_box_qty REAL,'
          'prod_price_box REAL,'
          'prod_oth_qty REAL,'
          'prod_price_oth REAL'
          ')');

      batch.execute('CREATE TABLE Orders ('
          'tr_id TEXT PRIMARY KEY,'
          'tr_date TEXT,'
          'tr_time TEXT,'
          'tr_paid INTEGER,'
          'tr_payment TEXT,'
          'tr_additional TEXT,'
          'tr_tax TEXT,'
          'tr_total REAL,'
          'tr_discount REAL,'
          'tr_cust_name TEXT'
          ')');

      batch.execute('CREATE TABLE OrderDetail('
          'ord_id TEXT PRIMARY KEY,'
          'ord_tr_id TEXT,'
          'ord_menu_id INTEGER,'
          'ord_menu_name TEXT,'
          'ord_qty INTEGER,'
          'ord_price REAL,'
          'ord_sub_total REAL'
          ')');

      await batch.commit();
    });
  }

  // Insert menu on database
  insertMenu(MenuModel menus) async {
    final db = await database;
    final res = await db.insert('Product', menus.toJson());

    return res;
  }

  // Delete all menus
  Future<int> deleteAllMenus() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM Product');

    return res;
  }

  Future<List<MenuModel>> getAllMenus({int? limit}) async {
    final db = await database;
    var q = "SELECT * FROM Product ORDER BY prod_name";
    if (limit != null) {
      q = "SELECT * FROM Product ORDER BY prod_name LIMIT $limit";
    }
    final res = await db.rawQuery(q);

    List<MenuModel> list =
        res.isNotEmpty ? res.map((c) => MenuModel.fromJson(c)).toList() : [];

    return list;
  }

  Future<MenuModel> getProductId(String code) async {
    final db = await database;
    final res =
        await db.query("Product", where: "prod_id = ?", whereArgs: [code]);
    return MenuModel.fromJson(res.first);
  }

  Future<List<MenuModel>> searchMenu(String keyword) async {
    final db = await database;
    final code = keyword;
    final name = keyword;
    final res = await db.rawQuery(
        "SELECT * FROM Product WHERE prod_code LIKE ? OR prod_name LIKE ?  ORDER BY prod_name",
        ['%$code%', '%$name%']);

    List<MenuModel> list =
        res.isNotEmpty ? res.map((c) => MenuModel.fromJson(c)).toList() : [];
    return list;
  }

  // Insert menu on database
  insertOrder(OrderModel cats) async {
    final db = await database;
    final res = await db.insert('Orders', cats.toJson());

    return res;
  }

  // Delete all menus
  Future<int> deleteAllOrder() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM Orders');

    deleteAllOrderD();

    return res;
  }

  Future<List<OrderModel>> getAllOrder() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM Orders");

    List<OrderModel> list =
        res.isNotEmpty ? res.map((c) => OrderModel.fromJson(c)).toList() : [];
    return list;
  }

  Future<dynamic> getSumaryOrder(String date) async {
    final db = await database;
    final res =
        await db.rawQuery("SELECT * FROM Orders WHERE tr_date =?", [date]);

    var list = [];
    for (var rs in res) {
      OrderListModel mm = OrderListModel.fromJson(rs);
      var resd = await db
          .rawQuery("SELECT * FROM OrderDetail WHERE ord_tr_id=?", [mm.trId]);
      mm.details = resd.map((e) => OrderDetailModel.fromJson(e)).toList();
      list.add(mm.toJson());
    }

    return list;
  }

  Future<List<OrderModel>> getCart() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM Orders WHERE tr_paid = 0");

    List<OrderModel> list =
        res.isNotEmpty ? res.map((c) => OrderModel.fromJson(c)).toList() : [];
    return list;
  }

  Future<List<OrderModel>> getOrderId(String orderId) async {
    final db = await database;
    final res =
        await db.rawQuery("SELECT * FROM Orders WHERE tr_id=?", [orderId]);

    List<OrderModel> list =
        res.isNotEmpty ? res.map((e) => OrderModel.fromJson(e)).toList() : [];
    return list;
  }

  Future<int> updateOrder(Map<String, dynamic> json, String trId) async {
    final db = await database;
    final res =
        await db.update("Orders", json, where: "tr_id=?", whereArgs: [trId]);

    return res;
  }

  Future<List<OrderDetailModel>> getOrderDetail(String orderId) async {
    final db = await database;
    final res = await db
        .rawQuery("SELECT * FROM OrderDetail WHERE ord_tr_id=? ", [orderId]);

    List<OrderDetailModel> list = res.isNotEmpty
        ? res.map((c) => OrderDetailModel.fromJson(c)).toList()
        : [];

    return list;
  }

  // Insert menu on database
  insertOrderDetail(OrderDetailModel cats) async {
    final db = await database;
    final res = await db.insert('OrderDetail', cats.toJson());

    return res;
  }

  // Delete all menus
  Future<int> deleteAllOrderD() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM OrderDetail');

    return res;
  }

  Future<int> deleteAllOrderID(String code) async {
    final db = await database;
    final res =
        await db.rawDelete('DELETE FROM OrderDetail WHERE ord_tr_id=?', [code]);

    // await deleteOrderId(code);

    return res;
  }

  Future<int> deleteOrderId(String orderId) async {
    final db = await database;
    final res =
        await db.rawDelete('DELETE FROM Orders WHERE tr_id=?', [orderId]);
    return res;
  }

  Future<List<OrderDetailModel>> getAllOrderD() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM OrderDetail");

    List<OrderDetailModel> list = res.isNotEmpty
        ? res.map((c) => OrderDetailModel.fromJson(c)).toList()
        : [];

    return list;
  }

  Future<dynamic> getOrderDId(String code) async {
    final db = await database;

    var ress = await db.rawQuery("SELECT * FROM Orders WHERE tr_id =?", [code]);
    var resd = await db
        .rawQuery("SELECT * FROM OrderDetail WHERE ord_tr_id=?", [code]);

    var res = {
      "code": 200,
      "data": ress,
      "details": resd,
    };

    return res;
  }

  Future<dynamic> getDash() async {
    final db = await database;
    final res = await db.rawQuery("""
        SELECT pcs, qty, jml, cart, total, mns, tgl, dd FROM (
          (SELECT 
            COUNT(1) qty,
            IFNULL(SUM(CASE WHEN tr_paid = 0 THEN 1 ELSE 0 END),0) cart, 
            IFNULL(SUM(CASE WHEN (tr_paid = 1 AND tr_date = DATE('now','localtime')) THEN 1 ELSE 0 END),0) jml, 
            IFNULL(SUM(CASE WHEN (tr_paid = 1 AND tr_date = DATE('now','localtime')) THEN tr_total ELSE 0 END),0) total,
            tr_date tgl,
            DATE('now','localtime') dd
          FROM Orders) a,
          (SELECT IFNULL(SUM(ord_qty),0) pcs FROM OrderDetail) b,
          (SELECT COUNT(1) mns FROM Product) c
        ) aa 
        """);

    return res;
  }

  Future<dynamic> history() async {
    final db = await database;
    // final res = await db.rawQuery(
    //     """SELECT *, (SELECT COUNT(1) dtl FROM OrderDetail WHERE ord_tr_id = tr_id) jml
    //     FROM Orders WHERE tr_paid = '1' AND tr_date = DATE('now','localtime') ORDER BY tr_id DESC LIMIT 10 """);

    final res = await db.rawQuery(
        """SELECT *, (SELECT COUNT(1) dtl FROM OrderDetail WHERE ord_tr_id = tr_id) jml 
        FROM Orders ORDER BY tr_id DESC""");

    return res;
  }

  Future<dynamic> getMaxId() async {
    final db = await database;
    String dd = formatDateTime(getCurrentDateTime(), patern: "dd").toString();
    wLog(dd);
    final res = await db.rawQuery(
        "SELECT COUNT(1) jml FROM Orders WHERE substr(tr_id, 1, 2) =? ", [dd]);
    return res;
  }

  Future<dynamic> getPaidOrder() async {
    final db = await database;
    // final res = await db.rawQuery(
    //     """SELECT * FROM Orders WHERE tr_paid = '1' AND tr_date = DATE('now','localtime') """);
    final res = await db.rawQuery("""SELECT * FROM Orders""");
    var orders = [];
    for (var rs in res) {
      orders.add("'${rs.values.first}'");
    }
    var ins = orders.toString().replaceAll("[", "(").replaceAll("]", ")");
    var q = "SELECT * FROM OrderDetail WHERE ord_tr_id IN $ins";
    var dtl = await db.rawQuery(q);

    var result = {
      "code": 200,
      "data": res,
      "detail": dtl,
    };

    return result;
  }
}
