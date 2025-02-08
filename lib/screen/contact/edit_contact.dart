import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:etiguette/database/database.dart';
import 'package:etiguette/screen/dashboard/main_dashboard.dart';
import 'package:etiguette/utils/colors.dart';
import 'package:etiguette/utils/savebutton.dart';
import 'package:etiguette/utils/text_input_field_customer.dart';

class EditContact extends StatefulWidget {
  final int contactId; // Add an ID for the contact
  final String contactName;
  final String contactNotes;
  final String contactType;
  final Uint8List? contactPhoto; // Change type to Uint8List

  EditContact({
    Key? key,
    required this.contactId,
    required this.contactName,
    required this.contactNotes,
    required this.contactType,
    required this.contactPhoto,
  }) : super(key: key);

  @override
  _EditContactState createState() => _EditContactState();
}

class _EditContactState extends State<EditContact> {
  TextEditingController contactController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String dropdownValue = 'Platonic';
  File? _image;
  Uint8List? _contactPhoto;
  final picker = ImagePicker();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set initial values for controllers
    contactController.text = widget.contactName;
    descriptionController.text = widget.contactNotes;
    dropdownValue = widget.contactType;
    _contactPhoto = widget.contactPhoto;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorWhite,
      bottomNavigationBar: BottomAppBar(
        color: colorWhite,
        child: SaveButton(
          width: 343,
          height: 45,
          title: "Update",
          onTap: _saveContact,
        ),
      ),
      appBar: AppBar(
        title: Text("Edit Contact"),
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
                    ? (_contactPhoto == null
                        ? Image.asset("assets/add.png")
                        : Image.memory(
                            _contactPhoto!,
                            fit: BoxFit.cover,
                            height: 300,
                            width: MediaQuery.of(context).size.width,
                          ))
                    : Image.file(
                        _image!,
                        fit: BoxFit.cover,
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
        _contactPhoto =
            null; // Clear the initial photo when a new image is picked
      }
    });
  }

  void _saveContact() async {
    setState(() {
      isLoading = true;
    });

    try {
      Uint8List? photoBytes;
      if (_image != null) {
        photoBytes = await _image!.readAsBytes();
      } else {
        photoBytes = _contactPhoto;
      }

      final dbHelper = DatabaseMethod();
      await dbHelper.updateContact({
        'id': widget.contactId,
        'name': contactController.text,
        'notes': descriptionController.text,
        'type': dropdownValue,
        'image': photoBytes,
      });

      // Show a success message or navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Contact updated successfully!")),
      );

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (builder) => MainDashboard(
                  initialPageIndex: 2))); // Change the index as needed
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
