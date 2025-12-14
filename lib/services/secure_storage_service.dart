// lib/services/secure_storage_service.dart

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SecureStorageService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _hiveKey = 'hive_encryption_key';

  /// Generates or retrieves the encryption key for Hive boxes.
  static Future<List<int>> getHiveKey() async {
    // 1. Check if key exists
    final String? keyString = await _secureStorage.read(key: _hiveKey);

    if (keyString == null) {
      // 2. Generate a new 32-byte key
      final List<int> newKey = Hive.generateSecureKey();
      // 3. Store it safely as a base64 string
      await _secureStorage.write(
        key: _hiveKey,
        value: base64UrlEncode(newKey),
      );
      return newKey;
    } else {
      // 4. Return existing key
      return base64Url.decode(keyString);
    }
  }

  /// Safe way to open an encrypted box.
  /// If the box is corrupted or has encryption mismatch (e.g. from previous non-encrypted version),
  /// it deletes the box and re-creates it.
  static Future<Box<T>> openEncryptedBox<T>(
      String boxName, List<int> key) async {
    try {
      return await Hive.openBox<T>(
        boxName,
        encryptionCipher: HiveAesCipher(key),
      );
    } catch (e) {
      print('Error opening box $boxName: $e. Deleting and recreating...');
      // If error (likely encryption mismatch), delete box and start fresh
      await Hive.deleteBoxFromDisk(boxName);
      return await Hive.openBox<T>(
        boxName,
        encryptionCipher: HiveAesCipher(key),
      );
    }
  }
}
