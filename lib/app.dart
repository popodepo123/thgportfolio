import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:thgportfolio/pages/portfolio_page.dart';
import 'package:thgportfolio/theme.dart';

// Enables smooth scrolling and drag-to-scroll on web
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tristan Harvey Godoy - Portfolio',
      theme: portfolioTheme,
      scrollBehavior: MyCustomScrollBehavior(),
      debugShowCheckedModeBanner: false,
      home: const PortfolioPage(),
    );
  }
}
