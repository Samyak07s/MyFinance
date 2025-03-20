import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_finance/helper/colors.dart';
import 'package:my_finance/pages/auth/login_page.dart';
import 'package:my_finance/pages/home_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Ensure Firebase is initialized
  runApp(MyFinanceApp());
}

class MyFinanceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "MyFinance",
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
        primaryColor: AppColors.primaryColor,
        scaffoldBackgroundColor: AppColors.backgroundColor,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.primaryColor,
          selectionColor: AppColors.primaryColor.withOpacity(0.5),
          selectionHandleColor: AppColors.primaryColor,
        ),
      ),
      home: AuthWrapper(), // Determines if user is logged in or not
    );
  }
}

// Decides whether to show Login or Home screen
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
        }
        if (snapshot.hasData ) {
          return const HomePage(); // User is logged in, go to Home Page
        } else {
          return LoginPage(); // Otherwise, show Login Page
        }
      },
    );
  }
}
