import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_finance/models/category_model.dart';

class CategoryService {
  final CollectionReference _categoryCollection =
      FirebaseFirestore.instance.collection('categories');

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
