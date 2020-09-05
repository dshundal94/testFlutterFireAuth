import 'package:flutter/material.dart';
import 'package:workout_capture/home.dart';
import 'package:workout_capture/landingPage.dart';
import 'package:workout_capture/user.dart';

class AuthWidget extends StatelessWidget {
  const AuthWidget({Key key, @required this.userSnapshot}) : super(key: key);
  final AsyncSnapshot<UserApp> userSnapshot;

  @override
  Widget build(BuildContext context) {
    if (userSnapshot.connectionState == ConnectionState.active) {
      return userSnapshot.hasData ? HomePage() : Background();
    }
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
