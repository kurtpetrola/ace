# 📚 Academia Classroom Explorer

Academia Classroom Explorer is an application designed to help students view, monitor, and manage their grades and educational information in a convenient, orderly, and efficient manner.

## ✨ Features

### 🎓 **Student Module**
- **Dashboard**: Centralized view of all enrolled classes and recent activities.
- **Classroom Interface**:
  - **Stream**: View announcements and class updates.
  - **Classwork**: Access assignments, quizzes, and materials.
  - **People**: View classmates and teachers.
- **Submission System**: Submit text-based answers directly within the app for assigned classwork.
- **Grade Monitoring**: Real-time view of grades (Prelim, Midterm, Final) and calculated averages.
- **Join Classes**: Easy enrollment using unique class codes.

### 👨‍🏫 **Teacher Module**
- **Classroom Management**: Create and manage classes, subject codes, and schedules.
- **Assignment System**: Post assignments, quizzes, and materials for students.
- **Grading Portal**:
  - **View student submissions**.
  - **Assign grades and provide feedback**.
- **Roster Control**: Monitor class enrollment and student details.

### 🛡️ **Admin Module**
- **System Oversight**: Centralized view of all classes and users.
- **User Management**:
  - Distinct role management (Admin, Teacher, Student).
  - Search and filter user database.
  - Approve or remove accounts.
- **Grades Oversight**: Monitor academic performance across different classes.

### ⚡ **Offline Capabilities**
- **Zero-Latency Loading**: Instant access to Classes, Grades, and Profile Stats using Hive caching.
- **Offline Startup**: Bypasses network checks to launch immediately into the dashboard.
- **Background Sync**: Automatically updates cached data when internet connection is restored.

## 💻 Tech Stack

| Component | Technology | Description |
| :--- | :--- | :--- |
| **Framework** | **Flutter** | Cross-platform UI toolkit for building beautiful, natively compiled applications. |
| **Language** | **Dart** | Optimized for fast apps on any platform. |
| **State Management** | **Riverpod** | Robust, compile-safe state management solution for scalable architecture. |
| **Backend** | **Firebase** | Handles Authentication (Email/Password), Cloud Firestore, and Realtime Database. |
| **Local Storage** | **Hive** | **Offline-First**. Primary local database for caching classes, grades, and user sessions. |

## 🏗️ Project Architecture

The project follows a **Hybrid Architecture** that strategically combines **Feature-First** and **Layer-First** organization to ensure both modularity and global consistency.

-   **Feature-First (`lib/features/`)**: Business logic and UI are grouped by domain (e.g., Auth, Dashboards). Each feature is self-contained with its own presentation and logic layers.
-   **Layer-First (`lib/services/`, `lib/models/`, etc.)**: Shared infrastructure, global data models, and cross-cutting utilities are organized by technical layer.

```
lib/
├── features/     # Modular domain logic & UI
│   ├── admin_dashboard/
│   ├── auth/
│   ├── student_dashboard/
│   └── teacher_dashboard/
├── core/         # App-wide constants & theme
├── common/       # Reusable widgets & dialogs
├── services/     # Shared data sources (Firebase, Hive)
├── models/       # Global data models & entities
└── main.dart     # App entry point & initialization
```

## 🔑 Demo Access

The application now uses **Email & Password** for secure login.

**Student Access (Demo):**
- **Email:** `johndoe@ace.com`
- **Password:** `StudentSecure99!`

**Teacher Access (Demo):**
- **Email:** `mrsmith@ace.com`
- **Password:** `TeacherSecure99!`

**Admin Access:**
- Available upon request for security reasons.

## 📥 Installation

You can download the latest **Android APK** file and install the application manually from the **[releases page](https://github.com/kurtpetrola/ace/releases)**.

## 🛠 Future Enhancements

The following features are planned for future updates to further enhance functionality:

- [ ] **File Attachments**: Enable file uploads (PDFs, Images) for student submissions and teacher materials.
- [ ] **Push Notifications**: Real-time alerts for new assignments, graded work, and announcements via Firebase Cloud Messaging.
- [ ] **Integrated Chat**: In-app messaging system for student-teacher communication.
- [ ] **Calendar Integration**: Dynamic schedule view based on enrolled classes and due dates.
- [ ] **Exportable Reports**: Generate PDF/Excel reports of grades for administrators.

## 💡 Note

This project builds upon the foundation of [Academia Classroom Explorer](https://github.com/kurtpetrola/Academia-Classroom-Explorer), representing the **complete implementation** of all core modules, system integration, and final feature delivery.
