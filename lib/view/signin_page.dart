import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/const.dart';
import '../db/db.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _message;
  Color _messageColor = Colors.red;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final savedEmail = await _secureStorage.read(key: 'email');
    final savedPassword = await _secureStorage.read(key: 'password');

    if (savedEmail != null && savedPassword != null) {
      _emailController.text = savedEmail;
      _passwordController.text = savedPassword;

      // Optional: Auto login
      _handleSignIn(autoLogin: true);
    }
  }

  Future<void> _handleSignIn({bool autoLogin = false}) async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final conn = await DBService.connect();
      if (conn != null) {
        final result = await conn.execute(
          "SELECT * FROM users WHERE email = :email AND password = :password",
          {"email": email, "password": password},
        );

        await conn.close();

        if (result.rows.isNotEmpty) {
          final user = result.rows.first.assoc();

          /// Save credentials & user ID
          await _secureStorage.write(key: 'email', value: email);
          await _secureStorage.write(key: 'password', value: password);
          await _secureStorage.write(key: 'user_id', value: user['id']);

          setState(() {
            _message = "Login successful!";
            _messageColor = Colors.green;
          });

          await Future.delayed(const Duration(milliseconds: 800));
          if (mounted) Navigator.pushNamed(context, '/home');
        } else {
          if (!autoLogin) {
            setState(() {
              _message = "Invalid email or password";
              _messageColor = Colors.red;
            });
          } else {
            setState(() {
              _message = null;
              _emailController.clear();
              _passwordController.clear();
            });
          }
        }
      } else {
        setState(() {
          _message = "Database connection failed";
          _messageColor = Colors.red;
        });
      }
    } catch (e) {
      setState(() {
        _message = "Error signing in: ${e.toString()}";
        _messageColor = Colors.red;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration({required String label, required IconData icon, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: navbar),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: const AssetImage("assets/profile1.png"),
                backgroundColor: gaugemeter,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Welcome Back",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: heading),
            ),
            const SizedBox(height: 8),
            Text(
              "Sign in to continue",
              style: TextStyle(fontSize: 16, color: subheading),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration(label: "Email", icon: Icons.email),
                      validator: (value) => value!.isEmpty ? "Enter email" : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: _inputDecoration(label: "Password", icon: Icons.lock),
                      validator: (value) => value!.isEmpty ? "Enter password" : null,
                    ),
                    const SizedBox(height: 20),
                    if (_message != null)
                      Text(
                        _message!,
                        style: TextStyle(color: _messageColor, fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: navbar,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: _isLoading ? null : _handleSignIn,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                          "Sign In",
                          style: TextStyle(
                            color: navbar_text,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account?", style: TextStyle(color: subheading)),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: Text(
                            "Sign Up",
                            style: TextStyle(color: heading, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
