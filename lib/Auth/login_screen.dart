import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Api/Api.dart';
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

      // Ici, récupérez les données supplémentaires nécessaires après la connexion
      await loadUserData(userCredential.user!.uid);
      if (!mounted) return;

      Navigator.pushReplacement(
          // Utilisez pushReplacement pour éviter de revenir à l'écran de connexion
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

  Future<void> loadUserData(String userId) async {
    // Simulez un délai pour le chargement des données ou effectuez des opérations de base de données
    await Future.delayed(Duration(
        seconds:
            2)); // Supposons que cela prend 2 secondes pour charger les données

    // Supposons que vous récupériez des données depuis Firestore ou une autre source
    // Exemple : FirebaseFirestore.instance.collection('users').doc(userId).get();
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
                        Padding(
                          padding: const EdgeInsets.all(20),
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
                        SizedBox(height: 20),
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
                        SizedBox(
                          height: 15.0,
                        ),
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
                      ])),
                ),
              ),
            ),
    );
  }
}
