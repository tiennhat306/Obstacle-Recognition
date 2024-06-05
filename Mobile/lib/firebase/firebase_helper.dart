import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create
  Future<void> createData(String path, Map<String, dynamic> data) async {
    await _firestore.doc(path).set(data);
  }

  // Read
  Future<DocumentSnapshot> getData(String path) async {
    return await _firestore.doc(path).get();
  }

  // Update
  Future<void> updateData(String path, Map<String, dynamic> data) async {
    await _firestore.doc(path).update(data);
  }

  // Delete
  Future<void> deleteData(String path) async {
    await _firestore.doc(path).delete();
  }
}
