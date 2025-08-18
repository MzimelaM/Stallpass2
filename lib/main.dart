import 'package:flutter/material.dart';
import 'LoginPage.dart';
import 'AdminLoginPage.dart';
import 'HomePage.dart';
import 'NotificationPage.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/adminLogin': (context) => const AdminLoginPage(),
        '/home': (context) => const HomePage(),
        '/notifications': (context) => const NotificationPage(),
      },
    );
  }
}
