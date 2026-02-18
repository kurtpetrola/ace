// lib/common/widgets/buttons/admin_button.dart

import 'package:flutter/material.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ace/core/constants/app_strings.dart';
import 'package:ace/features/auth/presentation/login/admin_login_page.dart';

class AdminButton extends StatelessWidget {
  final Function()? onTap;

  const AdminButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => const AdminLoginPage(),
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
        AceStrings.adminBtn,
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
