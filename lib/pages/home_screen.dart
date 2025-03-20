import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:my_finance/api/auth/auth_service.dart';
import 'package:my_finance/helper/colors.dart';
import 'package:my_finance/pages/add_transction.dart';
import 'package:my_finance/pages/category_page.dart';
import 'package:my_finance/pages/transactions_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "User";
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
      backgroundColor: AppColors.backgroundColor,

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Greeting with Logout Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Hello, $userName 👋",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  onPressed: () async {
                    await AuthService.logoutUser();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Overview Card
            Card(
              color: AppColors.cardBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      "Total Balance",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    Text(
                      "\$${totalBalance.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryTile("Expenses", lastMonthExpense, Colors.red),
                        _buildSummaryTile("Earnings", lastMonthEarnings, Colors.green),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Expense Chart
            Card(
              color: AppColors.backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      "Spending by Category",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 180,
                      child: PieChart(
                        PieChartData(
                          sections: expenseByCategory.entries.map((entry) {
                            return PieChartSectionData(
                              title: entry.key,
                              value: entry.value,
                              color: getCategoryColor(entry.key),
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
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
            ),

            const SizedBox(height: 20),

            // Transactions & Categories
            _buildNavigationButton(
              title: "Show All Transactions",
              icon: Icons.arrow_forward_ios_rounded,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AllTransactionsPage()));
              },
            ),

            const SizedBox(height: 10),

            _buildNavigationButton(
              title: "Manage Categories",
              icon: Icons.arrow_forward_ios_rounded,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryPage()));
              },
            ),

            const SizedBox(height: 70),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddTransactionPage()));
        },
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        shape: const CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // Summary Card (Expenses & Earnings)
  Widget _buildSummaryTile(String title, double amount, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(
          "\$${amount.toStringAsFixed(2)}",
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Navigation Buttons (Transactions & Categories)
  Widget _buildNavigationButton({required String title, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: AppColors.cardBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
              Icon(icon, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  // Category Color Mapping
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
}
