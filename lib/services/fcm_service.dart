// lib/services/fcm_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class FCMService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  /// Initialize FCM and request permissions
  Future<void> initialize(String userId) async {
    try {
      // Request permission for iOS
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) {
          print('User granted notification permission');
        }

        // Get FCM token
        String? token = await _fcm.getToken();
        if (token != null) {
          await _saveFCMToken(userId, token);
          if (kDebugMode) {
            print('FCM Token: $token');
          }
        }

        // Listen for token refresh
        _fcm.onTokenRefresh.listen((newToken) {
          _saveFCMToken(userId, newToken);
        });

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle background messages
        FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
      } else {
        if (kDebugMode) {
          print('User declined notification permission');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing FCM: $e');
      }
    }
  }

  /// Save FCM token to database
  Future<void> _saveFCMToken(String userId, String token) async {
    try {
      await _db.child('fcmTokens/$userId').set({
        'token': token,
        'platform': defaultTargetPlatform.name,
        'updatedAt': ServerValue.timestamp,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error saving FCM token: $e');
      }
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Foreground message: ${message.notification?.title}');
    }
    // You can show a local notification here or update UI
  }

  /// Handle background messages (when app is opened from notification)
  void _handleBackgroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Background message opened: ${message.notification?.title}');
    }
    // Navigate to appropriate screen based on message data
  }

  /// Get the current FCM token
  Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
      }
      return null;
    }
  }

  /// Delete FCM token (e.g., on logout)
  Future<void> deleteToken(String userId) async {
    try {
      await _fcm.deleteToken();
      await _db.child('fcmTokens/$userId').remove();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting FCM token: $e');
      }
    }
  }
}

/// Top-level function to handle background messages
/// Must be a top-level function, not a class method
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Background message received: ${message.notification?.title}');
  }
}
