import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? status;
  final Map<String, String> fields;
  const ApiException(this.message, {this.status, this.fields = const {}});
  @override
  String toString() => message;
}

/// One in-memory session. Tokens are cleared on sign-out or an expired session.
class ApiClient {
  static final instance = ApiClient();
  final http.Client _client;
  final String? origin;
  final Duration timeout;
  String? token;
  Map<String, dynamic>? user;
  ApiClient({
    http.Client? client,
    this.origin,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client();

  void signOut() {
    token = null;
    user = null;
  }

  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
  }) async {
    if (authenticated && token == null) {
      throw const ApiException('Please sign in to continue.', status: 401);
    }
    try {
      final request = http.Request(
        method,
        Uri.parse('${origin ?? ApiConfig.baseUrl}$path'),
      );
      request.headers['Accept'] = 'application/json';
      if (authenticated) request.headers['Authorization'] = 'Bearer $token';
      if (body != null) {
        request.headers['Content-Type'] = 'application/json';
        request.body = jsonEncode(body);
      }
      final response = await (() async => http.Response.fromStream(
        await _client.send(request),
      ))().timeout(timeout);
      Map<String, dynamic>? payload;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) payload = decoded;
      } on FormatException {
        /* A proxy may return an HTML error page. */
      }
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          payload?['success'] != true) {
        final fields = <String, String>{};
        if (payload?['errors'] is List) {
          for (final issue in payload!['errors']) {
            if (issue is Map &&
                issue['path'] is List &&
                (issue['path'] as List).isNotEmpty &&
                issue['message'] is String) {
              fields[issue['path'].first.toString()] = issue['message'];
            }
          }
        }
        final status = response.statusCode;
        if (status == 401 && authenticated) signOut();
        final message = status >= 500
            ? 'The service is unavailable right now. Please try again shortly.'
            : status == 401
            ? (authenticated
                  ? 'Your session has expired. Please sign in again.'
                  : 'Incorrect email or password.')
            : status == 403
            ? 'Your account does not have permission to do that.'
            : status == 429
            ? 'Too many attempts. Please wait before trying again.'
            : payload?['message'] is String
            ? payload!['message'] as String
            : 'The server returned an unexpected response. Please try again.';
        throw ApiException(message, status: status, fields: fields);
      }
      return payload!;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(
        'The request timed out. Check your connection and try again.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Cannot reach the server. Check your connection and try again.',
      );
    } on FormatException {
      throw const ApiException(
        'The server returned an unexpected response. Please try again.',
      );
    } catch (_) {
      throw const ApiException(
        'Could not complete the request. Please try again.',
      );
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    signOut();
    final result = await request(
      'POST',
      '/auth/login',
      body: {'email': email.trim().toLowerCase(), 'password': password},
    );
    final data = result['data'];
    if (data is! Map ||
        data['token'] is! String ||
        (data['token'] as String).isEmpty ||
        data['user'] is! Map ||
        !['resident', 'admin', 'collector'].contains(data['user']['role'])) {
      throw const ApiException(
        'The server returned an invalid sign-in response.',
      );
    }
    user = Map<String, dynamic>.from(data['user']);
    token = data['token'];
    return user!;
  }
}
