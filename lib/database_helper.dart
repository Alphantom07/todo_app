import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/utils/utils.dart';
import 'package:todo_app/NoDoitem.dart';

class DatabaseHelper{
  static final DatabaseHelper _instance = new DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper.internal();

  final String tableName = "nodoTbl";
  final String columnId = "id";
  final String columnItemName = "itemName";
  final String columnDateCreated = "dateCreated";
  static Database _db;

  Future<Database> get db async {
    if(_db!=null){
      return _db;
    }

    _db = await initDb();
    return _db;
  }

  initDb() async{
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path,"nodo_db.db");
    var ourdb= await openDatabase(path,version: 1,onCreate: _oncreate);
    return ourdb;
  }

  void _oncreate(Database db, int version) async{
    await db.execute(
        "CREATE TABLE $tableName($columnId INTEGER PRIMARY KEY, $columnItemName TEXT,$columnDateCreated TEXT)"
    );
   print("Table created");

  }

  Future<int> saveItem(NoDoItem item) async{
    var dbClient = await db;
    int res = await dbClient.insert("$tableName", item.toMap());
    print(res.toString());
    return res;
  }

  Future<List> getItems() async{
    var dbClient  = await db;
    var res = await dbClient.rawQuery(" SELECT * FROM $tableName ORDER BY $columnDateCreated ASC");
    return res.toList();
  }

  Future<NoDoItem> getItem(int id) async{
    var dbClient = await db;
    var res = await dbClient.rawQuery("SELECT * FROM $tableName WHERE id = $id");
    if(res.length == 0){
      return null;
    }
    return new NoDoItem.fromMap(res.first);

  }

  Future<int> getCount() async{
    var dbCLient = await db;
    return Sqflite.firstIntValue(await dbCLient.rawQuery("SELECT COUNT(*) FROM $tableName"));
  }

  Future<int> deleteItem(int id) async{
    var dbClient = await db;
    return await dbClient.delete(tableName,where: "$columnId = ?",whereArgs: [id]);
    
  }

  Future<int> updateItem(NoDoItem item) async{
    var dbClient = await db;
    return await dbClient.update(tableName, item.toMap(),where: "$columnId = ?",whereArgs: [item.id]);
  }

  Future close() async{
    var dbClient = await db;
    return dbClient.close();
  }
}
