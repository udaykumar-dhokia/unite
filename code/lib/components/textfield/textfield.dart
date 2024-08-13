import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    this.suffix,
  }) : super(key: key);

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool isVisible = false;
  @override
  Widget build(BuildContext context) {

    return TextFormField(
      style: GoogleFonts.epilogue(color: AppColors.white),
      controller: widget.controller,
      initialValue: widget.initialValue,
      cursorColor: AppColors.successColor,
      obscureText: widget.labelText == "Password"? isVisible? false : true : widget.obscureText,
      keyboardType: widget.keyboardType,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines,
      enabled: widget.enabled,
      textInputAction: widget.textInputAction,
      decoration: InputDecoration(
        filled: false,
        fillColor: AppColors.grey.withOpacity(0.2),
        labelStyle: GoogleFonts.epilogue(color: AppColors.white),
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        suffixIcon: widget.labelText == "Password"? GestureDetector(
          onTap: (){
            setState(() {
              isVisible = !isVisible;
            });
          },
          child: Icon(isVisible? Icons.visibility_off : Icons.visibility, color: AppColors.white,),) : widget.suffixIcon != null ? Icon(widget.suffixIcon, color: AppColors.white,) :  null,
        suffix: widget.suffix,
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
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
    );
  }
}
