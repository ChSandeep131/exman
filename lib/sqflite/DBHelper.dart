// ignore: file_names
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static Future<Database> db() async {
    return openDatabase("Name_database", version: 1,
        onCreate: (Database database, int version) async {
      await tableCreate(database);
    });
  }

  static Future<void> tableCreate(Database database) async {
    await database.execute("""CREATE TABLE data(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      item STRING,
      merchant STRING,
      price REAL,
      payment STRING,
      category STRING,
      ctime STRING
    )""");
    await database.execute("""CREATE TABLE imported_data(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      item STRING,
      merchant STRING,
      price REAL,
      payment STRING,
      category STRING,
      ctime STRING
    )""");
  }

  static Future<int> createData(Map<String, dynamic> dataMap) async {
    final db = await DbHelper.db();
    return await db.insert("data", dataMap);
  }

  static getData() async {
    final db = await DbHelper.db();
    final List<Map<String, dynamic>> maps =
        await db.query('data', orderBy: "id");
    return maps;
  }

  static Future<int> updateData(Map<String, dynamic> dataMap) async {
    final db = await DbHelper.db();
    return await db
        .update('data', dataMap, where: 'id = ?', whereArgs: [dataMap['id']]);
  }

  static Future<void> deleteData(int id) async {
    final db = await DbHelper.db();
    try {
      await db.delete("data", where: "id =?", whereArgs: [id]);
    } catch (e) {
      print("Error deleting data: $e");
    }
  }

  static Future<int> createImportedData(Map<String, dynamic> dataMap) async {
    final db = await DbHelper.db();
    return await db.insert("imported_data", dataMap);
  }

  static getImportedData() async {
    final db = await DbHelper.db();
    final List<Map<String, dynamic>> maps =
        await db.query('imported_data', orderBy: "id");
    return maps;
  }
}
