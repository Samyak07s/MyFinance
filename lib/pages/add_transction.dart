import 'package:flutter/material.dart';
import 'package:my_finance/api/transaction_service.dart';
import 'package:my_finance/helper/colors.dart';
import 'package:my_finance/models/transaction_model.dart';
import 'package:intl/intl.dart';
import 'package:my_finance/widgets/category_dropdown.dart';

class AddTransactionPage extends StatefulWidget {
  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final TransactionService _transactionService = TransactionService();

  String _transactionType = 'Expense'; // Default type
  double _amount = 0.0;
  String _selectedCategory = 'Food'; // Default category
  String _description = '';

  final List<String> _categories = [
    'Food',
    'Rent',
    'Entertainment',
    'Transport',
    'Shopping',
    'Health',
    'Salary',
    'Investment',
    'Bills',
    'Savings'
  ];

  void _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      TransactionModel newTransaction = TransactionModel(
        id: '',
        amount: _amount,
        category: _selectedCategory,
        type: _transactionType,
        description: _description,
        date: DateTime.now(), // Automatically set the current date and time
      );

      await _transactionService.addTransaction(newTransaction);
      Navigator.pop(context); // Close the page after saving
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add New Transaction",
          style: TextStyle(color: Colors.white), // Ensures white text
        ),
        backgroundColor: AppColors.appBarColor,
        iconTheme:
            IconThemeData(color: Colors.white), // Ensures white back icon
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction Type Selection
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildRadioButton("Income"),
                  _buildRadioButton("Expense"),
                ],
              ),
              const SizedBox(height: 16),

              // Amount Input
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Amount",
                  prefixText: "₹ ",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter an amount";
                  }
                  if (double.tryParse(value) == null) {
                    return "Enter a valid number";
                  }
                  return null;
                },
                onSaved: (value) {
                  _amount = double.parse(value!);
                },
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              CategoryDropdown(
                onCategorySelected: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Description Input
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) {
                  _description = value ?? "";
                },
              ),
              const SizedBox(height: 16),

              // Date Display
              Text(
                "Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "Save Transaction",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for radio buttons
  Widget _buildRadioButton(String type) {
    return Row(
      children: [
        Radio(
          value: type,
          groupValue: _transactionType,
          onChanged: (value) {
            setState(() {
              _transactionType = value.toString();
            });
          },
        ),
        Text(type),
      ],
    );
  }
}
