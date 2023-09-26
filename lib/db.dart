import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

class DB {
  static String dbPath = "";
  static Future<sql.Database> openDatabase() async {
    dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(
      path.join(dbPath, "teste.db"),
      onCreate: (db, version) {
        db.execute(
            'CREATE TABLE IF NOT EXISTS persons (id INTEGER PRIMARY KEY, name TEXT, age INT)');
      },
      version: 1,
    );
  }

  static Future<void> save(Map<String, dynamic> data) async {
    final db = await DB.openDatabase();
    await db.insert("persons", data);
  }

  static Future<List<Map<String, dynamic>>> load() async {
    final db = await DB.openDatabase();
    return db.query("persons");
  }

  static Future<void> delete() async {
    final db = await DB.openDatabase();
    await db.execute("DROP DATABASE persons");
  }

  static Future<void> getDbPath() async {
    final db = await DB.openDatabase();
    print(dbPath);
    Directory? externalStoragePath = await getExternalStorageDirectory();
    print(externalStoragePath);
  }
}
