import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class StudentsDatabase {
  static Database? _db;

  Future<Database?> get db async {
    if (_db == null) {
      _db = await initialDb();
      return _db;
    } else {
      return _db;
    }
  }

  initialDb() async {
    String databasepath = await getDatabasesPath();
    String path = join(databasepath, 'quran_circle_v2.db');
    Database mydb = await openDatabase(
      path,
      onCreate: _onCreate,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
    return mydb;
  }

  _onCreate(Database db, int version) async {
    // جدول الطلاب الأساسي
    await db.execute('''
      CREATE TABLE "Students" (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        age TEXT NOT NULL,
        join_date TEXT NOT NULL,
        circle_name TEXT NOT NULL,
        initial_memorized TEXT NOT NULL,
        initial_revision TEXT NOT NULL
      )
    ''');

    // جدول السجل اليومي (الحفظ والمراجعة اليومية لكل طالب)
    await db.execute('''
      CREATE TABLE "DailyRecords" (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        memorized TEXT NOT NULL,
        revision TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (student_id) REFERENCES Students (id) ON DELETE CASCADE
      )
    ''');
    print("تم إنشاء جداول قاعدة البيانات بنجاح");
  }

  readData(String sql) async {
    Database? mydata = await db;
    List<Map> response = await mydata!.rawQuery(sql);
    return response;
  }

  insertData(String sql) async {
    Database? mydata = await db;
    int response = await mydata!.rawInsert(sql);
    return response;
  }

  updateData(String sql) async {
    Database? mydata = await db;
    int response = await mydata!.rawUpdate(sql);
    return response;
  }

  deleteData(String sql) async {
    Database? mydata = await db;
    int response = await mydata!.rawDelete(sql);
    return response;
  }
}
