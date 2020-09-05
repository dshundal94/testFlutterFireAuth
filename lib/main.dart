import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_capture/auth.dart';
import 'package:workout_capture/auth_widget.dart';
import 'package:workout_capture/auth_widget_builder.dart';
import 'package:firebase_core/firebase_core.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
} 

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider<AuthService>(
        create: (_) => AuthService(),
        child: AuthWidgetBuilder(builder: (context, userSnapshot) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: AuthWidget(userSnapshot: userSnapshot),
          );
        }));
  }
}
