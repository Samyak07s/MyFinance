import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_finance/models/transaction_model.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 Get current user ID
  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? "";

  // 🔹 Fetch transactions as a stream (real-time updates)
  Stream<List<TransactionModel>> getTransactionsStream() {
    if (_userId.isEmpty) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TransactionModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // 🔹 Add a new transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    if (_userId.isEmpty) return;

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('transactions')
        .add(transaction.toMap());
  }

  // 🔹 Delete a transaction by ID
  Future<void> deleteTransaction(String id) async {
    if (_userId.isEmpty) return;

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('transactions')
        .doc(id)
        .delete();
  }
}
