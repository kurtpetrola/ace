// selection_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ace/common/widgets/buttons/admin_button.dart';
import 'package:ace/common/widgets/buttons/register_button.dart';
import 'package:ace/common/widgets/buttons/student_button.dart';
import 'package:ace/features/auth/widgets/selection_header.dart';

// Change StatelessWidget to ConsumerWidget
class SelectionPage extends ConsumerWidget {
  const SelectionPage({Key? key}) : super(key: key);

  // The build method now receives WidgetRef ref
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      backgroundColor: ColorPalette.accentBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 100),
                SelectionHeader(),
                Text(
                  'Academia Classroom Explorer',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w900,
                      fontSize: 25),
                ),
                SizedBox(height: 50),
                StudentButton(onTap: null),
                SizedBox(height: 10),
                AdminButton(onTap: null),
                SizedBox(height: 10),
                RegisterButton(onTap: null),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
