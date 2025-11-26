// class_work_tab.dart

import 'package:flutter/material.dart';
import 'package:ace/core/constants/app_colors.dart';

class Classwork extends StatefulWidget {
  const Classwork({Key? key}) : super(key: key);

  @override
  State<Classwork> createState() => _ClassworkState();
}

class _ClassworkState extends State<Classwork> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.accentBlack,
    );
  }
}
