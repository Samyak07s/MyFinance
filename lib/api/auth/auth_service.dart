import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 Register a new user
  static Future<User?> registerUser(
      String email, String password, String name) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'name': name,
        'email': email,
        'uid': userCredential.user?.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential.user;
    } catch (e) {
      print('Error registering user: $e');
      return null;
    }
  }

  // 🔹 Login user
  static Future<User?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Error logging in: ${e.message}');
      return null;
    }
  }

  // 🔹 Google Sign-In
  static Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // User canceled sign-in

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Check if the user has a display name
        if (user.displayName == null || user.displayName!.isEmpty) {
          _askForUserName(context, user);
        } else {
          print('User signed in: ${user.displayName}');
        }
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
    }
  }

  // 🔹 Show dialog to ask for user name
  static void _askForUserName(BuildContext context, User user) {
    TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // Force user to enter name
      builder: (context) {
        return AlertDialog(
          title: Text("Enter Your Name"),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: "Your Name"),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String name = nameController.text.trim();
                if (name.isNotEmpty) {
                  // Update Firebase Auth Profile
                  await user.updateDisplayName(name);
                  await user.reload();

                  // Store in Firestore for future use
                  await _firestore.collection("users").doc(user.uid).set({
                    "name": name,
                    "email": user.email,
                    "uid": user.uid,
                    "photoURL": user.photoURL,
                  });

                  Navigator.pop(context);
                  print("Name saved: $name");
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
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
  static User? getCurrentUser() {
    return _auth.currentUser;
  }
}
