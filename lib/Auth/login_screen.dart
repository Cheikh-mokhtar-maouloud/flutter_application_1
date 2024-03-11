import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Api/Api.dart';
import 'package:flutter_application_1/components/button.dart';
import 'package:flutter_application_1/components/passwords.dart';
import 'package:flutter_application_1/Auth/ForgetPassword.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/Auth/sign_up_screen.dart';
import 'package:flutter_application_1/Auth/service/authgoogle.dart';
import 'package:flutter_application_1/widgets/navbar_roots.dart';
import 'package:flutter_application_1/Auth/sign_up_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

class loginScreen extends StatefulWidget {
  @override
  State<loginScreen> createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {
  bool passToggle = true;
  String email = "", password = "";
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  void userLogin() async {
    try {
      String email = _emailTextController.text;
      String password = _passwordTextController.text;
      await Apis.auth
          .signInWithEmailAndPassword(email: email, password: password);
      if (!mounted) return;
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => NavBarRoots()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(
            "No User Found for that Email",
            style: TextStyle(fontSize: 18.0),
          ),
        ));
        if (await Apis.userExist()) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => NavBarRoots()));
        } else {
          await Apis.createUser().then((value) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => loginScreen()));
          });
        }
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(
            "Wrong Password Provided by User",
            style: TextStyle(fontSize: 18.0),
          ),
        ));
      }
    }
  }

  // Future<void> _signInWithGoogle(BuildContext context) async {
  //   try {
  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //     if (googleUser != null) {
  //       final GoogleSignInAuthentication googleAuth =
  //           await googleUser.authentication;

  //       final AuthCredential credential = GoogleAuthProvider.credential(
  //         accessToken: googleAuth.accessToken,
  //         idToken: googleAuth.idToken,
  //       );

  //       await FirebaseAuth.instance.signInWithCredential(credential);

  //       // Rediriger l'utilisateur vers la page suivante après la connexion
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(builder: (context) => NavBarRoots()),
  //       );
  //     }
  //   } catch (e) {
  //     print("Error signing in with Google: $e");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: SafeArea(
            child: Form(
                key: _formkey,
                child: Column(children: [
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Image.asset(
                      "images/doctors.png",
                    ),
                  ),
                  SizedBox(height: 10),
                  // Padding(
                  //   padding: const EdgeInsets.all(12),
                  //   child: TextField(
                  //     decoration: InputDecoration(
                  //       border: OutlineInputBorder(),
                  //       label: Text("Enter Username"),
                  //       prefixIcon: Icon(Icons.person),
                  //     ),
                  //   ),
                  // ),
                  // reusableTextField("Entrer Email", Icons.person_outline, false,
                  //     _emailTextController),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Entre Email';
                        }
                        return null;
                      },
                      controller: _emailTextController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        labelText: "Enter Email",
                        prefixIcon: Icon(Icons.email),
                      ),
                      onTap: () {
                        setState(() {
                          passToggle = !passToggle;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 15),
                  Padding(
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
                  ),
                  // reusableTextField("Entrer Password", Icons.lock_outline, true,
                  //     _passwordTextController),
                  SizedBox(height: 20),
                  // Padding(
                  //   padding: const EdgeInsets.all(15),
                  //   child: InkWell(
                  //     onTap: () {
                  //       Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //             builder: (context) => NavBarRoots(),
                  //           ));
                  //     },
                  //     child: Container(
                  //       padding: EdgeInsets.symmetric(vertical: 15),
                  //       width: double.infinity,
                  //       decoration: BoxDecoration(
                  //         color: Color(0xFF7165D6),
                  //         borderRadius: BorderRadius.circular(10),
                  //         boxShadow: [
                  //           BoxShadow(
                  //             color: Colors.black12,
                  //             blurRadius: 4,
                  //             spreadRadius: 2,
                  //           ),
                  //         ],
                  //       ),
                  //       child: Center(
                  //         child: Text(
                  //           "Log In",
                  //           style: TextStyle(
                  //             fontSize: 23,
                  //             fontWeight: FontWeight.bold,
                  //             color: Colors.white,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // button(
                  //   title: "Log In",
                  //   onTap: () {
                  //     FirebaseAuth.instance
                  //         .signInWithEmailAndPassword(
                  //             email: _emailTextController.text,
                  //             password: _passwordTextController.text)
                  //         .then((value) {
                  //       Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //             builder: (context) => NavBarRoots(),
                  //           ));
                  //     }).onError((error, stackTrace) {
                  //       print("Error ${error.toString()}");
                  //     });
                  //   },
                  // ),
                  button(
                    title: " Login ",
                    onTap: () {
                      if (_formkey.currentState!.validate()) {
                        userLogin();
                      }
                    },
                  ),
                  Center(
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
                  ),

                  Center(
                    child: Text(
                      "or LogIn with",
                      style: TextStyle(
                          color: Color(0xFF273671),
                          fontSize: 22.0,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          AuthMethods().signInWithGoogle(context);
                        },
                        child: Image.asset(
                          "images/google.png",
                          height: 30,
                          width: 30,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
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
                      ),
                    ],
                  ),
                ])),
          ),
        ),
      ),
    );
  }
}
