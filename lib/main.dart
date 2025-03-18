import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_finance/pages/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyFinance',
      debugShowCheckedModeBanner: false, // Remove the debug banner
      home: HomeScreen(),  // Set HomeScreen as the initial route
    );
  }
}
