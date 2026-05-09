import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:snapbooth_mobile/providers/photobooth_provider.dart';
import 'package:snapbooth_mobile/screens/home_screen.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Supabase with safety for UI-only testing
    try {
      await Supabase.initialize(
        url: 'https://sdvgbmoahxkrwwwpzrsp.supabase.co',
        anonKey: 'sb_publishable_USLNuaE5N03UhIZ-JDIrCw_zrlvAnvV',
      );
    } catch (e) {
      debugPrint('Supabase initialization failed: $e. App will run in UI-only mode.');
    }

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PhotoboothProvider()),
        ],
        child: const SnapBoothApp(),
      ),
    );
  }, (error, stack) {
    debugPrint('Global Error: $error');
    debugPrint('Stack Trace: $stack');
  });
}

class SnapBoothApp extends StatelessWidget {
  const SnapBoothApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnapBooth',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF741E31),
          primary: const Color(0xFF741E31),
          secondary: const Color(0xFFF6BAD6),
          surface: const Color(0xFFF1D3DF),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF420D19),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF741E31),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
