import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_finance/models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 Get current user ID
  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? "";

  // 🔹 Default Categories (Used when initializing a new user)
  final List<ExpenseCategoryModel> defaultCategories = [
    ExpenseCategoryModel(id: '1', name: 'Food', color: '#FF5733', iconName: 'food'),
    ExpenseCategoryModel(id: '2', name: 'Rent', color: '#4285F4', iconName: 'rent'),
    ExpenseCategoryModel(id: '3', name: 'Entertainment', color: '#FFEB3B', iconName: 'entertainment'),
    ExpenseCategoryModel(id: '4', name: 'Transport', color: '#4CAF50', iconName: 'transport'),
    ExpenseCategoryModel(id: '5', name: 'Shopping', color: '#9C27B0', iconName: 'shopping'),
    ExpenseCategoryModel(id: '6', name: 'Health', color: '#E91E63', iconName: 'health'),
    ExpenseCategoryModel(id: '7', name: 'Salary', color: '#009688', iconName: 'salary'),
    ExpenseCategoryModel(id: '8', name: 'Investment', color: '#FF9800', iconName: 'investment'),
    ExpenseCategoryModel(id: '9', name: 'Bills', color: '#795548', iconName: 'bills'),
    ExpenseCategoryModel(id: '10', name: 'Savings', color: '#607D8B', iconName: 'savings'),
  ];

  // 🔹 Fetch all categories for the logged-in user
  Future<List<ExpenseCategoryModel>> fetchCategories() async {
    if (_userId.isEmpty) return [];

    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('categories')
        .get();

    return snapshot.docs
        .map((doc) => ExpenseCategoryModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // 🔹 Add a new category for the user
  Future<void> addCategory(ExpenseCategoryModel category) async {
    if (_userId.isEmpty) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('categories')
          .add(category.toMap());

      print("✅ Category added successfully: ${category.name}");
    } catch (e) {
      print("❌ Firestore Error: $e"); // Debug Firestore errors
    }
  }

  // 🔹 Delete a category
  Future<void> deleteCategory(String id) async {
    if (_userId.isEmpty) return;

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('categories')
        .doc(id)
        .delete();
  }

  // 🔹 Update a category (e.g., name, color, icon)
  Future<void> updateCategory(ExpenseCategoryModel category) async {
    if (_userId.isEmpty) return;

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('categories')
        .doc(category.id)
        .update(category.toMap());
  }

  // 🔹 Fetch a single category by ID
  Future<ExpenseCategoryModel?> getCategoryById(String id) async {
    if (_userId.isEmpty) return null;

    DocumentSnapshot doc = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('categories')
        .doc(id)
        .get();

    if (doc.exists) {
      return ExpenseCategoryModel.fromFirestore(
          doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // 🔹 Check if a category with the same name exists for the user
  Future<bool> doesCategoryExist(String name) async {
    if (_userId.isEmpty) return false;

    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('categories')
        .where('name', isEqualTo: name)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // 🔹 Initialize default categories when a new user registers
  Future<void> initializeDefaultCategories() async {
    if (_userId.isEmpty) return;

    final categoryCollection = _firestore
        .collection('users')
        .doc(_userId)
        .collection('categories');

    // Check if categories already exist
    final existingCategories = await categoryCollection.get();
    if (existingCategories.docs.isNotEmpty) return;

    // Add default categories
    for (var category in defaultCategories) {
      await categoryCollection.add(category.toMap());
    }
  }

  // Fetch category color from Firestore
Future<Color> getCategoryColorFromFirestore(String category) async {
  try {
    DocumentSnapshot categoryDoc = await FirebaseFirestore.instance
        .collection('categories')
        .doc(category)  // Assuming the category name is used as the document ID
        .get();

    if (categoryDoc.exists) {
      String hexColor = categoryDoc["color"] ?? "#9e9e9e"; // Default color if not found
      return Color(int.parse('0xFF${hexColor.replaceFirst('#', '')}'));
    } else {
      return Color(0xFF9e9e9e); // Default gray color if category is not found in Firestore
    }
  } catch (e) {
    print("Error fetching category color: $e");
    return Color(0xFF9e9e9e); // Default gray color on error
  }
}
}
