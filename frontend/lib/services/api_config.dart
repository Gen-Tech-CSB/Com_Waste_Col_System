import 'package:flutter/foundation.dart';

class ApiConfig {
  // Pass the backend origin (without /api) for physical devices or deployment.
  static const String _override = String.fromEnvironment('API_BASE_URL');

  static String get uploadsBase {
    final origin = _override.isNotEmpty
        ? _override
        : (!kIsWeb && defaultTargetPlatform == TargetPlatform.android
              ? 'http://10.0.2.2:3000'
              : 'http://localhost:3000');
    return origin.replaceFirst(RegExp(r'/+$'), '');
  }

  static String get baseUrl => '$uploadsBase/api';
}
