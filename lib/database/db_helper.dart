import 'package:poc_wgj/models/contact_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  // Singleton instance
  static final DBHelper _instance = DBHelper._internal();

  // Factory constructor to return the single instance
  factory DBHelper() => _instance;

  // Private constructor to prevent external instantiation
  DBHelper._internal();

  // Database reference
  static Database? _database;

  // Getter to return the database instance, initializing it if necessary
  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // Method to initialize the database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'calle.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Method to create tables in the database
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        image BLOB,
        phoneNumber TEXT
      )
    ''');
  }

  // Method to insert a new item into the items table
  Future<int> insertContact(ContactItem contact) async {
    try {
      final db = await database;
      int id = await db!.insert('contacts', contact.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
          print('ID wgj $id');
          return id;
    } catch (e) {
      print('Error in creation $e');
      return 0;
    }
  }

  // Method to retrieve all items from the items table
  Future<List<ContactItem>> getContacts() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db!.query('contacts');
      print(maps);
      print('Maps');
      return List.generate(maps.length, (i) {
        return ContactItem(
            id: maps[i]['id'],
            name: maps[i]['name'],
            phoneNumber: maps[i]['phoneNumber'],
            image: maps[i]['image']);
      });
    } catch (e) {
      print('Error to get list $e');
      return [];
    }
  }

  // Method to update an item in the items table
  Future<int> updateContact(ContactItem contact) async {
    try {
      print('update contact ${contact.id}');
      final db = await database;
      return await db!.update(
        'contacts',
        contact.toMap(),
        where: 'id = ?',
        whereArgs: [contact.id],
      );
    } catch (e) {
      print('Error to update $e');
      return 0;
    }
  }

  // Method to delete an item from the items table
  Future<int> deleteContact(int id) async {
    try {
      final db = await database;
      return await db!.delete(
        'contacts',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error in delete $e');
      return 0;
    }
  }
}
