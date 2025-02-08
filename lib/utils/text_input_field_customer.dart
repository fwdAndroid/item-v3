import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:etiguette/utils/colors.dart';

class TextFormInputFieldCustomer extends StatelessWidget {
  final TextEditingController controller;
  final bool isPass;
  final String hintText;
  final int? maxlines;
  final VoidCallback? onTap;

  final IconData? IconSuffix;
  final IconData? preFixICon;
  final TextInputType textInputType;

  const TextFormInputFieldCustomer(
      {Key? key,
      required this.controller,
      this.isPass = false,
      this.IconSuffix,
      this.onTap,
      this.preFixICon,
      this.maxlines,
      required this.hintText,
      required this.textInputType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final boo = OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(
          color: Color(0xffF0F3F6),
        ));
    return Container(
      width: 343,
      height: 60,
      child: TextField(
        onTap: onTap,
        maxLines: maxlines,
        decoration: InputDecoration(
          suffixIcon: Icon(
            IconSuffix,
            color: textColor,
          ),
          prefixIcon: Icon(
            preFixICon,
            color: textColor,
          ),
          enabledBorder: boo,
          focusedBorder: boo,
          disabledBorder: boo,
          fillColor: Color(0xffF6F7F9),
          hintText: hintText,
          hintStyle: GoogleFonts.nunitoSans(fontSize: 16),
          border: InputBorder.none,
          filled: true,
          contentPadding: EdgeInsets.all(8),
        ),
        keyboardType: textInputType,
        controller: controller,
        obscureText: isPass,
      ),
    );
  }
}
