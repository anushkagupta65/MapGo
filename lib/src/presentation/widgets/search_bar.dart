// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:map_assessment/src/utils/app_colors.dart';

class CustomSearchAppBar extends StatelessWidget {
  final VoidCallback onTap;

  const CustomSearchAppBar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 0),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: AppColors.textLight),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Search your route … ",
                style: TextStyle(color: AppColors.textLight, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
