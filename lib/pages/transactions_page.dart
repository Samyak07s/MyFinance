import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_finance/api/transaction_service.dart';
import 'package:my_finance/helper/colors.dart';
import 'package:my_finance/models/transaction_model.dart';

class AllTransactionsPage extends StatelessWidget {
  final TransactionService _transactionService = TransactionService();

  AllTransactionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "All Transactions",
          style: TextStyle(color: Colors.white), // Ensures white text
        ),
        backgroundColor: AppColors.appBarColor,
        iconTheme:
            IconThemeData(color: Colors.white), // Ensures white back icon
      ),
      body: StreamBuilder<List<TransactionModel>>(
        stream: _transactionService.getTransactionsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No transactions found."));
          }

          List<TransactionModel> transactions = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _groupedTransactions(transactions).length,
            itemBuilder: (context, index) {
              final entry = _groupedTransactions(transactions)[index];
              final String date = entry.key;
              final List<TransactionModel> dailyTransactions = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      date,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  ...dailyTransactions
                      .map((transaction) =>
                          _buildTransactionTile(context, transaction))
                      .toList(),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTransactionTile(
      BuildContext context, TransactionModel transaction) {
    bool isIncome = transaction.type.toLowerCase() == "income";

    return Card(
      color: Colors.black54, // Background color for dark mode
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        leading: IconTheme(
          data: const IconThemeData(size: 30, weight: 900),
          child: Icon(
            isIncome ? Icons.arrow_upward : Icons.arrow_downward,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          transaction.category,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        trailing: Text(
          "${isIncome ? '+' : '-'} ₹${transaction.amount.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (transaction.description != "")
                  _detailRow("Description", transaction.description),
                _detailRow(
                  "Date",
                  DateFormat('dd MMM, yyyy | hh:mm a').format(transaction.date),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteDialog(context, transaction),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, TransactionModel transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Transaction"),
        content: Text("Are you sure you want to delete this transaction?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _transactionService.deleteTransaction(transaction.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  List<MapEntry<String, List<TransactionModel>>> _groupedTransactions(
      List<TransactionModel> transactions) {
    Map<String, List<TransactionModel>> grouped = {};

    for (var transaction in transactions) {
      String formattedDate =
          DateFormat('dd MMM, yyyy').format(transaction.date);
      grouped.putIfAbsent(formattedDate, () => []).add(transaction);
    }

    return grouped.entries.toList();
  }
}
