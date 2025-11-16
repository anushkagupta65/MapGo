// lib/presentation/widgets/custom_autocomplete_textfield.dart
import 'package:flutter/material.dart';
import 'package:map_assessment/src/utils/app_colors.dart';

class CustomAutoCompleteTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final FocusNode? focusNode;
  final bool showUseCurrentLocation;

  const CustomAutoCompleteTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.focusNode,
    this.showUseCurrentLocation = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      style: const TextStyle(color: AppColors.textWhite),
      cursorColor: AppColors.blueGlow,
      decoration: InputDecoration(
        labelStyle: const TextStyle(color: AppColors.textMuted),
        hintStyle: const TextStyle(color: AppColors.textMuted),
        hintText: hintText,
        filled: true,
        fillColor: AppColors.bgCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.textMuted, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.textMuted, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.blueGlow, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 14,
        ),
      ),
    );
  }
}
