import 'dart:io';
import 'package:etiguette/screen/dashboard/main_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:etiguette/proivder/contact_provider.dart';
import 'package:etiguette/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:etiguette/utils/savebutton.dart';
import 'package:etiguette/utils/text_input_field_customer.dart';

class AddContacts extends StatefulWidget {
  const AddContacts({Key? key}) : super(key: key);

  @override
  State<AddContacts> createState() => _AddContactsState();
}

class _AddContactsState extends State<AddContacts> {
  TextEditingController contactController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String dropdownValue = 'Platonic';
  File? _image;
  final picker = ImagePicker();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final contactNotifier =
        Provider.of<ContactNotifier>(context, listen: false);
    return Scaffold(
      backgroundColor: colorWhite,
      bottomNavigationBar: BottomAppBar(
        color: colorWhite,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SaveButton(
            width: 343,
            height: 45,
            title: "Add Contact",
            onTap: () => _addContact(contactNotifier),
          ),
        ),
      ),
      appBar: AppBar(
        title: Text("Add Contact"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _image == null
                    ? Image.asset("assets/add.png")
                    : Image.file(
                        fit: BoxFit.cover,
                        _image!,
                        height: 300,
                        width: MediaQuery.of(context).size.width,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormInputFieldCustomer(
                controller: contactController,
                hintText: "Contact Name",
                textInputType: TextInputType.name,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                isExpanded: true,
                value: dropdownValue,
                items: [
                  'Platonic',
                  'Romantic',
                ].map((String items) {
                  return DropdownMenuItem<String>(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: "Notes",
                ),
                maxLines: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  void _addContact(ContactNotifier contactNotifier) async {
    final contactName = contactController.text;
    final notes = descriptionController.text;
    final contactType = dropdownValue;

    if (contactName.isEmpty) {
      _showSnackbar(context, 'Contact name is required.');
      return;
    } else {
      setState(() {
        isLoading = true;
      });
      try {
        Map<String, dynamic> contact = {
          'name': contactName,
          'notes': notes,
          'type': contactType,
        };
        if (_image != null) {
          contact['image'] = _image!.readAsBytesSync();
        }
        await contactNotifier.addContact(contact);
        _showSnackbar(context, 'Contact added successfully.');
        contactController.clear();
        descriptionController.clear();
        setState(() {
          _image = null;
        });
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (builder) => MainDashboard(initialPageIndex: 2)));
      } catch (e) {
        print('Error: $e');
        _showSnackbar(context, 'Failed to add contact.');
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
