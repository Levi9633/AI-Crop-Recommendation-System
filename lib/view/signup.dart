import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';  // <-- Added
import '../utils/const.dart';
import '../db/db.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  bool _isLoading = false;
  bool _signupSuccess = false;

  String? _message;
  Color _messageColor = Colors.red;

  // Secure storage instance
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> _handleSignUp() async {
    setState(() {
      _message = null;
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final conn = await DBService.connect();

      if (conn == null) {
        setState(() {
          _message = "Database connection failed. Please try again.";
          _messageColor = Colors.red;
          _isLoading = false;
        });
        return;
      }

      final res = await conn.execute(
        '''
        INSERT INTO users (first_name, last_name, email, password)
        VALUES (:fn, :ln, :em, :pw)
        ''',
        {
          'fn': _firstName.text.trim(),
          'ln': _lastName.text.trim(),
          'em': _email.text.trim(),
          'pw': _password.text, // TODO: hash passwords in production!
        },
      );

      await conn.close();

      // Save email & password securely for auto-login
      await _secureStorage.write(key: 'email', value: _email.text.trim());
      await _secureStorage.write(key: 'password', value: _password.text);

      setState(() {
        _signupSuccess = true;
        _message = "Signup successful! Redirecting...";
        _messageColor = Colors.green;
        _isLoading = false;
      });

      await Future.delayed(const Duration(seconds: 3));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _message = "Signup failed: ${e.toString()}";
        _messageColor = Colors.red;
        _isLoading = false;
      });
    }
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: navbar, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _textField(String label, TextEditingController ctrl,
      {TextInputType type = TextInputType.text, bool obscure = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      obscureText: obscure,
      decoration: _inputDecoration(label),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Enter $label';
        if (label == "Email" &&
            !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
          return 'Enter a valid Email';
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: heading,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Sign up to get started!",
                  style: TextStyle(
                    fontSize: 16,
                    color: subheading,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (_signupSuccess)
                  Column(
                    children: [
                      Icon(Icons.check_circle_outline,
                          color: Colors.green, size: 150),
                      const SizedBox(height: 20),
                      Text(
                        _message ?? "Signup Successful! Redirecting...",
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                else
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _textField("First Name", _firstName),
                        const SizedBox(height: 16),
                        _textField("Last Name", _lastName),
                        const SizedBox(height: 16),
                        _textField("Email", _email,
                            type: TextInputType.emailAddress),
                        const SizedBox(height: 16),
                        _textField("Password", _password, obscure: true),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirm,
                          obscureText: true,
                          decoration: _inputDecoration("Confirm Password"),
                          validator: (v) =>
                          v != _password.text ? "Passwords don't match" : null,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSignUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: navbar,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              elevation: 5,
                              shadowColor: navbar.withOpacity(0.4),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                                : Text(
                              "Sign Up",
                              style: TextStyle(
                                  color: navbar_text,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_message != null)
                          Text(
                            _message!,
                            style: TextStyle(
                                color: _messageColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Already have an account? Login",
                    style: TextStyle(
                      color: navbar,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
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
