import 'package:edge_detection/config/app_router.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Edge Detector',
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark().copyWith(
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Colors.black,
          contentTextStyle: TextStyle(
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.teal),
          ),
        ),
      ),
      themeMode: ThemeMode.dark,
      // home: const EdgeDetector(),
      routerConfig: AppRouter().router,
    );
  }
}
