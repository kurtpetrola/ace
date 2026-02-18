// main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ace/features/auth/widgets/selection_page.dart';
import 'package:ace/features/auth/wrapper_screen.dart';
import 'package:ace/services/fcm_service.dart';
import 'package:ace/core/theme/theme_provider.dart';
import 'package:ace/core/theme/theme_data.dart';
import 'package:ace/models/classroom.dart';
import 'package:ace/services/hive_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Firebase FIRST and synchronously
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 1.5. Set up FCM background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // 2. Initialize Hive second
  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter(ClassroomAdapter());

  // 3. Open Hive boxes
  final loginBox = await Hive.openBox('_loginbox');
  await Hive.openBox(HiveConstants.kClassBox);
  await Hive.openBox(HiveConstants.kGradesBox);
  await Hive.openBox(HiveConstants.kStudentStatsBox);

  final bool userLoggedIn = loginBox.get('isLoggedIn') ?? false;

  // 4. Wrap the app with ProviderScope
  runApp(
    ProviderScope(
      // This enables Riverpod for the whole app
      child: MyApp(userLoggedIn: userLoggedIn),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final bool userLoggedIn;

  const MyApp({super.key, required this.userLoggedIn}); // Pass login state

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the theme mode provider
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Apply theme based on theme mode
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      // Use the injected login state to determine the home screen
      home: userLoggedIn ? const WrapperScreen() : const SelectionPage(),
    );
  }
}
