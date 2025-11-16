import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:map_assessment/src/presentation/screens/map_screen.dart';
import 'package:map_assessment/src/services/map_service.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MapService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MapGo',
        darkTheme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: GoogleFonts.raleway().fontFamily,
        ),
        themeMode: ThemeMode.dark,
        home: const MapScreen(),
      ),
    );
  }
}
