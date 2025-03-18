class UserModel {
  String id;
  String email;
  String name;
  double balance;
  double lastMonthIncome;
  double lastMonthExpense;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.balance,
    required this.lastMonthIncome,
    required this.lastMonthExpense,
  });

  // Convert user data from Firestore to UserModel
  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      email: data['email'],
      name: data['name'],
      balance: data['balance']?.toDouble() ?? 0.0,
      lastMonthIncome: data['lastMonthIncome']?.toDouble() ?? 0.0,
      lastMonthExpense: data['lastMonthExpense']?.toDouble() ?? 0.0,
    );
  }

  // Convert UserModel to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'balance': balance,
      'lastMonthIncome': lastMonthIncome,
      'lastMonthExpense': lastMonthExpense,
    };
  }
}
