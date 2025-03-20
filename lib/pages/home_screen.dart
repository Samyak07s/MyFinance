import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:my_finance/api/auth/auth_service.dart';
import 'package:my_finance/api/category_service.dart';
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
  double totalBalance = 0.0;
  double lastMonthExpense = 0.0;
  double lastMonthEarnings = 0.0;
  Map<String, double> expenseByCategory = {};
  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchTransactions();
  }

  /// **Fetch User's Name from Firestore**
  Future<void> fetchUserData() async {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    if (uid.isEmpty) return;

    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if (userDoc.exists) {
      setState(() {
        userName = userDoc["name"] ?? "User";
      });
    }
  }

  /// **Fetch Transactions from Firestore and Calculate Stats**
  Future<void> fetchTransactions() async {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    if (uid.isEmpty) return;

    QuerySnapshot transactionsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .collection("transactions")
        .get();
    double balance = 0.0;
    double monthlyExpense = 0.0;
    double monthlyEarnings = 0.0;
    Map<String, double> categoryExpenses =
        {}; // track category expenses separately

    DateTime now = DateTime.now();
    int currentMonth = now.month;
    int currentYear = now.year;

    for (var doc in transactionsSnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      double amount = (data["amount"] ?? 0).toDouble();
      bool isExpense = data["type"] == "Expense";
      String category = data["category"] ?? "Other";
      DateTime transactionDate = (data["date"] as Timestamp).toDate();

      // Update balance: subtract for expenses, add for earnings
      balance += isExpense ? -amount : amount;

      // Check if transaction is from this month
      if (transactionDate.month == currentMonth &&
          transactionDate.year == currentYear) {
        if (isExpense) {
          monthlyExpense += amount;
        } else {
          monthlyEarnings += amount;
        }
      }

      // Update category expenses for the pie chart
      if (isExpense) {
        categoryExpenses[category] = (categoryExpenses[category] ?? 0) + amount;
      }
    }

    setState(() {
      totalBalance = balance;
      lastMonthExpense = monthlyExpense;
      lastMonthEarnings = monthlyEarnings;
      expenseByCategory =
          categoryExpenses; // Update the state for the pie chart
    });
  }

  Future<List<PieChartSectionData>> _fetchCategoryColors(
      List<String> categories) async {
    List<PieChartSectionData> sectionDataList = [];

    for (String category in categories) {
      Color categoryColor =
          await CategoryService().getCategoryColorFromFirestore(category);

      sectionDataList.add(
        PieChartSectionData(
          title: category,
          value: expenseByCategory[category] ?? 0.0,
          color: categoryColor,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return sectionDataList; // Make sure to return the list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Hello, ${userName.split(' ')[0]} ",
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

            // **Overview Card**
            Card(
              color: AppColors.cardBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text("Total Balance",
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
                    Text(
                      "₹${totalBalance.toStringAsFixed(2)}",
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
                        _buildSummaryTile(
                            "Expenses", lastMonthExpense, Colors.red),
                        _buildSummaryTile(
                            "Earnings", lastMonthEarnings, Colors.green),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // **Expense Chart**
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
                      child: FutureBuilder<List<PieChartSectionData>>(
                        future: _fetchCategoryColors(
                            expenseByCategory.keys.toList()),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return const Center(
                                child: Text('Error fetching data.'));
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                                child: Text('No data available.'));
                          }

                          return PieChart(
                            PieChartData(
                              sections: snapshot
                                  .data!, // Directly use the processed sections
                              borderData: FlBorderData(show: false),
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // **Transactions & Categories**
            _buildNavigationButton(
              title: "Show All Transactions",
              icon: Icons.arrow_forward_ios_rounded,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AllTransactionsPage())).then((_) {
                  fetchTransactions(); // Re-fetch data after returning from CategoryPage
                });
              },
            ),

            const SizedBox(height: 10),

            _buildNavigationButton(
              title: "Manage Categories",
              icon: Icons.arrow_forward_ios_rounded,
              onTap: () {
                Navigator.push(context,
                        MaterialPageRoute(builder: (context) => CategoryPage()))
                    .then((_) {
                  fetchTransactions(); // Re-fetch data after returning from CategoryPage
                });
              },
            ),

            const SizedBox(height: 70),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddTransactionPage()))
              .then((_) {
            fetchTransactions(); // Re-fetch data after returning from AddTransactionPage
          });
        },
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        shape: const CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // Summary Tile for Expenses & Earnings
  Widget _buildSummaryTile(String title, double amount, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(
          "\₹${amount.toStringAsFixed(2)}",
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
  Widget _buildNavigationButton(
      {required String title,
      required IconData icon,
      required VoidCallback onTap}) {
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
              Text(title,
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
              Icon(icon, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  // Category Color Mapping
  Color getCategoryColor(String hexColor) {
    // Convert the hex color string to a Color object
    return Color(int.parse(hexColor.replaceFirst('#', '0xff')));
  }
}
