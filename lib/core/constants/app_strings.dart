// lib/core/constants/app_strings.dart

class AceStrings {
  static const List<String> sex = ['Male', 'Female'];

  static final List<String> ages = _generateAges();

  static const String deptPrefix = 'College of ';
  static const List<String> dept = [
    '${deptPrefix}Allied Health Sciences (CAHS)',
    '${deptPrefix}Arts and Sciences (CAS)',
    '${deptPrefix}Criminal Justice Education (CCJE)',
    '${deptPrefix}Education Liberal Arts (CELA)',
    '${deptPrefix}Engineering and Architecture (CEA)',
    '${deptPrefix}Information Technology Education (CITE)',
    '${deptPrefix}Management and Accountancy (CMA)',
  ];

  static List<String> _generateAges() {
    return [for (int i = 18; i <= 70; i++) i.toString()];
  }

  // Auth Labels
  static const String appName = 'Academia Classroom Explorer';
  static const String login = 'LOGIN';
  static const String register = 'REGISTER';
  static const String signUp = 'Sign up';
  static const String or = 'OR';
  static const String dontHaveAccount = "Don't have an account? ";

  // Login Titles
  static const String studentLogin = 'Student Login';
  static const String teacherLogin = 'Teacher Login';
  static const String adminLogin = 'Admin Login';

  // Button Labels
  static const String studentBtn = 'STUDENT';
  static const String teacherBtn = 'TEACHERS';
  static const String adminBtn = 'ADMINISTRATION';

  // Form Labels & Hints
  static const String emailLabel = 'Email Address';
  static const String emailHint = 'Enter your Email';
  static const String passwordLabel = 'Password';
  static const String passwordHint = 'Enter your Password';

  // Registration Specific
  static const String registrationTitle = 'Registration';
  static const String fullNameLabel = 'Full Name';
  static const String fullNameHint = 'Enter your Full Name';
  static const String studentIdLabel = 'Student Number';
  static const String studentIdHint = 'Enter your Student Number';
  static const String passwordStrongHint = 'Enter a strong password';
  static const String genderHint = 'Gender';
  static const String ageHint = 'Age';
  static const String deptHint = 'Department';
}
