import 'package:flutter/material.dart';
import '../utils/const.dart';
import '../db/db.dart';

class ChangePasswordPage extends StatefulWidget {
  final int userId;

  const ChangePasswordPage({super.key, required this.userId});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _loading = false;
  String? _errorMessage;
  bool _passwordChanged = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  late AnimationController _successAnimationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _successAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _successAnimationController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _successAnimationController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final newPassword = _passwordController.text;

    try {
      final conn = await DBService.connect();

      final result = await conn.execute(
        "UPDATE users SET password = :password, last_updated = CURRENT_TIMESTAMP WHERE id = :id",
        {
          'password': newPassword,
          'id': widget.userId,
        },
      );

      await conn.close();

      if (result.affectedRows > BigInt.zero) {
        setState(() => _passwordChanged = true);
        _successAnimationController.forward();

        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.pop(context);
      } else {
        setState(() {
          _errorMessage = "Password unchanged or user not found.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: ${e.toString()}";
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Stack(
          children: [
            if (_passwordChanged)
              Center(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 100, color: Colors.green),
                      const SizedBox(height: 16),
                      const Text(
                        "Password Changed!",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              )
            else
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    
                    const SizedBox(height: 20),
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.arrow_back_ios_new, color: heading),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Back",
                                        style: TextStyle(
                                          color: heading,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Icon(Icons.lock_outline, size: 60, color: navbar),
                              const SizedBox(height: 8),
                              Text(
                                "Change Password",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: heading,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Make sure it's strong and secure.",
                                style: TextStyle(color: subheading),
                              ),
                              const SizedBox(height: 30),

                              // New Password
                              _buildPasswordField(
                                controller: _passwordController,
                                label: "New Password",
                                obscure: !_showPassword,
                                toggle: () => setState(() => _showPassword = !_showPassword),
                              ),
                              const SizedBox(height: 16),

                              // Confirm Password
                              _buildPasswordField(
                                controller: _confirmPasswordController,
                                label: "Confirm Password",
                                obscure: !_showConfirmPassword,
                                toggle: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                              ),

                              const SizedBox(height: 24),

                              if (_errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                  ),
                                ),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _updatePassword,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: navbar,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                      : const Text(
                                    "Update Password",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback toggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: toggle,
        ),
        filled: true,
        fillColor: gaugemeter.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter $label';
        if (label == "New Password" && value.length < 6) return 'Password must be at least 6 characters';
        if (label == "Confirm Password" && value != _passwordController.text) return 'Passwords do not match';
        return null;
      },
    );
  }
}
