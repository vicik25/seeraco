import 'package:flutter/material.dart';

import 'app.dart';
import 'data/seera_supabase.dart';

export 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SeeraSupabase.initialize();
  runApp(const MyApp());
}
