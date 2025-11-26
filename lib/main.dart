// main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ace/features/auth/widgets/selection_page.dart';
import 'package:ace/features/dashboard/presentation/homescreen_page.dart';

// Moved userLoggedIn initialization logic into main()

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Firebase and Hive concurrently
  await Future.wait([
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ),
    Hive.initFlutter(),
  ]);

  // 2. Open Hive box and check login status
  final loginBox = await Hive.openBox("_loginbox");
  final bool userLoggedIn = loginBox.get("isLoggedIn") ?? false;

  // 3. Wrap the app with ProviderScope
  runApp(
    ProviderScope(
      // This enables Riverpod for the whole app
      child: MyApp(userLoggedIn: userLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool userLoggedIn;

  const MyApp({super.key, required this.userLoggedIn}); // Pass login state

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Use the injected login state to determine the home screen
      home: userLoggedIn ? const HomeScreenPage() : const SelectionPage(),
    );
  }
}
