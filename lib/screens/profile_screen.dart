import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../widgets/app_toast.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService auth = AuthService();
  bool isUpgrading = false;

  void showCreateAccountDialog() {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Create Account"),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Your workouts will carry over to your new account.",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Color(0xFFE0E0E0)),
                  decoration: InputDecoration(
                    labelText: "Email",
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return "Enter a valid email";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Color(0xFFE0E0E0)),
                  decoration: InputDecoration(
                    labelText: "Password",
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("CANCEL"),
            ),
            TextButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                Navigator.pop(dialogContext);

                setState(() {
                  isUpgrading = true;
                });

                try {
                  await auth.upgradeGuestAccount(
                    emailController.text.trim(),
                    passwordController.text,
                  );

                  if (!mounted) return;

                  setState(() {
                    isUpgrading = false;
                  });

                  showSuccessToast(context, "Account created!");
                } on FirebaseAuthException catch (e) {
                  if (!mounted) return;

                  setState(() {
                    isUpgrading = false;
                  });

                  String message = "Something went wrong. Try again.";

                  if (e.code == 'email-already-in-use' ||
                      e.code == 'credential-already-in-use') {
                    message =
                        "That email is already registered. Log out and log in with it instead — your guest workouts won't carry over that way, though.";
                  } else if (e.code == 'weak-password') {
                    message = "Password is too weak.";
                  } else if (e.code == 'invalid-email') {
                    message = "That email address is invalid.";
                  }

                  showErrorToast(context, message);
                } catch (e) {
                  if (!mounted) return;

                  setState(() {
                    isUpgrading = false;
                  });

                  showErrorToast(context, "Something went wrong. Try again.");
                }
              },
              child: const Text(
                "CREATE",
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = UserService.getCachedProfile();
    final String name = profile['name'];
    final double weight = profile['weight'];

    User? user = FirebaseAuth.instance.currentUser;
    bool isGuest = user?.isAnonymous ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.green,
                    child: Icon(
                      Icons.person,
                      size: 45,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Weight: $weight lbs",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            if (isGuest)
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
                  onPressed: isUpgrading ? null : showCreateAccountDialog,
                  child: isUpgrading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "CREATE ACCOUNT",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () async {
                  await auth.logout();
                },
                child: const Text(
                  "LOGOUT",
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
    );
  }
}