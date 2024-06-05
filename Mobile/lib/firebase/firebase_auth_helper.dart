import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthHelper {
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential?> signUpWithEmailAndPassword(String email,
      String password, String name, String phone, Function onSuccess) async {
    try {
      // _auth
      //     .createUserWithEmailAndPassword(
      //   email: email,
      //   password: password,
      // )
      //     .then((user) {
      //   _createUser(user.user!.uid, name, phone, onSuccess);
      //   print('User registered: ${user}');
      //   onSuccess();
      // });

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _createUser(userCredential.user!.uid, name, email, phone, onSuccess);
      print('User registered: ${userCredential}');
      onSuccess();

      return userCredential;

      // Additional logic for saving the name and phone number to the user profile, if needed.
      // For simplicity, it's not included in this example.
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        // throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        // throw Exception('The account already exists for that email.');
      }
    } catch (e) {
      print('Error during registration: $e');
      return null;
      // return null;
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password, Function onSuccess) async {
    try {
      // _auth
      //     .signInWithEmailAndPassword(
      //   email: email,
      //   password: password,
      // )
      //     .then((user) {
      //   onSuccess();
      // }).catchError((err) {
      //   print('Error during sign in: $err');
      // });

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      onSuccess();
      return userCredential;
    } catch (e) {
      print('Error during sign in: $e');
      return null;
    }
  }

  void signOut() async {
    await _auth.signOut();
  }

  _createUser(String userId, String name, String email, String phone,
      Function onSuccess) {
    var user = {
      'id': userId,
      "name": name,
      "email": email,
      "phone": phone,
    };
    CollectionReference userReference =
        FirebaseFirestore.instance.collection('users');
    userReference.doc(userId).set(user).then((_) {
      onSuccess();
    }).catchError((err) {
      print('Error during creating user: $err');
    });
  }
}
