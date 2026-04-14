import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const CricfyTVApp());
}

class CricfyTVApp extends StatelessWidget {
  const CricfyTVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BoundaryCric',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080808),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1AFFD5),
          secondary: Color(0xFF3B82F6),
          surface: Color(0xFF121214),
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
