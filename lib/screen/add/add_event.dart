import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:etiguette/screen/contact/contact_detail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:etiguette/database/database.dart';
import 'package:etiguette/screen/recomendation/recomendation.dart';
import 'package:etiguette/utils/colors.dart';
import 'package:etiguette/utils/savebutton.dart';
import 'package:etiguette/utils/text_input_field_customer.dart';

class AddEvents extends StatefulWidget {
  final dynamic contact;
  final contactName;
  final String category;
  AddEvents({
    Key? key,
    required this.contact,
    required this.contactName,
    required this.category,
  }) : super(key: key);

  @override
  _AddEventsState createState() => _AddEventsState();
}

class _AddEventsState extends State<AddEvents> {
  TextEditingController dateController = TextEditingController();
  TextEditingController occusianController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  String dropdownvalue = 'Send';
  String itemCategory = "mini";

  final dbHelper = DatabaseMethod();

  var items = ['Send', 'Receive'];
  var itemsCategorys = ['mini', 'small', 'medium', 'large', 'huge'];

  bool isLoading = false;
  bool isDescriptionReceived = false;

  final picker = ImagePicker();

  File? _image;

  Map<String, dynamic>? selectedContact;

  String selectedDescription = '';

  void setSelectedDescription(String description) {
    setState(() {
      selectedDescription = description;
      if (descriptionController.text.isEmpty) {
        descriptionController.text = description;
      } else {
        descriptionController.text =
            '${descriptionController.text}\n$description';
      }
      isDescriptionReceived = true;
    });
  }

  Future<void> _pickImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final pickedFile =
                    await picker.pickImage(source: ImageSource.camera);
                setState(() {
                  if (pickedFile != null) {
                    _image = File(pickedFile.path);
                  }
                });
              },
              child: Text('Camera'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final pickedFile =
                    await picker.pickImage(source: ImageSource.gallery);
                setState(() {
                  if (pickedFile != null) {
                    _image = File(pickedFile.path);
                  }
                });
              },
              child: Text('Gallery'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveEventToDatabase() async {
    if (dateController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        occusianController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("All fields are required"),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    String imagePath;
    if (_image != null) {
      final directory = await getApplicationDocumentsDirectory();
      imagePath =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png';
      await _image!.copy(imagePath);
    } else {
      // Use a default image path if no image is picked
      imagePath = 'assets/random_default.png';
    }

    final event = {
      'date': dateController.text,
      'occasion': occusianController.text,
      'description': descriptionController.text,
      'type': dropdownvalue,
      'itemCategory': itemCategory,
      'contact_name': widget.contactName,
      'contact_notes': widget.contact['notes'],
      'contact_type': widget.contact['type'],
      'contact_image': widget.contact['image'],
      'image': imagePath,
    };

    try {
      await dbHelper.insertEvent(event);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Event saved successfully'),
        ),
      );
      setState(() {
        isLoading = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ContactDetail(contact: widget.contact),
        ),
      );
    } catch (e) {
      print('Error saving event: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save event'),
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.contact['name']);
  }

  List<Map<String, dynamic>>? recommendations;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorWhite,
      bottomNavigationBar: BottomAppBar(
        color: colorWhite,
        child: isLoading
            ? Center(
                child: Text(""),
              )
            : Center(
                child: SaveButton(
                  title: "Save",
                  height: 45,
                  width: 343,
                  onTap: _saveEventToDatabase,
                ),
              ),
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: colorWhite),
        backgroundColor: mainColor,
        title: Text(
          "Add Items",
          style: GoogleFonts.workSans(
            color: colorWhite,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: _pickImage,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _image == null
                      ? Center(
                          child: Icon(Icons.add, color: Colors.red, size: 60))
                      : Center(
                          child: Image.file(
                            _image!,
                            fit: BoxFit.fill,
                            height: 80,
                            filterQuality: FilterQuality.high,
                            width: 80,
                          ),
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormInputFieldCustomer(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    lastDate: DateTime(3000),
                    firstDate: DateTime(2015),
                    initialDate: DateTime.now(),
                  );
                  if (pickedDate == null) return;
                  dateController.text =
                      DateFormat('yyyy-MM-dd').format(pickedDate);
                },
                controller: dateController,
                hintText: "Select Date",
                textInputType: TextInputType.name,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormInputFieldCustomer(
                controller: occusianController,
                hintText: "Event Name",
                textInputType: TextInputType.name,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton(
                isExpanded: true,
                value: dropdownvalue,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: items.map((String items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownvalue = newValue!;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton(
                isExpanded: true,
                value: itemCategory,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: itemsCategorys.map((String itemsCategorys) {
                  return DropdownMenuItem(
                    value: itemsCategorys,
                    child: Text(itemsCategorys),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    itemCategory = newValue!;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                maxLines: 5,
                controller: descriptionController,
                decoration: InputDecoration(
                  filled: true,
                  hintText: "Description",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(
                      color: borderColor,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(
                      color: borderColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(
                      color: borderColor,
                    ),
                  ),
                ),
              ),
            ),
            if (dropdownvalue == 'Send')
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: mainColor),
                      onPressed: () {
                        if (occusianController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Event Name is Required")));
                        } else if (descriptionController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Description is Required")));
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => Recommendation(
                                      description: descriptionController.text,
                                      contactType: widget.contact['type'],
                                      itemCategory: itemCategory,
                                      eventName: occusianController.text,
                                      onAddDescription:
                                          setSelectedDescription)));
                        }
                      },
                      child: Text(
                        "Recommend Gift",
                        style: GoogleFonts.manrope(
                          color: colorWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
