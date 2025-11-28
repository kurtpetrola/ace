// lib/features/student_dashboard/presentation/account_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'dart:convert';
import 'package:ace/models/user.dart';
import 'package:ace/common/widgets/dialogs/alertdialog.dart';
import 'package:ace/features/auth/widgets/selection_page.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  DateTime backPressedTime = DateTime.now();
  final _loginbox = Hive.box("_loginbox");
  late var fullname = _loginbox.get("User");
  String title = 'AlertDialog';
  bool tappedYes = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: ColorPalette.accentBlack,
        appBar: AppBar(
          toolbarHeight: (80),
          elevation: 0,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 30, right: 20),
              child: IconButton(
                iconSize: 40,
                onPressed: () async {
                  final action = await AlertDialogs.yesCancelDialog(
                      context,
                      'Logout this account?',
                      'You can always come back any time.');
                  if (action == DialogsAction.yes) {
                    setState(() => tappedYes = true);
                    _loginbox.put("isLoggedIn", false);
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (BuildContext context) =>
                            const SelectionPage(),
                      ),
                    );
                  } else {
                    setState(() => tappedYes = false);
                  }
                },
                icon: const Icon(Icons.exit_to_app),
                color: ColorPalette.secondary,
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(
              top: 140,
              left: 50,
              right: 50,
            ),
            // Updated FutureBuilder to expect a single User object
            child: FutureBuilder<User>(
                future: getUser(),
                builder: (context, AsyncSnapshot<User> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const <Widget>[
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              color: ColorPalette.secondary,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Loading...",
                            style: TextStyle(
                                color: ColorPalette.secondary,
                                fontFamily: 'Lato'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: ColorPalette.secondary,
                        ),
                        Text(
                          "Something went wrong",
                          style: TextStyle(
                              fontFamily: 'Lato',
                              color: ColorPalette.secondary,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Please Try again.",
                          style: TextStyle(
                            fontFamily: 'Lato',
                            color: ColorPalette.secondary,
                          ),
                        )
                      ],
                    ));
                  }

                  // Access the single User object directly
                  final user = snapshot.data!;

                  return Column(children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(55)),
                          child: const Icon(
                            Icons.person_outline_rounded,
                            size: 125,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 86, vertical: 6),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'Personal Information',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: ColorPalette.secondary,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w700,
                            fontSize: 14),
                      ),
                    ),
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                          ),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Column(
                              children: [
                                const SizedBox(height: 5),
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '',
                                    style: TextStyle(
                                      fontSize: 8.0,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                                Text(
                                  user.fullname.toString(), // Updated access
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black,
                                      fontFamily: 'Lato'),
                                ),
                                const SizedBox(
                                  height: 2,
                                ),
                                const Text(
                                  'Student',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                      fontFamily: 'Lato'),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "Student ID",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                      fontFamily: 'Lato'),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  height: 35,
                                  width: 155,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.200),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      user.userId.toString(), // Updated access
                                      style: const TextStyle(
                                          fontSize: 15, fontFamily: 'Lato'),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text(
                                  "Gender",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                      fontFamily: 'Lato'),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  height: 35,
                                  width: 155,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.200),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      user.gender.toString(), // Updated access
                                      style: const TextStyle(
                                          fontSize: 15, fontFamily: 'Lato'),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text(
                                  "Age",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                      fontFamily: 'Lato'),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  height: 35,
                                  width: 155,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.200),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      user.age.toString(), // Updated access
                                      style: const TextStyle(
                                          fontSize: 15, fontFamily: 'Lato'),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Text(
                                  "E-mail Address",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                      fontFamily: 'Lato'),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  height: 40,
                                  width: 220,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.200),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      user.email.toString(), // Updated access
                                      style: const TextStyle(
                                          fontSize: 15, fontFamily: 'Lato'),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text(
                                  "Department",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                      fontFamily: 'Lato'),
                                ),
                                const SizedBox(
                                  height: 2,
                                ),
                                Container(
                                  height: 45,
                                  width: 250,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.200),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      user.department
                                          .toString(), // Updated access
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 15, fontFamily: 'Lato'),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                              ],
                            )))
                  ]);
                }),
          ),
        ));
  }

  // Refactored getUser function: Returns a single Future<User>
  Future<User> getUser() async {
    DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref().child("Students/$fullname");
    try {
      DataSnapshot snapshot = await databaseReference.get();
      if (snapshot.exists && snapshot.value != null) {
        Map<String, dynamic> myObj = jsonDecode(jsonEncode(snapshot.value));
        User myUserObj = User.fromJson(myObj);
        return myUserObj;
      } else {
        throw Exception("Student data not found for $fullname.");
      }
    } catch (error) {
      rethrow;
    }
  }

  void toast(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        text,
        textAlign: TextAlign.center,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
      width: 200,
      backgroundColor: Colors.grey,
      duration: const Duration(milliseconds: 1000),
    ));
  }
}
