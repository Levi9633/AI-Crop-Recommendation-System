import 'package:flutter/material.dart';
import '../utils/const.dart';
import '../db/db.dart';

class UpdateContactInfoPage extends StatefulWidget {
  final int userId;
  const UpdateContactInfoPage({super.key, required this.userId});

  @override
  State<UpdateContactInfoPage> createState() => _UpdateContactInfoPageState();
}

class _UpdateContactInfoPageState extends State<UpdateContactInfoPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _stateController;
  late TextEditingController _districtController;
  late TextEditingController _placeController;

  bool _loading = false;
  bool _fetchingData = true;
  bool _updateSuccess = false;

  late AnimationController _successAnimationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _stateController = TextEditingController();
    _districtController = TextEditingController();
    _placeController = TextEditingController();
    _fetchUserData();

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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _placeController.dispose();
    _successAnimationController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      final conn = await DBService.connect();

      final result = await conn.execute(
        "SELECT first_name, last_name, state, district, place FROM users WHERE id = :id",
        {"id": widget.userId},
      );

      if (result.rows.isNotEmpty) {
        final row = result.rows.first;
        _firstNameController.text = row.colAt(0) ?? '';
        _lastNameController.text = row.colAt(1) ?? '';
        _stateController.text = row.colAt(2) ?? '';
        _districtController.text = row.colAt(3) ?? '';
        _placeController.text = row.colAt(4) ?? '';
      }

      await conn.close();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading user data: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _fetchingData = false);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final conn = await DBService.connect();

      await conn.execute(
        '''UPDATE users
           SET first_name = :first_name,
               last_name = :last_name,
               state = :state,
               district = :district,
               place = :place,
               last_updated = CURRENT_TIMESTAMP
           WHERE id = :id''',
        {
          "first_name": _firstNameController.text.trim(),
          "last_name": _lastNameController.text.trim(),
          "state": _stateController.text.trim(),
          "district": _districtController.text.trim(),
          "place": _placeController.text.trim(),
          "id": widget.userId,
        },
      );

      await conn.close();

      if (mounted) {
        setState(() => _updateSuccess = true);
        _successAnimationController.forward();

        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: gaugemeter.withOpacity(0.1),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: _fetchingData
            ? const Center(child: CircularProgressIndicator())
            : Stack(
          children: [
            if (_updateSuccess)
              Center(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 100, color: Colors.green),
                      const SizedBox(height: 16),
                      const Text(
                        "Contact Info Updated!",
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
                              Icon(Icons.person_pin_circle, size: 60, color: navbar),
                              const SizedBox(height: 8),
                              Text(
                                "Update Contact Info",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: heading,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Keep your contact details up to date.",
                                style: TextStyle(color: subheading),
                              ),
                              const SizedBox(height: 30),

                              _buildTextField(_firstNameController, "First Name"),
                              _buildTextField(_lastNameController, "Last Name"),
                              _buildTextField(_stateController, "State"),
                              _buildTextField(_districtController, "District"),
                              _buildTextField(_placeController, "Place"),
                              const SizedBox(height: 24),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: navbar,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
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
                                    "Save Changes",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
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
}
