import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:etiguette/database/database.dart';
import 'package:etiguette/screen/dashboard/main_dashboard.dart';
import 'package:etiguette/screen/recomendation/recomendation.dart';
import 'package:etiguette/utils/colors.dart';
import 'package:etiguette/utils/constant.dart';
import 'package:etiguette/utils/savebutton.dart';
import 'package:etiguette/utils/text_input_field_customer.dart';

class EditEventDetails extends StatefulWidget {
  final Map<String, dynamic> event;

  EditEventDetails({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  _EditEventDetailsState createState() => _EditEventDetailsState();
}

class _EditEventDetailsState extends State<EditEventDetails> {
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

  BannerAd? _bannerAd;

  final String adUnitId = keys;

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadAd();
    _initializeForm();
  }

  void _initializeForm() {
    dateController.text = widget.event['date'] ?? '';
    occusianController.text = widget.event['occasion'] ?? '';
    descriptionController.text = widget.event['description'] ?? '';
    dropdownvalue = widget.event['type'] ?? 'Send';
    itemCategory = widget.event['itemCategory'] ?? 'mini';

    if (widget.event['image'] != null &&
        File(widget.event['image']).existsSync()) {
      _image = File(widget
          .event['image']); // Use the stored image path if the file exists
    }
  }

  Future getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void setSelectedDescription(String description) {
    setState(() {
      selectedDescription = description;
      descriptionController.text = description;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorWhite,
      bottomNavigationBar: BottomAppBar(
        color: colorWhite,
        child: SaveButton(
            title: "Update",
            height: 45,
            width: 343,
            onTap: () async {
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
              final event = {
                'id': widget.event['id'], // Ensure ID is included
                'date': dateController.text,
                'occasion': occusianController.text,
                'description': descriptionController.text,
                'type': dropdownvalue,
                'itemCategory': itemCategory,
                'contact_name': widget.event['contact_name'],
                'contact_notes': widget.event['contact_notes'],
                'contact_type': widget.event['contact_type'],
                'contact_image': widget.event['contact_image'],
                'image': _image?.path != null && File(_image!.path).existsSync()
                    ? _image!.path
                    : widget.event['image'], // Ensure the image path is valid
              };

              try {
                await dbHelper.updateEvent(event);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Event updated successfully'),
                  ),
                );
                setState(() {
                  isLoading = false;
                });
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (ctx) =>
                            MainDashboard())); // Pass the updated event back
              } catch (e) {
                print('Error updating event: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to update event'),
                  ),
                );
                setState(() {
                  isLoading = false;
                });
              }
            }),
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: colorWhite),
        backgroundColor: mainColor,
        title: Text(
          "Edit Items",
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
            GestureDetector(
              onTap: () {
                getImage(ImageSource.gallery);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _image == null
                    ? (widget.event['image'] != null &&
                            File(widget.event['image']).existsSync()
                        ? Image.file(
                            File(widget.event['image']),
                            fit: BoxFit.cover,
                            height: 200,
                            width: MediaQuery.of(context).size.width,
                          )
                        : Center(
                            child:
                                Icon(Icons.add, color: Colors.red, size: 60)))
                    : Image.file(
                        _image!,
                        fit: BoxFit.cover,
                        height: 200,
                        width: MediaQuery.of(context).size.width,
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
                  fillColor: greyColor,
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
            Visibility(
              visible: dropdownvalue == 'Send',
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: mainColor),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (builder) => Recommendation(
                                    eventName: occusianController.text,
                                    itemCategory: itemCategory,
                                    description: descriptionController.text,
                                    contactType: widget.event['contact_type'],
                                    onAddDescription: setSelectedDescription)));
                      },
                      child: Text(
                        "Recommended",
                        style: GoogleFonts.manrope(
                          color: colorWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: _bannerAd == null
                    ? Container()
                    : Container(
                        height: AdSize.banner.height.toDouble(),
                        width: AdSize.banner.width.toDouble(),
                        child: AdWidget(ad: _bannerAd!)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _loadAd() {
    final bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: adUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    );

    bannerAd.load();
  }
}
