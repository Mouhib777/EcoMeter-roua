import 'package:animate_do/animate_do.dart';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:roua_benamor/screens/homePage.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _acceptedTerms = false;
  String? email;
  String? f_name;
  String? password;
  String? p_confirm;
  var _fNameController = TextEditingController();
  var _emailController = TextEditingController();
  var _passwordController = TextEditingController();
  var _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FadeIn(
                    child: Text(
                      'EcoMeter',
                      style: TextStyle(
                        fontSize: 40.0,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 30.0),
                  FadeInLeft(
                    child: SizedBox(
                      width: 330,
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'address@mail.com',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          labelText: '  E-mail address',
                        ),
                        autofocus: false,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          } else {
                            setState(() {
                              email = value;
                            });
                            return null;
                          }
                        },
                        onChanged: (value) {
                          email = value;
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  FadeInLeft(
                    child: SizedBox(
                      width: 330,
                      child: TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          labelText: '  Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                        autofocus: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          } else {
                            setState(() {
                              password = value;
                            });
                            return null;
                          }
                        },
                        onChanged: (value) {
                          password = value;
                        },
                        obscureText: _obscureText,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  FadeInLeft(
                    child: SizedBox(
                      width: 330,
                      child: TextFormField(
                        controller: _confirmController,
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          labelText: '  Confirm Password',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'password not confirmed';
                          } else if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          } else {
                            setState(() {
                              p_confirm = value;
                            });
                            return null;
                          }
                        },
                        onChanged: (value) {
                          p_confirm = value;
                        },
                        obscureText: true,
                      ),
                    ),
                  ),
                  SizedBox(height: 40.0),
                  FadeInLeft(
                    child: Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              setState(() {
                                _isLoading = true;
                              });
                              UserCredential user = await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                      email: email!.trim(),
                                      password: password!.trim());
                              final User? userr =
                                  FirebaseAuth.instance.currentUser;
                              final _uid = userr!.uid;
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(_uid)
                                  .set({
                                "email": "$email",
                                "password": "$password",
                              });
                              Navigator.of(context).push(PageRouteBuilder(
                                  transitionDuration: Duration.zero,
                                  pageBuilder:
                                      (context, animation, secondary) =>
                                          HomePage()));

                              EasyLoading.showSuccess(
                                  'user with email $email was created');
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'weak-password') {
                                AnimatedSnackBar.material(
                                  "Invalid password",
                                  type: AnimatedSnackBarType.error,
                                  duration: Duration(seconds: 4),
                                  mobileSnackBarPosition:
                                      MobileSnackBarPosition.bottom,
                                ).show(context);
                              } else if (e.code == 'invalid-email') {
                                AnimatedSnackBar.material(
                                  "Invalid email address",
                                  type: AnimatedSnackBarType.error,
                                  duration: Duration(seconds: 4),
                                  mobileSnackBarPosition:
                                      MobileSnackBarPosition.bottom,
                                ).show(context);
                              } else if (e.code == 'email-already-in-use') {
                                AnimatedSnackBar.material(
                                  "This email address is already in use",
                                  type: AnimatedSnackBarType.error,
                                  duration: Duration(seconds: 4),
                                  mobileSnackBarPosition:
                                      MobileSnackBarPosition.bottom,
                                ).show(context);
                              }
                            } catch (ex) {
                              print(ex);
                              AnimatedSnackBar.material(
                                "$ex",
                                type: AnimatedSnackBarType.error,
                                duration: Duration(seconds: 4),
                                mobileSnackBarPosition:
                                    MobileSnackBarPosition.bottom,
                              ).show(context);
                            }
                            FocusScopeNode currentFocus =
                                FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }

                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.all(16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Text(
                          'Sign up',
                          style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                      child: _isLoading
                          ? CircularProgressIndicator(
                              color: Colors.red,
                            )
                          : null),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
