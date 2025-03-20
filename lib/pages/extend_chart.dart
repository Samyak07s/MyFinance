import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_finance/api/category_service.dart';
import 'package:my_finance/helper/colors.dart';
import 'package:my_finance/helper/icons.dart';
import '../models/transaction_model.dart';

class ExpensesByCategoryPage extends StatefulWidget {
  @override
  _ExpensesByCategoryPageState createState() => _ExpensesByCategoryPageState();
}

class _ExpensesByCategoryPageState extends State<ExpensesByCategoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _userId = FirebaseAuth.instance.currentUser?.uid ?? "";

  Map<String, double> categoryExpenses =
      {}; // Stores total expense per category
  Map<String, IconData> categoryIcons = {}; // Stores category icon
  Map<String, Color> categoryColors = {}; // Stores category color

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    if (_userId.isEmpty) return;

    try {
      QuerySnapshot transactionsSnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection("transactions")
          .where('type', isEqualTo: "Expense")
          .get();

      print('Fetched ${transactionsSnapshot.docs.length} transactions.');

      if (transactionsSnapshot.docs.isEmpty) {
        print('No transactions found.');
      }

      Map<String, double> tempCategoryExpenses = {};
      Map<String, IconData> tempCategoryIcons = {};
      Map<String, Color> tempCategoryColors = {};

      for (var doc in transactionsSnapshot.docs) {
        TransactionModel transaction = TransactionModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);

        // Update expense per category
        tempCategoryExpenses[transaction.category] =
            (tempCategoryExpenses[transaction.category] ?? 0) +
                transaction.amount;

        // Fetch category details from CategoryService
        tempCategoryIcons[transaction.category] =
            AppIcons.icons[transaction.category] ?? Icons.category;
        tempCategoryColors[transaction.category] =
            await CategoryService.getCategoryColor(
                transaction.category, _userId);
      }

      setState(() {
        categoryExpenses = tempCategoryExpenses;
        categoryIcons = tempCategoryIcons;
        categoryColors = tempCategoryColors;
      });
    } catch (e) {
      print("Error fetching transactions: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Expenses by Category",
          style: TextStyle(color: Colors.white), // Ensures white text
        ),
        backgroundColor: AppColors.appBarColor,
        iconTheme:
            IconThemeData(color: Colors.white), // Ensures white back icon
      ),
      body: categoryExpenses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : categoryExpenses.isEmpty
              ? const Center(child: Text('No expenses found!'))
              : ListView.builder(
                  itemCount: categoryExpenses.length,
                  itemBuilder: (context, index) {
                    String category = categoryExpenses.keys.elementAt(index);
                    double totalExpense = categoryExpenses[category]!;

                    IconData categoryIcon =
                        categoryIcons[category] ?? Icons.category;
                    Color categoryColor =
                        categoryColors[category] ?? Colors.grey;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      color: categoryColor.withOpacity(0.2),
                      child: ListTile(
                        leading: Icon(categoryIcon, color: categoryColor),
                        title: Text(category,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        subtitle:
                            Text("Total: ₹${totalExpense.toStringAsFixed(2)}",
                            style: const TextStyle(color: Colors.white)),
                      ),
                    );
                  },
                ),
    );
  }
}
