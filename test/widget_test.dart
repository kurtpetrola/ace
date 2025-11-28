// widget_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ace/main.dart';
import 'package:ace/features/auth/widgets/selection_page.dart';
import 'package:ace/features/student_dashboard/presentation/homescreen_page.dart';

void main() {
  testWidgets('Renders SelectionPage when user is logged out',
      (WidgetTester tester) async {
    // 1. Wrap MyApp with ProviderScope to enable Riverpod state for the test
    // 2. Pass the required 'userLoggedIn: false' to show the SelectionPage
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(userLoggedIn: false),
      ),
    );

    // Trigger a frame rebuild if necessary (not always needed for initial build)
    await tester.pumpAndSettle();

    // Instead of verifying a counter, verify an element specific to the SelectionPage.
    // Based on your SelectionPage code, it contains the text 'Academia Classroom Explorer'.
    expect(find.byType(SelectionPage), findsOneWidget);
    expect(find.text('Academia Classroom Explorer'), findsOneWidget);
    expect(find.byType(HomeScreenPage), findsNothing);
  });

  testWidgets('Renders HomeScreenPage when user is logged in',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(userLoggedIn: true), // Pass true to show HomeScreenPage
      ),
    );

    await tester.pumpAndSettle();

    // --- Verification for logged-in state ---
    expect(find.byType(HomeScreenPage), findsOneWidget);
    expect(find.byType(SelectionPage), findsNothing);
  });
}
