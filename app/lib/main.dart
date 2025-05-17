import 'package:flutter/material.dart';
import 'package:spotfix/screens/home_screen.dart';
import 'package:spotfix/screens/profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spotfix/screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'your supabase url,
    anonKey:
       'your supabase anon key
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
