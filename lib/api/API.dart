import 'package:cloud_firestore/cloud_firestore.dart';

class API {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 Get user details from Firestore
  static Future<Map<String, dynamic>?> getUserDetails(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
    }
  }
}
