import 'package:flutter/material.dart';
import 'package:ai_plant_app/utils/const.dart';
import 'package:ai_plant_app/l10n/app_localizations.dart';
import 'package:ai_plant_app/view/profile.dart';
import 'package:ai_plant_app/main.dart';  // Import to call setLocale

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Center(child: Text("Home Page", style: TextStyle(fontSize: 24, color: heading))),
    Center(child: Text("Policies Page", style: TextStyle(fontSize: 24, color: heading))),
    Center(child: Text("AI Bot Page", style: TextStyle(fontSize: 24, color: heading))),
    Center(child: Text("News Page", style: TextStyle(fontSize: 24, color: heading))),
    const ProfilePage(),
  ];

  // List of supported languages for dropdown
  final Map<String, String> _languages = {
    'en': 'English',
    'hi': 'Hindi',
    'kn': 'Kannada',
    'pa': 'Punjabi',
  };

  String? _selectedLanguageCode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize selected language from current locale on build
    _selectedLanguageCode = Localizations.localeOf(context).languageCode;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _changeLanguage(String? languageCode) {
    if (languageCode != null && languageCode != _selectedLanguageCode) {
      setState(() {
        _selectedLanguageCode = languageCode;
      });
      MyApp.setLocale(context, Locale(languageCode));
    }
  }

  Widget _buildNavItem(IconData icon, String label, int index, {bool isCenter = false}) {
    final bool isSelected = _selectedIndex == index;

    Widget child = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: isCenter ? 30 : 28,
          color: isCenter ? navbar_text : (isSelected ? navbar : subheading),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: isCenter ? Colors.white : (isSelected ? navbar : subheading),
            fontSize: isCenter ? 10 : 11,
          ),
        ),
      ],
    );

    if (isCenter) {
      child = Container(
        height: 50,
        decoration: BoxDecoration(
          color: navbar,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: navbar.withOpacity(0.6),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: Center(child: child),
      );
    }

    return Expanded(
      flex: isCenter ? 2 : 1,
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 70,
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 0),
        decoration: BoxDecoration(
          color: gaugemeter,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(Icons.home_outlined, loc.home, 0),
            _buildNavItem(Icons.policy_outlined, loc.policies, 1),
            _buildNavItem(Icons.smart_toy_outlined, loc.aiBot, 2, isCenter: true),
            _buildNavItem(Icons.newspaper_outlined, loc.news, 3),
            _buildNavItem(Icons.person_outline, loc.profile, 4),
          ],
        ),
      ),
    );
  }
}
