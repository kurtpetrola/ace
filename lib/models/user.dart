// user.dart

class User {
  // Use non-nullable fields if you expect them to always be present
  // If a field might truly be missing from Firebase/JSON, use String?
  final String fullname;
  final String password;
  final String studentid;
  final String email;
  final String age;
  final String department;
  final String gender;
  final String role;

  User({
    required this.fullname,
    required this.password,
    required this.studentid,
    required this.email,
    required this.age,
    required this.department,
    required this.gender,
    this.role = 'student',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Cast values safely. Use ?? '' to provide a non-nullable default if missing
    return User(
      fullname: json["fullname"] as String? ?? '',
      password: json["password"] as String? ?? '',
      studentid: json["studentid"] as String? ?? '',
      email: json["email"] as String? ?? '',
      age: json["age"] as String? ?? '',
      department: json["department"] as String? ?? '',
      gender: json["gender"] as String? ?? '',
      role: json["role"] as String? ?? 'student',
    );
  }

  Map<String, dynamic> toJson() => {
        "fullname": fullname,
        "password": password,
        "studentid": studentid,
        "email": email,
        "age": age,
        "department": department,
        "gender": gender,
        "role": role,
      };
}
