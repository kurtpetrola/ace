import 'package:flutter/material.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ace/features/auth/presentation/registration_page.dart';

class RegisterButton extends StatelessWidget {
  final Function()? onTap;

  const RegisterButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => RegisterPage(),
        ));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorPalette.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
      ),
      child: const Text(
        "REGISTER",
        style: TextStyle(
          color: ColorPalette.accentBlack,
          fontFamily: 'Lato',
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
    );
  }
}
