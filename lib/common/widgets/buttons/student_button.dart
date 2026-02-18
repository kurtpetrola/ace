// lib/common/widgets/buttons/student_button.dart

import 'package:flutter/material.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ace/core/constants/app_strings.dart';
import 'package:ace/features/auth/presentation/login/student_login_page.dart';

class StudentButton extends StatelessWidget {
  final Function()? onTap;

  const StudentButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => const StudentLoginPage(),
        ));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isDarkMode ? ColorPalette.secondary : ColorPalette.accentBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
        minimumSize: const Size(double.infinity, 50),
      ),
      child: Text(
        AceStrings.studentBtn,
        style: TextStyle(
          color: isDarkMode ? ColorPalette.accentBlack : ColorPalette.secondary,
          fontFamily: 'Lato',
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
    );
  }
}
