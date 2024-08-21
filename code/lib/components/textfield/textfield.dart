import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:unite/constants/color/color.dart';

class CustomTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final int? maxLength;
  final int? maxLines;
  final bool enabled;
  final bool? isDark;
  final TextInputAction? textInputAction;

  const CustomTextFormField({
    Key? key,
    this.isDark,
    this.controller,
    this.initialValue,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.maxLength,
    this.maxLines = 1,
    this.enabled = true,
    this.textInputAction,
    this.suffix,
  }) : super(key: key);

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool isVisible = false;
  bool isUsernameTaken = false;

  Future<void> _checkUsernameExists(String username) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        isUsernameTaken = true;
      });
    } else {
      setState(() {
        isUsernameTaken = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: widget.labelText == "Date of Birth" ? true : false,
      style: GoogleFonts.epilogue(
          color: !widget.isDark! ? AppColors.black : AppColors.white),
      controller: widget.controller,
      initialValue: widget.initialValue,
      cursorColor: AppColors.warningColor,
      obscureText: widget.labelText == "Password"
          ? isVisible
              ? false
              : true
          : widget.obscureText,
      keyboardType: widget.keyboardType,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines,
      enabled: widget.enabled,
      textInputAction: widget.textInputAction,
      decoration: InputDecoration(
        labelStyle: GoogleFonts.epilogue(
            color: !widget.isDark! ? AppColors.black : AppColors.white),
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon != null
            ? Icon(
                widget.prefixIcon,
                color: !widget.isDark! ? AppColors.black : AppColors.white,
              )
            : null,
        suffixIcon: widget.labelText == "Password"
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    isVisible = !isVisible;
                  });
                },
                child: Icon(
                  isVisible ? Icons.visibility_off : Icons.visibility,
                  color: !widget.isDark! ? AppColors.black : AppColors.white,
                ),
              )
            : widget.labelText == "Date of Birth"
                ? IconButton(
                    onPressed: () async {
                      DateTime today = DateTime.now();
                      DateTime earliestAllowedDate =
                          DateTime(today.year - 13, today.month, today.day);

                      DateTime? pickedDate = await showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          lastDate: earliestAllowedDate);

                      if (pickedDate != null) {
                        String formattedDate =
                            DateFormat('dd-MM-yyyy').format(pickedDate);
                        setState(() {
                          widget.controller?.text = formattedDate;
                        });
                      }
                    },
                    icon: Icon(widget.suffixIcon))
                : widget.suffixIcon != null
                    ? Icon(
                        widget.suffixIcon,
                        color:
                            !widget.isDark! ? AppColors.black : AppColors.white,
                      )
                    : null,
        border: const UnderlineInputBorder(),
        enabledBorder: const UnderlineInputBorder(),
        focusedBorder: const UnderlineInputBorder(),
      ),
      validator: (value) {
        if (widget.labelText == "Email") {
          if (value == null || value.isEmpty) {
            return 'Please enter your email';
          } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return 'Please enter a valid email address';
          }
        } else if (widget.labelText == "Password") {
          if (value == null || value.isEmpty) {
            return 'Please enter your password';
          } else if (value.length < 6) {
            return 'Password must be at least 6 characters long';
          }
        }
        return null;
      },
      
      onChanged: (value) {
        if (widget.labelText == "Username") {
          _checkUsernameExists(value);
        }
        if (widget.onChanged != null) {
          widget.onChanged!(value);
        }
      },
      onFieldSubmitted: widget.onFieldSubmitted,
    );
    
  }
}
