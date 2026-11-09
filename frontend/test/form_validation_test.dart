import 'package:flutter_test/flutter_test.dart';
import 'package:community_waste_frontend/services/form_validation.dart';

void main() {
  test(
    'email validation permits normal addresses and rejects malformed addresses',
    () {
      for (final email in [
        'resident@example.com',
        ' User.Name+home@sub.example.org ',
      ]) {
        expect(validateEmail(email), isNull, reason: email);
      }
      for (final email in [
        '',
        'name',
        'name@',
        'name@localhost',
        'name@.com',
        'name@-example.com',
        'name@example-.com',
        'a..b@example.com',
        '.name@example.com',
        'name @example.com',
        'name@example.c',
        'name@@example.com',
      ]) {
        expect(validateEmail(email), isNotNull, reason: email);
      }
    },
  );
  test(
    'new passwords require eight characters and respect the bcrypt byte limit',
    () {
      expect(validateNewPassword('1234567'), isNotNull);
      expect(validateNewPassword('12345678'), isNull);
      expect(validateNewPassword('a' * 72), isNull);
      expect(validateNewPassword('a' * 73), isNotNull);
      expect(validateNewPassword('😀' * 19), isNotNull);
    },
  );
}
