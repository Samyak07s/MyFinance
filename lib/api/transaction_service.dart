import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_finance/models/transaction_model.dart';

class TransactionService {
  final CollectionReference _transactionCollection =
      FirebaseFirestore.instance.collection('transactions');

  // Fetch transactions as a stream (real-time updates)
  Stream<List<TransactionModel>> getTransactionsStream() {
    return _transactionCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TransactionModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Add a new transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    await _transactionCollection.add(transaction.toMap());
  }

  // Delete a transaction by ID
  Future<void> deleteTransaction(String id) async {
    await _transactionCollection.doc(id).delete();
  }
}
