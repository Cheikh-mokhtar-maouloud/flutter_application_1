import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Api/Api.dart';
import 'package:flutter_application_1/Auth/service/loginFunction.dart';
import 'package:flutter_application_1/components/button.dart';
import 'package:flutter_application_1/Auth/ForgetPassword.dart';
import 'package:flutter_application_1/Auth/sign_up_screen.dart';
import 'package:flutter_application_1/Auth/service/authgoogle.dart';
import 'package:flutter_application_1/widgets/navbar_roots.dart';

class loginScreen extends StatefulWidget {
  @override
  State<loginScreen> createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {
  bool isLoading = false;
  bool passToggle = true;
  String email = "", password = "";
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  void userLogin() async {
    setState(() {
      isLoading = true; // Commence le chargement
    });

    try {
      String email = _emailTextController.text;
      String password = _passwordTextController.text;
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      if (!mounted) return;

      await LoginFunctions.loginandupdate(userCredential);







      Navigator.pushReplacement(

          context,
          MaterialPageRoute(builder: (context) => NavBarRoots()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showDialogError("No User Found for that Email");
      } else if (e.code == 'wrong-password') {
        showDialogError("Wrong Password Provided by User");
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false; // Arrête le chargement
        });
      }
    }
  }



  void showDialogError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.orangeAccent,
      content: Text(
        message,
        style: TextStyle(fontSize: 18.0),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.white,
              child: SingleChildScrollView(
                child: SafeArea(
                  child: Form(
                      key: _formkey,
                      child: Column(children: [
                        SizedBox(height: 10),
                        Imagewidget(),
                        SizedBox(height: 10),
                        buildemail("Please validate your email",_emailTextController,"Email",Icons.email),
                        SizedBox(height: 15),
                        buildemail("Please validate your password",_passwordTextController,"Password",Icons.lock),

                        SizedBox(height: 20),
                        buttonlogin(),
                        Forgetwidget(context),
                        SizedBox(
                          height: 15.0,
                        ),
                        cREATEAcountCom(context),
                      ])),
                ),
              ),
            ),
    );
  }

  button buttonlogin() {
    return button(
                        title: " Login ",
                        onTap: () {
                          if (_formkey.currentState!.validate()) {
                            userLogin();
                          }
                        },
                      );
  }

  Center Forgetwidget(BuildContext context) {
    return Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ForgotPassword()));
                          },
                          child: Text(
                            "Forget Password",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
  }

  Padding Imagewidget() {
    return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Image.asset(
                          "images/doctors.png",
                        ),
                      );
  }

  Padding PasswordWidget() {
    return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Entre Password';
                            }
                            return null;
                          },
                          controller: _passwordTextController,
                          obscureText: passToggle,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  15.0), // Ajout de BorderRadius.circular(15.0)
                            ),
                            labelText: "Enter Password",
                            prefixIcon: Icon(Icons.lock),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  passToggle = !passToggle;
                                });
                              },
                              icon: Icon(
                                passToggle
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ),
                        ),
                      );
  }

  Padding buildemail(String validateEmail,TextEditingController _emailTextController,String label,IconData icon) {
    return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return validateEmail;
                            }
                            return null;
                          },
                          controller: _emailTextController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            labelText: "$label",
                            prefixIcon: Icon(icon),
                          ),
                          onTap: () {
                            setState(() {

                            });
                          },
                        ),
                      );
  }

  Row cREATEAcountCom(BuildContext context) {
    return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have any account?",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignUpScreen(),
                                  ));
                            },
                            child: Text(
                              "Create Account",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7165D6),
                              ),
                            ),
                          ),
                        ],
                      );
  }
}
