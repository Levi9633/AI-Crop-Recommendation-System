import 'package:ai_plant_app/view/change_password.dart';
import 'package:ai_plant_app/view/update_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';  // <--- Add this
import 'package:ai_plant_app/l10n/app_localizations.dart';

import 'package:ai_plant_app/view/Home.dart';
import 'package:ai_plant_app/view/profile.dart';
import 'package:ai_plant_app/view/signin_page.dart';
import 'package:ai_plant_app/view/signup.dart';
import 'package:ai_plant_app/utils/const.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const String _languageCodeKey = 'language_code';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Locale _locale = const Locale('hi');

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    String? code = await _storage.read(key: _languageCodeKey);
    if (code != null && mounted) {
      setState(() {
        _locale = Locale(code);
      });
    }
  }

  void setLocale(Locale locale) async {
    setState(() {
      _locale = locale;
    });
    await _storage.write(key: _languageCodeKey, value: locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Plant App',
      theme: ThemeData(
        canvasColor: background,
        fontFamily: 'Roboto',
      ),

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('kn'),
        Locale('pa'),
      ],

      locale: _locale,

      initialRoute: '/',
      routes: {
        '/': (context) => const SignInPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == '/update_profile') {
          final args = settings.arguments;
          if (args == null || args is! String) {
            // You can return an error page if no userId found
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(title: const Text('Error')),
                body: const Center(child: Text('User ID not provided')),
              ),
            );
          }

          final userId = int.tryParse(args);
          if (userId == null) {
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(title: const Text('Error')),
                body: const Center(child: Text('Invalid User ID')),
              ),
            );
          }

          return MaterialPageRoute(
            builder: (_) => UpdateContactInfoPage(userId: userId),
          );
        }

        if (settings.name == '/change_password') {
          final args = settings.arguments;
          if (args == null || args is! String) {
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(title: const Text('Error')),
                body: const Center(child: Text('User ID not provided')),
              ),
            );
          }
          final userId = int.tryParse(args);
          if (userId == null) {
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(title: const Text('Error')),
                body: const Center(child: Text('Invalid User ID')),
              ),
            );
          }
          return MaterialPageRoute(
            builder: (_) => ChangePasswordPage(userId: userId),
          );
        }

        // Return null to fallback to other routes or show unknown page
        return null;

      },
    );
  }
}

