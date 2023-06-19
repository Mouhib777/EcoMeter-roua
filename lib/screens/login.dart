import 'package:animate_do/animate_do.dart';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roua_benamor/screens/homePage.dart';
import 'package:roua_benamor/screens/register.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? email;
  String? password;
  String? p_confirm;
  var _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

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
              child: FadeInDownBig(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FadeIn(
                      delay: Duration(milliseconds: 1400),
                      child: Image.asset(
                        "assets/images/logo_society.jpg",
                      ),
                    ),
                    SizedBox(height: 30.0),
                    SizedBox(
                      width: 350,
                      child: TextField(
                        style: GoogleFonts.montserrat(),
                        decoration: InputDecoration(
                          labelStyle: GoogleFonts.montserrat(),
                          hintStyle: GoogleFonts.montserrat(),
                          prefixStyle: GoogleFonts.montserrat(),
                          counterStyle: GoogleFonts.montserrat(),
                          suffixStyle: GoogleFonts.montserrat(),
                          floatingLabelStyle: GoogleFonts.montserrat(),
                          hintText: 'address@mail.com',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          labelText: '  E-mail address',
                          // counterText:
                          //     '*Please use a verified e-mail',
                        ),
                        autofocus: false,
                        keyboardType: TextInputType.emailAddress,
                        maxLength: 40,
                        onChanged: (value) {
                          email = value;
                        },
                        // ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    SizedBox(
                      width: 350,
                      child: TextFormField(
                        style: GoogleFonts.montserrat(),
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelStyle: GoogleFonts.montserrat(),
                          hintStyle: GoogleFonts.montserrat(),
                          prefixStyle: GoogleFonts.montserrat(),
                          counterStyle: GoogleFonts.montserrat(),
                          suffixStyle: GoogleFonts.montserrat(),
                          floatingLabelStyle: GoogleFonts.montserrat(),
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
                          hintText: 'Password',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          labelText: '  Password',
                        ),
                        autofocus: false,

                        maxLength: 40,
                        onChanged: (value) {
                          password = value;
                        },
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

                        obscureText: _obscureText,

                        // ),
                      ),
                    ),
                    SizedBox(height: 40.0),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            setState(() {
                              _isLoading = true;
                            });
                            UserCredential user = await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                    email: email!.trim(),
                                    password: password!.trim());

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomePage(),
                                ));
                          } on FirebaseAuthException catch (ex) {
                            if (ex.code == 'user-not-found') {
                              AnimatedSnackBar.material(
                                "No user found with this email",
                                type: AnimatedSnackBarType.error,
                                duration: Duration(seconds: 4),
                                mobileSnackBarPosition:
                                    MobileSnackBarPosition.bottom,
                              ).show(context);
                            } else if (ex.code == 'wrong-password') {
                              AnimatedSnackBar.material(
                                'Incorrect password',
                                type: AnimatedSnackBarType.error,
                                duration: Duration(seconds: 6),
                                mobileSnackBarPosition:
                                    MobileSnackBarPosition.bottom,
                              ).show(context);
                            } else if (ex.code == 'invalid-email') {
                              AnimatedSnackBar.material(
                                'Invalid email address',
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
                          backgroundColor: Color(0xFF19278a),
                          padding: EdgeInsets.all(16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Text(
                          'Sign in',
                          style: GoogleFonts.montserratAlternates(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                        child: _isLoading ? CircularProgressIndicator() : null),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "don't have an account",
                          style: GoogleFonts.montserrat(color: Colors.grey),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(PageRouteBuilder(
                                transitionDuration: Duration.zero,
                                pageBuilder: (context, animation, secondary) =>
                                    RegisterScreen()));
                          },
                          child: Text(
                            "Register now",
                            style: GoogleFonts.montserrat(
                                fontSize: 20,
                                color: Color(0xffa2061b),
                                fontWeight: FontWeight.w600),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
