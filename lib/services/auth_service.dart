import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/user.dart';

class AuthService {
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;

  // Sign up
  Future<User?> signUp(String email, String password) async {
    try {
      fb.UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      fb.User? fbUser = result.user;

      if (fbUser != null) {
        return User(
          id: fbUser.uid,
          email: fbUser.email!,
          password: password, // Usually, you don't store password locally
        );
      }
    } catch (e) {
      print("SignUp Error: $e");
    }
    return null;
  }

  // Login
  Future<User?> signIn(String email, String password) async {
    try {
      fb.UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      fb.User? fbUser = result.user;

      if (fbUser != null) {
        return User(
          id: fbUser.uid,
          email: fbUser.email!,
          password: password,
        );
      }
    } catch (e) {
      print("SignIn Error: $e");
    }
    return null;
  }

  // Logout
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Current User
  User? getCurrentUser() {
    final fb.User? fbUser = _firebaseAuth.currentUser;
    if (fbUser != null) {
      return User(id: fbUser.uid, email: fbUser.email!, password: '');
    }
    return null;
  }
}