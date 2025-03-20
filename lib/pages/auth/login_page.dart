import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_finance/api/auth/auth_service.dart';
import 'package:my_finance/helper/colors.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLogin = true; // Toggle between login and register
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String? confirmPasswordError; // Error message for confirm password

  void _handleEmailAuth(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return; // Stop if form is invalid

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (isLogin) {
      // **Login Flow**
      User? user = (await AuthService.loginUser(email, password)) as User?;
      if (user == null) {
        _showSnackBar("User not found! Please register.");
        setState(() => isLogin = false); // Switch to register mode
      }
    } else {
      // **Register Flow**
      String name = nameController.text.trim();
      String confirmPassword = confirmPasswordController.text.trim();

      if (password != confirmPassword) {
        setState(() => confirmPasswordError = "Passwords do not match");
        return;
      } else {
        setState(() => confirmPasswordError = null); // Clear error if match
      }

      User? user = await AuthService.registerUser(email, password, name);
      if (user != null) {
        _showSuccessDialog("Registration successful! Please log in.");
        setState(() => isLogin = true); // Switch to login mode
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: isLogin ? 230 : 150),
                const Text(
                  "MyFinance",
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),

                // Full Name (Only in Register Mode)
                if (!isLogin) ...[
                  TextFormField(
                    controller: nameController,
                    style: TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Full Name"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your name";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                ],

                // Email
                TextFormField(
                  controller: emailController,
                  style: TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Email"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your email";
                    }
                    if (!RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                        .hasMatch(value)) {
                      return "Enter a valid email";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Password
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Password"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a password";
                    }
                    if (value.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Confirm Password (Always at the Bottom, Only in Register Mode)
                if (!isLogin) ...[
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    style: TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Confirm Password"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please confirm your password";
                      }
                      if (value != passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                  if (confirmPasswordError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        confirmPasswordError!,
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  const SizedBox(height: 12),
                ],

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
        borderSide: BorderSide(color: AppColors.primaryColor),
        borderRadius: BorderRadius.circular(10),
      ),
      errorStyle: TextStyle(color: Colors.red), // Red error text
    );
  }
}
