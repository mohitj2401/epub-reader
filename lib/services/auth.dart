import 'package:firebase_auth/firebase_auth.dart';

import '../models/user.dart';

class AuthService {
  String error = '';

  FirebaseAuth _auth = FirebaseAuth.instance;
  UserModel? _userFromFirebase(User? user) {
    if (user == null) {
      return null;
    }
    return UserModel(uid: user.uid);
  }

  Future signInEmailAndPass(String email, String password) async {
    try {
      UserCredential authResult = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? firebaseUser = authResult.user;
      return _userFromFirebase(firebaseUser);
    } catch (e) {
      error = e.toString();
      print(e.toString());
    }
  }

  Future changedPassword(String password) async {
    try {
      _auth.currentUser?.updatePassword(password).catchError((onError) {
        print(onError.toString());
      });
    } catch (e) {
      error = e.toString();
      print(e.toString());
    }
  }

  Future signUpWithEmailAndPass(String email, String password) async {
    try {
      UserCredential authResult = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? firebaseUser = authResult.user;
      return _userFromFirebase(firebaseUser);
    } catch (e) {
      error = e.toString();
      print(e.toString());
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(
          '"""""""""""""""""""""""""""""""""""""""""""""""e.toString()"""""""""""""""""""""""""""""""""""""""""""""""');
      return null;
    }
  }
}
