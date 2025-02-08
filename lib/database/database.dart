import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseMethod {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final String path = join(await getDatabasesPath(), 'app_database.db');
    return openDatabase(
      path,
      version: 6,
      onCreate: (Database db, int version) async {
        await db.execute(
          "CREATE TABLE IF NOT EXISTS users(id INTEGER PRIMARY KEY, name TEXT, email TEXT, password TEXT)",
        );
        await db.execute(
          "CREATE TABLE IF NOT EXISTS contacts(id INTEGER PRIMARY KEY, name TEXT, notes TEXT, type TEXT, image BLOB)",
        );
        await db.execute(
          "CREATE TABLE IF NOT EXISTS events(id INTEGER PRIMARY KEY, date TEXT, occasion TEXT, description TEXT, image TEXT, type TEXT, itemCategory TEXT, contact_id INTEGER, contact_name TEXT, contact_notes TEXT, contact_type TEXT, contact_image BLOB, FOREIGN KEY(contact_id) REFERENCES contacts(id))",
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 5) {
          await db.execute(
            "CREATE TABLE IF NOT EXISTS contacts(id INTEGER PRIMARY KEY, name TEXT, notes TEXT, type TEXT, image BLOB)",
          );
          await db.execute(
            "CREATE TABLE IF NOT EXISTS events(id INTEGER PRIMARY KEY, date TEXT, occasion TEXT, description TEXT, image TEXT, type TEXT, itemCategory TEXT, contact_id INTEGER, contact_name TEXT, contact_notes TEXT, contact_type TEXT, contact_image BLOB, FOREIGN KEY(contact_id) REFERENCES contacts(id))",
          );
        }
        if (oldVersion < 6) {
          // Rename image column to image and add itemCategory column if they do not exist
          await db.execute(
            "ALTER TABLE events RENAME TO temp_events",
          );
          await db.execute(
            "CREATE TABLE IF NOT EXISTS events(id INTEGER PRIMARY KEY, date TEXT, occasion TEXT, description TEXT, image TEXT, type TEXT, itemCategory TEXT, contact_id INTEGER, contact_name TEXT, contact_notes TEXT, contact_type TEXT, contact_image BLOB, FOREIGN KEY(contact_id) REFERENCES contacts(id))",
          );

          await db.execute(
            "INSERT INTO events (id, date, occasion, description, image, type, contact_id, contact_name, contact_notes, contact_type, contact_image) SELECT id, date, occasion, description, NULL AS image, type, contact_id, contact_name, contact_notes, contact_type, contact_image FROM temp_events",
          );
          await db.execute(
            "DROP TABLE temp_events",
          );
        }
      },
    );
  }

  Future<void> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    await db.insert(
      'users',
      user,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return users.isNotEmpty ? users.first : null;
  }

  Future<void> insertContact(Map<String, dynamic> contact) async {
    final db = await database;
    await db.insert(
      'contacts',
      contact,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllContacts() async {
    final db = await database;
    return await db.query('contacts');
  }

  Future<void> insertEvent(Map<String, dynamic> event) async {
    final db = await database;
    await db.insert(
      'events',
      event,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllEvents() async {
    final db = await database;
    return await db.query(
      'events',
      orderBy: 'date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getTopFiveEvents() async {
    final db = await database;
    final currentDate = DateTime.now().toIso8601String();
    final events = await db.query(
      'events',
      where: 'date >= ?',
      whereArgs: [currentDate],
      orderBy: 'date DESC',
      limit: 5,
    );
    return events;
  }

  Future<int> getContactsCount() async {
    final db = await database;
    final List<Map<String, dynamic>> contacts = await db.query(
      'contacts',
    );
    return contacts.length;
  }

  Future<int> getEventsCount() async {
    final db = await database;
    final currentDate = DateTime.now().toIso8601String();
    final List<Map<String, dynamic>> events = await db.query(
      'events',
      where: 'date >= ?',
      whereArgs: [currentDate],
    );
    return events.length;
  }

  Future<List<Map<String, dynamic>>> getReceivedEvents() async {
    final db = await database;
    return await db.query(
      'events',
      where: 'type = ?',
      whereArgs: ['Receive'],
      orderBy: 'date DESC', // Sort by date in descending order
    );
  }

  Future<List<Map<String, dynamic>>> getSendEvents() async {
    final db = await database;
    return await db.query(
      'events',
      where: 'type = ?',
      whereArgs: ['Send'],
      orderBy: 'date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getReceivedEvent(
      String contactName) async {
    final db = await database;
    return await db.query(
      'events',
      where: 'type = ? AND contact_name = ?',
      whereArgs: ['Receive', contactName],
      orderBy: 'date DESC', // Sort by date in descending order
    );
  }

  Future<List<Map<String, dynamic>>> getSendEvent(String contactName) async {
    final db = await database;
    return await db.query(
      'events',
      where: 'type = ? AND contact_name = ?',
      whereArgs: ['Send', contactName],
      orderBy: 'date DESC', // Sort by date in descending order
    );
  }

  Future<List<Map<String, dynamic>>> getContactEvents(
      String contactName) async {
    final db = await database;
    return db.query(
      'events',
      where: 'contact_name = ?',
      whereArgs: [contactName],
      orderBy: 'date DESC', // Sort by date in descending order
    );
  }

  Future<int> getContactEventsCount(String contactName) async {
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM events WHERE contact_name = ?', [contactName]));
    return count ?? 0;
  }

  Future<void> updateEvent(Map<String, dynamic> event) async {
    final db = await database;
    await db.update(
      'events',
      event,
      where: "id = ?",
      whereArgs: [event['id']],
    );
  }

  Future<void> updateContact(Map<String, dynamic> contact) async {
    final db = await database;
    await db.update(
      'contacts',
      contact,
      where: "id = ?",
      whereArgs: [contact['id']],
    );
  }

  //Delete
  Future<void> deleteContactAndEvents(int contactId) async {
    final db = await database;
    // Delete events associated with the contact
    await db.delete(
      'events',
      where: 'contact_id = ?',
      whereArgs: [contactId],
    );
    // Delete the contact itself
    await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [contactId],
    );
  }

  // Debugging Method
  Future<void> printAllEvents() async {
    final db = await database;
    final List<Map<String, dynamic>> events = await db.query('events');
    for (var event in events) {
      print(event);
    }
  }
}
