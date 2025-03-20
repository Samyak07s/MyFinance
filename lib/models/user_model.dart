import 'package:my_finance/models/category_model.dart';
import 'package:my_finance/models/transaction_model.dart';

class UserModel {
  String id;
  String email;
  String name;
  double balance;
  double lastMonthIncome;
  double lastMonthExpense;
  List<TransactionModel> transactions;
  List<ExpenseCategoryModel> categories;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.balance,
    required this.lastMonthIncome,
    required this.lastMonthExpense,
    required this.transactions,
    required this.categories,
  });

  // Convert Firestore data to UserModel
  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    List<TransactionModel> transactions = (data['transactions'] as List<dynamic>?)
            ?.map((t) => TransactionModel.fromFirestore(t as Map<String, dynamic>, t['id']))
            .toList() ??
        [];

    List<ExpenseCategoryModel> categories = (data['categories'] as List<dynamic>?)
            ?.map((c) => ExpenseCategoryModel.fromFirestore(c as Map<String, dynamic>, c['id']))
            .toList() ??
        [];

    return UserModel(
      id: id,
      email: data['email'],
      name: data['name'],
      balance: data['balance']?.toDouble() ?? 0.0,
      lastMonthIncome: data['lastMonthIncome']?.toDouble() ?? 0.0,
      lastMonthExpense: data['lastMonthExpense']?.toDouble() ?? 0.0,
      transactions: transactions,
      categories: categories,
    );
  }

  // Convert UserModel to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'balance': balance,
      'lastMonthIncome': lastMonthIncome,
      'lastMonthExpense': lastMonthExpense,
      'transactions': transactions.map((t) => t.toMap()).toList(),
      'categories': categories.map((c) => c.toMap()).toList(),
    };
  }
}
