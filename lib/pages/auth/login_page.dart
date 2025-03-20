import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_finance/api/auth/auth_service.dart';
import 'package:my_finance/helper/colors.dart';
import 'package:my_finance/models/user_model.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLogin = true; // Toggle between login and register
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  void _handleEmailAuth(BuildContext context) async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (isLogin) {
      // **Login Flow**
      UserModel? user = await AuthService.loginUser(email, password);
      if (user == null) {
        _showSnackBar("User not found! Please register.");
        setState(() => isLogin = false);
      }
    } else {
      // **Register Flow**
      String name = nameController.text.trim();
      String confirmPassword = confirmPasswordController.text.trim();

      if (name.isEmpty) {
        _showSnackBar("Please enter your name.");
        return;
      }
      if (password != confirmPassword) {
        _showSnackBar("Passwords do not match.");
        return;
      }

      User? user = await AuthService.registerUser(email, password, name);
      if (user != null) {
        _showSuccessDialog("Registration successful! Please log in.");
        setState(() => isLogin = true);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Success", style: TextStyle(color: Colors.green)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                    height: isLogin
                        ? 230
                        : 150), // Moves "MyFinance" up in register mode

                // App Name / Logo
                const Text(
                  "MyFinance",
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                // Form Fields
                Form(
                  child: Column(
                    children: [
                      // Full Name (Only in Register Mode)
                      if (!isLogin) ...[
                        TextField(
                          controller: nameController,
                          style: TextStyle(color: Colors.white),
                          decoration: _inputDecoration("Full Name"),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Email
                      TextField(
                        controller: emailController,
                        style: TextStyle(color: Colors.white),
                        decoration: _inputDecoration("Email"),
                      ),
                      const SizedBox(height: 12),

                      // Password
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        style: TextStyle(color: Colors.white),
                        decoration: _inputDecoration("Password"),
                      ),
                      const SizedBox(height: 12),

                      // Confirm Password (Always on bottom in Register Mode)
                      if (!isLogin) ...[
                        TextField(
                          controller: confirmPasswordController,
                          obscureText: true,
                          style: TextStyle(color: Colors.white),
                          decoration: _inputDecoration("Confirm Password"),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Login / Register Button
                ElevatedButton(
                  onPressed: () => _handleEmailAuth(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                    shape: StadiumBorder(),
                  ),
                  child: Text(isLogin ? "Log in" : "Register",
                      style: TextStyle(color: Colors.black, fontSize: 18)),
                ),

                const SizedBox(height: 20),

                // Toggle Between Login & Register
                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(
                    isLogin
                        ? "Don't have an account? Register"
                        : "Already registered? Log in",
                    style: TextStyle(color: Colors.cyanAccent, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.grey[900],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primaryColor), // Change color
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
