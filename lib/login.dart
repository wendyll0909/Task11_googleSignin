import 'package:flutter/material.dart';
import 'package:notes_firebase/auth_service.dart';
import 'home_page.dart';
import 'register.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passCtrl,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),

            ElevatedButton(
  child: Text("Login"),
  onPressed: () async {
    final user = await auth.loginWithEmail(emailCtrl.text, passCtrl.text);

    if (user != null && user.emailVerified) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } else if (user != null && !user.emailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please verify your email first.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed. Check email/password.")),
      );
    }
  },
),

            OutlinedButton(
  child: Text("Login with Google"),
  onPressed: () async {
    final user = await auth.signInWithGoogle();

    if (user != null) {
      // Successfully logged in → go to HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } else {
      // User canceled or error → show message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In canceled or failed")),
      );
    }
  },
),

            TextButton(
              child: Text("Create an account"),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RegisterPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
