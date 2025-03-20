import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_finance/models/category_model.dart';

class CategoryService {
  final CollectionReference _categoryCollection =
      FirebaseFirestore.instance.collection('categories');

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

  // ✅ Fetch all categories from Firestore
  Future<List<ExpenseCategoryModel>> fetchCategories() async {
    QuerySnapshot snapshot = await _categoryCollection.get();
    return snapshot.docs
        .map((doc) => ExpenseCategoryModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // ✅ Add a new category
  Future<void> addCategory(ExpenseCategoryModel category) async {
    try {
      await _categoryCollection.add(category.toMap());
      print("✅ Category added successfully: ${category.name}");
    } catch (e) {
      print("❌ Firestore Error: $e"); // Debug Firestore errors
    }
  }

  // ✅ Delete a category
  Future<void> deleteCategory(String id) async {
    await _categoryCollection.doc(id).delete();
  }

  // ✅ Update a category (e.g., name, color, icon)
  Future<void> updateCategory(ExpenseCategoryModel category) async {
    await _categoryCollection.doc(category.id).update(category.toMap());
  }

  // ✅ Fetch a single category by ID
  Future<ExpenseCategoryModel?> getCategoryById(String id) async {
    DocumentSnapshot doc = await _categoryCollection.doc(id).get();
    if (doc.exists) {
      return ExpenseCategoryModel.fromFirestore(
          doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // ✅ Check if a category with the same name exists (useful before adding)
  Future<bool> doesCategoryExist(String name) async {
    QuerySnapshot snapshot =
        await _categoryCollection.where('name', isEqualTo: name).get();
    return snapshot.docs.isNotEmpty;
  }
}
