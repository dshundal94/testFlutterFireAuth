import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:workout_capture/auth_service.dart';
import 'package:workout_capture/user.dart';

class AuthService implements AuthServiceClass {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //create user object based on Firebase User
  UserApp _userFromFirebaseUser(User user) {
    return user != null ? UserApp(uid: user.uid) : null;
  }

  //User stream
  @override
  Stream<UserApp> get onAuthStateChanged {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  @override
  Future<UserApp> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;
      return _userFromFirebaseUser(user);//convert firebase user stream to your own user model
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        throw PlatformException(code: 'invalid-credential');
      } else if (e.code == 'wrong-password') {
         throw PlatformException(code:'wrong-password');
      } else if(e.code == 'user-not-found') {
          throw PlatformException(code:'user-not-found');
      } else if(e.code == 'user-disabled') {
          throw PlatformException(code:'user-disabled');
      } else if (e.code == 'too-many-requests') {
         throw PlatformException(code:'too-many-requests');
      } else if (e.code == 'operation-not-allowed') {
          throw PlatformException(code:'operation-not-allowed');
      } else if (e.code == 'account-exists-with-different-credential') {
          throw PlatformException(code:'account-exists-with-different-credential');
      } else {
        throw PlatformException(code:e.code.toString());
      }
    }
  }

  //sign out
  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  UserApp currentUser() {
    final User user = _auth.currentUser;
    return _userFromFirebaseUser(user);
  }

  @override
  void dispose() {}
}
