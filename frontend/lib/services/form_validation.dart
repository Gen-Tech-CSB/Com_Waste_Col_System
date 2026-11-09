import 'dart:convert';

/// Format checks only; mailbox ownership requires email verification.
String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Enter your email address.';
  if (email.length > 150 || email.contains(RegExp(r'\s'))) {
    return 'Enter a valid email address.';
  }
  final parts = email.split('@');
  if (parts.length != 2) return 'Enter a valid email address.';
  final local = parts[0];
  final labels = parts[1].split('.');
  if (local.isEmpty ||
      local.length > 64 ||
      local.startsWith('.') ||
      local.endsWith('.') ||
      local.contains('..') ||
      !RegExp(r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+$").hasMatch(local) ||
      labels.length < 2 ||
      labels.any(
        (label) =>
            label.isEmpty ||
            label.length > 63 ||
            !RegExp(r'^[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?$')
                .hasMatch(label),
      ) ||
      !RegExp(r'^[A-Za-z]{2,}$').hasMatch(labels.last)) {
    return 'Enter a valid email address.';
  }
  return null;
}

String? validateNewPassword(String? value) {
  if ((value?.length ?? 0) < 8) return 'Use at least 8 characters.';
  if (utf8.encode(value!).length > 72) {
    return 'Use a password of 72 UTF-8 bytes or fewer.';
  }
  return null;
}
