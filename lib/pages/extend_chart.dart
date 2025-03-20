// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:my_finance/models/expense_model.dart';
// import 'package:my_finance/services/category_service.dart';

// class ExpensesByCategoryPage extends StatefulWidget {
//   @override
//   _ExpensesByCategoryPageState createState() => _ExpensesByCategoryPageState();
// }

// class _ExpensesByCategoryPageState extends State<ExpensesByCategoryPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final String _userId = FirebaseAuth.instance.currentUser?.uid ?? "";
//   final CategoryService _categoryService = CategoryService();

//   Map<String, List<ExpenseModel>> categorizedExpenses = {};
//   Map<String, Color> categoryColors = {};

//   @override
//   void initState() {
//     super.initState();
//     fetchExpenses();
//   }

//   Future<void> fetchExpenses() async {
//     if (_userId.isEmpty) return;

//     QuerySnapshot snapshot = await _firestore
//         .collection('users')
//         .doc(_userId)
//         .collection('expenses')
//         .get();

//     Map<String, List<ExpenseModel>> tempCategorizedExpenses = {};
//     Map<String, Color> tempCategoryColors = {};

//     for (var doc in snapshot.docs) {
//       ExpenseModel expense = ExpenseModel.fromFirestore(
//           doc.data() as Map<String, dynamic>, doc.id);
      
//       if (!tempCategorizedExpenses.containsKey(expense.category)) {
//         tempCategorizedExpenses[expense.category] = [];
//         tempCategoryColors[expense.category] = await _categoryService.getCategoryColorFromFirestore(expense.category);
//       }
//       tempCategorizedExpenses[expense.category]!.add(expense);
//     }

//     setState(() {
//       categorizedExpenses = tempCategorizedExpenses;
//       categoryColors = tempCategoryColors;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Expenses by Category')),
//       body: categorizedExpenses.isEmpty
//           ? const Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: categorizedExpenses.length,
//               itemBuilder: (context, index) {
//                 String category = categorizedExpenses.keys.elementAt(index);
//                 List<ExpenseModel> expenses = categorizedExpenses[category]!;
//                 double total = expenses.fold(0, (sum, item) => sum + item.amount);
//                 Color categoryColor = categoryColors[category] ?? Colors.grey;

//                 return Card(
//                   margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                   color: categoryColor.withOpacity(0.2),
//                   child: ExpansionTile(
//                     title: Text(category, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                     subtitle: Text("Total: ₹${total.toStringAsFixed(2)}"),
//                     children: expenses.map((expense) {
//                       return ListTile(
//                         title: Text(expense.name),
//                         subtitle: Text("₹${expense.amount.toStringAsFixed(2)}"),
//                         trailing: Text(expense.date),
//                       );
//                     }).toList(),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }
