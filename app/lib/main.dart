import 'package:flutter/material.dart';
import 'package:spotfix/screens/home_screen.dart';
import 'package:spotfix/screens/profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spotfix/screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ydirmwelgatlcabaoqgt.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlkaXJtd2VsZ2F0bGNhYmFvcWd0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyOTQwNzksImV4cCI6MjA2Mjg3MDA3OX0.gyj4VRDSYp2QhFNqbGQucTK3MUQ7O8myggeMVQnVWuY',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpotFix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.pink,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
