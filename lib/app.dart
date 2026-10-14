import 'package:flutter/material.dart';

import 'core/theme/seera_colors.dart';
import 'navigator.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Seera.co_',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: SeeraColors.pinkPop, brightness: Brightness.light),
        scaffoldBackgroundColor: SeeraColors.pinkMist,
        useMaterial3: true,
      ),
      routerConfig: nav.routerConfig,
    );
  }
}
