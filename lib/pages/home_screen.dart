import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:my_finance/helper/colors.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "User"; // Replace with actual user data in the future
  double totalBalance = 5000.0;
  double lastMonthExpense = 1500.0;
  double lastMonthEarnings = 3000.0;

  Map<String, double> expenseByCategory = {
    "Food": 500,
    "Rent": 700,
    "Entertainment": 300,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor, // Dark Mode Theme
      appBar: AppBar(
        title: Text("MyFinance"),
        backgroundColor: AppColors.appBarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Name
            Text(
              "Hello, $userName 👋",
              style: TextStyle(color: AppColors.whiteText, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            // Overview Card
            Card(
              color: AppColors.cardBackgroundColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Balance", style: TextStyle(color: AppColors.secondaryText, fontSize: 16)),
                    Text("\$${totalBalance.toStringAsFixed(2)}",
                        style: TextStyle(color: AppColors.primaryText, fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Last Month’s Expense", style: TextStyle(color: AppColors.secondaryText)),
                            Text("\$${lastMonthExpense.toStringAsFixed(2)}",
                                style: TextStyle(color: AppColors.errorColor, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Last Month’s Earnings", style: TextStyle(color: AppColors.secondaryText)),
                            Text("\$${lastMonthEarnings.toStringAsFixed(2)}",
                                style: TextStyle(color: AppColors.successColor, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Expense Chart
            Text("Spending by Category", style: TextStyle(color: AppColors.whiteText, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: expenseByCategory.entries.map((entry) {
                    return PieChartSectionData(
                      title: entry.key,
                      value: entry.value,
                      color: getCategoryColor(entry.key),
                      titleStyle: TextStyle(color: AppColors.whiteText, fontSize: 12),
                    );
                  }).toList(),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color getCategoryColor(String category) {
    switch (category) {
      case "Food":
        return AppColors.foodColor;
      case "Rent":
        return AppColors.rentColor;
      case "Entertainment":
        return AppColors.entertainmentColor;
      default:
        return Colors.grey;
    }
  }

  // You can add methods here to update the data and call setState() to refresh the widget
  void updateBalance(double newBalance) {
    setState(() {
      totalBalance = newBalance;
    });
  }

  void updateExpense(Map<String, double> newExpenses) {
    setState(() {
      expenseByCategory = newExpenses;
    });
  }

  void updateEarnings(double newEarnings) {
    setState(() {
      lastMonthEarnings = newEarnings;
    });
  }

  void updateLastMonthExpense(double newExpense) {
    setState(() {
      lastMonthExpense = newExpense;
    });
  }
}
