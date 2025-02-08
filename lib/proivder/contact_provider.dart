import 'dart:async';
import 'package:etiguette/database/database.dart';
import 'package:flutter/foundation.dart';

class ContactNotifier extends ChangeNotifier {
  final DatabaseMethod dbHelper = DatabaseMethod();
  StreamController<List<Map<String, dynamic>>> _contactsController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  Stream<List<Map<String, dynamic>>> get contactsStream =>
      _contactsController.stream;

  void dispose() {
    _contactsController.close();
    super.dispose();
  }

  ContactNotifier() {
    loadContacts();
  }

  Future<void> loadContacts() async {
    List<Map<String, dynamic>> contacts = await dbHelper.getAllContacts();
    _contactsController.add(contacts);
  }

  Future<void> addContact(Map<String, dynamic> contact) async {
    await dbHelper.insertContact(contact);
    loadContacts(); // Reload contacts after adding a new one
  }

  Future<void> updateContact(Map<String, dynamic> updatedContact) async {
    await dbHelper.updateContact(updatedContact);
    loadContacts(); // Reload contacts after updating
  }
}
