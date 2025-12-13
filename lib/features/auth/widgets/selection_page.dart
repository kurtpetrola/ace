// lib/features/auth/widgets/selection_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ace/common/widgets/buttons/admin_button.dart';
import 'package:ace/common/widgets/buttons/register_button.dart';
import 'package:ace/common/widgets/buttons/student_button.dart';
import 'package:ace/common/widgets/buttons/teacher_button.dart';

// Change StatelessWidget to ConsumerWidget
class SelectionPage extends ConsumerWidget {
  const SelectionPage({Key? key}) : super(key: key);

  // The build method now receives WidgetRef ref
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the current theme brightness to determine text color
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDarkMode ? ColorPalette.secondary : ColorPalette.accentBlack;

    return Scaffold(
      // Allow the theme to determine the background color
      // backgroundColor: ColorPalette.accentBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 100),
                // Replaced SelectionHeader with direct image asset
                Container(
                  width: 250,
                  height: 220,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/aceicon.png'),
                    ),
                  ),
                ),
                Text(
                  'Academia Classroom Explorer',
                  style: TextStyle(
                      color: textColor,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w900,
                      fontSize: 25),
                ),
                const SizedBox(height: 50),
                SizedBox(
                  width: 320,
                  child: Column(
                    children: [
                      StudentButton(onTap: null),
                      const SizedBox(height: 10),
                      AdminButton(onTap: null),
                      const SizedBox(height: 10),
                      TeacherButton(onTap: null),
                      const SizedBox(height: 20),
                      // Visual separation for Register
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: isDarkMode
                                  ? ColorPalette.lightGray
                                  : ColorPalette.darkGrey,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "OR",
                              style: TextStyle(
                                  color: isDarkMode
                                      ? ColorPalette.lightGray
                                      : ColorPalette.darkGrey,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: isDarkMode
                                  ? ColorPalette.lightGray
                                  : ColorPalette.darkGrey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      RegisterButton(onTap: null),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
