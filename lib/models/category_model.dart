import 'package:flutter/material.dart';

class ExpenseCategoryModel {
  String id;
  String name;
  String color;
  String iconName; // Storing icon as a string

  ExpenseCategoryModel({
    required this.id,
    required this.name,
    required this.color,
    required this.iconName,
  });

  // Convert category data from Firestore to ExpenseCategoryModel
  factory ExpenseCategoryModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ExpenseCategoryModel(
      id: id,
      name: data['name'],
      color: data['color'],
      iconName: data['iconName'] ?? 'category', // Default icon if not found
    );
  }

  // Convert ExpenseCategoryModel to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'color': color,
      'iconName': iconName,
    };
  }

  // Convert the stored string into an actual Flutter icon
  IconData get icon {
    return iconMapping[iconName] ?? Icons.category; // Default to 'category' icon
  }

  static final Map<String, IconData> iconMapping = {
    'food': Icons.fastfood,
    'rent': Icons.home,
    'entertainment': Icons.movie,
    'transport': Icons.directions_bus,
    'shopping': Icons.shopping_cart,
    'health': Icons.local_hospital,
    'salary': Icons.attach_money,
    'investment': Icons.trending_up,
    'misc': Icons.category,
  };
}
