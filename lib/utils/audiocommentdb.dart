import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:top_news_app/utils/constants.dart';

class DatabaseHelper {
  static final DatabaseHelper dbHelper = DatabaseHelper();

   Database? _database;

  static const tableComment = """
  CREATE TABLE IF NOT EXISTS ${AppConstants.commentTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ${AppConstants.newsId} TEXT NOT NULL,
        ${AppConstants.audioUrl} TEXT NOT NULL
      );""";

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await createDatabase();
    return _database;
  }

  //This is optional, and only used for changing DB schema migrations
  void onUpgrade(Database database, int oldVersion, int newVersion) {
    if (newVersion > oldVersion) {}
  }

// We need to write custom code to handle version changes. Not implemented
  Future<Database> createDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, AppConstants.telecomDatabase);
    return await openDatabase(path,
        version: 1, onCreate: initDB, onUpgrade: onUpgrade);

  }

  void initDB(Database database, int version) async {
    await database.execute(tableComment);
  }

}
