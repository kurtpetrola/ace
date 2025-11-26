import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ace/features/auth/widgets/selection_page.dart';
import 'package:ace/features/dashboard/presentation/homescreen_page.dart';

bool? userLoggedIn;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  var _loginbox = await Hive.openBox("_loginbox");
  userLoggedIn = await _loginbox.get("isLoggedIn");
  userLoggedIn ??= false;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: userLoggedIn! ? const HomeScreenPage() : SelectionPage(),
    );
  }
}
