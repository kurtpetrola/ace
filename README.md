# 📚 Academia Classroom Explorer

Academia Classroom Explorer is an application designed to help students view, monitor, and manage their grades and educational information in a convenient, orderly, and efficient manner.

## ✨ Features

- **Grade Remark Preview**: Allows students to preview and understand grade remarks for better academic tracking.
- **Account Preview**: A secure tab for viewing personal registration information, accessible only via authorized login.
- **Classroom**: A structured environment managing subjects, schedules, teachers, and distributing tasks online.
- **Cross-Platform**: Seamless installation and smooth operation on both Android and iOS devices.
- **Responsive Design**: UI dynamically adjusts to maintain an optimal user experience across different screen sizes.

## 💻 Tech Stack

| Component             | Technology   | Purpose                                                                                                                                 |
| :-------------------- | :----------- | :-------------------------------------------------------------------------------------------------------------------------------------- |
| **Mobile Framework**  | **Flutter**  | Cross-platform UI development for iOS and Android.                                                                                      |
| **Backend**           | **Firebase** | Provides a robust, scalable backend for Authentication, Cloud Firestore for the main Database, and Cloud Messaging (for notifications). |
| **State Management**  | **Riverpod** | A compile-safe, scalable solution for managing complex application state and separating business logic from the UI.                     |
| **Local Persistence** | **Hive**     | Lightweight, high-performance NoSQL key-value database for local data caching (e.g., initial load data) and offline access.             |

## 🔑 Demo Accounts

Use the following accounts to quickly explore the application's different user roles (Student and Admin) without needing to register:

- **Student Account**
  - **Student ID:** `STU-001`
  - **Password:** `StudentSecure99!`
- **Admin Account**
  - **Admin ID:** `ADM-001`
  - **Password:** `AdminSecure99!`

## 🛠 To Do & Future Enhancements

The following features are prioritized for development:

- **Notification System:** Implement real-time push notifications for new grades and assigned tasks via Firebase Cloud Messaging.
- **User-Specific Scheduling:** Integrate a dynamic calendar view based on the user's registered sections/subjects.
