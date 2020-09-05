import 'dart:async';
import 'package:workout_capture/user.dart';

abstract class AuthServiceClass {
  UserApp currentUser();
  Future<UserApp> signInWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Stream<UserApp> get onAuthStateChanged;
  void dispose();
}