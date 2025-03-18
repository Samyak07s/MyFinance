import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Total Income
            Card(
              child: ListTile(
                title: Text('Total Income'),
                subtitle: Text('\$5000'),
              ),
            ),
            // Total Expenses
            Card(
              child: ListTile(
                title: Text('Total Expenses'),
                subtitle: Text('\$2000'),
              ),
            ),
            // Net Balance
            Card(
              child: ListTile(
                title: Text('Net Balance'),
                subtitle: Text('\$3000'),
              ),
            ),
            SizedBox(height: 20),
            // You can add other sections like charts or transaction history here
          ],
        ),
      ),
    );
  }
}
