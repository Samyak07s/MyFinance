import 'package:flutter/material.dart';
import 'package:my_finance/api/category_service.dart';
import 'package:my_finance/helper/colors.dart';
import 'package:my_finance/models/category_model.dart';

class PopUP {
  void showPopupMenu(BuildContext context, TapDownDetails details,
      ExpenseCategoryModel category) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx, // X position
        details.globalPosition.dy, // Y position
        details.globalPosition.dx + 10, // Avoids overflow
        details.globalPosition.dy + 10,
      ),
      color: AppColors.cardBackgroundColor, // Dark background
      items: [
        buildPopupMenuItem("Delete", Icons.delete, Colors.red, Colors.red),
      ],
    ).then((value) {
      if (value != null) {
        handleMenuSelection(context, value, category);
      }
    });
  }

  PopupMenuItem<String> buildPopupMenuItem(
      String text, IconData icon, Color iconColor, Color textColor) {
    return PopupMenuItem(
      value: text,
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(color: textColor)),
        ],
      ),
    );
  }

  void handleMenuSelection(
      BuildContext context, String value, ExpenseCategoryModel category) {
    switch (value) {
      case 'Delete':
        _deleteCategory(context, category);
        break;
    }
  }

  Future<void> _deleteCategory(
      BuildContext context, ExpenseCategoryModel category) async {
    await CategoryService().deleteCategory(category.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${category.name} deleted")),
    );
  }
}
