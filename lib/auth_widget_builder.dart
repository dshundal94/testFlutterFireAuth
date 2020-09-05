import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_capture/auth.dart';
import 'package:workout_capture/user.dart';

class AuthWidgetBuilder extends StatelessWidget {
  const AuthWidgetBuilder({Key key, @required this.builder}) : super(key: key);
  final Widget Function(BuildContext, AsyncSnapshot<UserApp>) builder;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    return StreamBuilder<UserApp>(
        stream: authService.onAuthStateChanged,
        builder: (context, snapshot) {
          final UserApp user = snapshot.data;
          if (user != null) {
            return MultiProvider(
              providers: [
                Provider<UserApp>.value(value: user),
              ],
              child: builder(context, snapshot),
            );
          }
          return builder(context, snapshot);
        });
  }
}
