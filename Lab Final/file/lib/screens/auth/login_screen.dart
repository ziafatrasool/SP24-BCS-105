import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import '../../core/constants/images.dart';
import '../../widgets/loading_animation.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/page_background.dart';
import '../home/home_screen.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isHuman = false;
  bool rememberMe = false;
  String? savedEmail;
  String? savedPassword;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('saved_email');
    final password = prefs.getString('saved_password');
    if (email != null && password != null) {
      setState(() {
        savedEmail = email;
        savedPassword = password;
        rememberMe = true;
        emailController.text = email;
        passwordController.text = password;
      });
    }
  }

  Future<void> _saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_email', email);
    await prefs.setString('saved_password', password);
  }

  Future<void> _clearSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_email');
    await prefs.remove('saved_password');
    setState(() {
      savedEmail = null;
      savedPassword = null;
      rememberMe = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
        body: PageBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(AppImages.logo, height: 52),
                    const SizedBox(width: 8),
                  ],
                ),
                const SizedBox(height: 30),
                const Text(
                  "Welcome to SkillVerse Pro",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                if (savedEmail != null && savedPassword != null)
                  Card(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white10
                        : Colors.grey.shade200,
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      title: Text(savedEmail!),
                      subtitle: const Text('Saved login available'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: _clearSavedCredentials,
                        tooltip: 'Clear saved login',
                      ),
                      onTap: () {
                        setState(() {
                          emailController.text = savedEmail!;
                          passwordController.text = savedPassword!;
                        });
                      },
                    ),
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
                  value: rememberMe,
                  onChanged: (value) {
                    setState(() {
                      rememberMe = value ?? false;
                    });
                  },
                  title: const Text('Remember me'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 10),
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
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () async {
                            final email = emailController.text.trim();
                            final password = passwordController.text.trim();

                            if (email.isEmpty || password.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Please enter email and password'),
                                ),
                              );
                              return;
                            }

                            if (!isHuman) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please confirm you are human'),
                                ),
                              );
                              return;
                            }

                            final signedIn = await authProvider.signIn(
                              email: email,
                              password: password,
                            );

                            if (signedIn) {
                              if (rememberMe) {
                                await _saveCredentials(email, password);
                              } else {
                                await _clearSavedCredentials();
                              }
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HomeScreen(),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(authProvider.authError ??
                                      'Login failed. Check credentials.'),
                                ),
                              );
                            }
                          },
                    child: authProvider.isLoading
                        ? const LoadingAnimation(size: 24)
                        : const Text("Login"),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text("Forgot?",
                            style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignupScreen()),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blue.withOpacity(0.2),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text("Sign Up",
                            style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
