import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:my_finance/api/auth/auth_service.dart';
import 'package:my_finance/helper/colors.dart';
import 'package:my_finance/pages/category_page.dart';

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

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0), // Uniform margin
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Align everything properly
          children: [
            SizedBox(height: 35.0),

            // User Greeting with Logout Button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Hello, $userName 👋",
                    style: TextStyle(
                      color: AppColors.whiteText,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis, // Prevent overflow issues
                  ),
                  IconButton(
                    icon: Icon(Icons.logout, color: Colors.red),
                    onPressed: () async {
                      await AuthService.logoutUser();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 10),

            // Overview Card
            SizedBox(
              height: 160,
              child: Card(
                color: AppColors.cardBackgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Total Balance",
                          style: TextStyle(
                              color: AppColors.secondaryText, fontSize: 16)),
                      Text("\$${totalBalance.toStringAsFixed(2)}",
                          style: TextStyle(
                              color: AppColors.primaryText,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text("Last Month’s Expense",
                                  style: TextStyle(
                                      color: AppColors.secondaryText)),
                              Text("\$${lastMonthExpense.toStringAsFixed(2)}",
                                  style: TextStyle(
                                      color: AppColors.errorColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            children: [
                              Text("Last Month’s Earnings",
                                  style: TextStyle(
                                      color: AppColors.secondaryText)),
                              Text("\$${lastMonthEarnings.toStringAsFixed(2)}",
                                  style: TextStyle(
                                      color: AppColors.successColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),

            // Expense Chart
            Expanded(
              child: GestureDetector(
                onTap: () => print('chart clicked'),
                child: Card(
                  color: AppColors.backgroundColor,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Spending by Category",
                          style: TextStyle(
                            color: AppColors.whiteText,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sections: expenseByCategory.entries.map((entry) {
                                return PieChartSectionData(
                                  title: entry.key,
                                  value: entry.value,
                                  color: getCategoryColor(entry.key),
                                  titleStyle: TextStyle(
                                    color: AppColors.whiteText,
                                    fontSize: 12,
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
              ),
            ),

            SizedBox(height: 16),

            // Transaction Cards
            GestureDetector(
              onTap: () => print('Show all Transactions clicked'),
              child: Container(
                width: double.infinity, // Makes it take full width
                child: Card(
                  color: AppColors.cardBackgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Show all Transactions',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                        Icon(Icons.arrow_forward_ios_rounded,
                            color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 5.0),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CategoryPage()),
                );
              },
              child: Container(
                width: double.infinity,
                child: Card(
                  color: AppColors.cardBackgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Categories',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                        Icon(Icons.arrow_forward_ios_rounded,
                            color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 70),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => print('Add new transaction'),
        backgroundColor: AppColors.primaryColor,
        child: Icon(Icons.add, color: Colors.white, size: 28),
        shape: CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
