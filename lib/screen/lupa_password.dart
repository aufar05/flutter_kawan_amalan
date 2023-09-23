import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LupaPasswordScreen extends StatefulWidget {
  const LupaPasswordScreen({Key? key}) : super(key: key);

  @override
  State<LupaPasswordScreen> createState() => _LupaPasswordScreenState();
}

class _LupaPasswordScreenState extends State<LupaPasswordScreen> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              content: Text(
                  'Link ganti password sudah dikirim silahkan cek email anda'),
            );
          });
    } on FirebaseAuthException catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              'Masukan Email untuk mendapat link reset password',
              style: TextStyle(fontSize: 18),
            ),
          ),
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: TextField(
                controller: emailController,
                cursorColor: Colors.black,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(),
                  labelText: 'Email',
                  contentPadding: EdgeInsets.all(10),
                  fillColor: Color.fromARGB(255, 232, 230, 230),
                ),
              ),
            ),
          ),
          MaterialButton(
            onPressed: passwordReset,
            color: Colors.blue,
            child: const Text(
              'Reset Password',
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
