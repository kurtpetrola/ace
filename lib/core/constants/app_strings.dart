// app_strings.dart

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
}
