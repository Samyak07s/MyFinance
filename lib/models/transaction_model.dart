import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  String id;
  double amount;
  String category;
  String type;  // 'Income' or 'Expense'
  String description;
  DateTime date;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.type,
    required this.description,
    required this.date,
  });

  // Convert transaction data from Firestore to TransactionModel
  factory TransactionModel.fromFirestore(Map<String, dynamic> data, String id) {
    return TransactionModel(
      id: id,
      amount: data['amount']?.toDouble() ?? 0.0,
      category: data['category'],
      type: data['type'],
      description: data['description'],
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  // Convert TransactionModel to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'category': category,
      'type': type,
      'description': description,
      'date': Timestamp.fromDate(date),
    };
  }
}
