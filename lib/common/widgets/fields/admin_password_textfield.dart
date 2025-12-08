// admin_password_textfield.dart

import 'package:flutter/material.dart';

class AdminPassword extends StatefulWidget {
  final controller;
  final String hintText;
  final bool obscureText;

  AdminPassword({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  State<AdminPassword> createState() => _AdminPasswordState();
}

class _AdminPasswordState extends State<AdminPassword> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: TextField(
        controller: widget.controller,
        obscureText: _obscureText,
        decoration: InputDecoration(
          hintText: widget.hintText,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Theme.of(context).dividerTheme.color ??
                    Colors.grey.shade400),
          ),
          fillColor: Theme.of(context).cardTheme.color == Colors.white
              ? Colors.white
              : Theme.of(context).colorScheme.surface,
          filled: true,
        ),
      ),
    );
  }
}
