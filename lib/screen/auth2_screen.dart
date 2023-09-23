import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:test1/screen/lupa_password.dart';
import 'package:test1/screen/utils.dart';
import '../main.dart';
import '../util/constants.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController2 = TextEditingController();
  final passwordController2 = TextEditingController();
  final usernameController = TextEditingController();

  bool _halamanDaftar = false;

  late AnimationController _animationController;
  late Animation<double> _animationTextRotate;

  void setUpAnimation() {
    _animationController =
        AnimationController(vsync: this, duration: defaultDuration);

    _animationTextRotate =
        Tween<double>(begin: 0, end: 90).animate(_animationController);
  }

  void updateView() {
    setState(() {
      _halamanDaftar = !_halamanDaftar;
    });
    _halamanDaftar
        ? _animationController.forward()
        : _animationController.reverse();
  }

  @override
  void initState() {
    setUpAnimation();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: AnimatedBuilder(
            animation: _animationController,
            builder: (context, _) {
              return Stack(
                children: [
                  //login
                  AnimatedPositioned(
                    duration: defaultDuration,
                    width: size.width * 0.88,
                    height: size.height,
                    left: _halamanDaftar ? -size.width * 0.76 : 0,
                    child: Container(
                        color: loginBg,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.13),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Spacer(),
                              Container(
                                color: Colors.white,
                                child: TextField(
                                  controller: emailController,
                                  cursorColor: Colors.black,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    contentPadding:
                                        EdgeInsets.all(size.width * 0.025),
                                  ),
                                ),
                              ),
                              SizedBox(height: size.height * 0.015),
                              Container(
                                color: Colors.white,
                                child: TextField(
                                  controller: passwordController,
                                  cursorColor: Colors.black,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    contentPadding:
                                        EdgeInsets.all(size.width * 0.025),
                                  ),
                                  obscureText: true,
                                ),
                              ),
                              SizedBox(height: size.width * 0.02),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return const LupaPasswordScreen();
                                      }));
                                    },
                                    child: const Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            color: Colors
                                                .black, // Warna bayangan teks hitam
                                            offset: Offset(
                                                2, 2), // Arah bayangan (x, y)
                                            blurRadius:
                                                3, // Intensitas bayangan
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(flex: 2),
                            ],
                          ),
                        )),
                  ), //daftar
                  AnimatedPositioned(
                      duration: defaultDuration,
                      height: size.height,
                      width: size.width * 0.88,
                      left: _halamanDaftar
                          ? size.width * 0.12
                          : size.width * 0.88,
                      child: Container(
                        color: signupBg,
                        child: Form(
                          key: formKey,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.13),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Spacer(),
                                  SizedBox(height: size.height * 0.1),
                                  Container(
                                    color: Colors.white,
                                    child: TextFormField(
                                      controller: usernameController,
                                      cursorColor: Colors.black,
                                      textInputAction: TextInputAction.next,
                                      decoration: InputDecoration(
                                          labelText: 'Username',
                                          contentPadding: EdgeInsets.all(
                                              size.width * 0.025)),
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      validator: (value) =>
                                          value != null && value.isEmpty
                                              ? 'Username Harus diisi'
                                              : null,
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.015),
                                  Container(
                                    color: Colors.white,
                                    child: TextFormField(
                                      controller: emailController2,
                                      cursorColor: Colors.black,
                                      textInputAction: TextInputAction.next,
                                      decoration: InputDecoration(
                                          labelText: 'Email',
                                          contentPadding: EdgeInsets.all(
                                              size.width * 0.025)),
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      validator: (email) => email != null &&
                                              !EmailValidator.validate(email)
                                          ? 'Masukan Email yang valid'
                                          : null,
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.015),
                                  Container(
                                    color: Colors.white,
                                    child: TextFormField(
                                      controller: passwordController2,
                                      cursorColor: Colors.black,
                                      textInputAction: TextInputAction.next,
                                      decoration: InputDecoration(
                                          labelText: 'Password',
                                          contentPadding: EdgeInsets.all(
                                              size.width * 0.025)),
                                      obscureText: true,
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      validator: (value) =>
                                          value != null && value.length < 6
                                              ? 'Password minimal 6 karakter'
                                              : null,
                                    ),
                                  ),
                                  const Spacer(flex: 2)
                                ]),
                          ),
                        ),
                      )),
                  AnimatedPositioned(
                    duration: defaultDuration,
                    top: size.height * 0.1,
                    left: 0,
                    right:
                        _halamanDaftar ? -size.width * 0.06 : size.width * 0.06,
                    child: CircleAvatar(
                      backgroundColor: Colors.white60,
                      radius: 35,
                      child: AnimatedSwitcher(
                        duration: defaultDuration,
                        child: Padding(
                          padding: EdgeInsets.all(size.width * 0.02),
                          child: SvgPicture.asset("lib/icons/logoKA.svg"),
                        ),
                      ),
                    ),
                  ),

                  //masuk text
                  AnimatedPositioned(
                      duration: defaultDuration,
                      bottom: _halamanDaftar
                          ? size.height / 2 - 80
                          : size.height * 0.4,
                      left: _halamanDaftar ? 0 : size.width * 0.44 - 105,
                      child: AnimatedDefaultTextStyle(
                        duration: defaultDuration,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: _halamanDaftar
                              ? size.width * 0.055
                              : size.width * 0.065,
                          fontWeight: FontWeight.bold,
                          color: _halamanDaftar ? Colors.white : Colors.white,
                        ),
                        child: Transform.rotate(
                          angle: -_animationTextRotate.value * pi / 180,
                          alignment: Alignment.topLeft,
                          child: InkWell(
                            onTap: () {
                              if (_halamanDaftar) {
                                updateView();
                              } else {
                                signIn();
                              }
                            },
                            child: Container(
                              decoration: _halamanDaftar
                                  ? const BoxDecoration()
                                  : BoxDecoration(
                                      border: Border.all(
                                          width: size.width * 0.005,
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255)),
                                      color: const Color(0xff203E58),
                                      borderRadius: BorderRadius.circular(50),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: const Offset(0,
                                              3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: defaultPadding * 0.75),
                              width: size.width * 0.6,
                              child: Text(
                                'Masuk'.toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )),

                  Positioned(
                    right: size.width * 0.44,
                    width: size.width,
                    height: size.height * 0.7,
                    bottom: !_halamanDaftar
                        ? size.height * 0.9
                        : size.height * 0.12,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity! > 0) {
                          updateView();
                        }
                      },
                      child: const Icon(
                        Icons.swipe_right,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  //daftar text
                  AnimatedPositioned(
                      duration: defaultDuration,
                      bottom: !_halamanDaftar
                          ? size.height / 2 - 80
                          : size.height * 0.3,
                      right: _halamanDaftar ? size.width * 0.44 - 105 : 0,
                      child: AnimatedDefaultTextStyle(
                        duration: defaultDuration,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: !_halamanDaftar
                              ? size.width * 0.055
                              : size.width * 0.065,
                          fontWeight: FontWeight.bold,
                          color: !_halamanDaftar ? Colors.white : Colors.white,
                        ),
                        child: Transform.rotate(
                          angle: (90 - _animationTextRotate.value) * pi / 180,
                          alignment: Alignment.topRight,
                          child: InkWell(
                            onTap: () {
                              if (_halamanDaftar) {
                                signUp();
                              } else {
                                updateView();
                              }
                            },
                            child: Container(
                              decoration: !_halamanDaftar
                                  ? const BoxDecoration()
                                  : BoxDecoration(
                                      border: Border.all(
                                          width: size.width * 0.005,
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255)),
                                      color: const Color(0xFF00C470),
                                      borderRadius: BorderRadius.circular(50),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: const Offset(0,
                                              3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: defaultPadding * 0.75),
                              width: size.width * 0.6,
                              child: Text(
                                'Daftar'.toUpperCase(),
                              ),
                            ),
                          ),
                        ),
                      )),
                  Positioned(
                    left: size.width * 0.44,
                    width: size.width,
                    height: size.height * 0.7,
                    bottom:
                        _halamanDaftar ? size.height * 0.9 : size.height * 0.12,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity! < 0) {
                          updateView();
                        }
                      },
                      child: const Icon(
                        Icons.swipe_left,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Positioned(
                  //   left: size.width * 0.44,
                  //   width: size.width,
                  //   height: size.height * 0.5,
                  //   bottom:
                  //       _halamanDaftar ? size.height * 0.9 : size.height * 0.12,
                  //   child: GestureDetector(
                  //     behavior: HitTestBehavior.translucent,
                  //     onHorizontalDragEnd: (details) {
                  //       if (details.primaryVelocity! < 0) {
                  //         updateView();
                  //       }
                  //     },
                  //     child: SizedBox(
                  //       width: 150,
                  //       height: 150,
                  //       child: const Icon(
                  //         Icons.arrow_forward,
                  //         color: Colors.white,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              );
            }));
  }

  Future signIn() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      // print(e);

      Utils.showSnackBar(e.message);
    }
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  Future<void> signUp() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    final username = usernameController.text.trim();
    final email = emailController2.text.trim();
    final password = passwordController2.text.trim();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final authResult =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(authResult.user!.uid)
          .set({
        'email': email,
        'username': username,
        'userId': authResult.user!.uid,
      });
    } on FirebaseAuthException catch (e) {
      // print(e);
      Utils.showSnackBar(e.message);
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}
