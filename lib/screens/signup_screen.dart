import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../widgets/app_toast.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService auth = AuthService();

  bool loading = false;

  Future<void> signup() async {
    setState(() {
      loading = true;
    });

    try {
      await auth.signUp(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context);
      return;
    } on FirebaseAuthException catch (e) {
      String message = "Something went wrong. Try again.";

      if (e.code == 'email-already-in-use') {
        message = "That email is already registered.";
      } else if (e.code == 'weak-password') {
        message = "Password is too weak.";
      } else if (e.code == 'invalid-email') {
        message = "That email address is invalid.";
      }

      if (mounted) showErrorToast(context, message);
    } catch (e) {
      if (mounted) {
        showErrorToast(context, "Something went wrong. Try again.");
      }
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "CREATE ACCOUNT",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Start tracking your fitness journey.",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: emailController,
                        style: const TextStyle(
                          color: Color(0xFFE0E0E0),
                        ),
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: const Icon(
                            Icons.email,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF2A2A2A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: passwordController,
                        style: const TextStyle(
                          color: Color(0xFFE0E0E0),
                        ),
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(
                            Icons.lock,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF2A2A2A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: loading ? null : signup,
                          child: loading
                              ? const CircularProgressIndicator()
                              : const Text(
                                  "CREATE ACCOUNT",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Already have an account? Login",
                    style: TextStyle(
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}