import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/components/button.dart';
import 'package:flutter_application_1/components/numberphone.dart';
import 'package:flutter_application_1/components/passwords.dart';
import 'package:flutter_application_1/components/textformfield.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/Auth/login_screen.dart';
import 'package:flutter_application_1/Auth/service/authgoogle.dart';
import 'package:flutter_application_1/widgets/navbar_roots.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool passToggle = true;
  String email = "", password = "", name = "";
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _nameTextController = TextEditingController();
  TextEditingController _phoneTextController = TextEditingController();
  TextEditingController _addressTextController = TextEditingController();
  List<String> addresses = [
    "Nema",
    "NKTT",
    "NDB",
    "Rosso",
    "Kifa",
  ];
  final _formkey = GlobalKey<FormState>();
  registration() async {
    String email = _emailTextController.text;
    String password = _passwordTextController.text;
    String name = _nameTextController.text;
    String phone = _phoneTextController.text;

    String address = _addressTextController.text;
    if (password.isNotEmpty &&
        _nameTextController.text.isNotEmpty &&
        email.isNotEmpty &&
        phone.isNotEmpty &&
        address.isNotEmpty) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        FirebaseFirestore.instance
            .collection("users")
            .doc(userCredential.user!.uid)
            .set({
          "name": name,
          "email": email,
          "phone": phone,
          "Adress": address,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Registered Successfully",
            style: TextStyle(fontSize: 20.0),
          ),
        ));
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => NavBarRoots()));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "Password Provided is too Weak",
              style: TextStyle(fontSize: 18.0),
            ),
          ));
        } else if (e.code == "email-already-in-use") {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "Account Already exists",
              style: TextStyle(fontSize: 18.0),
            ),
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
            child: Form(
                key: _formkey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Image.asset(
                          "images/doctors.png",
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Entre Name';
                            }
                            return null;
                          },
                          controller: _nameTextController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            labelText: "Entrer Full Name",
                            prefixIcon: Icon(Icons.person),
                          ),
                          onTap: () {
                            setState(() {
                              passToggle = !passToggle;
                            });
                          },
                        ),
                      ),

                      SizedBox(height: 20),

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
                            labelText: "Entrer Email",
                            prefixIcon: Icon(Icons.email),
                          ),
                          onTap: () {
                            setState(() {
                              passToggle = !passToggle;
                            });
                          },
                        ),
                      ),

                      SizedBox(height: 20),

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
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            labelText: "Entrer Password",
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

                      SizedBox(height: 10),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          controller: _phoneTextController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            labelText: "Entrer Phone Number",
                            prefixIcon: Icon(Icons.phone),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter Phone Number';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: "Entrer Adress",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          value: addresses.isNotEmpty ? addresses.first : null,
                          onChanged: (value) {
                            setState(() {
                              _addressTextController.text = value!;
                            });
                          },
                          items: addresses.map((address) {
                            return DropdownMenuItem<String>(
                              value: address,
                              child: Text(address),
                            );
                          }).toList(),
                        ),
                      ),

                      button(
                        title: "Create Account",
                        onTap: () {
                          if (_formkey.currentState!.validate()) {
                            registration();
                          }
                        },
                      ),

                      // SizedBox(height: 5),
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
                          SizedBox(height: 10),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Already have an account? ",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => loginScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Log In",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF7165D6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ]))),
      ),
    );
  }
}
