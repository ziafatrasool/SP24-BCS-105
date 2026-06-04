import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/images.dart';
import '../../widgets/loading_animation.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/page_background.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isHuman = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
        appBar: AppBar(title: const Text("Create Account")),
        body: PageBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(AppImages.logo, height: 52),
                        const SizedBox(width: 12),
                        const Text(
                          'SkillVerse Pro',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Full Name"),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: "Email"),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "Password"),
                    ),
                    const SizedBox(height: 15),
                    CheckboxListTile(
                      value: isHuman,
                      onChanged: (value) {
                        setState(() {
                          isHuman = value ?? false;
                        });
                      },
                      title: const Text('I am not a robot'),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : () async {
                                final name = nameController.text.trim();
                                final email = emailController.text.trim();
                                final password = passwordController.text.trim();

                                if (name.isEmpty ||
                                    email.isEmpty ||
                                    password.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please fill all fields'),
                                    ),
                                  );
                                  return;
                                }

                                if (!isHuman) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Please confirm you are human'),
                                    ),
                                  );
                                  return;
                                }

                                final created = await authProvider.signUp(
                                  email: email,
                                  password: password,
                                  name: name,
                                );

                                if (!mounted) return;

                                if (created) {
                                  final message = authProvider.authMessage ??
                                      authProvider.authError ??
                                      'Account created successfully. Please log in.';
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(message),
                                      duration: const Duration(seconds: 5),
                                    ),
                                  );

                                  // Always navigate to login if signup succeeds
                                  Future.delayed(const Duration(seconds: 1),
                                      () {
                                    if (mounted) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const LoginScreen(),
                                        ),
                                      );
                                    }
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(authProvider.authError ??
                                          'Unable to create account. Try again.'),
                                      duration: const Duration(seconds: 5),
                                    ),
                                  );
                                }
                              },
                        child: authProvider.isLoading
                            ? const LoadingAnimation(size: 24)
                            : const Text("Register"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
