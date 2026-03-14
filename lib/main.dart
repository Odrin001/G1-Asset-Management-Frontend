import 'package:flutter/material.dart';
import 'screens/register_screen.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white
        )
      ),
    );
  }
}