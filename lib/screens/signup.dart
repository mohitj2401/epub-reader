import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:our_books/helpers/helpers.dart';
import 'package:our_books/screens/add_books.dart';
import 'package:our_books/screens/book_screen.dart';
import 'package:our_books/screens/signin.dart';
import 'package:our_books/services/auth.dart';
import 'package:our_books/services/database.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  AuthService authService = new AuthService();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  signUp() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      await authService
          .signUpWithEmailAndPass(emailTextEditingController.text,
              passwordTextEditingController.text)
          .then((value) {
        if (value != null) {
          setState(() {
            isLoading = false;
          });
          Map<String, String> userInfoMap = {
            "name": nameTextEditingController.text,
            "email": emailTextEditingController.text,
            "role": "student",
          };
          FirebaseAuth firebaseAuth = FirebaseAuth.instance;
          DatabaseService()
              .uploadUserInfo(userInfoMap, firebaseAuth.currentUser?.uid);
          HelperFunctions.saveUserLoggedIn(true);
          HelperFunctions.saveUserRole('user');

          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => AddBook()));
        } else {
          setState(() {
            isLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          "Welcome to Ours Book",
          style: TextStyle(color: Colors.blue, fontSize: 24),
        )),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height - 60,
                child: Form(
                  key: formKey,
                  child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        children: <Widget>[
                          showAlert(),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 40, top: 40),
                            child: Text(
                              "SignUp",
                              style: TextStyle(
                                  color: Colors.blueGrey, fontSize: 30),
                            ),
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value != null) {
                                if (value.isEmpty) {
                                  return "Please Enter Name";
                                } else {
                                  return null;
                                }
                              }
                            },
                            controller: nameTextEditingController,
                            decoration: InputDecoration(
                              hintText: "Name",
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value != null) {
                                if (RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(value)) {
                                  return null;
                                } else {
                                  return "Enter correct email";
                                }
                              }
                            },
                            controller: emailTextEditingController,
                            decoration: InputDecoration(
                              hintText: "Email",
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          TextFormField(
                            obscureText: true,
                            validator: (value) {
                              if (value != null) {
                                if (value.isEmpty) {
                                  return "Please Enter Password";
                                } else {
                                  return null;
                                }
                              }
                            },
                            controller: passwordTextEditingController,
                            decoration: InputDecoration(
                              hintText: "Password",
                            ),
                          ),
                          SizedBox(
                            height: 24,
                          ),
                          GestureDetector(
                            onTap: () {
                              signUp();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              width: MediaQuery.of(context).size.width - 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                "Sign In",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 17),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Have An Account? ",
                                style: TextStyle(fontSize: 16),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SignIn()));
                                },
                                child: Text(
                                  "Sign In",
                                  style: TextStyle(
                                    fontSize: 16,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 60,
                          )
                        ],
                      )),
                ),
              ),
            ),
    );
  }

  Widget showAlert() {
    if (authService.error != '') {
      return Container(
        color: Colors.amberAccent,
        width: double.infinity,
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.error_outline),
            ),
            Expanded(
              child: Text(authService.error),
            ),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                setState(() {
                  authService.error = '';
                });
              },
            )
          ],
        ),
      );
    } else {
      return SizedBox(height: 0);
    }
  }
}
