import 'package:flutter/material.dart';
import 'screens/home/home_screen.dart';
import 'theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://oalkbttbbeknsiqknhhi.supabase.co',
    publishableKey: 'sb_publishable_bASizUTG8Fmqmcl1cYm3dA_FBnk5OqN',
  );
  runApp(const EconLabApp());
}

class EconLabApp extends StatelessWidget {
  const EconLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EconLab Lite',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}