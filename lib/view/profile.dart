import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ai_plant_app/l10n/app_localizations.dart';
import '../main.dart';
import '../utils/const.dart';
import '../db/db.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _storage = const FlutterSecureStorage();
  String? userId;
  String fullName = "";

  String selectedLanguageCode = 'en';
  late Map<String, String> languageOptions;

  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    final savedUserId = await _storage.read(key: 'user_id');
    final savedLang = await _storage.read(key: 'selected_language');
    if (mounted) {
      setState(() {
        userId = savedUserId;
        selectedLanguageCode = savedLang ?? 'en';
      });
      if (savedUserId != null) _fetchUserName(int.parse(savedUserId));
      _updateLocale(Locale(selectedLanguageCode));
    }
  }

  Future<void> _fetchUserName(int id) async {
    try {
      final conn = await DBService.connect();
      final result = await conn.execute(
        "SELECT first_name, last_name FROM users WHERE id = :id",
        {'id': id},
      );
      await conn.close();
      if (result.rows.isNotEmpty) {
        final row = result.rows.first;
        setState(() {
          fullName = "${row.colByName('first_name')} ${row.colByName('last_name')}";
        });
      }
    } catch (e) {
      debugPrint('Failed to fetch user name: $e');
    }
  }

  void _updateLocale(Locale locale) {
    MyApp.setLocale(context, locale);
  }

  Future<void> _onLanguageChanged(String? newCode) async {
    if (newCode == null) return;
    setState(() => selectedLanguageCode = newCode);
    await _storage.write(key: 'selected_language', value: newCode);
    _updateLocale(Locale(newCode));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    languageOptions = {
      'en': loc.languageEnglish,
      'hi': loc.languageHindi,
      'kn': loc.languageKannada,
      'pa': loc.languagePunjabi,
    };

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 55,
                  backgroundImage: const AssetImage("assets/profile.png"),
                  backgroundColor: gaugemeter.withOpacity(0.2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                loc.welcome,
                style: TextStyle(fontSize: 26, color: heading, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                fullName.isNotEmpty ? fullName : '...',
                style: TextStyle(fontSize: 20, color: subheading, letterSpacing: 0.5),
              ),
              const SizedBox(height: 40),
              _profileOption(
                context,
                icon: Icons.contact_phone_outlined,
                title: loc.updateContactInfo,
                onTap: () {
                  if (userId != null) {
                    Navigator.pushNamed(context, '/update_profile', arguments: userId);
                  }
                },
              ),
              _profileOption(
                context,
                icon: Icons.lock_outline,
                title: 'Change Password',
                onTap: () {
                  if (userId != null) {
                    Navigator.pushNamed(context, '/change_password', arguments: userId);
                  }
                },
              ),
              _toggleTile(icon: Icons.notifications_outlined, title: loc.notifications, value: true, onChanged: (val) {}),
              const SizedBox(height: 30),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(loc.language, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: heading)),
              ),
              const SizedBox(height: 12),
              _languageDropdown(),
              const Spacer(),
              Text("v 1.0.0", style: TextStyle(color: subheading.withOpacity(0.6))),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _storage.deleteAll();
                    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navbar,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                  ),
                  child: Text(
                    loc.signOut,
                    style: TextStyle(color: navbar_text, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _languageDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: gaugemeter.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gaugemeter.withOpacity(0.4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedLanguageCode,
          dropdownColor: gaugemeter,
          icon: const Icon(Icons.language_outlined, color: navbar),
          iconSize: 28,
          style: TextStyle(color: heading, fontSize: 16, fontWeight: FontWeight.w600),
          items: languageOptions.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Row(children: [const SizedBox(width: 10), Text(entry.value)]),
            );
          }).toList(),
          onChanged: _onLanguageChanged,
          elevation: 6,
          borderRadius: BorderRadius.circular(12),
          isExpanded: true,
        ),
      ),
    );
  }

  Widget _profileOption(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero, // Fixed here
      leading: Icon(icon, color: heading),
      title: Text(title, style: TextStyle(fontSize: 16, color: heading, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: gaugemeter.withOpacity(0.1),
    );
  }

  Widget _toggleTile({required IconData icon, required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero, // Fixed here
      secondary: Icon(icon, color: heading),
      title: Text(title, style: TextStyle(fontSize: 16, color: heading, fontWeight: FontWeight.w600)),
      activeColor: navbar,
      value: value,
      onChanged: onChanged,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: gaugemeter.withOpacity(0.1),
    );
  }
}
