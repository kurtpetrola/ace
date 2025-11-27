// lib/models/user.dart

class User {
  // --- Fields for a Secure and Generic User Profile ---
  // The unique identifier for the user (e.g., STU-001 or ADM-001).
  final String userId;
  final String fullname;
  // This field is used for Firebase Auth and MUST be present in the database.
  final String email;
  final String age;
  final String department;
  final String gender;
  // This field determines routing (Admin or Student).
  final String role;

  User({
    required this.userId,
    required this.fullname,
    required this.email,
    required this.age,
    required this.department,
    required this.gender,
    this.role = 'student', // Default is student
  });

  // Factory constructor to build the User object from Firebase Realtime Database JSON.
  factory User.fromJson(Map<String, dynamic> json) {
    // Determine the ID key dynamically, as student data might use 'studentid'
    // and admin data might use 'adminid'. The actual key used in the DB node
    // is usually the safest bet, but we will look for common identifiers.

    // NOTE: In the authentication services, the userId is the KEY (e.g., STU-001)
    // so we must ensure one of the IDs is captured.
    final String retrievedId = json["studentid"] as String? ??
        json["adminid"] as String? ??
        ''; // Fallback

    return User(
      // We use the dynamically retrieved ID
      userId: retrievedId,

      // All fields are safely cast using '?? '' to prevent runtime null exceptions
      fullname: json["fullname"] as String? ?? '',
      email: json["email"] as String? ?? '',
      age: json["age"] as String? ?? '',
      department: json["department"] as String? ?? '',
      gender: json["gender"] as String? ?? '',
      role: json["role"] as String? ?? 'student',
    );
  }

  // Method to convert the User object back into JSON (for saving/updating data)
  Map<String, dynamic> toJson() => {
        // We ensure the saved key matches the role type for simplicity
        if (role == 'admin') 'adminid': userId,
        if (role == 'student') 'studentid': userId,

        "fullname": fullname,
        "email": email,
        "age": age,
        "department": department,
        "gender": gender,
        "role": role,
        // ⚠️ SECURITY NOTE: The 'password' field has been REMOVED from the model
        // because it is handled securely by Firebase Auth.
      };
}
