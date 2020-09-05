import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:workout_capture/auth.dart';


final Color darkBlue = Color.fromARGB(255, 18, 32, 47);

class TextFieldExample extends StatefulWidget {
  @override
  _TextFieldExampleState createState() => _TextFieldExampleState();
}

class _TextFieldExampleState extends State<TextFieldExample> {
  @override
  void dispose() {
    _username.close();
    _password.close();
    super.dispose();
  }

  String validatorMessage;
  bool validate = false; //will be true if the user clicked in the    login button
  final _username = StreamController<String>(); //stream to   validate   the text
  final _password = StreamController<String>();
  bool hasError = false;
  String errorString;
  Future<String> futureString;

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(29),
          ),
          //expose streambuilder to the column widget to use on multiple widgets
          child: StreamBuilder<String>(
              initialData: '',
              stream: _username.stream,
              builder: (context, usernameSnapshot) {
                return StreamBuilder<String>(
                    initialData: '',
                    stream: _password.stream,
                    builder: (context, passwordSnapshot) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          TextField(
                            onChanged: _username
                                .add, //everytime the text changes a new value will be added to the stream
                            decoration: InputDecoration(
                              icon: Icon(Icons.person),
                              hintText: "Email",
                            ),
                          ),
                          TextField(
                            obscureText: true,
                            onChanged: _password
                                .add, //everytime the text changes a new value will be added to the stream
                            decoration: InputDecoration(
                              icon: Icon(Icons.visibility),
                              hintText: "Password",
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 5),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(29),
                              child: RaisedButton(
                                disabledColor: Colors.grey[300],
                                padding: EdgeInsets.symmetric(vertical: 10),
                                //when user presses button, validate turns to true and we check snapshots to get the data for the entries
                                onPressed: (usernameSnapshot.data.isNotEmpty &&
                                      passwordSnapshot.data.isNotEmpty)
                                  ? () =>
                                      handleSubmit(usernameSnapshot, passwordSnapshot)
                                  : null,
                                child: Text("Login"),
                              ),
                            ),
                          ),
                          //checking the stream and if the user clicked in the button and this shows container when keyboard is on
                          if (hasError && validate && MediaQuery.of(context).viewInsets.bottom == 0 && errorString.length > 0) 
                            Container(
                              alignment: Alignment.center,
                              child: Text(
                                errorString,
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            )
                          else
                            Container()
                        ],
                      );
                    });
              })),
    );
  }

  Future<String> _signInWithEmailAndPassword(BuildContext context,AsyncSnapshot<String> userSnapshot,AsyncSnapshot<String> passwordSnapshot) async {
    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      await auth.signInWithEmailAndPassword(
          userSnapshot.data.trim(), passwordSnapshot.data.trim());
    } on PlatformException catch (e) {
      // hasError = true;
      if (e.code == 'invalid-credential') {
        setState(() {
          errorString = "Email address appears to be malformed/expired";
        });
      } else if (e.code == 'wrong-password') {
        setState(() {
          errorString = "Password associated with this email is wrong";
        });
      } else if (e.code == 'user-not-found') {
        setState(() {
          errorString = "Email has not been registered, please sign up :)";
        });
      } else if (e.code == 'user-disabled') {
        setState(() {
          errorString = "User with this email has been disabled :(";
        });
      } else if (e.code == 'too-many-requests') {
        setState(() {
          errorString = "Too many requests, please try again later.";
        });
      } else if (e.code == 'operation-not-allowed') {
        setState(() {
          errorString = "Signing in with email and password is not enabled";
        });
      } else if (e.code == 'account-exists-with-different-credential') {
        setState(() {
          errorString =
              "Email has already been registered. Reset your password.";
        });
      }
    } on Exception catch (e) {
      print(e.toString());
    }
    if (errorString != null) {
      return Future.error(errorString);
    }
    return 'Success';
  }

  //Handle the string that needs to be inserted into the Error text widget
  String errorStringOutput(AsyncSnapshot<String> usernameSnapshot,
      AsyncSnapshot<String> passwordSnapshot) {
    if (EmailValidator.validate(usernameSnapshot.data.trim()) == false) {
      setState(() {
        errorString = 'Oh no! Enter a valid email please.';
      });
    } else if (passwordSnapshot.data.trim().length <= 8) {
      setState(() {
        errorString = 'Oops! Password should be at least 8 characters.';
      });
    } 
    return errorString;
  }

  //create function to execute when submitting login state
  Future<dynamic> handleSubmit(AsyncSnapshot<String> userSnapshot,
      AsyncSnapshot<String> passwordSnapshot) async {
    FocusScope.of(context).unfocus();
    if (userSnapshot.data.trim().isNotEmpty &&
        passwordSnapshot.data.trim().isNotEmpty &&
        passwordSnapshot.data.trim().length >= 8 &&
        EmailValidator.validate(userSnapshot.data.trim())) {
          validate = true;
          futureString = _signInWithEmailAndPassword(context, userSnapshot, passwordSnapshot);
          futureString.then((String result) {
            setState(() {
              errorString = result;
            });
          });
          if(errorString != "Success") {
            hasError = true;
            validate = true;
            errorStringOutput(userSnapshot, passwordSnapshot);
            setState(() {
              errorString = '';
            });
          } else {
            print('Why did it reach here?');
          }
    } else {
      hasError = true;
      validate = true;
      errorStringOutput(userSnapshot, passwordSnapshot);
    }
  }

}
