import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:ace/pages/selection_page.dart';
import '../constant/colors.dart';
import '../constant/strings.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _idnumController = TextEditingController();

  bool _obscureText = true;

  String? _sexValue;
  String? _deptValue;
  String? _ageValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorPalette.accentBlack,
      body: Center(
        child: Container(
          height: 700,
          width: 360,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(30),
            ),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 5),
                const Icon(
                  Icons.assignment_ind_rounded,
                  color: ColorPalette.accentBlack,
                  size: 70,
                ),
                const SizedBox(height: 15),
                const Text(
                  'REGISTRATION',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _fnameController,
                  labelText: 'Full Name',
                  hintText: 'Enter your Full Name',
                  icon: Icons.person,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _idnumController,
                  labelText: 'Student Number',
                  hintText: 'Enter your Student Number',
                  icon: Icons.assignment_ind_rounded,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _emailController,
                  labelText: 'Email Address',
                  hintText: 'Enter your Email Address',
                  icon: Icons.email,
                ),
                const SizedBox(height: 10),
                _buildPasswordTextField(),
                const SizedBox(height: 10),
                _buildDropdownField(
                  hint: 'GENDER',
                  value: _sexValue,
                  items: AceStrings.sex,
                  onChanged: (value) => setState(() {
                    _sexValue = value;
                  }),
                ),
                const SizedBox(height: 10),
                _buildDropdownField(
                  hint: 'AGE',
                  value: _ageValue,
                  items: AceStrings.ages,
                  onChanged: (value) => setState(() {
                    _ageValue = value;
                  }),
                ),
                const SizedBox(height: 10),
                _buildDropdownField(
                  hint: 'DEPARTMENT',
                  value: _deptValue,
                  items: AceStrings.dept,
                  onChanged: (value) => setState(() {
                    _deptValue = value;
                  }),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: 300,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _register,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.black,
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "REGISTER",
                        style: TextStyle(
                          color: ColorPalette.secondary,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                    ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          labelStyle: const TextStyle(color: ColorPalette.accentBlack),
          hintStyle:
              const TextStyle(fontSize: 12, color: ColorPalette.accentBlack),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: ColorPalette.accentBlack),
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: ColorPalette.accentBlack),
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          prefixIcon: Icon(icon, color: ColorPalette.accentBlack),
        ),
      ),
    );
  }

  Widget _buildPasswordTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextField(
        controller: _passController,
        obscureText: _obscureText,
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle:
              const TextStyle(fontSize: 16, color: ColorPalette.accentBlack),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: ColorPalette.accentBlack),
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: ColorPalette.accentBlack),
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
          hintText: 'Enter a strong password',
          hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
          prefixIcon: const Icon(Icons.key, color: ColorPalette.accentBlack),
          suffixIcon: IconButton(
            color: ColorPalette.accentBlack,
            icon: _obscureText
                ? const Icon(Icons.visibility_off)
                : const Icon(Icons.visibility),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      width: 300,
      height: 60,
      decoration: const BoxDecoration(
        color: ColorPalette.hintColor,
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      child: DropdownButtonFormField<String>(
        dropdownColor: ColorPalette.hintColor,
        hint: Text(
          hint,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Lato',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        value: value,
        isExpanded: true,
        iconSize: 32,
        icon: const Icon(Icons.arrow_drop_down, color: ColorPalette.secondary),
        items: items.map(_buildMenuItem).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  DropdownMenuItem<String> _buildMenuItem(String item) => DropdownMenuItem(
        value: item,
        child: Text(
          item,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: ColorPalette.secondary,
          ),
        ),
      );

  Future<void> _register() async {
    DatabaseReference dbReference = FirebaseDatabase.instance
        .ref()
        .child("Students/${_idnumController.text}/");
    await dbReference.child("fullname").set(_fnameController.text);
    await dbReference.child("studentid").set(_idnumController.text);
    await dbReference.child("email").set(_emailController.text);
    await dbReference.child("password").set(_passController.text);
    await dbReference.child("gender").set(_sexValue);
    await dbReference.child("age").set(_ageValue);
    await dbReference.child("department").set(_deptValue);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => const SelectionPage()));
  }
}
