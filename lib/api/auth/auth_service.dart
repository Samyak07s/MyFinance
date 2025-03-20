import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_finance/helper/dialogs.dart';
import 'package:my_finance/models/user_model.dart';
import 'package:my_finance/models/transaction_model.dart';
import 'package:my_finance/pages/home_screen.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 Register a new user
  static Future<User?> registerUser(String email, String password, String name) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // Create user model with empty transactions & categories
      UserModel newUser = UserModel(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        balance: 0.0,
        lastMonthIncome: 0.0,
        lastMonthExpense: 0.0,
        transactions: [],
        categories: [],
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set(newUser.toMap());

      return userCredential.user;
    } catch (e) {
      print('Error registering user: $e');
      return null;
    }
  }

  // 🔹 Login user
  static Future<UserModel?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(email: email, password: password);

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userCredential.user!.uid).get();

      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc.data() as Map<String, dynamic>, userCredential.user!.uid);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('Error logging in: ${e.message}');
      return null;
    }
  }

  // 🔹 Google Sign-In
  static Future<void> signInWithGoogle(BuildContext context) async {
    try {
      Dialogs.showProgressBar(context);

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        Navigator.pop(context);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        Navigator.pop(context);
        Dialogs.showSnackbar(context, "Google Sign-In failed!");
        return;
      }

      // Check if user exists in Firestore
      final doc = await _firestore.collection('users').doc(user.uid).get();
      bool isNewUser = !doc.exists;

      if (isNewUser) {
        String? name = await _askForUserName(context);
        if (name == null || name.trim().isEmpty) {
          await _auth.signOut();
          await GoogleSignIn().signOut();
          Navigator.pop(context);
          return;
        }
        await _saveUserToFirestore(user, name);
      }

      Navigator.pop(context);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
    } catch (e) {
      Navigator.pop(context);
      Dialogs.showSnackbar(context, "Google Sign-In failed: $e");
    }
  }

  /// Ask user for their name (only for first-time Google sign-in)
  static Future<String?> _askForUserName(BuildContext context) async {
    TextEditingController nameController = TextEditingController();

    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Enter Your Name"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: "Your Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, nameController.text.trim()),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  /// Save new user data to Firestore
  static Future<void> _saveUserToFirestore(User user, String name) async {
    UserModel newUser = UserModel(
      id: user.uid,
      email: user.email ?? "",
      name: name,
      balance: 0.0,
      lastMonthIncome: 0.0,
      lastMonthExpense: 0.0,
      transactions: [],
      categories: [],
    );

    await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
  }

  // 🔹 Logout user
  static Future<void> logoutUser() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }

  // 🔹 Delete user account
  static Future<bool> deleteUser() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).delete();
        await user.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  // 🔹 Get current user
  static Future<UserModel?> getCurrentUser() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    DocumentSnapshot userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
    if (userDoc.exists) {
      return UserModel.fromFirestore(userDoc.data() as Map<String, dynamic>, firebaseUser.uid);
    }
    return null;
  }
}
