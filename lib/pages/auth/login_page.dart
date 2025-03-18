import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_finance/api/auth/auth_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLogin = true; // Toggle between login and register
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  void _handleGoogleBtnClick() async {
    await AuthService.signInWithGoogle();
  }

  void _handleEmailAuth(BuildContext context) async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (isLogin) {
      // **Login Flow**
      User? user = await AuthService.loginUser(email, password);
      if (user == null) {
        _showErrorDialog("User not found! Please register.");
        setState(() => isLogin = false); // Switch to register mode
      }
    } else {
      // **Register Flow**
      String name = nameController.text.trim();
      String confirmPassword = confirmPasswordController.text.trim();

      if (name.isEmpty) {
        _showErrorDialog("Please enter your name.");
        return;
      }
      if (password != confirmPassword) {
        _showErrorDialog("Passwords do not match.");
        return;
      }

      User? user = await AuthService.registerUser(email, password, name);
      if (user != null) {
        _showSuccessDialog("Registration successful! Please log in.");
        setState(() => isLogin = true); // Switch to login mode
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error", style: TextStyle(color: Colors.red)),
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
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Name / Logo
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
            if (!isLogin)
              Column(
                children: [
                  TextField(
                    controller: nameController,
                    style: TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Full Name"),
                  ),
                  const SizedBox(height: 12),
                ],
              ),

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

            // Confirm Password (Only in Register Mode)
            if (!isLogin)
              Column(
                children: [
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    style: TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Confirm Password"),
                  ),
                  const SizedBox(height: 12),
                ],
              ),

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

            const SizedBox(height: 30),

            // OR Divider
            const Row(
              children: [
                Expanded(child: Divider(color: Colors.white30, thickness: 1)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text("OR",
                      style: TextStyle(color: Colors.white70, fontSize: 16)),
                ),
                Expanded(child: Divider(color: Colors.white30, thickness: 1)),
              ],
            ),

            const SizedBox(height: 30),

            // Google Sign-In Button
            ElevatedButton.icon(
              onPressed: _handleGoogleBtnClick,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey.shade300),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 25),
                shape: StadiumBorder(),
              ),
              icon:
                  Image.asset('images/google_logo.png', height: 24, width: 24),
              label: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Log in using ',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    TextSpan(
                      text: 'Google',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Toggle Between Login & Register
            TextButton(
              onPressed: () => setState(() => isLogin = !isLogin),
              child: Text(
                isLogin ? "Don't have an account? Register" : "Already registered? Log in",
                style: TextStyle(color: Colors.cyanAccent, fontSize: 16),
              ),
            ),
          ],
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
    );
  }
}
