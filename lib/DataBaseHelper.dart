import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'UserModel.dart';

class DataBaseHelper {
  static final _databaseName = "userdb.db";
  static final _databaseVersion = 1;

  static final table = 'user';

  static final columnId = 'id';
  static final columnfirstName = 'firstName';
  static final columnlastName = 'lastName';
  static final columnphoneNo = 'phoneNo';
  static final columnemail = 'email';
  static final columnimage = 'image';

  DataBaseHelper._privateConstructor();
  static final DataBaseHelper instance = DataBaseHelper._privateConstructor();

  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnfirstName TEXT NOT NULL,
            $columnlastName TEXT NOT NULL,
            $columnphoneNo TEXT NOT NULL,
            $columnemail TEXT NOT NULL,
            $columnimage TEXT NOT NULL
          )
          ''');
  }

  Future<int> insert(UserModel usermodel) async {
    Database db = await instance.database;
    var res = await db.insert(table, usermodel.toMap());
    return res;
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    var res = await db.query(table, orderBy: "$columnId DESC");
    return res;
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<void> clearTable() async {
    Database db = await instance.database;
    return await db.rawQuery("DELETE FROM $table");
  }
}
