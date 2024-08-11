import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unite/constants/color/color.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final int? maxLength;
  final int? maxLines;
  final bool enabled;
  final TextInputAction? textInputAction;

  const CustomTextFormField({
    Key? key,
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: GoogleFonts.epilogue(color: AppColors.white),
      controller: controller,
      initialValue: initialValue,
      cursorColor: AppColors.successColor,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLength: maxLength,
      maxLines: maxLines,
      enabled: enabled,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        filled: false,
        fillColor: AppColors.grey.withOpacity(0.2),
        labelStyle: GoogleFonts.epilogue(color: AppColors.white),
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
        border: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey, // Border color
            width: 1.0, // Border width
          ),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey, // Color when the TextFormField is enabled
            width: 1.0,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.successColor, // Color when the TextFormField is focused
            width: 2.0,
          ),
        ),
      ),
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}
