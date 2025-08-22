import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> storeUserData({
    required String uid,
    required String name,
    required String email,
    String? motivationalLine,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'user_details': {
        'name': name,
        'email': email,
        'motivational_line': motivationalLine ?? '',
        'created_at': FieldValue.serverTimestamp(),
      },
    });
  }
}
