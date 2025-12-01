// lib/models/user.dart

class User {
  // --- Fields for a Secure and Generic User Profile ---
  // The unique identifier for the user (e.g., STU-001 or ADM-001).
  final String userId;
  final String fullname;
  // This field is used for Firebase Auth and MUST be present in the database.
  final String email;

  // Storing age as an integer is more appropriate for calculations/sorting.
  final int age;

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
    // Determine the ID key dynamically, falling back to a generic 'uid' if 'studentid'/'adminid' aren't present.
    // NOTE: It is best practice for the DB to consistently use one key, like 'uid'.
    final String retrievedId = json["uid"] as String? ??
        json["studentid"] as String? ??
        json["adminid"] as String? ??
        '';

    // Safely parse the age, defaulting to 0 if null or not parsable as int.
    final int parsedAge = int.tryParse(json["age"]?.toString() ?? '0') ?? 0;

    return User(
      // We use the dynamically retrieved ID
      userId: retrievedId,

      // All fields are safely cast using '?? '' to prevent runtime null exceptions
      fullname: json["fullname"] as String? ?? '',
      email: json["email"] as String? ?? '',
      age: parsedAge,
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
        "age": age
            .toString(), // Store age as a string in the DB if the original model required it, but int is preferred.
        "department": department,
        "gender": gender,
        "role": role,
        // ⚠️ SECURITY NOTE: The 'password' field has been REMOVED from the model
        // because it is handled securely by Firebase Auth.
      };
}
